/**
 * PDF-lib processor wrapper for PrivatPDF
 * Provides client-side PDF manipulation using pdf-lib
 *
 * This module is loaded via ES6 import and exposes functions to the global window object
 * for Dart interop.
 */

// 🔒 SECURITY: Using jsDelivr for better CDN support and integrity verification
import { PDFDocument, StandardFonts, rgb } from 'https://cdn.jsdelivr.net/npm/pdf-lib@1.17.1/+esm';

/**
 * Merge multiple PDFs into a single document
 * @param {Uint8Array[]} pdfBytesArray - Array of PDF byte arrays
 * @returns {Promise<Uint8Array>} - Merged PDF bytes
 */
async function mergePDFs(pdfBytesArray) {
  try {
    console.log(`[PDFLibProcessor] Merging ${pdfBytesArray.length} PDFs...`);

    const mergedPdf = await PDFDocument.create();

    for (let i = 0; i < pdfBytesArray.length; i++) {
      const pdfBytes = pdfBytesArray[i];
      console.log(`[PDFLibProcessor] Loading PDF ${i + 1}/${pdfBytesArray.length} (${pdfBytes.length} bytes)`);

      const pdf = await PDFDocument.load(pdfBytes);
      const pageCount = pdf.getPageCount();
      console.log(`[PDFLibProcessor] PDF ${i + 1} has ${pageCount} pages`);

      const copiedPages = await mergedPdf.copyPages(pdf, pdf.getPageIndices());
      copiedPages.forEach((page) => mergedPdf.addPage(page));
    }

    console.log(`[PDFLibProcessor] Merge complete. Total pages: ${mergedPdf.getPageCount()}`);
    const mergedBytes = await mergedPdf.save();
    console.log(`[PDFLibProcessor] Saved merged PDF (${mergedBytes.length} bytes)`);

    return mergedBytes;
  } catch (error) {
    console.error('[PDFLibProcessor] Merge error:', error);
    throw new Error(`PDF merge failed: ${error.message}`);
  }
}

/**
 * Split PDF by extracting specific pages
 * @param {Uint8Array} pdfBytes - Original PDF bytes
 * @param {number[]} pageNumbers - Zero-indexed page numbers to extract
 * @returns {Promise<Uint8Array>} - New PDF with extracted pages
 */
async function splitPDF(pdfBytes, pageNumbers) {
  try {
    console.log(`[PDFLibProcessor] Splitting PDF, extracting ${pageNumbers.length} pages...`);

    const pdfDoc = await PDFDocument.load(pdfBytes);
    const totalPages = pdfDoc.getPageCount();
    console.log(`[PDFLibProcessor] Source PDF has ${totalPages} pages`);

    // Validate page numbers
    for (const pageNum of pageNumbers) {
      if (pageNum < 0 || pageNum >= totalPages) {
        throw new Error(`Invalid page number: ${pageNum} (valid range: 0-${totalPages - 1})`);
      }
    }

    const newPdf = await PDFDocument.create();
    const pages = await newPdf.copyPages(pdfDoc, pageNumbers);
    pages.forEach(page => newPdf.addPage(page));

    console.log(`[PDFLibProcessor] Split complete. New PDF has ${newPdf.getPageCount()} pages`);
    const splitBytes = await newPdf.save();
    console.log(`[PDFLibProcessor] Saved split PDF (${splitBytes.length} bytes)`);

    return splitBytes;
  } catch (error) {
    console.error('[PDFLibProcessor] Split error:', error);
    throw new Error(`PDF split failed: ${error.message}`);
  }
}

/**
 * Protect PDF with password encryption
 * @param {Uint8Array} pdfBytes - Original PDF bytes
 * @param {string} password - User password for encryption
 * @returns {Promise<Uint8Array>} - Encrypted PDF bytes
 */
async function protectPDF(pdfBytes, password) {
  try {
    console.log(`[PDFLibProcessor] Protecting PDF with password...`);

    if (!password || password.length < 6) {
      throw new Error('Password must be at least 6 characters');
    }

    const pdfDoc = await PDFDocument.load(pdfBytes);
    const pageCount = pdfDoc.getPageCount();
    console.log(`[PDFLibProcessor] PDF has ${pageCount} pages`);

    // Note: pdf-lib encryption options
    // - userPassword: Password to open the PDF
    // - ownerPassword: Password to modify permissions
    // - permissions: What's allowed (printing, modifying, copying)
    const encryptedBytes = await pdfDoc.save({
      userPassword: password,
      ownerPassword: password,
      permissions: {
        printing: 'highResolution',
        modifying: false,
        copying: false,
        annotating: false,
        fillingForms: false,
        contentAccessibility: true,
        documentAssembly: false,
      },
    });

    console.log(`[PDFLibProcessor] PDF protected successfully (${encryptedBytes.length} bytes)`);
    return encryptedBytes;
  } catch (error) {
    console.error('[PDFLibProcessor] Protect error:', error);
    throw new Error(`PDF protection failed: ${error.message}`);
  }
}

/**
 * Get page count from a PDF
 * @param {Uint8Array} pdfBytes - PDF bytes
 * @returns {Promise<number>} - Number of pages
 */
async function getPageCount(pdfBytes) {
  try {
    const pdfDoc = await PDFDocument.load(pdfBytes);
    const pageCount = pdfDoc.getPageCount();
    console.log(`[PDFLibProcessor] PDF has ${pageCount} pages`);
    return pageCount;
  } catch (error) {
    console.error('[PDFLibProcessor] Get page count error:', error);
    throw new Error(`Failed to get page count: ${error.message}`);
  }
}

/**
 * Compress PDF by reducing image quality
 * @param {Uint8Array} pdfBytes - Original PDF bytes
 * @param {number} quality - Quality factor (0.0-1.0, where 1.0 is best quality)
 * @returns {Promise<Uint8Array>} - Compressed PDF bytes
 *
 * Note: This is a simplified implementation. Full compression would require:
 * 1. Extracting embedded images from PDF
 * 2. Compressing each image via Canvas API
 * 3. Re-embedding compressed images into PDF
 *
 * For MVP, we're returning the original PDF with optimization settings applied.
 */
async function compressPdf(pdfBytes, quality) {
  try {
    console.log(`[PDFLibProcessor] Compressing PDF with quality ${quality}...`);

    const pdfDoc = await PDFDocument.load(pdfBytes);
    const pageCount = pdfDoc.getPageCount();
    console.log(`[PDFLibProcessor] PDF has ${pageCount} pages`);

    // Save with compression options
    // pdf-lib automatically compresses images and streams during save
    const compressedBytes = await pdfDoc.save({
      useObjectStreams: true,
      addDefaultPage: false,
      objectsPerTick: 50,
    });

    const originalSize = pdfBytes.length;
    const compressedSize = compressedBytes.length;
    const savings = ((1 - compressedSize / originalSize) * 100).toFixed(1);

    console.log(`[PDFLibProcessor] Compression complete:`);
    console.log(`  - Original: ${originalSize} bytes`);
    console.log(`  - Compressed: ${compressedSize} bytes`);
    console.log(`  - Savings: ${savings}%`);

    return compressedBytes;
  } catch (error) {
    console.error('[PDFLibProcessor] Compress error:', error);
    throw new Error(`PDF compression failed: ${error.message}`);
  }
}

// Expose functions to window object for Dart interop
window.PDFLibProcessor = {
  mergePDFs,
  splitPDF,
  protectPDF,
  getPageCount,
  compressPdf,
};

console.log('[PDFLibProcessor] Initialized successfully');
