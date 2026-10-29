<div align="center">

# ♡ Arisu's Guide to Japanese ♡

**A read-only beginner guide to one Japanese learning roadmap~**

English | [简体中文](README.zh-Hans.md) | [繁體中文](README.zh-Hant.md)

[stellarie.github.io/arisu-method](https://stellarie.github.io/arisu-method/) (｡•̀ᴗ-)✧

</div>

> A personal method, not a course. The author learned Japanese from zero with it.

## What is this?

This site is a guide for complete beginners in Japanese. It has eight stages. Each stage page explains why the stage works, more than what to do.

- **Overview page:** a road of eight pink hearts, one for each stage.
- **Stage pages:** each page explains the idea, why it works, what it feels like, signs of progress, common mistakes, the step, when to move on, and links and tools.
- **Tools page:** every dictionary, popup reader, flashcard app, free text, and place to talk, sorted by what it does.
- **FAQ page:** the questions beginners ask, answered once.

You read the site in a browser. It uses plain HTML and CSS, with no JavaScript and no build step.

## The eight stages

| # | Stage | You do |
|---|---|---|
| 1 | Baby steps (Kana and Tae Kim) | Learn kana. Read Tae Kim's guide up to から and けど. |
| 2 | Dive deep, dive hard (吾輩は猫である) | Read the novel. Crawl if you must. |
| 3 | Modern input and output (週に一度クラスメイトを買う話) | Read the novel. Then start output. |
| 4 | Compressing your thoughts in four characters (四字熟語) | Learn 200 to 300 four-character idioms. |
| 5 | A primer on old text (般若心経 and 魏志倭人伝) | Read both texts alongside stages 2 to 7. |
| 6 | Trivia and more (Japanese Wikipedia) | Read it in large amounts. |
| 7 | Even more old text (Really old texts) | Read old texts. Do not give up. |
| 8 | Congratulations, you can now start Chinese (Chinese) | Start to learn Chinese. |

## Requirements

- A web browser. This is all you need to read the guide.
- To run the quality gate: Bash with GNU `grep`, `sed`, and `diff`. The author tested only Linux.
- Optional: `vnu` or `tidy` for HTML validation. Without them the gate prints `SKIP html-validate`.

## Use it (≧∀≦)

### 1. Read it online

Open <https://stellarie.github.io/arisu-method/>. You see a road of eight hearts.

### 2. Or get a local copy

```bash
git clone https://github.com/stellarie/arisu-method.git
```

You get a folder named `arisu-method`.

### 3. Open the overview page

Open `arisu-method/index.html` in your browser. All links are relative, so the site works from `file://`.

Fonts come from Google Fonts. Pages fall back to system fonts when the load fails.

## Quality gate

`./check.sh` checks the whole site. Each failure prints one line: `FAIL <check> <file>: <detail>`.

| Check | It fails when |
|---|---|
| structure | `index.html` is missing. |
| shared | A nav or footer block differs from the block in `index.html`. |
| link | A local `href` or `src` points to a missing file. |
| pre | A page contains `<pre>`. |
| script | A page contains a script tag, an inline event handler, or a `javascript:` URL. |
| template | A page contains leaked generator code, such as `{J("x")}`. |
| nested | A tag opens inside another tag, such as `<ul class="<span">`. |
| svg | An `<svg>` has no `role="img"` or no `<title>`. |
| svg-color | An inline `<svg>` uses a hex color. |
| chain | The prev and next links do not form one chain from stage 1 to stage 8. |
| front | `index.html` does not link `tools.html` or `faq.html` from its body. |
| cue | A stage page has no `class="go"` move-on block. |
| verify | A `VERIFY` comment remains, and you passed `--release`. |
| html-validate | `vnu` or `tidy` reports an error. |

The gate also lists Latin words inside `lang="ja"` elements. This report is for information only.

A passing run prints `check: pass` and exits 0.

## Configuration

| Setting | Where | Default |
|---|---|---|
| Dark mode | Your browser or system theme | Follows the system |
| Reduced motion | Your system setting | Animations stop |
| Pages source | Repository settings | Branch `main`, path `/` |
| Jekyll | `.nojekyll` | Off |

## Develop (๑•̀ㅂ•́)و✧

```bash
./check.sh
./check.sh --release
bash tests/run.sh
```

- `./check.sh` runs the gate. Add `--release` to fail on every `VERIFY` comment.
- `bash tests/run.sh` runs the gate on the fixture sites under `tests/fixtures/`. It runs 16 cases. Each line prints `ok` or `FAIL`.

> Known gap (´ ˘ `): some durations, example texts, and claims are still drafts. The author marks each one with a `VERIFY` comment in the HTML. `./check.sh --release` lists them.

## License

All rights reserved © stellarie. Made with ♡ ( •̀ᴗ•́ )و
