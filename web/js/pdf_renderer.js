/**
 * PDF Renderer Module
 *
 * Provides high-quality PDF page rendering capabilities using PDF.js.
 * Designed specifically for OCR preprocessing and thumbnail generation.
 *
 * Key Features:
 * - Renders PDF pages to PNG images at configurable scale (default 2x for OCR)
 * - Supports single and batch page rendering
 * - Provides page dimension queries
 * - Memory-efficient with proper cleanup
 * - 100% client-side processing (no server uploads)
 *
 * Usage:
 *   const imageDataUrl = await window.pdfRenderer.renderPageToImage(pdfBytes, 0);
 *   const images = await window.pdfRenderer.renderPagesToImages(pdfBytes, [0,1,2]);
 *   const dims = await window.pdfRenderer.getPageDimensions(pdfBytes, 0);
 */

// Import PDF.js from local vendor directory (privacy-first, no CDN)
import * as pdfjsLib from '/js/vendor/pdfjs/pdf.min.mjs';

// Configure PDF.js worker
pdfjsLib.GlobalWorkerOptions.workerSrc = '/js/vendor/pdfjs/pdf.worker.min.mjs';

/**
 * Default rendering configuration optimized for OCR
 */
const DEFAULT_CONFIG = {
  scale: 2.0,              // 2x scale for high-quality OCR text extraction
  format: 'png',           // PNG for lossless quality (vs JPEG compression)
  backgroundColor: '#ffffff', // White background for scanned documents
  quality: 1.0             // Maximum quality (used for JPEG if format changes)
};

/**
 * Load a PDF document from bytes
 * @param {Uint8Array|ArrayBuffer} pdfBytes - PDF file bytes
 * @returns {Promise<PDFDocumentProxy>} Loaded PDF document
 * @public - Exported for reuse across multiple page renders
 */
export async function loadPdfDocument(pdfBytes) {
  console.log('[PDFRenderer] Loading PDF document...');

  try {
    // Convert to Uint8Array if needed
    const data = pdfBytes instanceof Uint8Array ? pdfBytes : new Uint8Array(pdfBytes);

    // Load the PDF document
    const loadingTask = pdfjsLib.getDocument({ data });
    const pdfDoc = await loadingTask.promise;

    console.log(`[PDFRenderer] PDF loaded successfully: ${pdfDoc.numPages} pages`);
    return pdfDoc;
  } catch (error) {
    console.error('[PDFRenderer] Failed to load PDF:', error?.message || error);

    // Provide user-friendly error messages
    if (error.name === 'PasswordException') {
      throw new Error('Cannot render encrypted/password-protected PDFs');
    } else if (error.name === 'InvalidPDFException') {
      throw new Error('Invalid or corrupted PDF file');
    } else {
      throw new Error(`PDF loading failed: ${error.message || 'Unknown error'}`);
    }
  }
}

/**
 * Render a single PDF page to a canvas and convert to image data URL
 * @param {PDFPageProxy} page - PDF.js page object
 * @param {Object} config - Rendering configuration
 * @returns {Promise<string>} Image data URL (PNG format)
 * @private
 */
async function renderPageToCanvas(page, config = DEFAULT_CONFIG) {
  const { scale, format, backgroundColor } = { ...DEFAULT_CONFIG, ...config };

  // Get page viewport at target scale
  const viewport = page.getViewport({ scale });
  const width = Math.floor(viewport.width);
  const height = Math.floor(viewport.height);

  console.log(`[PDFRenderer] Rendering page to ${width}x${height} (scale: ${scale}x)`);

  // Create canvas
  let canvas = null;
  let context = null;

  try {
    canvas = document.createElement('canvas');
    canvas.width = width;
    canvas.height = height;
    context = canvas.getContext('2d', { alpha: false });

    if (!context) {
      throw new Error('Failed to create canvas 2D context');
    }

    // Fill background
    context.fillStyle = backgroundColor;
    context.fillRect(0, 0, width, height);

    // Render PDF page to canvas
    const renderContext = {
      canvasContext: context,
      viewport: viewport,
      background: 'white' // PDF.js internal background setting
    };

    await page.render(renderContext).promise;
    console.log(`[PDFRenderer] Page rendered successfully`);

    // Convert canvas to data URL
    const mimeType = format === 'jpeg' ? 'image/jpeg' : 'image/png';
    const quality = format === 'jpeg' ? config.quality || 0.92 : undefined;
    const dataUrl = canvas.toDataURL(mimeType, quality);

    return dataUrl;

  } catch (error) {
    console.error('[PDFRenderer] Page rendering failed:', error);
    throw new Error(`Failed to render page: ${error.message}`);
  } finally {
    // Clean up canvas memory
    if (canvas) {
      canvas.width = 0;
      canvas.height = 0;
      canvas = null;
    }
    context = null;
  }
}

