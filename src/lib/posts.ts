import { getCollection, type CollectionEntry } from 'astro:content';

export type Post = CollectionEntry<'posts'>;

/** 取所有已发布文章，按时间倒序 */
export async function getPosts(): Promise<Post[]> {
  const all = await getCollection('posts', ({ data }) => !data.draft);
  return all.sort((a, b) => b.data.date.valueOf() - a.data.date.valueOf());
}

/** 文章的网址后缀 */
export function postSlug(post: Post): string {
  return post.data.slug ?? post.id;
}

/** 2026-10-24 */
export function isoDate(d: Date): string {
  return new Date(d).toISOString().slice(0, 10);
}

/** 2026.10.24 */
export function cnDate(d: Date): string {
  const dt = new Date(d);
  return `${dt.getFullYear()}.${String(dt.getMonth() + 1).padStart(2, '0')}.${String(dt.getDate()).padStart(2, '0')}`;
}

/** 10.24 */
export function shortDate(d: Date): string {
  const dt = new Date(d);
  return `${String(dt.getMonth() + 1).padStart(2, '0')}.${String(dt.getDate()).padStart(2, '0')}`;
}

/** 估算阅读时长（分钟）：中文 400 字/分钟，英文 220 词/分钟 */
export function readingTime(body: string | undefined): number {
  if (!body) return 1;
  const cjk = (body.match(/[\u4e00-\u9fa5]/g) || []).length;
  const words = (body.match(/[A-Za-z0-9][A-Za-z0-9'-]*/g) || []).length;
  return Math.max(1, Math.round(cjk / 400 + words / 220));
}

/** 统计所有标签及其文章数，按数量倒序 */
export function tagCounts(posts: Post[]): { tag: string; count: number }[] {
  const map = new Map<string, number>();
  for (const p of posts) {
    for (const t of p.data.tags) map.set(t, (map.get(t) ?? 0) + 1);
  }
  return [...map.entries()]
    .map(([tag, count]) => ({ tag, count }))
    .sort((a, b) => b.count - a.count || a.tag.localeCompare(b.tag, 'zh-CN'));
}

/** 按年份分组（归档页用） */
export function groupByYear(posts: Post[]): { year: number; posts: Post[] }[] {
  const map = new Map<number, Post[]>();
  for (const p of posts) {
    const y = new Date(p.data.date).getFullYear();
    if (!map.has(y)) map.set(y, []);
    map.get(y)!.push(p);
  }
  return [...map.entries()]
    .map(([year, list]) => ({ year, posts: list }))
    .sort((a, b) => b.year - a.year);
}

/** 相邻文章（用于详情页的上一篇/下一篇） */
export function neighbours(posts: Post[], current: Post): { prev?: Post; next?: Post } {
  const i = posts.findIndex((p) => p.id === current.id);
  return { prev: posts[i + 1], next: posts[i - 1] };
}
