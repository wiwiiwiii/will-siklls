param(
    [string]$MainTex = "report.tex",
    [ValidateSet("auto", "en", "cn")]
    [string]$Language = "auto",
    [switch]$Clean
)

$ErrorActionPreference = "Stop"

function Invoke-Step {
    param(
        [string]$Command,
        [string[]]$CommandArgs
    )

    Write-Host ">> $Command $( $CommandArgs -join ' ')"
    & $Command @CommandArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed ($LASTEXITCODE): $Command $( $CommandArgs -join ' ')"
    }
}

if (-not (Test-Path -LiteralPath $MainTex)) {
    throw "Main tex not found: $MainTex"
}

$MainTex = (Resolve-Path -LiteralPath $MainTex).Path
$base = [System.IO.Path]::GetFileNameWithoutExtension($MainTex)
$dir = Split-Path -Parent $MainTex

Push-Location $dir
try {
    if ($Language -eq "auto") {
        $raw = Get-Content -LiteralPath $MainTex -Raw
        if ($raw -match "[\u4e00-\u9fff]") {
            $Language = "cn"
        }
        else {
            $Language = "en"
        }
        Write-Host "Detected language: $Language"
    }

    if ($Clean) {
        if (Get-Command latexmk -ErrorAction SilentlyContinue) {
            Invoke-Step "latexmk" @("-c", $MainTex)
        }
        else {
            $patterns = @(
                "*.aux", "*.bbl", "*.bcf", "*.blg", "*.fdb_latexmk", "*.fls",
                "*.log", "*.out", "*.run.xml", "*.synctex.gz", "*.toc", "*.xdv"
            )
            foreach ($p in $patterns) {
                Get-ChildItem -LiteralPath . -Filter $p -ErrorAction SilentlyContinue |
                    Remove-Item -Force -ErrorAction SilentlyContinue
            }
        }
    }

    $rawContent = Get-Content -LiteralPath $MainTex -Raw
    $hasBiblatex = $rawContent -match "\\addbibresource"
    $hasBibtex = $rawContent -match "\\bibliography\s*\{"

    if (Get-Command latexmk -ErrorAction SilentlyContinue) {
        if ($Language -eq "cn") {
            Invoke-Step "latexmk" @("-xelatex", "-interaction=nonstopmode", "-file-line-error", $MainTex)
        }
        else {
            Invoke-Step "latexmk" @("-pdf", "-interaction=nonstopmode", "-file-line-error", $MainTex)
        }
    }
    else {
        $engine = if ($Language -eq "cn") { "xelatex" } else { "pdflatex" }

        if (-not (Get-Command $engine -ErrorAction SilentlyContinue)) {
            throw "Engine not found on PATH: $engine"
        }

        Invoke-Step $engine @("-interaction=nonstopmode", "-file-line-error", $MainTex)

        if ($hasBiblatex) {
            if (Get-Command biber -ErrorAction SilentlyContinue) {
                Invoke-Step "biber" @($base)
            }
            else {
                Write-Warning "BibLaTeX detected but biber is not available."
            }
        }
        elseif ($hasBibtex) {
            if (Get-Command bibtex -ErrorAction SilentlyContinue) {
                Invoke-Step "bibtex" @($base)
            }
            else {
                Write-Warning "BibTeX references detected but bibtex is not available."
            }
        }

        Invoke-Step $engine @("-interaction=nonstopmode", "-file-line-error", $MainTex)
        Invoke-Step $engine @("-interaction=nonstopmode", "-file-line-error", $MainTex)
    }

    $pdfPath = Join-Path $dir ($base + ".pdf")
    if (-not (Test-Path -LiteralPath $pdfPath)) {
        throw "Build finished but PDF not found: $pdfPath"
    }

    Write-Host "Build succeeded: $pdfPath"
    if (Test-Path -LiteralPath (Join-Path $dir "Makefile")) {
        Write-Host "Tip: project Makefile is available (make report / make clean)."
    }
}
finally {
    Pop-Location
}
