import rss from '@astrojs/rss';
import type { APIContext } from 'astro';
import { getPosts, postSlug } from '../lib/posts';
import { site } from '../site.config';

export async function GET(context: APIContext) {
  const posts = await getPosts();

  return rss({
    title: `${site.name} · ${site.tagline}`,
    description: site.description,
    site: context.site ?? 'https://halfway.example.com',
    items: posts.map((p) => ({
      title: p.data.title,
      pubDate: p.data.date,
      description: p.data.description,
      link: `/posts/${postSlug(p)}/`,
      categories: p.data.tags,
    })),
    customData: '<language>zh-cn</language>',
  });
}
