const test = require('node:test');
const assert = require('node:assert/strict');
const { SDK } = require('../dist/index.js');

test('unified SDK exposes expected services', () => {
  const sdk = new SDK();
  assert.equal(typeof sdk.search, 'object');
});

test('ESM entrypoint exports the unified SDK', async () => {
  const { SDK: ESMSDK } = await import('../dist/esm/index.mjs');
  const sdk = new ESMSDK();
  assert.equal(typeof sdk.search, 'object');
});

test('ESM service entrypoint exports generated API symbols', async () => {
  const { API, Client } = await import('../dist/esm/service/search/index.mjs');
  assert.equal(typeof API, 'function');
  assert.equal(typeof Client, 'function');
});