/**
 * Render a single PDF page to an image data URL
 *
 * @param {Uint8Array|ArrayBuffer} pdfBytes - PDF file bytes
 * @param {number} pageIndex - Zero-based page index (0 = first page)
 * @param {Object} options - Rendering options
 * @param {number} [options.scale=2.0] - Rendering scale factor (2x recommended for OCR)
 * @param {string} [options.format='png'] - Output format ('png' or 'jpeg')
 * @param {string} [options.backgroundColor='#ffffff'] - Background color
 * @returns {Promise<string>} Image data URL (e.g., "data:image/png;base64,...")
 * @throws {Error} If page index is invalid or rendering fails
 *
 * @example
 * const imageUrl = await window.pdfRenderer.renderPageToImage(pdfBytes, 0, { scale: 2.0 });
 * // Use imageUrl with Tesseract.js or display in <img> tag
 */
export async function renderPageToImage(pdfBytes, pageIndex, options = {}) {
  console.log(`[PDFRenderer] renderPageToImage called for page ${pageIndex}`);

  let pdfDoc = null;
  let page = null;

  try {
    // Load PDF document
    pdfDoc = await loadPdfDocument(pdfBytes);

    // Validate page index
    if (pageIndex < 0 || pageIndex >= pdfDoc.numPages) {
      throw new Error(
        `Invalid page index ${pageIndex}. PDF has ${pdfDoc.numPages} pages (valid range: 0-${pdfDoc.numPages - 1})`
      );
    }

    // Get page (PDF.js uses 1-based page numbers internally)
    page = await pdfDoc.getPage(pageIndex + 1);

    // Render page to canvas and get data URL
    const imageDataUrl = await renderPageToCanvas(page, options);

    console.log(`[PDFRenderer] Successfully rendered page ${pageIndex}`);
    return imageDataUrl;

  } catch (error) {
    console.error(`[PDFRenderer] Error rendering page ${pageIndex}:`, error);
    throw error;
  } finally {
    // Clean up resources
    if (page) {
      page.cleanup();
    }
    if (pdfDoc) {
      await pdfDoc.destroy();
    }
  }
}

/**
 * Render a page from an already-loaded PDF document
 * This avoids reloading the PDF for each page, improving performance
 *
 * @param {PDFDocumentProxy} pdfDocument - Already loaded PDF.js document
 * @param {number} pageIndex - Zero-based page index (0 = first page)
 * @param {Object} options - Rendering options
 * @param {number} [options.scale=2.0] - Rendering scale factor
 * @param {string} [options.format='png'] - Output format ('png' or 'jpeg')
 * @param {string} [options.backgroundColor='#ffffff'] - Background color
 * @returns {Promise<string>} Image data URL
 * @throws {Error} If page index is invalid or rendering fails
 *
 * @example
 * const pdfDoc = await window.pdfRenderer.loadPdfDocument(pdfBytes);
 * for (let i = 0; i < pdfDoc.numPages; i++) {
 *   const imageUrl = await window.pdfRenderer.renderPageFromDocument(pdfDoc, i);
 *   // Process imageUrl
 * }
 * await pdfDoc.destroy(); // Clean up when done
 */
export async function renderPageFromDocument(pdfDocument, pageIndex, options = {}) {
  console.log(`[PDFRenderer] renderPageFromDocument called for page ${pageIndex}`);

  let page = null;

  try {
    // Validate page index
    if (pageIndex < 0 || pageIndex >= pdfDocument.numPages) {
      throw new Error(
        `Invalid page index ${pageIndex}. PDF has ${pdfDocument.numPages} pages (valid range: 0-${pdfDocument.numPages - 1})`
      );
    }

    // Get page (PDF.js uses 1-based page numbers internally)
    page = await pdfDocument.getPage(pageIndex + 1);

    // Render page to canvas and get data URL
    const imageDataUrl = await renderPageToCanvas(page, options);

    console.log(`[PDFRenderer] Successfully rendered page ${pageIndex} from document`);
    return imageDataUrl;

  } catch (error) {
    console.error(`[PDFRenderer] Error rendering page ${pageIndex} from document:`, error);
    throw error;
  } finally {
    // Clean up page resources (but NOT the document - caller owns it)
    if (page) {
      page.cleanup();
    }
  }
}

/**
 * Render multiple PDF pages to image data URLs
 *
 * @param {Uint8Array|ArrayBuffer} pdfBytes - PDF file bytes
 * @param {number[]} pageIndices - Array of zero-based page indices to render
 * @param {Object} options - Rendering options
 * @param {number} [options.scale=2.0] - Rendering scale factor
 * @param {string} [options.format='png'] - Output format ('png' or 'jpeg')
 * @param {string} [options.backgroundColor='#ffffff'] - Background color
 * @param {Function} [progressCallback] - Optional callback(pageIndex, total, imageUrl)
 * @returns {Promise<string[]>} Array of image data URLs in same order as pageIndices
 * @throws {Error} If any page index is invalid or rendering fails
 *
 * @example
 * const images = await window.pdfRenderer.renderPagesToImages(
 *   pdfBytes,
 *   [0, 1, 2],
 *   { scale: 2.0 },
 *   (index, total, url) => console.log(`Rendered ${index + 1}/${total}`)
 * );
 */
