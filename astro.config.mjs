import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

// 正式网址。改了域名只需要改这一行（或设置环境变量 SITE_URL 覆盖）
const SITE = process.env.SITE_URL || 'https://radjackin.github.io';

export default defineConfig({
  site: SITE,
  integrations: [sitemap()],
  markdown: {
    // 代码高亮主题：与暗色极客风格匹配
    shikiConfig: {
      theme: 'vesper',
      wrap: false,
    },
  },
});
