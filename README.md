# will-siklls

本仓库用于托管可复用的 Codex 技能（skills），当前包含 2 个核心技能：

1. `arxiv-style-report-cn-en`
2. `research-plot-style-scienceplots`

## Skills

### 1) arxiv-style-report-cn-en
面向中英文论文式报告与调研报告交付，强调可复现和直出 PDF 的工程链路。

- 主要能力
  - 语义触发（无需显式写技能名）
  - 直链路：`data -> tex -> pdf`
  - `main.tex + sections/tables/figures` 结构化工程
  - 中文报告默认排版约束（行距、段首缩进、图表标题中文化）
  - Makefile 与脚手架支持（`report/pdf/clean/distclean`）

- 关键文件
  - `SKILL.md`
  - `assets/template-en.tex`
  - `assets/template-cn.tex`
  - `assets/template-cn-market.tex`
  - `scripts/scaffold-report.ps1`
  - `scripts/build-report.ps1`

### 2) research-plot-style-scienceplots
面向科学风格图表输出，强调统一配色、条纹规则、中文可读性和低噪视觉风格。

- 主要能力
  - `scienceplots + matplotlib` 统一样式
  - 固定调色盘与固定条纹序列
  - 柱图标注边界钳制与长标签防遮挡
  - 柔化多分类配色与低饱和热力图策略
  - PDF-only 图表资产输出（适配 TeX 插图）

- 关键文件
  - `SKILL.md`
  - `scripts/style_template.py`

## Repository Layout

```text
will-siklls/
├─ arxiv-style-report-cn-en/
│  ├─ SKILL.md
│  ├─ agents/openai.yaml
│  ├─ assets/
│  ├─ references/
│  └─ scripts/
└─ research-plot-style-scienceplots/
   ├─ SKILL.md
   ├─ agents/openai.yaml
   ├─ references/
   └─ scripts/
```

## Quick Start (PowerShell)

### Report Skill

```powershell
# scaffold
./scripts/scaffold-report.ps1 -Language cn -Template market-cn -Output tex/main.tex

# build
./scripts/build-report.ps1 -MainTex tex/main.tex -Language cn -Clean
```

### Plot Skill

```powershell
python scripts/style_template.py
```

## Maintenance Notes

- 建议保持 `SKILL.md` 与 `assets/scripts` 同步更新。
- 更新技能后，建议做最小冒烟验证：
  - 报告技能：EN + CN 各 scaffold 一次并编译。
  - 绘图技能：运行 `style_template.py` 检查输出和风格。
- 如需避免空参考文献警告，请在模板中按需启用 bibliography 区块（有实际引用时再打开）。

---

# English Summary

This repository hosts reusable Codex skills for:

1. structured CN/EN report generation (`arxiv-style-report-cn-en`), and
2. publication-style plotting with consistent aesthetics (`research-plot-style-scienceplots`).

Both skills are designed for semantic triggering, reproducible workflows, and practical reuse in real projects.