export async function renderPagesToImages(pdfBytes, pageIndices, options = {}, progressCallback = null) {
  console.log(`[PDFRenderer] renderPagesToImages called for ${pageIndices.length} pages`);

  let pdfDoc = null;
  const imageUrls = [];

  try {
    // Load PDF document once
    pdfDoc = await loadPdfDocument(pdfBytes);

    // Validate all page indices upfront
    for (const pageIndex of pageIndices) {
      if (pageIndex < 0 || pageIndex >= pdfDoc.numPages) {
        throw new Error(
          `Invalid page index ${pageIndex}. PDF has ${pdfDoc.numPages} pages (valid range: 0-${pdfDoc.numPages - 1})`
        );
      }
    }

    // Render each page sequentially
    for (let i = 0; i < pageIndices.length; i++) {
      const pageIndex = pageIndices[i];
      let page = null;

      try {
        // Get page
        page = await pdfDoc.getPage(pageIndex + 1);

        // Render to canvas
        const imageUrl = await renderPageToCanvas(page, options);
        imageUrls.push(imageUrl);

        // Progress callback
        if (progressCallback) {
          progressCallback(i, pageIndices.length, imageUrl);
        }

        console.log(`[PDFRenderer] Rendered page ${pageIndex} (${i + 1}/${pageIndices.length})`);

      } finally {
        // Clean up page after rendering
        if (page) {
          page.cleanup();
        }
      }
    }

    console.log(`[PDFRenderer] Successfully rendered all ${pageIndices.length} pages`);
    return imageUrls;

  } catch (error) {
    console.error('[PDFRenderer] Error rendering pages:', error);
    throw error;
  } finally {
    // Clean up PDF document
    if (pdfDoc) {
      await pdfDoc.destroy();
    }
  }
}

/**
 * Get dimensions of a PDF page without rendering it
 *
 * @param {Uint8Array|ArrayBuffer} pdfBytes - PDF file bytes
 * @param {number} pageIndex - Zero-based page index
 * @param {number} [scale=1.0] - Scale factor for dimension calculation
 * @returns {Promise<{width: number, height: number, rotation: number}>} Page dimensions
 * @throws {Error} If page index is invalid
 *
 * @example
 * const dims = await window.pdfRenderer.getPageDimensions(pdfBytes, 0);
 * console.log(`Page size: ${dims.width}x${dims.height}`);
 */
export async function getPageDimensions(pdfBytes, pageIndex, scale = 1.0) {
  console.log(`[PDFRenderer] getPageDimensions called for page ${pageIndex}`);

  let pdfDoc = null;
  let page = null;

  try {
    // Load PDF document
    pdfDoc = await loadPdfDocument(pdfBytes);

    // Validate page index
    if (pageIndex < 0 || pageIndex >= pdfDoc.numPages) {
      throw new Error(
        `Invalid page index ${pageIndex}. PDF has ${pdfDoc.numPages} pages (valid range: 0-${pdfDoc.numPages - 1})`
      );
    }

    // Get page
    page = await pdfDoc.getPage(pageIndex + 1);

    // Get viewport at specified scale
    const viewport = page.getViewport({ scale });

    const dimensions = {
      width: Math.floor(viewport.width),
      height: Math.floor(viewport.height),
      rotation: viewport.rotation
    };

    console.log(`[PDFRenderer] Page ${pageIndex} dimensions: ${dimensions.width}x${dimensions.height}`);
    return dimensions;

  } catch (error) {
    console.error(`[PDFRenderer] Error getting page dimensions:`, error);
    throw error;
  } finally {
    // Clean up resources
    if (page) {
      page.cleanup();
    }
    if (pdfDoc) {
      await pdfDoc.destroy();
    }
  }
}

/**
 * Get total number of pages in a PDF
 *
 * @param {Uint8Array|ArrayBuffer} pdfBytes - PDF file bytes
 * @returns {Promise<number>} Number of pages in the PDF
 * @throws {Error} If PDF cannot be loaded
 *
 * @example
 * const pageCount = await window.pdfRenderer.getPageCount(pdfBytes);
 */
export async function getPageCount(pdfBytes) {
  console.log('[PDFRenderer] getPageCount called');

  let pdfDoc = null;

  try {
    pdfDoc = await loadPdfDocument(pdfBytes);
    const count = pdfDoc.numPages;
    console.log(`[PDFRenderer] PDF has ${count} pages`);
    return count;
  } catch (error) {
    console.error('[PDFRenderer] Error getting page count:', error);
    throw error;
  } finally {
    if (pdfDoc) {
      await pdfDoc.destroy();
    }
  }
}

// Export functions via window object for cross-module access
console.log('[PDFRenderer] Module loaded, exposing functions via window.pdfRenderer');
window.pdfRenderer = {
  loadPdfDocument,           // Load PDF once, reuse for multiple renders
  renderPageFromDocument,    // Render from already-loaded document (efficient)
  renderPageToImage,         // Render single page (loads PDF each time)
  renderPagesToImages,       // Render multiple pages
  getPageDimensions,         // Get page dimensions
  getPageCount               // Get page count
};

// Also export for ES6 module imports
export default {
  renderPageToImage,
  renderPagesToImages,
  getPageDimensions,
  getPageCount
};
