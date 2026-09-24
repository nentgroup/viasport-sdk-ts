<img src="../.github/assets/viaplay_logo.svg" align="right" height="96" width="96" alt="Viasport SDK logo" />

<br />

# Viasport SDK for TypeScript

Typed clients for the Viasport Search API, generated from the OpenAPI spec and published as a CommonJS package.

<!-- BEGIN GENERATED SDK VERSION -->
> SDK version: `v0.1.10`
<!-- END GENERATED SDK VERSION -->

## <picture><source media="(prefers-color-scheme: dark)" srcset="../.github/assets/icons/icon-install-dark.svg"><img src="../.github/assets/icons/icon-install.svg" alt="Installation" width="18" height="18" aria-label="Installation"></picture> Installation

```bash
npm install @viaplay/svn-sdk-ts
```

## <picture><source media="(prefers-color-scheme: dark)" srcset="../.github/assets/icons/icon-quickstart-dark.svg"><img src="../.github/assets/icons/icon-quickstart.svg" alt="Quick start" width="18" height="18" aria-label="Quick start"></picture> Quick start

### 1) Configure the SDK with an issued access key

For normal usage, you already have an access key and can instantiate the SDK directly:

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

If you need to create a key first, the generated API exposes `loginWithEmailAndPassword()` and `createAccessKey()` on the search service, but in day-to-day SDK usage you usually just set `ACCESS_KEY` and initialize the client that way.

## <picture><source media="(prefers-color-scheme: dark)" srcset="../.github/assets/icons/icon-services-dark.svg"><img src="../.github/assets/icons/icon-services.svg" alt="Services" width="18" height="18" aria-label="Services"></picture> Services

| Service | SDK property | Service docs |
|---|---|---|
| Search | `sdk.search` | [Search Service](services/search.md) |

## <picture><source media="(prefers-color-scheme: dark)" srcset="../.github/assets/icons/icon-env-dark.svg"><img src="../.github/assets/icons/icon-env.svg" alt="Environment variables" width="18" height="18" aria-label="Environment variables"></picture> Client configuration

| Field | Type | Default |
|---|---|---|
| `baseURL` | `string` | service internal URL (or `process.env.GATEWAY_URL` when set) |
| `accessKey` | `string` | `process.env.ACCESS_KEY` or `""` |
| `timeoutMs` | `number` | `10000` |
| `maxRetries` | `number` | `3` |

## <picture><source media="(prefers-color-scheme: dark)" srcset="../.github/assets/icons/icon-docs-dark.svg"><img src="../.github/assets/icons/icon-docs.svg" alt="Generated files" width="18" height="18" aria-label="Generated files"></picture> Generated files

> [!NOTE]
> SDK source is generated. To change API surface or models, update the OpenAPI specs and regenerate with `task generate:all`.

## <picture><source media="(prefers-color-scheme: dark)" srcset="../.github/assets/icons/icon-sync-dark.svg"><img src="../.github/assets/icons/icon-sync.svg" alt="Regeneration" width="18" height="18" aria-label="Regeneration"></picture> Development commands

| Command | Description |
|---|---|
| `task generate:all` | Regenerate search TypeScript SDK and unified `sdk.ts` |
| `task generate SERVICE=search PKG=search SPEC=api/search.yml` | Regenerate one service |
| `task generate:sdk` | Regenerate only unified `sdk.ts` |
| `npm run build` | Generate SDK and compile TypeScript into `dist/` |
| `npm run typecheck` | Run TypeScript type-check without emitting files |
| `npm test` | Build and run smoke tests |
