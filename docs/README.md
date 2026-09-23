# SVN SDK for TypeScript

Generated TypeScript clients for Viaplay SVN services.

<!-- BEGIN GENERATED SDK VERSION -->
> SDK version: `v0.1.10`
<!-- END GENERATED SDK VERSION -->

> [!NOTE]
> SDK source is generated. To change API surface or models, update the OpenAPI specs and regenerate with `task generate:all`.

## Prerequisites

- Node.js 24+
- Docker
- [Task](https://taskfile.dev/) (`task --version`)

## Installation

```bash
npm install @nentgroup/svn-sdk-ts
```

## Your first call

This package is distributed as CommonJS.

```javascript
const { SDK } = require("@viaplay/svn-sdk-ts");

const sdk = new SDK({
  default: {
    accessKey: process.env.ACCESS_KEY,
    baseURL: process.env.GATEWAY_URL,
  },
});

const results = await sdk.search.search({ query: { query: "premier league", limit: 10 } });
console.log(results.data.total);
```

## Services

Use the unified `SDK` to access the generated service:

| Service | SDK property | Service docs |
|---|---|---|
| Search | `sdk.search` | [Search Service](services/search.md) |

## Standalone service client

If you only need one service, import it directly:

```javascript
const { API, Client } = require("@viaplay/svn-sdk-ts/service/search");

const search = new API(new Client({
  accessKey: process.env.ACCESS_KEY,
  baseURL: process.env.GATEWAY_URL,
  timeoutMs: 10_000,
  maxRetries: 3,
}));

const results = await search.search({ query: { query: "premier league", limit: 10 } });
console.log(results.data.total);
```

## Error handling

Operations throw typed payloads for known non-2xx responses. Unknown failures (network, timeout, unexpected status) are thrown as regular errors.

```javascript
try {
  await sdk.search.retrieveAnArticleByID({ id: "unknown-id" });
} catch (err) {
  // For known API statuses, generated operations throw the response payload.
  console.error(err);
}
```

## SSE streaming

The current public search SDK does not expose SSE operations.

## Client configuration

Each generated service client accepts this config shape:

| Field | Type | Default |
|---|---|---|
| `baseURL` | `string` | service internal URL (or `process.env.GATEWAY_URL` when set) |
| `accessKey` | `string` | `process.env.ACCESS_KEY` or `""` |
| `pathPrefix` | `string` | service-specific API path prefix |
| `timeoutMs` | `number` | `10000` |
| `maxRetries` | `number` | `3` |

## Development commands

| Command | Description |
|---|---|
| `task generate:all` | Regenerate search TypeScript SDK and unified `sdk.ts` |
| `task generate SERVICE=search PKG=search SPEC=api/search.yml` | Regenerate one service |
| `task generate:sdk` | Regenerate only unified `sdk.ts` |
| `npm run build` | Generate SDK and compile TypeScript into `dist/` |
| `npm run typecheck` | Run TypeScript type-check without emitting files |
| `npm test` | Build and run smoke tests |
