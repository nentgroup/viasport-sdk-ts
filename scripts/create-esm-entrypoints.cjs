const { mkdirSync, writeFileSync } = require('node:fs');
const { join } = require('node:path');

const esmDirectory = join('dist', 'esm');

mkdirSync(join(esmDirectory, 'service', 'search'), { recursive: true });

writeFileSync(
  join(esmDirectory, 'index.mjs'),
  `import cjs from '../index.js';

export const { SDK, Search } = cjs;
export default cjs;
`,
);

writeFileSync(
  join(esmDirectory, 'sdk.mjs'),
  `import cjs from '../sdk.js';

export const { SDK } = cjs;
export default cjs;
`,
);

writeFileSync(
  join(esmDirectory, 'service', 'search', 'index.mjs'),
  `export * from '../../../service/search/index.js';
import cjs from '../../../service/search/index.js';

export default cjs;
`,
);
