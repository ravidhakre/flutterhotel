const fs = require('fs');
const path = require('path');

const srcDir = path.join(__dirname, '..', 'images');
const destDir = path.join(__dirname, '..', 'public', 'images');

if (!fs.existsSync(destDir)) {
  fs.mkdirSync(destDir, { recursive: true });
}

// Copy logo
const logoSrc = path.join(srcDir, 'Flutter_Logo_(1).avif');
if (fs.existsSync(logoSrc)) {
  fs.copyFileSync(logoSrc, path.join(destDir, 'logo.avif'));
  console.log('Logo copied to public/images/logo.avif');
}

// Map files to clean names
const files = fs.readdirSync(srcDir);
files.forEach((file, idx) => {
  const src = path.join(srcDir, file);
  if (file.toLowerCase().endsWith('.jpg') || file.toLowerCase().endsWith('.jpeg') || file.toLowerCase().endsWith('.avif')) {
    const ext = path.extname(file);
    let destName = `hotel-img-${idx + 1}${ext}`;
    if (file.includes('Logo')) {
      destName = 'logo.avif';
    }
    fs.copyFileSync(src, path.join(destDir, destName));
    console.log(`Copied ${file} -> ${destName}`);
  }
});
