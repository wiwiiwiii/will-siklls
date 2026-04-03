param(
    [ValidateSet("en", "cn")]
    [string]$Language = "en",
    [ValidateSet("default", "market-cn")]
    [string]$Template = "default",
    [string]$Output = "tex/main.tex",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Write-ScaffoldFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Content,
        [switch]$ForceWrite
    )

    if ((-not (Test-Path -LiteralPath $Path)) -or $ForceWrite) {
        $parent = Split-Path -Parent $Path
        if ($parent -and -not (Test-Path -LiteralPath $parent)) {
            New-Item -ItemType Directory -Path $parent | Out-Null
        }
        Set-Content -LiteralPath $Path -Value $Content -Encoding UTF8
    }
}

$skillRoot = Split-Path -Parent $PSScriptRoot
$assetDir = Join-Path $skillRoot "assets"

if ($Template -eq "market-cn" -and $Language -ne "cn") {
    Write-Warning "Template 'market-cn' requires Chinese chain; overriding Language to 'cn'."
    $Language = "cn"
}

$templateFile = if ($Template -eq "market-cn") { "template-cn-market.tex" } else { "template-" + $Language + ".tex" }
$templatePath = Join-Path $assetDir $templateFile
$stylePath = Join-Path $assetDir "arxiv.sty"
$bibPath = Join-Path $assetDir "references.bib"
$makefilePath = Join-Path $assetDir "Makefile.report"

if (-not (Test-Path -LiteralPath $templatePath)) { throw "Template not found: $templatePath" }

$outputPath = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Output))
$targetDir = Split-Path -Parent $outputPath
if (-not (Test-Path -LiteralPath $targetDir)) { New-Item -ItemType Directory -Path $targetDir | Out-Null }
if ((Test-Path -LiteralPath $outputPath) -and -not $Force) { throw "Output already exists: $outputPath (use -Force to overwrite)" }

Copy-Item -LiteralPath $templatePath -Destination $outputPath -Force

$targetStyle = Join-Path $targetDir "arxiv.sty"
if ((-not (Test-Path -LiteralPath $targetStyle)) -or $Force) { Copy-Item -LiteralPath $stylePath -Destination $targetStyle -Force }

$targetBib = Join-Path $targetDir "references.bib"
if ($Template -ne "market-cn") {
    if ((-not (Test-Path -LiteralPath $targetBib)) -or $Force) { Copy-Item -LiteralPath $bibPath -Destination $targetBib -Force }
}

$projectRoot = Split-Path -Parent $targetDir
$targetMakefile = Join-Path $projectRoot "Makefile"
if ((Test-Path -LiteralPath $makefilePath) -and ((-not (Test-Path -LiteralPath $targetMakefile)) -or $Force)) {
    Copy-Item -LiteralPath $makefilePath -Destination $targetMakefile -Force
}
if (Test-Path -LiteralPath $targetMakefile) {
    $mk = Get-Content -Raw $targetMakefile
    $mk = [regex]::Replace($mk, 'LANG \?= (cn|en)', "LANG ?= $Language", 1)
    Set-Content -LiteralPath $targetMakefile -Value $mk -Encoding UTF8
}

$sectionsDir = Join-Path $targetDir "sections"
$tablesDir = Join-Path $targetDir "tables"
$figuresDir = Join-Path $targetDir "figures"
foreach ($d in @($sectionsDir, $tablesDir, $figuresDir)) {
    if (-not (Test-Path -LiteralPath $d)) { New-Item -ItemType Directory -Path $d | Out-Null }
}

$scriptsDir = Join-Path $projectRoot "scripts"
if (-not (Test-Path -LiteralPath $scriptsDir)) { New-Item -ItemType Directory -Path $scriptsDir | Out-Null }

