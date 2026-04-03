# Citation and Link Policy

## Core rules
- Every external evidence source must be attributed.
- In LaTeX reports, use either:
  - claim-level footnotes, or
  - bibliography/in-text citation markers.
- Do not leave bare URLs in running prose.

## Xiaohongshu evidence pattern (recommended)
1. In body text, use grouped evidence IDs in footnotes.
```tex
结论描述。\footnote{证据编号：E001、E002、E003。完整链接见附录证据清单与参考链接。}
```

2. In appendix, provide evidence table.
- Required columns: 品牌 / 型号 / note_id / 标题 / URL.

3. In references section, list direct source URLs.
- For XHS projects, references should be xiaohongshu URLs (including usable direct links).

## LaTeX patterns
Footnote style:
```tex
A source-backed statement.\footnote{\url{https://example.com/source}}
```

Bibliography style:
```tex
Evidence supports this claim \citep{example_source}.
```
