# Viasport SDK for TypeScript


> [!NOTE]
> `src/service/`, `src/sdk.ts`, and `src/index.ts` are generated. Edit specs in `api/` and regenerate to make SDK changes.

## Prerequisites

- Node.js 24+
- Docker
- [Task](https://taskfile.dev/) (`task --version`)

## Install

```bash
npm install @viaplay/svn-sdk-ts
```

## Quick start

This package is distributed as CommonJS.

```ts
const { SDK } = require('@viaplay/svn-sdk-ts');

const sdk = new SDK({
  default: {
    accessKey: process.env.ACCESS_KEY,
    baseURL: process.env.GATEWAY_URL,
    timeoutMs: 10_000,
    maxRetries: 3,
  },
});

const results = await sdk.search.search({ query: { query: 'premier league', limit: 10 } });
console.log(results.data.total);
```

## Commands

| Command                                                       | Description                                      |
| ------------------------------------------------------------- | ------------------------------------------------ |
| `task generate:all`                                           | Regenerate search SDK and unified `sdk.ts`       |
| `task generate SERVICE=search PKG=search SPEC=api/search.yml` | Regenerate one service                           |
| `task generate:sdk`                                           | Regenerate only unified `sdk.ts`                 |
| `npm run build`                                               | Generate SDK and compile TypeScript into `dist/` |
| `npm run typecheck`                                           | Run TypeScript type-check without emitting files |
| `npm test`                                                    | Build and run smoke tests                        |
| `npm run ci`                                                  | Clean, install, build, and test pipeline         |

## Services

The unified `SDK` exposes:

- `sdk.search`

You can also import a single service directly:

```ts
const { API, Client } = require('@viaplay/svn-sdk-ts/service/search');
const search = new API(new Client({ accessKey: process.env.ACCESS_KEY }));
```

## Repository layout

- `api/` OpenAPI specs (source of truth)
- `src/service/<name>/` generated per-service TypeScript clients
- `src/sdk.ts` generated unified top-level SDK
- `src/index.ts` generated package entrypoint
- `docs/` generated docs and API reference
- `test/` smoke tests
