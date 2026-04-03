SHELL := C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
.SHELLFLAGS := -NoProfile -ExecutionPolicy Bypass -Command

PYTHON ?= python
TEX_DIR ?= tex
MAIN_TEX ?= $(TEX_DIR)/main.tex
LANG ?= cn

BUILD_SCRIPT ?= C:/Users/nerdz/.codex/skills/arxiv-style-report-cn-en/scripts/build-report.ps1

.PHONY: report plots pdf clean distclean

report: plots pdf

plots:
	if (Test-Path 'scripts') { $$plots = Get-ChildItem -Path 'scripts' -Filter 'plot_fig_*.py' -File | Sort-Object Name; if ($$plots.Count -gt 0) { foreach($$p in $$plots){ $(PYTHON) $$p.FullName } } else { Write-Host 'skip plots: no plot_fig_*.py found' } } else { Write-Host 'skip plots: scripts dir not found' }

pdf:
	if (Test-Path '$(MAIN_TEX)') { & '$(BUILD_SCRIPT)' -MainTex '$(MAIN_TEX)' -Language $(LANG) -Clean } else { Write-Host 'skip pdf: $(MAIN_TEX) not found' }

clean:
	Get-ChildItem -Path '$(TEX_DIR)' -Recurse -File -Include *.aux,*.bbl,*.blg,*.bcf,*.fdb_latexmk,*.fls,*.log,*.out,*.run.xml,*.synctex.gz,*.toc,*.lof,*.lot,*.xdv -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

distclean: clean
	if (Test-Path '$(TEX_DIR)/figures') { Get-ChildItem -Path '$(TEX_DIR)/figures' -File -Include *.png,*.jpg,*.jpeg -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue }
