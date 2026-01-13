/**
 * Tesseract.js OCR processor for PrivatPDF
 * Provides client-side OCR (Optical Character Recognition) using Tesseract.js
 *
 * This module handles text extraction from images and scanned PDFs entirely in the browser.
 */

// 🔒 SECURITY: Using jsDelivr CDN for Tesseract.js with specific version
import Tesseract from 'https://cdn.jsdelivr.net/npm/tesseract.js@5/+esm';

/**
 * Progress callback type
 * @callback ProgressCallback
 * @param {number} currentPage - Current page being processed (1-indexed)
 * @param {number} totalPages - Total number of pages
 * @param {string} status - Status message (e.g., 'recognizing text', 'loading language')
 * @param {number} progress - Progress percentage (0-100)
 */

/**
 * OCR result for a single page
 * @typedef {Object} PageOcrResult
 * @property {number} pageNumber - Page number (1-indexed)
 * @property {string} text - Extracted text
 * @property {number} confidence - Confidence score (0-100)
 */

/**
 * Extract text from a PDF file using OCR
 * @param {Uint8Array} pdfBytes - PDF file bytes
 * @param {string} language - Tesseract language code (e.g., 'deu', 'eng')
 * @param {ProgressCallback} progressCallback - Progress update callback (optional)
 * @returns {Promise<Object>} - OCR result with text per page and metadata
 */
async function extractTextFromPDF(pdfBytes, language, progressCallback) {
  const startTime = Date.now();

  try {
    console.log(`[OCRProcessor] Starting OCR with language: ${language}`);
    console.log(`[OCRProcessor] PDF size: ${pdfBytes.length} bytes`);

    // Load PDF document once and reuse it for all page renders
    // This avoids the issue where second PDF load fails
    if (!window.pdfRenderer || !window.pdfRenderer.loadPdfDocument) {
      throw new Error('PDF renderer module not loaded');
    }

    const pdfDocument = await window.pdfRenderer.loadPdfDocument(pdfBytes);
    const totalPages = pdfDocument.numPages;
    console.log(`[OCRProcessor] PDF loaded successfully: ${totalPages} pages`);

    if (totalPages === 0) {
      throw new Error('PDF has no pages');
    }

    // Initialize Tesseract worker
    console.log(`[OCRProcessor] Creating Tesseract worker...`);
    const worker = await Tesseract.createWorker(language, 1, {
      logger: (m) => {
        // Log Tesseract progress
        console.log(`[Tesseract] ${m.status}: ${m.progress ? (m.progress * 100).toFixed(0) + '%' : ''}`);

        // Forward to Dart callback if provided
        if (progressCallback && m.status) {
          // Don't send every single update, only meaningful ones
          if (m.status === 'recognizing text' || m.status === 'loading language' || m.status === 'initializing api') {
            progressCallback(0, totalPages, m.status, m.progress ? m.progress * 100 : 0);
          }
        }
      }
    });

    console.log(`[OCRProcessor] Tesseract worker ready`);

    // Results storage
    const textByPage = {};
    const confidenceByPage = {};

    // Process each page
    for (let pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      const pageNumber = pageIndex + 1;
      console.log(`[OCRProcessor] Processing page ${pageNumber}/${totalPages}...`);

      // Notify progress
      if (progressCallback) {
        progressCallback(pageNumber, totalPages, 'processing', (pageIndex / totalPages) * 100);
      }

      try {
        // Render PDF page to image using the already-loaded PDF document
        const imageDataUrl = await renderPdfPageFromDocument(pdfDocument, pageIndex);

        // Perform OCR on the rendered page image
        const { data: { text, confidence } } = await worker.recognize(imageDataUrl);

        console.log(`[OCRProcessor] Page ${pageNumber} OCR complete. Confidence: ${confidence.toFixed(2)}%`);
        console.log(`[OCRProcessor] Extracted text length: ${text.length} characters`);

        textByPage[pageNumber] = text.trim();
        confidenceByPage[pageNumber] = confidence / 100; // Convert to 0-1 range

      } catch (pageError) {
        console.error(`[OCRProcessor] Error processing page ${pageNumber}:`, pageError);
        // Store empty text and zero confidence for failed pages
        textByPage[pageNumber] = '';
        confidenceByPage[pageNumber] = 0;
      }
    }

    // Cleanup
    await worker.terminate();
    console.log(`[OCRProcessor] Tesseract worker terminated`);

    // Clean up PDF document
    if (pdfDocument) {
      await pdfDocument.destroy();
      console.log(`[OCRProcessor] PDF document destroyed`);
    }

    const processingTimeMs = Date.now() - startTime;
    console.log(`[OCRProcessor] OCR complete in ${processingTimeMs}ms`);

    // Final progress callback
    if (progressCallback) {
      progressCallback(totalPages, totalPages, 'complete', 100);
    }

    return {
      textByPage,
      confidenceByPage,
      totalPages,
      processingTimeMs,
      language
    };

  } catch (error) {
    console.error('[OCRProcessor] OCR error:', error);
    throw new Error(`OCR failed: ${error.message}`);
  }
}