if ($Language -eq "cn") {
    $sectionStubs = @{
        "00_abstract.tex" = @"
%--------------------------------------------------------------------------------
本模板用于快速搭建中文论文式报告工程，默认生成章节、表格与图形目录，并保持分割线、双空行和段内单行的可协作写作格式。
"@
        "01_background.tex" = @"
%--------------------------------------------------------------------------------
\section{研究背景}


%--------------------------------------------------------------------------------
请在本节说明目标人群、使用场景、决策约束与问题边界，再进入比较与结论，避免一上来直接给排名。


%--------------------------------------------------------------------------------
建议把段落写成长段，并把关键定义、数据口径和样本边界说完整，减少碎片化短段落。
"@
        "02_related_work.tex" = @"
%--------------------------------------------------------------------------------
\section{相关工作}


%--------------------------------------------------------------------------------
建议先归纳常见测评路径，再指出其局限，并说明本报告如何在样本口径、权重方法与可复核性方面改进。
"@
        "03_methods.tex" = @"
%--------------------------------------------------------------------------------
\section{方法}


%--------------------------------------------------------------------------------
建议采用加权评分函数：
\begin{equation}
S_b = \sum_{k=1}^{K} w_k x_{b,k}, \quad \sum_{k=1}^{K} w_k = 1.
\label{eq:weighted_score}
\end{equation}
其中 \(S_b\) 为目标对象总分，\(x_{b,k}\) 为维度归一化值，\(w_k\) 为维度权重。
"@
        "04_experiments.tex" = @"
%--------------------------------------------------------------------------------
\section{实验}


%--------------------------------------------------------------------------------
实验部分建议采用图表与正文相邻的写法。示例结果见表~\ref{tab:demo_scores_cn}，并在图~\ref{fig:demo_scores_cn}后立即解释差异来源。

\input{tables/table_01_demo}

\IfFileExists{figures/fig_01_demo.pdf}{
\begin{figure}[H]
\centering
\includegraphics[width=0.85\linewidth]{figures/fig_01_demo.pdf}
\caption{示例分数图}
\label{fig:demo_scores_cn}
\end{figure}
}{}
"@
        "05_discussion.tex" = @"
%--------------------------------------------------------------------------------
\section{讨论}


%--------------------------------------------------------------------------------
讨论建议明确样本偏差、外推边界、版本差异影响，以及统计结果与最终购买建议之间的适用范围。
"@
        "06_conclusion.tex" = @"
%--------------------------------------------------------------------------------
\section{总结}


%--------------------------------------------------------------------------------
总结建议采用关键发现、适用场景与实施建议三段式结构，保证结论可以直接落地到实际决策。
"@
        "07_appendix_samples.tex" = @"
%--------------------------------------------------------------------------------
\section{附录：样本清单}


%--------------------------------------------------------------------------------
\input{tables/table_04_sample_index}
"@
    }

    $table01 = @"
\begin{table}[H]
\centering
\begin{threeparttable}
\caption{示例得分表}
\label{tab:demo_scores_cn}
\begin{tabularx}{0.84\linewidth}{>{\centering\arraybackslash}m{2.8cm}>{\centering\arraybackslash}m{2.0cm}>{\arraybackslash}X}
\toprule
对象 & 综合得分 & 说明 \\
\midrule
示例A & 68.5 & 该行可替换为真实结果。 \\
示例B & 64.2 & 该行可替换为真实结果。 \\
\bottomrule
\end{tabularx}
\begin{tablenotes}[flushleft]
\footnotesize
\item 注：此表用于验证 tables 目录与 \texttt{\textbackslash input} 链路。
\end{tablenotes}
\end{threeparttable}
\end{table}
"@

    $table04 = @"
\setlength{\LTleft}{0pt plus 1fill}
\setlength{\LTright}{0pt plus 1fill}
\begin{ThreePartTable}
\begin{TableNotes}[flushleft]
\footnotesize
\item 注：样本 URL 优先使用最短可访问链接，缺失时回退采集原链。
\end{TableNotes}
\footnotesize
\begin{longtable}{@{}p{1.1cm}p{1.4cm}p{2.2cm}p{3.2cm}p{1.6cm}p{4.6cm}@{}}
\caption{样本清单（占位）\label{tab:sample_index_cn}}\\
\toprule
样本编号 & 品牌 & 型号 & 标题 & 作者 & URL \\
\midrule
\endfirsthead
\toprule
样本编号 & 品牌 & 型号 & 标题 & 作者 & URL \\
\midrule
\endhead
\midrule
\multicolumn{6}{r}{续下页}\\
\endfoot
\bottomrule
\insertTableNotes\\
\endlastfoot
S001 & 示例品牌 & 示例型号 & 示例标题 & 示例作者 & \url{https://www.xiaohongshu.com/explore/1234567890abcdef} \\
\end{longtable}
\end{ThreePartTable}
"@
}
else {
    $sectionStubs = @{
        "00_abstract.tex" = @"
%--------------------------------------------------------------------------------
This scaffold validates a direct TeX-to-PDF workflow and provides a long-form report skeleton with sections, tables, figures, and optional references.
"@
        "01_background.tex" = @"
%--------------------------------------------------------------------------------
\section{Background}


%--------------------------------------------------------------------------------
Define the practical context and decision constraints before presenting any ranking so the narrative stays process-first.


%--------------------------------------------------------------------------------
Keep each paragraph on a single source line, keep two blank lines between paragraphs, and place separator comments before every logical block.
"@
        "02_related_work.tex" = @"
%--------------------------------------------------------------------------------
\section{Related Work}


%--------------------------------------------------------------------------------
Summarize existing evaluation patterns and explain their limits, then describe how this report improves reproducibility through explicit weighting, explicit data transforms, and traceable sources.
"@
        "03_methods.tex" = @"
%--------------------------------------------------------------------------------
\section{Methods}


%--------------------------------------------------------------------------------
Use a weighted scoring function:
\begin{equation}
S_b = \sum_{k=1}^{K} w_k x_{b,k}, \quad \sum_{k=1}^{K} w_k = 1.
\label{eq:weighted_score}
\end{equation}
where \(S_b\) is the final score, \(x_{b,k}\) is the normalized value, and \(w_k\) is the dimension weight.
"@
        "04_experiments.tex" = @"
%--------------------------------------------------------------------------------
\section{Experiments}


%--------------------------------------------------------------------------------
Table~\ref{tab:demo_scores_en} validates table integration from the \texttt{tables} folder, while Figure~\ref{fig:demo_scores_en} validates chart insertion from \texttt{tex/figures}. Equation~\ref{eq:weighted_score} is cited to verify cross-references.

\input{tables/table_01_demo}

\IfFileExists{figures/fig_01_demo.pdf}{
\begin{figure}[H]
\centering
\includegraphics[width=0.85\linewidth]{figures/fig_01_demo.pdf}
\caption{Demo score chart for smoke validation}
\label{fig:demo_scores_en}
\end{figure}
}{}


%--------------------------------------------------------------------------------
Interpretation text should stay adjacent to each figure or table instead of stacking all floats together on one page.
"@
        "05_discussion.tex" = @"
%--------------------------------------------------------------------------------
\section{Discussion}


%--------------------------------------------------------------------------------
Discuss sample bias, scope boundaries, and version effects explicitly so conclusions remain decision-safe.
"@
        "06_conclusion.tex" = @"
%--------------------------------------------------------------------------------
\section{Conclusion}


%--------------------------------------------------------------------------------
Conclude with key findings, implementation notes, and follow-up checks linked back to methods and experiments.
"@
        "07_appendix_samples.tex" = @"
%--------------------------------------------------------------------------------
\section{Appendix: Sample Index}


%--------------------------------------------------------------------------------
\input{tables/table_04_sample_index}
"@
    }

    $table01 = @"
\begin{table}[H]
\centering
\begin{threeparttable}
\caption{Demo weighted scores}
\label{tab:demo_scores_en}
\begin{tabularx}{0.84\linewidth}{>{\centering\arraybackslash}m{2.6cm}>{\centering\arraybackslash}m{2.2cm}>{\centering\arraybackslash}X}
\toprule
Brand & Sample Size & Weighted Score \\
\midrule
GONGCUN & 25 & 68.77 \\
TYMO & 25 & 68.47 \\
VODANA & 25 & 65.63 \\
LENA & 25 & 59.58 \\
\bottomrule
\end{tabularx}
\begin{tablenotes}[flushleft]
\footnotesize
\item Note: Placeholder table generated by scaffold. Replace with real outputs when available.
\end{tablenotes}
\end{threeparttable}
\end{table}
"@

    $table04 = @"
\setlength{\LTleft}{0pt plus 1fill}
\setlength{\LTright}{0pt plus 1fill}
\begin{ThreePartTable}
\begin{TableNotes}[flushleft]
\footnotesize
\item Note: Prefer short canonical URLs and keep sample IDs stable for traceability.
\end{TableNotes}
\footnotesize
\begin{longtable}{@{}p{1.1cm}p{1.4cm}p{2.2cm}p{3.2cm}p{1.6cm}p{4.4cm}@{}}
\caption{Sample index (placeholder)\label{tab:sample_index_en}}\\
\toprule
Sample ID & Brand & Model & Title & Author & URL \\
\midrule
\endfirsthead
\toprule
Sample ID & Brand & Model & Title & Author & URL \\
\midrule
\endhead
\midrule
\multicolumn{6}{r}{Continued on next page}\\
\endfoot
\bottomrule
\insertTableNotes\\
\endlastfoot
S001 & DemoBrand & DemoModel & Demo post title & DemoAuthor & \url{https://www.xiaohongshu.com/explore/1234567890abcdef} \\
\end{longtable}
\end{ThreePartTable}
"@
}

foreach ($name in $sectionStubs.Keys) {
    $path = Join-Path $sectionsDir $name
    Write-ScaffoldFile -Path $path -Content $sectionStubs[$name] -ForceWrite:$Force
}

Write-ScaffoldFile -Path (Join-Path $tablesDir "table_01_demo.tex") -Content $table01 -ForceWrite:$Force
Write-ScaffoldFile -Path (Join-Path $tablesDir "table_04_sample_index.tex") -Content $table04 -ForceWrite:$Force

$plotScriptPath = Join-Path $scriptsDir "plot_fig_01_demo.py"
$plotScript = @"
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np

PALETTE = ["#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3"]
HATCHES = ["////", "....", "xxxx", "----"]


def main() -> None:
    root = Path(__file__).resolve().parent.parent
    out_dir = root / "tex" / "figures"
    out_dir.mkdir(parents=True, exist_ok=True)
    out_file = out_dir / "fig_01_demo.pdf"

    labels = ["GONGCUN", "TYMO", "VODANA", "LENA"]
    values = np.array([68.77, 68.47, 65.63, 59.58], dtype=float)
    x = np.arange(len(labels))

    plt.style.use("default")
    plt.rcParams.update(
        {
            "font.family": "serif",
            "font.size": 11,
            "axes.labelsize": 11,
            "xtick.labelsize": 10,
            "ytick.labelsize": 10,
            "pdf.fonttype": 42,
            "ps.fonttype": 42,
        }
    )

    fig, ax = plt.subplots(figsize=(7.2, 3.8), dpi=300)
    bars = ax.bar(x, values, width=0.42, color=PALETTE, edgecolor="#4A4A4A", linewidth=0.7, alpha=0.88)

    for bar, hatch in zip(bars, HATCHES):
        bar.set_hatch(hatch)

    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.set_ylabel("Weighted Score")
    ax.set_ylim(55, 72)
    ax.grid(axis="y", linestyle="--", linewidth=0.5, alpha=0.30)

    for b, v in zip(bars, values):
        ax.text(b.get_x() + b.get_width() / 2, v + 0.25, f"{v:.2f}", ha="center", va="bottom", fontsize=10)

    fig.tight_layout()
    fig.savefig(out_file, format="pdf")
    plt.close(fig)
    print(f"[ok] generated: {out_file}")


if __name__ == "__main__":
    main()
"@
Write-ScaffoldFile -Path $plotScriptPath -Content $plotScript -ForceWrite:$Force

Write-Host "Scaffold created: $outputPath"
Write-Host "Companion style: $targetStyle"
if (Test-Path -LiteralPath $targetBib) { Write-Host "Companion bib: $targetBib" }
if (Test-Path -LiteralPath $targetMakefile) { Write-Host "Makefile: $targetMakefile" }
Write-Host "Sections dir: $sectionsDir"
Write-Host "Tables dir: $tablesDir"
Write-Host "Figures dir: $figuresDir"
Write-Host "Next: run build-report.ps1 -MainTex '$outputPath' -Language $Language"

