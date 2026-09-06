const fs = require('fs');
const path = require('path');

function checkFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const regex = /["'](\/images\/[^"']+)["']/g;
  let match;
  while ((match = regex.exec(content)) !== null) {
    const p = match[1];
    const fullPath = path.join(__dirname, '../public', p);
    if (!fs.existsSync(fullPath)) {
      console.log('BROKEN IMAGE in ' + filePath + ':', p);
    }
  }
}

const viewsDir = './views';
fs.readdirSync(viewsDir).forEach(f => {
  if (f.endsWith('.ejs')) checkFile(path.join(viewsDir, f));
});

const dataDir = './data';
fs.readdirSync(dataDir).forEach(f => {
  if (f.endsWith('.json')) checkFile(path.join(dataDir, f));
});
