const test = require('node:test');
const assert = require('node:assert/strict');
const { SDK } = require('../dist/index.js');
test('unified SDK exposes expected services', () => {
  const sdk = new SDK();
  assert.equal(typeof sdk.search, 'object');
});
