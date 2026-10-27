import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

// 上线前只需要改这一行：改成你的真实网址（GitHub Pages 或自己的域名）
// 也可以不改，用环境变量 SITE_URL 覆盖
const SITE = process.env.SITE_URL || 'https://halfway.example.com';

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
