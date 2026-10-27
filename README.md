# 半途 · 个人博客

暗色极客风格的个人博客。静态站，Astro 构建，无数据库、无后台、无插件。

- 写一篇新文章 = 新建一个 `.md` 文件
- 预览 = 双击 `本地预览.cmd`
- 发布 = `构建静态站.cmd` → 把 `dist` 文件夹传给托管商（或用 Git 自动构建）

---

## 一、怎么发一篇新文章（最常用）

1. 打开 `src/content/posts/` 文件夹
2. 新建一个文件，命名成 `2026-11-01-我的标题.md`（用英文或拼音，不要用中文文件名和空格）
3. 把下面的模板复制进去，改内容：

```markdown
---
title: 文章标题
description: 一句话摘要，会出现在搜索结果和分享卡片里（120 字以内）
date: 2026-11-01
tags: [技术笔记, 前端]
slug: my-post
series: 大鱼吃小鱼
draft: false
---

正文从这里开始，正常的 Markdown 语法都支持。

## 二级标题

- 列表
- 列表

> 引用

`行内代码`，代码块：

```gdscript
func hello() -> void:
    print("hi")
```

表格、图片、加粗、链接都支持。
```

4. 保存 → 首页、标签页、归档页、RSS、搜索索引**全部自动更新**
5. 双击 `本地预览.cmd`，浏览器打开 `http://localhost:4321` 看效果

### 字段说明

| 字段 | 必填 | 说明 |
|---|---|---|
| `title` | ✅ | 标题 |
| `description` | ✅ | 摘要，搜索结果和分享卡片显示这句 |
| `date` | ✅ | `YYYY-MM-DD` |
| `tags` | 建议 | 2～4 个，中英文都行 |
| `slug` | 可选 | 网址后缀（英文），不填就用文件名 |
| `series` | 可选 | 系列名，会显示在文章页顶部面包屑 |
| `draft` | 可选 | `true` = 只在本地预览，不发布 |

> 改完样式或配置后如果首页没变化，重新运行一次 `本地预览.cmd` 即可。

---

## 二、本地预览 / 构建

| 想做什么 | 双击 |
|---|---|
| 边写边看（改完自动刷新） | `本地预览.cmd` → 打开 http://localhost:4321 |
| 生成可上线的静态文件 | `构建静态站.cmd` → 输出到 `dist/` |

