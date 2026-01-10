// Node.js preamble for dart2js compiled code
// dart2js uses 'self' which exists in browsers but not Node.js
globalThis.self = globalThis;

// Expose Node.js globals for dart2js interop
globalThis.require = require;
globalThis.process = process;
