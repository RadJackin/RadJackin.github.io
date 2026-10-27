import type { APIRoute } from 'astro';
import { getPosts, postSlug, isoDate } from '../lib/posts';

/** 构建时生成 /search.json，供搜索页在浏览器端过滤 */
export const GET: APIRoute = async () => {
  const posts = await getPosts();
  const body = posts.map((p) => ({
    title: p.data.title,
    description: p.data.description,
    slug: postSlug(p),
    date: isoDate(p.data.date),
    tags: p.data.tags,
  }));

  return new Response(JSON.stringify(body), {
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
  });
};
