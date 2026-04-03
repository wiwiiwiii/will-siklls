---
name: "arxiv-style-report-cn-en"
description: "Use proactively when user requests report/paper/PDF/调研报告/论文式写作/结构化章节/正式交付/LaTeX排版. Trigger by semantic intent without explicit skill name. Prefer direct TeX authoring with sections/tables/figures and reproducible PDF builds."
---

# arXiv-Style Report (CN+EN)

## When to use
- Semantic auto-trigger (no explicit skill name required).
: 用户说“写报告/调研报告/论文式/正式报告/PDF交付/章节化输出/可复现报告/LaTeX编译/学术风格”时，应主动触发。
: User asks for a report, paper-style writeup, market-research deliverable, or PDF-ready formal documentation.
- Strong trigger keywords (CN): `报告` `调研` `论文` `摘要` `方法` `实验` `讨论` `总结` `附录` `引用` `脚注` `LaTeX` `XeLaTeX` `PDF`.
- Strong trigger keywords (EN): `report` `paper-style` `formal writeup` `latex` `xelatex` `pdf` `appendix` `references` `citation`.
- If the request combines multiple charts/tables with narrative analysis, trigger this skill by default even without the skill name.

## Core output contract (must follow)
1. Direct chain only: `data -> figures/tables -> tex -> pdf`.
- Do not use “Markdown -> mechanical conversion -> PDF” as the main path.
- Do not generate the main narrative TeX from Python unless the user explicitly asks for code-generated TeX. Default to writing `tex/main.tex` and section files directly.

2. Repository layout (recommended baseline)
- `data/`: processed data.
- `data/raw/`: raw collected data.
- `scripts/`: quant scripts, plot scripts, helpers.
- `tex/`: TeX source root.
: `tex/main.tex`
: `tex/sections/*.tex`
: `tex/tables/*.tex`
: `tex/figures/*.pdf`
- root `Makefile`: `report`, `quant`, `plots`, `pdf`, `clean`, `distclean`.

3. Chinese market report chapter order (hard order)
- 研究背景
- 相关工作
- 方法
- 实验
- 讨论
- 总结

4. Reproducible build
- CN: `latexmk -xelatex` (or `build-report.ps1 -Language cn`).
- EN: `latexmk -pdf`.
- Keep `arxiv.sty` alongside `main.tex`.

## Citation and sample-link policy (Xiaohongshu)
1. Footnotes
- In正文,脚注优先指向样本编号（如 `S001-S006`），避免在正文塞长 URL。

2. Sample appendix table
- Appendix table fields: 样本编号 / 品牌 / 型号 / 标题 / 作者 / URL.
- URL strategy:
: Prefer short canonical form: `https://www.xiaohongshu.com/explore/{note_id}`.
: If unavailable, fall back to the captured URL (including `xsec` when required).

3. References behavior
- If the user requests footnote-only citations, do not force a bibliography section.
- If references are requested, keep them in `references.bib` only and let TeX decide whether to print them.

## Typography and layout defaults
- Chinese body font: `SimSun` (fallback `NSimSun` / `STSong`).
- English body font: `Times New Roman`.
- Math font: prefer `STIX Two Math` (fallback `XITS Math` / `Latin Modern Math`).
- Default body line spacing: `1.45-1.5`.
- Paragraph indent: `2em`.
- Global table row stretch: `\arraystretch = 1.5`.
- Tighten section/float spacing; avoid template whitespace that looks obviously machine-generated.
- Chinese reports should redefine caption prefixes to `图` / `表`.

## Source-formatting discipline
- Use `%--------------------------------------------------------------------------------` before each logical unit in section files.
- Keep each paragraph as a single source line when the user requests “段内不换行”.
- Leave two blank lines between paragraphs in section files.
- Keep figures and tables close to the paragraphs that interpret them; do not pile multiple floats onto one page without discussion.

## Table policy
- Use `booktabs`.
- Use `threeparttable` or `threeparttablex + tablenotes` when notes are needed.
- Use `longtable` for sample lists and other cross-page tables.
- Longtable centering: prefer `\setlength{\LTleft}{0pt plus 1fill}` and `\setlength{\LTright}{0pt plus 1fill}`.
- Column alignment heuristic (do not force every column centered):
: short categorical fields -> centered.
: numeric fields -> right aligned.
: long text / URLs -> left aligned, with URL column usually the widest.
- Avoid Markdown artifacts (`|---|`, backticks, heading markers) in `.tex`.

## Figure insertion policy
- `tex/figures` stores image assets only (PDF preferred).
- Figure inclusion code stays in section `.tex` files via `\includegraphics`.
- Do not generate figure-wrapper `.tex` files unless the user explicitly asks.
- Control figure width in TeX for consistency; `0.85\linewidth` is the default starting point for report figures.
- Prefer caption-only titling; do not add redundant in-figure titles unless the chart must stand alone.

## Writing quality and anti-trace rules
- No tool or pipeline traces in the narrative (no Codex/automation wording inside the report body).
- No answer-first reverse reasoning: derive conclusions from methods and experiments.
- Methods and experiment sections must explain weight design, formulas, and chart-based analysis in full prose.
- Merge overly short paragraphs; single-sentence paragraphs should be rare outside appendix notes.

## Quick start
1. Scaffold EN default:
```powershell
./scripts/scaffold-report.ps1 -Language en -Template default -Output tex/main.tex
```

2. Scaffold CN market template:
```powershell
./scripts/scaffold-report.ps1 -Language cn -Template market-cn -Output tex/main.tex
```

3. Build:
```powershell
./scripts/build-report.ps1 -MainTex tex/main.tex -Language cn -Clean
```

4. Or with Makefile:
```powershell
make report
```

## Resources
- `assets/arxiv.sty`: style file.
- `assets/template-en.tex`: EN baseline template.
- `assets/template-cn.tex`: CN baseline template.
- `assets/template-cn-market.tex`: CN market-report template.
- `assets/Makefile.report`: reusable Makefile skeleton.

## Scaffold style guarantees
- `scaffold-report.ps1` must create `tex/sections`, `tex/tables`, and `tex/figures` for both `default` and `market-cn` templates.
- Scaffolded section files must include `%--------------------------------------------------------------------------------` before each logical block.
- Scaffolded section files must use single-line paragraph source with two blank lines between paragraphs.
- At least one table stub must be generated under `tex/tables` so `\input{tables/...}` works immediately.
- The appendix sample-index stub must already use a centered `longtable` with a wider URL column.
