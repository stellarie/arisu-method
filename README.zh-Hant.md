<div align="center">

# ♡ The Arisu Method ♡

**一份唯讀的日語入門學習路線指南~**

[English](README.md) | [简体中文](README.zh-Hans.md) | 繁體中文

[stellarie.github.io/arisu-method](https://stellarie.github.io/arisu-method/) (｡•̀ᴗ-)✧

</div>

> 這是個人方法，不是課程。作者依此方法從零學會了日語。

## 這是什麼？

本站是寫給日語零基礎者的指南，共有八個階段。每個階段頁面重點說明這一步為什麼有效，而不只是要做什麼。

- **總覽頁：** 一條由八顆粉色愛心組成的路，每顆對應一個階段。
- **階段頁：** 每頁說明核心想法、為什麼有效、學習時的感受、進步的跡象、常見錯誤、這一步要做什麼，以及連結。

你在瀏覽器中閱讀本站。它只用純 HTML 和 CSS，沒有 JavaScript，也沒有建置步驟。

## 八個階段

| # | 階段 | 要做的事 |
|---|---|---|
| 1 | Kana and Tae Kim | 學會假名。讀 Tae Kim 的指南，讀到 から 和 けど 為止。 |
| 2 | 吾輩は猫である | 讀這部小說。必要時慢慢爬行。 |
| 3 | 週に一度クラスメイトを買う話 | 讀這部小說，然後開始輸出。 |
| 4 | 四字熟語 | 學會 200 到 300 個四字熟語。 |
| 5 | 般若心経 and 魏志倭人伝 | 在階段 2 到 7 期間一併閱讀這兩篇文本。 |
| 6 | Japanese Wikipedia | 大量閱讀日語維基百科。 |
| 7 | Really old texts | 讀很古老的文本。不要放棄。 |
| 8 | Chinese | 開始學習中文。 |

## 環境需求

- 一個網頁瀏覽器。閱讀指南只需要它。
- 執行品質檢查：Bash，以及 GNU 版 `grep`、`sed` 和 `diff`。只在 Linux 上測試過。
- 選用：`vnu` 或 `tidy`，用於 HTML 驗證。沒有它們時，檢查會輸出 `SKIP html-validate`。

## 使用 (≧∀≦)

### 1. 線上閱讀

開啟 <https://stellarie.github.io/arisu-method/>。你會看到一條由八顆愛心組成的路。

### 2. 或者取得本機副本

```bash
git clone https://github.com/stellarie/arisu-method.git
```

你會得到一個名為 `arisu-method` 的資料夾。

### 3. 開啟總覽頁

用瀏覽器開啟 `arisu-method/index.html`。所有連結都是相對連結，所以本站可以從 `file://` 執行。

字型來自 Google Fonts。載入失敗時，頁面會回退到系統字型。

## 品質檢查

`./check.sh` 會檢查整個網站。每個失敗輸出一行：`FAIL <check> <file>: <detail>`。

| 檢查 | 失敗條件 |
|---|---|
| structure | 缺少 `index.html`。 |
| shared | 某個導覽或頁尾區塊與 `index.html` 中的區塊不同。 |
| link | 本機 `href` 或 `src` 指向不存在的檔案。 |
| pre | 頁面含有 `<pre>`。 |
| script | 頁面含有 script 標籤、內嵌事件處理屬性或 `javascript:` URL。 |
| svg | `<svg>` 沒有 `role="img"` 或沒有 `<title>`。 |
| svg-color | 內嵌 `<svg>` 使用了十六進位顏色。 |
| chain | 上一頁和下一頁的連結沒有組成從階段 1 到階段 8 的一條鏈。 |
| verify | 仍有 `VERIFY` 註解，且你傳入了 `--release`。 |
| html-validate | `vnu` 或 `tidy` 回報了錯誤。 |

檢查還會列出 `lang="ja"` 元素內的拉丁字母單字。這份報告僅供參考。

檢查通過時會輸出 `check: pass`，並以 0 結束。

## 設定

| 設定 | 位置 | 預設值 |
|---|---|---|
| 深色模式 | 瀏覽器或系統主題 | 跟隨系統 |
| 減少動態效果 | 系統設定 | 動畫停止 |
| Pages 來源 | 儲存庫設定 | 分支 `main`，路徑 `/` |
| Jekyll | `.nojekyll` | 關閉 |

## 開發 (๑•̀ㅂ•́)و✧

```bash
./check.sh
./check.sh --release
bash tests/run.sh
```

- `./check.sh` 執行品質檢查。加上 `--release`，每個 `VERIFY` 註解都會導致失敗。
- `bash tests/run.sh` 在 `tests/fixtures/` 下的範例網站上執行檢查，共 11 個案例。每行輸出 `ok` 或 `FAIL`。

> 已知缺口 (´ ˘ `)：部分時長、範例文本和說法仍是草稿。作者在 HTML 中用 `VERIFY` 註解標出每一處。`./check.sh --release` 會列出它們。

## 授權

保留所有權利 © stellarie。Made with ♡ ( •̀ᴗ•́ )و
