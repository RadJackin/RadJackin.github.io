import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

/**
 * 文章字段规范 —— 写新文章时只要填这几项
 * ─────────────────────────────────────
 * title       标题（必填）
 * description 一句话摘要（必填，会出现在搜索结果和分享卡片）
 * date        日期 YYYY-MM-DD（必填）
 * tags        标签，2～4 个（建议）
 * slug        自定义网址后缀（可选，默认用文件名）
 * series      系列名（可选，同名文章会显示在系列里）
 * draft       true = 只在本地可见，不上线
 */
const posts = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/posts' }),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    date: z.coerce.date(),
    tags: z.array(z.string()).default([]),
    slug: z.string().optional(),
    series: z.string().optional(),
    draft: z.boolean().default(false),
  }),
});

export const collections = { posts };
