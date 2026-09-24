# Viasport SDK for TypeScript

Typed clients for the Viasport Search API, generated from the OpenAPI spec and published for both ESM `import` and CommonJS `require` consumers.

<!-- BEGIN GENERATED SDK VERSION -->
> SDK version: `v0.1.10`
<!-- END GENERATED SDK VERSION -->

## Installation

```bash
npm install @viaplay/viasport-sdk-ts
```

## Quick start

### 1) Configure the SDK with an issued access key

For normal usage, you already have an access key and can instantiate the SDK directly:

```ts
import { SDK } from '@viaplay/viasport-sdk-ts';

const sdk = new SDK({
  default: {
    accessKey: process.env.ACCESS_KEY,
    baseURL: process.env.GATEWAY_URL,
    timeoutMs: 10_000,
    maxRetries: 3,
  },
});

const results = await sdk.search.search({
  query: {
    contentType: 'sports',
    country: 'se',
    tag: 'sport:football',
    limit: 10,
  },
});

console.log(results.data.total);
```

CommonJS is also supported:

```js
const { SDK } = require('@viaplay/viasport-sdk-ts');
```

If you need to create a key first, the generated API exposes `loginWithEmailAndPassword()` and `createAccessKey()` on the search service, but in day-to-day SDK usage you usually just set `ACCESS_KEY` and initialize the client that way.

## Services

| Service | SDK property | Service docs |
|---|---|---|
| Search | `sdk.search` | [Search Service](services/search.md) |

## Client configuration

| Field | Type | Default |
|---|---|---|
| `baseURL` | `string` | service internal URL (or `process.env.GATEWAY_URL` when set) |
| `accessKey` | `string` | `process.env.ACCESS_KEY` or `""` |
| `timeoutMs` | `number` | `10000` |
| `maxRetries` | `number` | `3` |
