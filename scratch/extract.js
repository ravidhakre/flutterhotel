const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

// Read docx file buffer
const docxPath = path.join(__dirname, '..', 'Flutter Hotels & Resorts — Website Content.docx');
const buffer = fs.readFileSync(docxPath);

// Unzip document.xml from docx buffer
// DOCX is a zip file. Let's find PK zip entries.
// We can use child_process or a simple zip unpacker.
const { execSync } = require('child_process');

try {
  // Use PowerShell Expand-Archive to a temp dir
  const tempDir = path.join(__dirname, 'temp_docx');
  if (fs.existsSync(tempDir)) {
    fs.rmSync(tempDir, { recursive: true, force: true });
  }
  fs.mkdirSync(tempDir, { recursive: true });

  // Copy docx as zip
  const zipPath = path.join(__dirname, 'temp.zip');
  fs.copyFileSync(docxPath, zipPath);

  execSync(`powershell -Command "Expand-Archive -Path '${zipPath}' -DestinationPath '${tempDir}' -Force"`);

  const xmlPath = path.join(tempDir, 'word', 'document.xml');
  if (fs.existsSync(xmlPath)) {
    const xmlContent = fs.readFileSync(xmlPath, 'utf8');
    // Extract text inside <w:t> tags
    const textMatches = xmlContent.match(/<w:t[^>]*>(.*?)<\/w:t>/g) || [];
    const text = textMatches.map(m => m.replace(/<[^>]+>/g, '')).join(' ');
    
    // Clean paragraph breaks
    const cleanText = xmlContent
      .replace(/<\/w:p>/g, '\n')
      .replace(/<w:t[^>]*>(.*?)<\/w:t>/g, '$1')
      .replace(/<[^>]+>/g, '');

    fs.writeFileSync(path.join(__dirname, 'extracted_clean.txt'), cleanText, 'utf8');
    console.log('Successfully extracted docx content!');
    console.log('--- PREVIEW ---');
    console.log(cleanText.substring(0, 1500));
  }

  // Cleanup
  fs.unlinkSync(zipPath);
  fs.rmSync(tempDir, { recursive: true, force: true });
} catch (err) {
  console.error('Error extracting docx:', err);
}
