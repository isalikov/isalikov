// @ts-check
import { defineConfig } from 'astro/config';

// https://astro.build/config
export default defineConfig({
  // TODO: set the production URL once the domain is decided, e.g. site: 'https://example.com'
  output: 'static',
  trailingSlash: 'never',
  build: {
    format: 'file',
  },
});
