# LaTeX PDF Integration Policy

## Required
- Insert report figures in LaTeX with PDF paths only.
- Example:
```tex
\\includegraphics[width=\\columnwidth]{figures/result_plot.pdf}
```

## Sizing
- Keep a consistent width policy per section:
  - single-column figures: `\\columnwidth`
  - wide figures: `\\textwidth`
- Keep comparable chart types at the same physical size in one report.

## Notes
- Do not rotate ticks unless explicitly requested (default is 0 degrees).
- Keep bar widths light and avoid heavy visual blocks.
- Hatch fills are acceptable for category distinction in grayscale-friendly print.
