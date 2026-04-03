# Compile Chains

## English chain
Preferred:
```powershell
latexmk -pdf -interaction=nonstopmode -file-line-error report.tex
```
Fallback:
```powershell
pdflatex -interaction=nonstopmode -file-line-error report.tex
bibtex report
pdflatex -interaction=nonstopmode -file-line-error report.tex
pdflatex -interaction=nonstopmode -file-line-error report.tex
```

## Chinese chain
Preferred:
```powershell
latexmk -xelatex -interaction=nonstopmode -file-line-error report.tex
```
Fallback (BibLaTeX):
```powershell
xelatex -interaction=nonstopmode -file-line-error report.tex
biber report
xelatex -interaction=nonstopmode -file-line-error report.tex
xelatex -interaction=nonstopmode -file-line-error report.tex
```
Fallback (BibTeX):
```powershell
xelatex -interaction=nonstopmode -file-line-error report.tex
bibtex report
xelatex -interaction=nonstopmode -file-line-error report.tex
xelatex -interaction=nonstopmode -file-line-error report.tex
```

## Makefile workflow
If project contains `Makefile`:
```powershell
make report
make pdf
make clean
make distclean
```
