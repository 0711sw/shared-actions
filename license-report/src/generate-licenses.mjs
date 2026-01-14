import fs from 'fs';
import path from 'path';
import { init } from 'license-checker-rseidelsohn';

// Das Projektroot ist das aktuelle Arbeitsverzeichnis (working-directory im Workflow)
const projectRoot = process.cwd();

// Output-Datei in dist/
const outputFile = path.resolve(projectRoot, 'dist/licenses.txt');

// Custom licenses.txt im Projektroot (neben package.json)
const extraLicensesPath = path.resolve(projectRoot, 'licenses.txt');

console.log(`📁 Project root: ${projectRoot}`);
console.log(`📄 Extra licenses path: ${extraLicensesPath}`);
console.log(`📝 Output file: ${outputFile}`);

init(
  {
    start: projectRoot,
    production: true,
    json: true,
    customFormat: {
      licenseText: true,
      publisher: true,
      repository: true,
      email: true,
      licenseFile: true,
    },
  },
  (err, packages) => {
    if (err) {
      console.error('License checker error:', err);
      process.exit(1);
    }

    let output = '';

    // 1) Optional: extra licenses einlesen und oben einfügen
    if (fs.existsSync(extraLicensesPath)) {
      try {
        const extraContent = fs.readFileSync(extraLicensesPath, 'utf8').trimEnd();
        if (extraContent.length > 0) {
          console.log('✅ Found extra licenses.txt, prepending to output.');
          output += extraContent + '\n\n------------------------------------------------------------\n\n';
        }
      } catch (readErr) {
        console.error('⚠️ Error reading extra licenses.txt:', readErr);
        // Kein harter Abbruch – wir machen trotzdem weiter
      }
    } else {
      console.log('ℹ️ No extra licenses.txt found – skipping prepend.');
    }

    // 2) Danach: automatische Lizenzliste aus license-checker
    for (const [pkg, data] of Object.entries(packages)) {
      output += `${pkg}\n`;
      output += `License: ${data.licenses || 'N/A'}\n`;
      if (data.publisher) output += `Publisher: ${data.publisher}\n`;
      if (data.email) output += `Email: ${data.email}\n`;
      if (data.repository) output += `Repository: ${data.repository}\n`;
      if (data.licenseFile) output += `License file: ${data.licenseFile}\n`;

      if (data.licenseText) {
        output += `\n${data.licenseText}\n`;
      }

      output += `\n------------------------------------------------------------\n\n`;
    }

    fs.mkdirSync(path.dirname(outputFile), { recursive: true });
    fs.writeFileSync(outputFile, output, 'utf8');
    console.log(`✅ licenses.txt generated at: ${outputFile}`);
  }
);