如果 `cmd` 提示找不到 Node，说明内置运行时的路径变了，装一个 [Node.js](https://nodejs.org) 即可（脚本会自动改用系统的 node）。

---

## 三、部署上线（推荐：一键发布到 GitHub）

### 方式 A：一键脚本（推荐，配置一次，以后发文即上线）

前提：电脑上装了 GitHub CLI（`winget install GitHub.cli`，本机已经装好）。

1. 双击 **`一键发布.cmd`**
2. 第一次运行会让你登录 GitHub：浏览器里粘贴终端给的 8 位代码，点 Authorize
3. 脚本自动完成：建仓库 → 推送代码 → 开启 Pages → 设置站点地址
4. 等 1～2 分钟，你的博客就在 `https://你的用户名.github.io`

**以后每次发完文章**：双击同一个脚本 → 自动提交、推送、重新构建，1 分钟后线上更新。不用碰命令行，也不用再登录。

> 仓库名用脚本默认的 `你的用户名.github.io`（挂在根路径，零配置）。
> 如果你想用别的仓库名（比如 `blog`），博客会变成 `你的用户名.github.io/blog/`，站内链接需要额外配置，告诉我我帮你改。

### 方式 B：手动 GitHub（不想用脚本时）

1. 在 GitHub 新建仓库，**名字必须叫 `你的用户名.github.io`**，选 Public
2. 回到本地项目文件夹，依次执行（地址换成你的）：
   ```
   git init -b main
   git add -A
   git commit -m "初始化博客"
   git remote add origin https://github.com/你的用户名/你的用户名.github.io.git
   git push -u origin main
   ```
3. 仓库 Settings → Pages → Source 选 **GitHub Actions**
4. 仓库 Settings → Variables → Actions → 新建 `SITE_URL`，值为 `https://你的用户名.github.io`
5. 等 Actions 跑完（约 1 分钟），打开网址

### 方式 C：Vercel / Cloudflare Pages 拖拽（完全不用 Git）

1. 双击 `构建静态站.cmd`，生成 `dist` 文件夹
2. 打开 [vercel.com](https://vercel.com) 或 [pages.cloudflare.com](https://pages.cloudflare.com) 注册
3. 新建项目 → 选择「上传 / 拖拽」→ 把整个 `dist` 文件夹拖进去
4. 几十秒后给你一个网址

缺点：以后每次发文都要重新构建 + 重新拖一次。

### 方式 D：绑定自己的域名

1. 在任意域名商买一个（`.com` 约 ¥70～90/年）
2. 在 GitHub 仓库 Settings → Pages → Custom domain 填入域名
3. 到域名商后台加 DNS 记录（按 GitHub 提示，一般 10 分钟生效）
4. 把仓库变量 `SITE_URL` 改成你的正式域名（否则 sitemap / RSS 里还是旧地址）

> 用 Vercel / Cloudflare / GitHub Pages 托管**不需要 ICP 备案**。只有服务器在中国大陆才需要。

---

## 四、改站点信息

| 想改什么 | 改哪里 |
|---|---|
| 博客名字、副标题、邮箱、GitHub | `src/site.config.ts` |
| 正式域名（影响 sitemap、RSS、分享链接） | `astro.config.mjs` 里的 `site` 字段 |
| 配色 / 字号 / 间距 | `src/styles/global.css` 顶部的 `:root` 变量 |
| 首页自我介绍、项目进度 | `src/pages/index.astro` |
| 关于页 | `src/pages/about.astro` |
| 导航栏 | `src/layouts/BaseLayout.astro` 里的 `nav` 数组 |

改配色最快的方式：只改 `:root` 中的 `--accent`（强调色）、`--bg`（背景）、`--panel`（卡片底色）三个变量，整站气质就变了。

---

## 五、目录结构

```
my-blog/
├── src/
│   ├── content/posts/      ← 所有文章（一个 .md 一篇）
│   ├── layouts/            ← 页面骨架（导航、页脚、SEO）
│   ├── pages/              ← 路由：首页/列表/标签/归档/搜索/关于/404
│   ├── styles/global.css   ← 全站样式
│   ├── lib/posts.ts        ← 排序、阅读时长、标签统计等小工具
│   ├── site.config.ts      ← 站点信息
│   └── content.config.ts   ← 文章字段规范
├── public/                 ← 图标、robots.txt 等原样复制的文件
├── 本地预览.cmd
├── 构建静态站.cmd
└── astro.config.mjs
```

## 六、已经内置的功能

- 文章列表 / 详情 / 标签 / 归档 / 搜索 / 关于 / 404
- RSS 订阅（`/rss.xml`）
- sitemap（`/sitemap-index.xml`）与 robots.txt
- 每篇文章自动生成 SEO 标题、描述、canonical、Open Graph 标签
- 站内搜索：构建时生成索引，浏览器端过滤，不依赖服务器
- 代码高亮 + 复制按钮、表格、引用、图片样式
- 阅读进度条、响应式（手机 / 平板 / 桌面）
- 尊重系统「减少动态效果」设置

## 七、常见问题

**Q：改了文章，线上没变？**
A：GitHub Actions 方案需要等 1 分钟左右；拖拽方案需要重新构建 + 重新上传。

**Q：想加评论？**
A：推荐 [Giscus](https://giscus.app)（基于 GitHub Discussions，免费无广告），需要时告诉我，我接进去。

**Q：想加访问统计？**
A：推荐 Umami（自建或 Cloud）或 Vercel Analytics，同样可以后加。

**Q：图片放哪？**
A：放在 `public/` 下，文章里用 `/图片名.png` 引用；或者放 `src/content/posts/` 旁边用相对路径。大图记得先压缩。

**Q：想换回浅色主题？**
A：`global.css` 的 `:root` 变量就是整套配色，换一组值即可，不需要动任何页面结构。
