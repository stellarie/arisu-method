<div align="center">

# ♡ The Arisu Method ♡

**一份只读的日语入门学习路线指南~**

[English](README.md) | 简体中文 | [繁體中文](README.zh-Hant.md)

[stellarie.github.io/arisu-method](https://stellarie.github.io/arisu-method/) (｡•̀ᴗ-)✧

</div>

> 这是个人方法，不是课程。作者按此方法从零学会了日语。

## 这是什么？

本站是写给日语零基础者的指南，共有八个阶段。每个阶段页面重点说明这一步为什么有效，而不只是要做什么。

- **总览页：** 一条由八颗粉色爱心组成的路，每颗对应一个阶段。
- **阶段页：** 每页说明核心想法、为什么有效、学习时的感受、进步的迹象、常见错误、这一步要做什么，以及链接。

你在浏览器中阅读本站。它只用纯 HTML 和 CSS，没有 JavaScript，也没有构建步骤。

## 八个阶段

| # | 阶段 | 要做的事 |
|---|---|---|
| 1 | Kana and Tae Kim | 学会假名。读 Tae Kim 的指南，读到 から 和 けど 为止。 |
| 2 | 吾輩は猫である | 读这部小说。必要时慢慢爬行。 |
| 3 | 週に一度クラスメイトを買う話 | 读这部小说，然后开始输出。 |
| 4 | 四字熟語 | 学会 200 到 300 个四字熟语。 |
| 5 | 般若心経 and 魏志倭人伝 | 在阶段 2 到 7 期间一并阅读这两篇文本。 |
| 6 | Japanese Wikipedia | 大量阅读日语维基百科。 |
| 7 | Really old texts | 读很古老的文本。不要放弃。 |
| 8 | Chinese | 开始学习中文。 |

## 环境要求

- 一个网页浏览器。阅读指南只需要它。
- 运行质量检查：Bash，以及 GNU 版 `grep`、`sed` 和 `diff`。只在 Linux 上测试过。
- 可选：`vnu` 或 `tidy`，用于 HTML 校验。没有它们时，检查会输出 `SKIP html-validate`。

## 使用 (≧∀≦)

### 1. 在线阅读

打开 <https://stellarie.github.io/arisu-method/>。你会看到一条由八颗爱心组成的路。

### 2. 或者获取本地副本

```bash
git clone https://github.com/stellarie/arisu-method.git
```

你会得到一个名为 `arisu-method` 的文件夹。

### 3. 打开总览页

用浏览器打开 `arisu-method/index.html`。所有链接都是相对链接，所以本站可以从 `file://` 运行。

字体来自 Google Fonts。加载失败时，页面会回退到系统字体。

## 质量检查

`./check.sh` 会检查整个站点。每个失败输出一行：`FAIL <check> <file>: <detail>`。

| 检查 | 失败条件 |
|---|---|
| shared | 某个导航或页脚块与 `index.html` 中的块不同。 |
| link | 本地 `href` 或 `src` 指向不存在的文件。 |
| pre | 页面含有 `<pre>`。 |
| script | 页面含有 script 标签、内联事件处理属性或 `javascript:` URL。 |
| svg | `<svg>` 没有 `role="img"` 或没有 `<title>`。 |
| svg-color | 内联 `<svg>` 使用了十六进制颜色。 |
| chain | 上一页和下一页的链接没有组成从阶段 1 到阶段 8 的一条链。 |
| verify | 仍有 `VERIFY` 注释，且你传入了 `--release`。 |
| html-validate | `vnu` 或 `tidy` 报告了错误。 |

检查还会列出 `lang="ja"` 元素内的拉丁字母单词。这份报告仅供参考。

检查通过时会输出 `check: pass`，并以 0 退出。

## 配置

| 设置 | 位置 | 默认值 |
|---|---|---|
| 深色模式 | 浏览器或系统主题 | 跟随系统 |
| 减少动态效果 | 系统设置 | 动画停止 |
| Pages 来源 | 仓库设置 | 分支 `main`，路径 `/` |
| Jekyll | `.nojekyll` | 关闭 |

## 开发 (๑•̀ㅂ•́)و✧

```bash
./check.sh
./check.sh --release
bash tests/run.sh
```

- `./check.sh` 运行质量检查。加上 `--release`，每个 `VERIFY` 注释都会导致失败。
- `bash tests/run.sh` 在 `tests/fixtures/` 下的示例站点上运行检查，共 11 个用例。每行输出 `ok` 或 `FAIL`。

> 已知缺口 (´ ˘ `)：部分时长、示例文本和说法仍是草稿。作者在 HTML 中用 `VERIFY` 注释标出每一处。`./check.sh --release` 会列出它们。

## 许可

保留所有权利 © stellarie。Made with ♡ ( •̀ᴗ•́ )و
