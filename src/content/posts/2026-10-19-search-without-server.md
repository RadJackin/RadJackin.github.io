---
title: 不装任何服务，给静态博客做站内搜索
description: 构建时生成一份 JSON 索引，浏览器端过滤。30 行代码，不依赖任何搜索服务，也不增加首屏负担。
date: 2026-10-19
tags: [技术笔记, 前端]
slug: search-without-server
series: 建站
---

**一句话结论**：文章不多的时候（< 500 篇），一份 JSON 索引 + 一次 `includes()` 就够了，不需要 Algolia、不需要 Elasticsearch。

## 为什么不用现成的搜索服务

先说结论：不是不能用，是**不值得**。

- 第三方搜索服务要注册、要配 key、有免费额度限制，还可能在你不知道的时候停服；
- 全量索引库（比如前端全文搜索库）能离线跑，但会引入几百 KB 的依赖，对十几篇文章的博客是过度设计；
- 而个人博客的搜索需求其实很朴素：**输入关键词，找到标题/摘要里含这个词的文章**。

## 第一步：构建时导出索引

Astro 里加一个路由端点，构建时会自动生成一个静态 JSON 文件：

```ts
// src/pages/search.json.ts
import type { APIRoute } from 'astro';
import { getPosts, postSlug } from '../lib/posts';

export const GET: APIRoute = async () => {
  const posts = await getPosts();
  const body = posts.map((p) => ({
    title: p.data.title,
    description: p.data.description,
    slug: postSlug(p),
    tags: p.data.tags,
  }));
  return new Response(JSON.stringify(body), {
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
  });
};
```

产物是 `dist/search.json`，一篇文章约 200 字节。**50 篇文章也就 10 KB。**

## 第二步：浏览器端过滤

```js
let items = [];
fetch('/search.json').then((r) => r.json()).then((d) => (items = d));

function render(q) {
  const hits = items.filter((p) =>
    `${p.title} ${p.description} ${p.tags.join(' ')}`
      .toLowerCase()
      .includes(q.toLowerCase())
  );
  // 渲染到列表里……
}
```

就这些。没有索引构建、没有分词、没有网络请求（除了那一次 10 KB 的 fetch）。

## 三个细节让体验变好

**1. 输入即过滤，不要按回车**
`input` 事件直接过滤，符合所有人对搜索框的直觉。

**2. 空状态要说人话**
"没有匹配的文章 —— 试试更短的关键词"，比一个空白区域好得多。

**3. 转义 HTML**
搜索结果要拼进 `innerHTML`，标题里如果有 `<` 就会被当成标签。最简单的处理：

```js
const esc = (s) =>
  s.replace(/[&<>"]/g, (c) =>
    ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c])
  );
```

## 这个方案的边界

- **没分词**：搜"静态站"能命中"静态站点"，搜"站点 静态"搜不到。中文用户的输入习惯下，大多数时候没影响；
- **只搜标题/摘要/标签**：搜不到正文里的词。要正文搜索，就得把全文塞进 JSON（体积涨 20 倍），或者换 Pagefind 在构建时生成真正的中文可分片索引；
- **50 篇以内随便用**，500 篇以上建议换方案。

## 最后

一个搜索功能，一行后端代码都没有，构建完就是几个静态文件。**能靠静态文件解决的，就别引入服务**——这是今年我做减法最有效的原则。

> 下一篇写：写一篇博客要 4 小时？我把流程拆成了 6 步。