/**
 * Render a PDF page to an image using an already-loaded PDF document
 * @param {PDFDocumentProxy} pdfDocument - Loaded PDF.js document
 * @param {number} pageIndex - Page index (0-indexed)
 * @returns {Promise<string>} - Image data URL (PNG format at 2x scale)
 */
async function renderPdfPageFromDocument(pdfDocument, pageIndex) {
  // Check if PDF renderer is available
  if (!window.pdfRenderer || !window.pdfRenderer.renderPageFromDocument) {
    throw new Error('PDF renderer module not loaded. Ensure pdf_renderer.js is included before ocr_processor.js');
  }

  try {
    console.log(`[OCRProcessor] Rendering page ${pageIndex} to image...`);

    // Use PDF.js renderer with 2x scale for high-quality OCR
    const imageDataUrl = await window.pdfRenderer.renderPageFromDocument(pdfDocument, pageIndex, {
      scale: 2.0,
      format: 'png',
      backgroundColor: '#ffffff'
    });

    console.log(`[OCRProcessor] Page ${pageIndex} rendered successfully`);
    return imageDataUrl;

  } catch (error) {
    console.error(`[OCRProcessor] Failed to render page ${pageIndex}:`, error);
    throw new Error(`Failed to render PDF page: ${error.message}`);
  }
}

/**
 * Extract text from a single image
 * @param {Uint8Array|string} imageData - Image bytes or data URL
 * @param {string} language - Tesseract language code
 * @param {ProgressCallback} progressCallback - Progress update callback
 * @returns {Promise<Object>} - OCR result
 */
async function extractTextFromImage(imageData, language, progressCallback) {
  const startTime = Date.now();

  try {
    console.log(`[OCRProcessor] Starting image OCR with language: ${language}`);

    // Initialize Tesseract worker
    const worker = await Tesseract.createWorker(language, 1, {
      logger: (m) => {
        console.log(`[Tesseract] ${m.status}: ${m.progress ? (m.progress * 100).toFixed(0) + '%' : ''}`);
        if (progressCallback && m.status) {
          progressCallback(1, 1, m.status, m.progress ? m.progress * 100 : 0);
        }
      }
    });

    // Perform OCR
    const { data: { text, confidence } } = await worker.recognize(imageData);

    // Cleanup
    await worker.terminate();

    const processingTimeMs = Date.now() - startTime;
    console.log(`[OCRProcessor] Image OCR complete in ${processingTimeMs}ms`);
    console.log(`[OCRProcessor] Confidence: ${confidence.toFixed(2)}%`);

    return {
      textByPage: { 1: text.trim() },
      confidenceByPage: { 1: confidence / 100 },
      totalPages: 1,
      processingTimeMs,
      language
    };

  } catch (error) {
    console.error('[OCRProcessor] Image OCR error:', error);
    throw new Error(`Image OCR failed: ${error.message}`);
  }
}

// Export functions to global window object for Dart interop
window.ocrProcessor = {
  extractTextFromPDF,
  extractTextFromImage
};

console.log('[OCRProcessor] OCR processor module loaded');
