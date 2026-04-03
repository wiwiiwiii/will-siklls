---
name: "research-plot-style-scienceplots"
description: "Use proactively for chart/visualization requests in reports or papers. No explicit skill name required; trigger by semantic intent (图表/可视化/画图/柱状图/散点/热力图)."
---

# Research Plot Style (Scienceplots)

## When to use
- Semantic auto-trigger (no explicit skill name required).
: 用户说“画图/可视化/图表优化/柱状图/散点图/热力图/配色/图注/排版图”时，应主动触发。
: User asks for scientific figures, visualization polish, chart readability, or publication-ready plot assets.
- Strong trigger keywords (CN): `画图` `图表` `可视化` `柱状图` `散点图` `热力图` `配色` `标签遮挡` `图注` `scienceplots` `matplotlib`.
- Strong trigger keywords (EN): `plot` `chart` `visualization` `bar` `scatter` `heatmap` `palette` `overlap` `scienceplots` `matplotlib`.
- If the user asks for quantitative comparison with charts, trigger this skill by default.

## Hard constraints
1. Style system
- Use `scienceplots` with a deterministic `matplotlib` pipeline by default.

2. Unified color palette (fixed base order)
- `#66C2A5`
- `#FC8D62`
- `#8DA0CB`
- `#E78AC3`
- `#A6D854`
- `#E5C494`

3. Bar hatch policy (fixed order)
- Default categorical hatch order must follow the reference sample:
: `////`
: `....`
: `xxxx`
: `----`
- When more than four bars appear, keep cycling in the same order.
- Primary comparison bars should not rely on solid fills alone.

4. Output format
- Final figure assets must be vector PDF.
- Do not use PNG/JPG as the final insertion asset in report TeX.

5. Layout consistency
- Keep figure sizes aligned across the same report.
- Control final display width in TeX (`\includegraphics[width=...]`).
- Avoid piling many figures together without supporting paragraph analysis.

6. Readability rules
- Keep tick labels unrotated by default.
- Keep bars visually light: narrow widths, light edges, restrained gridlines.
- Clamp value annotations inside axis limits; no text should spill outside the plotting area.
- Omit in-figure titles when a report caption already carries the title.

7. Chinese label policy
- Chinese reports should use Chinese axis labels and legend text.
- Never expose raw `snake_case` keys directly.
- Use mapping helpers for model, brand, and dimension short names.
- Default CJK figure font: `SimSun` fallback chain.

8. Low-noise color policy
- For few-category comparison charts, use the base palette directly.
- For many-category bar charts, soften the same palette before plotting instead of jumping to a rainbow-like mix.
- For heatmaps, prefer low-chroma sequential maps built from off-white plus neighboring hues from the base palette.
- Avoid rainbow heatmaps or high-chroma diverging maps unless the data semantics require them.

9. Long-label anti-overlap policy
- Prefer one or more of the following:
: short aliases.
: controlled line wrap.
: horizontal bar layout.
: bbox-backed scatter labels with overlap reduction.
- Use leader lines only when necessary; default to正文解释 rather than graphic callouts.

## Recommended helper patterns
- `soften_color()` / `make_soft_palette()` for calmer multi-category bars.
- `make_heatmap_cmap()` for restrained sequential heatmaps.
- `annotate_bar_values_clamped()` for boundary-safe value labels.
- `scatter_labels_no_leader()` for readable label placement without ugly connectors.
- Shared `plot_bar()` helpers should centralize color and hatch rules rather than styling each chart ad hoc.

## Completion criteria
- All figures share one palette family and one hatch family.
- Multi-category bars feel orderly rather than flashy.
- Heatmaps read as quantitative gradients, not decorative color blocks.
- Outputs are PDF and can be inserted directly from `tex/figures/`.
- Labels are localized, readable, and non-overlapping.
- No raw internal keys leak into final chart text.
