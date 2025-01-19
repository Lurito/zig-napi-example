import * as path from 'node:path';
import * as url from 'node:url';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);

// Load the addon
console.log('Node: Loading addon...');
const addon = (() => {
    try {
        // Load the addon.node file compiled by Zig
        const __dirname = path.dirname(url.fileURLToPath(import.meta.url));
        const addonPath = path.join(__dirname, '..', 'zig-out', 'bin', 'addon.node');
        return require(addonPath);
    } catch (err) {
        console.error('Node: Error loading addon:', err);
        process.exit(1);
    }
})();
console.log('Node: Addon loaded successfully!');

// Call the exported `multiply` function
let result;
try {
    result = addon.multiply(61, 89); // Should output 5429
} catch (err) {
    console.error('Node: Failed to call multiply():', err);
    process.exit(1);
}
console.log(`Node: multiply() = ${result}`);

// Check if the result is correct
if (result === 5429) {
    console.log('Node: Calculation is correct!');
} else {
    console.log(`Node: Calculation error! Expected 5429 but got ${result}`);
}
