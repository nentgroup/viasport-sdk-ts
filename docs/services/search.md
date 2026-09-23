<!-- BEGIN AUTO-GENERATED -->
# Viasport Search API Reference

> **Version:** `v2.3.3` &nbsp;·&nbsp; **Package:** `search` &nbsp;·&nbsp; [Interactive API Reference](../api-reference.html#search)

Provides endpoints for discovering content in the Viaplay's sport-clips catalogue.

### HTTP status codes

| Code               | Summary                                                                        |
|--------------------|--------------------------------------------------------------------------------|
| 200                | OK - Everything worked as expected.                                            |
| 400                | Bad Request - The request was unacceptable, often due to a malformed body.     |
| 401                | Unauthorized - The resource requires an authenticated request.                 |
| 403                | Forbidden - The user does not have enough permissions to access this resource. |
| 404                | Not Found - The resource could not be found.                                   |
| 422                | Unprocessable Entity - Indicates a validation error.                           |
| 500, 502, 503, 504 | Server Errors - Something went wrong on the server's end. (These are rare.)    |

#### Error codes

| Error Code                 | Description                                      |
|----------------------------|--------------------------------------------------|
| `authentication_required`  | The request is missing the authorization header  |
| `invalid_request`          | Most probably the request body is malformed      |
| `resource_not_found`       | The requested resource does not exist.           |
| `validation_failed`        | One or more fields failed validation.            |
| `insufficient_permissions` | The user does not have the required permissions. |

### Migration Guide

This guide covers the breaking changes introduced in the new API and how to update your integration accordingly.

---

#### Date format: milliseconds → RFC 3339

All timestamp fields have been moved from Unix milliseconds to [RFC 3339](https://datatracker.ietf.org/doc/html/rfc3339) strings.

| Legacy field                     | New field        | Example (new)                      |
|----------------------------------|------------------|------------------------------------|
| `data.createdTimestamp`          | `data.createdAt` | `"2026-05-11T18:06:35Z"`           |
| `data.updatedTimestamp`          | `data.updatedAt` | `"2026-05-11T18:06:35Z"`           |
| `data.settings.publishTimestamp` | `data.publishAt` | `"2026-06-01T10:00:00Z"` or `null` |

The `createdFrom`, `createdTo`, `modifiedFrom`, and `modifiedTo` query parameters also accept RFC 3339 strings (or calendar dates in `YYYY-MM-DD` format) instead of millisecond timestamps.

---

#### ISO language code corrections

The legacy API has a known bug using `se` and `dk` as language codes. These have been replaced with the correct ISO 639-1 codes:

| Legacy (incorrect) | New (correct) |
|--------------------|---------------|
| `se`               | `sv`          |
| `dk`               | `da`          |

This affects the `language` field in article responses and the `language` query parameter. Clients that were matching on `se` or `dk` must update to `sv` and `da` respectively.
It also affects the taxonomy translation keys. For example, `data.tags.sports[].se.name` is now `data.tags.sport.sports[].translations.sv`.

---

#### New required parameters: `contentType` and `country`

Two parameters are now **required** on every search request and have no direct legacy equivalent:

| Parameter     | Values                              | Purpose                                      |
|---------------|-------------------------------------|----------------------------------------------|
| `contentType` | `sports`, `entertainment`           | Selects which content catalogue to search    |
| `country`     | `se`, `no`, `fi`, `dk`, `nl`        | Scopes results to a specific market          |

```
# New — both required
GET /search?contentType=sports&country=se&...
```

---

#### Query parameter: `content` → `tag=content:<value>`

The legacy `content` parameter filtered by content format (e.g. `video`, `text`, `pictures`). It has been unified into the repeatable `tag` filter:

```
# Legacy
GET /search?content=video&...

# New
GET /search?tag=content:video&...
```

---

#### Taxonomy filters: dedicated params → `tag` key-value pairs

Sport-specific filters (`sport`, `competition`, `videoCategory`) and the content-format filter (`content`) have been replaced by a repeatable `tag` parameter that accepts `kind:value` pairs. Multiple values for the same kind are OR-ed; different kinds are AND-ed.

| Legacy parameter               | New `tag` equivalent               |
|--------------------------------|------------------------------------|
| `sport=football`               | `tag=sport:football`               |
| `competition=Champions+League` | `tag=competition:champions-league` |
| `videoCategory=highlight`      | `tag=videoType:highlight`          |
| `content=video`                | `tag=content:video`                |

Example:

```
GET /search?contentType=sports&country=se&tag=sport:football&tag=competition:champions-league
```

New filter capabilities not present in the legacy API:

- `tag=team:<id>` — filter by team

- `tag=participant:<id>` — filter by participant

- `author=<email>` — filter by author email (repeatable, OR-ed, case-insensitive)

- `language=<iso-code>` — filter by article language (`sv`, `da`, `fi`, `nl`, `no`)

- `title=<substring>` — filter by title substring

---

#### Pagination: offset → cursor

The `offset` parameter has been removed in favour of opaque cursor-based pagination.

| Legacy        | New                                       |
|---------------|-------------------------------------------|
| `offset=20`   | `cursor=<token from previous response>`   |

To paginate, read `links.next.href` from the response and pass its `cursor` query parameter value unchanged in the following request. Do not construct or modify cursor tokens.

The `limit` parameter remains, with a maximum value of `200`.

---

#### Sort field names

Sortable field names have changed to match the new response schema. The format remains `field[:asc|desc]`, defaulting to `createdAt:desc`.

| Legacy sort value | New sort value  |
|-------------------|-----------------|
| *(implicit)*      | `createdAt`     |
| *(implicit)*      | `updatedAt`     |
| *(implicit)*      | `publishAt`     |
| *(not available)* | `title`         |
| *(not available)* | `slug`          |
| *(not available)* | `contentType`   |
| *(not available)* | `language`      |

---

#### Article response structure

The response shape has been significantly flattened. The `embedded` envelope has been removed; authors and videos are now inlined directly under `data`.

**Top-level field mapping**

| Legacy path                        | New path                    | Notes                                      |
|------------------------------------|-----------------------------|--------------------------------------------|
| `data.settings.language`           | `data.language`             |                                            |
| `data.settings.publishTimestamp`   | `data.publishAt`            | RFC 3339 or `null`                         |
| `data.settings.publishState`       | *(removed)*                 | No equivalent in new API                   |
| `data.settings.autoPlayFirstVideo` | *(removed)*                 | No equivalent in new API                   |
| `data.createdTimestamp`            | `data.createdAt`            | RFC 3339                                   |
| `data.updatedTimestamp`            | `data.updatedAt`            | RFC 3339                                   |
| `data.text.body`                   | `data.text`                 | Unwrapped to a plain string                |
| `data.preamble`                    | `data.preamble`             | Unchanged                                  |
| `data.tags.regions`                | `data.availabilityRegions`  | Moved out of `tags`                        |
| `data.factBoxWidgets`              | *(removed)*                 |                                            |
| `data.socialWidgets`               | *(removed)*                 |                                            |
| `data.sportStatWidgets`            | *(removed)*                 |                                            |
| `embedded.authors[].data`          | `data.authors[]`            | Flattened; `links.picture` removed         |
| `embedded.videos[]`                | `data.videos[]`             | See video structure below                  |
| `embedded.relatedArticles`         | *(removed)*                 |                                            |
| `embedded.polls`                   | *(removed)*                 |                                            |
| `embedded.pictures`                | *(removed)*                 |                                            |
| `links.post`                       | *(removed)*                 |                                            |
| `links.videoEmbed`                 | `data.embedUrl`             | Moved into the data body; see below        |
| `links.related`                    | *(removed)*                 |                                            |

**Tags structure**

Sport-specific tags are now nested under `data.tags.sport`, and taxonomy entities expose a structured `translations` map (keyed by correct ISO language codes) plus an `optaId` field instead of per-language top-level keys with a `slug`.

```
# Legacy
data.tags.sports[].se.name  →  New: data.tags.sport.sports[].translations.sv
data.tags.teams[].dk.name   →  New: data.tags.sport.teams[].translations.da
```

**Video structure**

Videos have moved from `embedded.videos[]` to `data.videos[]`. Each video now exposes orientation variants as named 
keys (`horizontal`, `vertical`). Only the orientations that have an available asset are present.

```
# Legacy
embedded.videos[0].data.mediaGuid            →  data.videos[0].horizontal.mediaGuid
embedded.videos[0].data.posterUrl            →  (removed; use posterUrls instead)
embedded.videos[0].data.posterUrls.small     →  data.videos[0].horizontal.posterUrls.small
```

Each video also carries a top-level `id` (ULID). The `orientation` field is no longer included inside each variant object — the key name already conveys it.

**Embed URL**

The legacy `links.videoEmbed.href` has been replaced by `data.embedUrl`, a pre-built player URL scoped to the requesting partner:

```
# Legacy
links.videoEmbed.href  →  "https://embed.viaplay.com/sport/<articleID>"

# New
data.embedUrl          →  "https://embed.viaplay.com/sport/<articleID>?partnerId=<partnerId>&showtitle=false&postplay=off"
```

The new URL includes partner scoping and sensible player defaults (`showtitle=false`, `postplay=off`) out of the box.

---

#### Before / After examples

**Legacy search request**

```
GET /search?q=Jens+Stage
  &sport=football
  &competition=champions-league
  &videoCategory=highlight
  &content=video
  &limit=20
  &offset=20
  &sort=createdAt
  &createdFrom=1704067200000
  &createdTo=1706745600000
  &exclude=id:863219a3-0a50-4c26-89dc-4834b62be3f1
```

**New search request**

```
GET /search?q=Jens+Stage
  &contentType=sports
  &country=se
  &tag=sport:football
  &tag=competition:champions-league
  &tag=videoType:highlight
  &tag=content:video
  &limit=20
  &cursor=WzE3MDAwMDAwMDAsImFiYy0xMjMiXQ
  &sort=createdAt:desc
  &createdFrom=2024-01-01
  &createdTo=2024-02-01
  &publishedFrom=2024-01-01
  &publishedTo=2024-02-01
  &exclude=id:863219a3-0a50-4c26-89dc-4834b62be3f1
```

Key differences at a glance:

- `contentType=sports` + `country=se` are new required parameters with no legacy equivalent

- `sport`, `competition`, `videoCategory`, `content` → repeatable `tag=kind:value` pairs

- `offset=20` → `cursor=<token>` (opaque, taken from `links.next.href` of the previous response)

- `createdFrom=1704067200000` → `createdFrom=2024-01-01` (RFC 3339 or `YYYY-MM-DD`)

- `sort=createdAt` → `sort=createdAt:desc` (direction now explicit)

- `publishedFrom` / `publishedTo` — new, filter by `publishAt` date range

---

**Legacy article response (abbreviated)**

```json
{
  "data": {
    "settings": { "language": "da", "publishTimestamp": 0 },
    "createdTimestamp": 1778522795000,
    "updatedTimestamp": 1778522795000,
    "text": { "body": "Men lørdag kunne Joakim Mæhle..." },
    "tags": {
      "regions": ["dk", "se", "no"],
      "sports": [{ "id": "football", "se": { "name": "Football" } }]
    }
  },
  "embedded": {
    "authors": [{ "data": { "email": "editor@example.com", "name": "Jane Doe" } }],
    "videos": [{ "data": { "mediaGuid": "4rxTeMBE8rjk9XVG06AqwrCtYYFRwaCy", "posterUrls": { "small": "..." } } }]
  },
  "links": {
    "self": {},
    "videoEmbed": { "href": "https://embed.viaplay.com/sport/82c374c8-5e3c-4ac1-8d20-93695b3375c0" }
  }
}
```

**New article response (abbreviated)**

```json
{
  "data": {
    "language": "da",
    "createdAt": "2026-05-11T18:06:35Z",
    "updatedAt": null,
    "publishedAt": "2026-05-12T18:06:35Z",
    "text": "Men lørdag kunne Joakim Mæhle...",
    "availabilityRegions": ["dk", "se", "no"],
    "embedUrl": "https://embed.viaplay.com/sport/82c374c8-5e3c-4ac1-8d20-93695b3375c0?partnerId=abc123&showtitle=false&postplay=off",
    "tags": {
      "sport": {
        "sports": [{ "id": "football", "translations": { "sv": "Football", "da": "Fodbold" }, "optaId": "34oqloyzlx0btgmhmzc4d8frl" }]
      }
    },
    "authors": [{ "email": "editor@example.com", "name": "Jane Doe" }],
    "videos": [{
      "id": "01KRC3GB2E2CTM8XJB6VWCD4GF",
      "horizontal": { "mediaGuid": "4rxTeMBE8rjk9XVG06AqwrCtYYFRwaCy", "posterUrls": { "small": "..." } },
      "vertical": { "mediaGuid": "9abCDeFGhiJK1LMN23OPqrStUV", "posterUrls": { "small": "..." } }
    }]
  },
  "links": { "self": { "href": "/search/articles/82c374c8-5e3c-4ac1-8d20-93695b3375c0" } }
}
```

---

## Quick Start

**Install**

```bash
npm install @viaplay/search-sdk
```


```javascript
import { SDK } from "../../index";

const sdk = new SDK({
  default: {
	accessKey: process.env.ACCESS_KEY,
  },
});

const api = sdk.search;
```

---

## Operations

---

### CreateAccessKey

`POST` `/identity/auth/access-keys`

You can create access keys to authenticate API requests without using your email and password.
This is useful for integrating with third-party services or automating tasks. Each access key is associated with a user and has the same permissions as that user.

**Generated method**

`createAccessKey` in `operations.ts`

**Example**

```javascript
const result = await api.createAccessKey({
  body: {} as any,
});

// Use the typed response when available.
void result;
```


**Error Responses**

| Status | Type |
|--------|------|
| `400` | `ErrBadRequest` |
| `401` | `ErrUserAuthenticationFailed` |


---

### LoginWithEmailAndPassword

`POST` `/identity/auth/login`

Login with email and password

**Generated method**

`loginWithEmailAndPassword` in `operations.ts`

**Example**

```javascript
const result = await api.loginWithEmailAndPassword({
  body: {} as any,
});

// Use the typed response when available.
void result;
```


**Error Responses**

| Status | Type |
|--------|------|
| `400` | `ErrBadRequest` |
| `401` | `ErrUserAuthenticationFailed` |


---

### Search

`GET` `/search/articles`

Search and list articles. Returns a HAL collection.

Set `limit` to the desired page size and follow `links.next.href` to walk
the rest of the result set. The link carries a `cursor` token that the
service uses to continue exactly where the previous page ended; pass it
through unchanged. The `next` link is omitted on the last page.

Use `?tag=kind:value` (repeatable) to filter by taxonomy. Multiple values
for the same kind are OR-ed; different kinds are AND-ed:

```
?tag=team:real-madrid&tag=team:fc-barcelona     → Real Madrid OR FC Barcelona
?tag=sport:football&tag=team:real-madrid        → football AND Real Madrid
```

**Generated method**

`search` in `operations.ts`

**Example**

```javascript
const result = await api.search({
  query: {
	contentType: "contentType-value",
	country: "country-value",
  },
});

// Use the typed response when available.
void result;
```


**Error Responses**

| Status | Type |
|--------|------|
| `400` | `ErrBadRequest` |
| `401` | `ErrUnAuthorized` |
| `422` | `ErrValidation` |
| `500` | `ErrInternal` |


---

### RetrieveAnArticleByID

`GET` `/search/articles/{id}`

Retrieve an article by id

**Generated method**

`retrieveAnArticleByID` in `operations.ts`

**Example**

```javascript
const result = await api.retrieveAnArticleByID({
  id: "id-value",
});

// Use the typed response when available.
void result;
```


**Error Responses**

| Status | Type |
|--------|------|
| `401` | `ErrUnAuthorized` |
| `404` | `ErrNotFound` |
| `500` | `ErrInternal` |



---

> For request/response schemas and interactive endpoint testing, see the [API Reference](../api-reference.html#search).
<!-- END AUTO-GENERATED -->




## Operations notes and sequencing

The search package mixes identity and content APIs. The auth endpoints are for obtaining a bearer token or a dedicated machine credential before a request that requires authorization, while the article endpoints are for discovery and detail fetching.

- `loginWithEmailAndPassword` is the shortest path to an authenticated user session. Use it for scripts or interactive apps that already have an email and password and need an `AuthenticationResponse` with `accessToken`, `refreshToken`, and `accessTokenExpiryEpochSeconds`.
- `createAccessKey` is better for backend integrations that should not store a user password. It returns a `key`, `token`, and `userId`, which makes it a safer long-lived credential for automation.
- `search` is the main discovery endpoint. Most client code will start here with `contentType`, `country`, `q`, `limit`, and optional `tag` and `sort` values, then follow `links.next.href` to continue through the result set.
- `retrieveAnArticleByID` is the detail endpoint for a single article once you already know the article `id` from a search result or an external link.

These flows are commonly chained in sequence:
1. Sign in with `loginWithEmailAndPassword` or create a dedicated credential with `createAccessKey`.
2. Call `search` to find matching articles and copy the selected `id` from `response.embedded.articles[n].data.id`.
3. Call `retrieveAnArticleByID({ id })` to fetch the full `Article` payload for rendering or validation.

### Factual parameter notes

- `createAccessKey` expects `body.name`; `body.description` is optional.
- `loginWithEmailAndPassword` expects `body.email` and `body.password`.
- `search` accepts a flat query object whose common keys are `contentType`, `country`, `q`, `limit`, `sort`, and `tag`; the response exposes `data.count`, `data.total`, `embedded.articles`, and optional `links.next.href` for pagination.
- `retrieveAnArticleByID` requires an `id` path parameter and returns a single `Article` under `response.data`.

## TypeScript examples

### Create a machine credential

```javascript
import { API, Client } from "@viaplay/svn-sdk-ts/service/search";

const api = new API(
  new Client({
    baseURL: process.env.GATEWAY_URL,
    accessKey: process.env.ACCESS_KEY,
  }),
);

const response = await api.createAccessKey({
  body: {
    name: "search-indexer",
    description: "Used by the crawler to refresh the article index",
  },
});

const createdKey = response.data;
if (!createdKey) {
  throw new Error("createAccessKey returned no payload");
}

console.log(createdKey.key, createdKey.userId);
```

### Log in with email and password

```javascript
import {
  API,
  AuthenticationResponse,
  Client,
} from "@viaplay/svn-sdk-ts/service/search";

const api = new API(
  new Client({
    baseURL: process.env.GATEWAY_URL,
  }),
);

const response = await api.loginWithEmailAndPassword({
  body: {
    email: "editor@example.com",
    password: process.env.SEARCH_PASSWORD ?? "",
  },
});

const auth = response.data;
if (!auth) {
  throw new Error("loginWithEmailAndPassword returned no payload");
}

const token: AuthenticationResponse = auth;
console.log(token.accessTokenExpiryEpochSeconds);
```

### Search with filters and follow the next-page cursor

```javascript
import { API, Article, Client } from "@viaplay/svn-sdk-ts/service/search";

const api = new API(
  new Client({
    baseURL: process.env.GATEWAY_URL,
    accessKey: process.env.ACCESS_KEY,
  }),
);

const response = await api.search({
  query: {
    contentType: "sports",
    country: "se",
    q: "Jens Stage",
    tag: "sport:football",
    sort: "createdAt:desc",
    limit: 20,
  },
});

const articles: Article[] = response.embedded.articles.map(({ data }) => data);
const firstArticle = articles[0];
if (firstArticle) {
  console.log(firstArticle.id, firstArticle.title);
}

if (response.links.next?.href) {
  const nextCursor = new URL(response.links.next.href).searchParams.get("cursor");
  if (nextCursor) {
    console.log("Next page cursor:", nextCursor);
  }
}
```

### Retrieve a single article and inspect nested media

```javascript
import {
  API,
  Article,
  Client,
  VideoVariant,
} from "@viaplay/svn-sdk-ts/service/search";

const api = new API(
  new Client({
    baseURL: process.env.GATEWAY_URL,
    accessKey: process.env.ACCESS_KEY,
  }),
);

const response = await api.retrieveAnArticleByID({
  id: "82c374c8-5e3c-4ac1-8d20-93695b3375c0",
});

const article: Article = response.data;
console.log(article.id, article.title, article.contentType);

const firstVideo = article.videos[0];
if (firstVideo && typeof firstVideo.horizontal === "object" && firstVideo.horizontal !== null) {
  const horizontal = firstVideo.horizontal as VideoVariant;
  console.log(horizontal.mediaGuid);
}
```

### Handle a typed validation error

```javascript
import { API, Client, ErrValidation } from "@viaplay/svn-sdk-ts/service/search";

const api = new API(
  new Client({
    baseURL: process.env.GATEWAY_URL,
    accessKey: process.env.ACCESS_KEY,
  }),
);

try {
  await api.search({
    query: {
      contentType: "sports",
      country: "se",
      q: "",
    },
  });
} catch (err) {
  const e = err as { status?: number; payload?: unknown };
  if (e.status === 422 && e.payload) {
    const validation: ErrValidation = e.payload as ErrValidation;
    console.log(validation.error.errCode);
    console.log(validation.error.message);
    if (validation.error.details) {
      console.log(validation.error.details);
    }
  } else {
    throw err;
  }
}
```

## Data Model

The search package has a small but reusable response model surface centered on `Article`.

- `Article`: shared by both `search` and `retrieveAnArticleByID`; each result includes `id`, `title`, `contentType`, `language`, `authors`, `videos`, `tags`, and optional `pictures` or `embedUrl`.
- `Video`: appears inside `Article.videos` and captures the available `horizontal` and `vertical` asset variants.
- `VideoVariant`: the actual media metadata for each video variant, including `mediaGuid`, `posterUrls`, and optional `duration`/`filename`.
- `Author`: reused whenever an article includes a byline with `name` and `email`.
- `Taxonomy`: represents the article's taxonomy buckets exposed via the `tags` field on `Article`.

The SDK uses a strict response envelope, so read `response.data` and `response.embedded.articles[]` as typed values instead of using ad-hoc `any` conversions.
