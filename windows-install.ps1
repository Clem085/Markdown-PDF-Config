# Install Markdown PDF Plus themes for the current Windows user.
# Works from any checkout directory; does not require administrator rights.
$ErrorActionPreference = 'Stop'

try {
    $repoDir = $PSScriptRoot
    if ([string]::IsNullOrWhiteSpace($repoDir)) {
        throw 'Cannot determine the script directory. Run the saved windows-install.ps1 file.'
    }

    $destinationDir = Join-Path $HOME '.config\Code\markdown-themes'

    function Find-Theme([string]$name) {
        $matches = @(Get-ChildItem -LiteralPath $repoDir -Recurse -File -Filter $name -ErrorAction Stop |
            Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' })
        if ($matches.Count -eq 0) {
            throw "Could not find $name in $repoDir"
        }
        if ($matches.Count -ne 1) {
            throw "Found $($matches.Count) copies of $name in $repoDir. Keep only one source copy."
        }
        return $matches[0].FullName
    }

    # Resolve both source files before changing anything.
    $lightSource = Find-Theme 'pdf-light.css'
    $darkSource = Find-Theme 'pdf-dark.css'

    New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null

    function Install-Theme([string]$source, [string]$name) {
        $target = Join-Path $destinationDir $name
        if (Test-Path -LiteralPath $target) {
            $item = Get-Item -LiteralPath $target
            if ($item.PSIsContainer) { throw "Destination is a directory: $target" }
            $sourceHash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
            $targetHash = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash
            if ($sourceHash -eq $targetHash) {
                Write-Host "Unchanged: $target" -ForegroundColor DarkGray
                return
            }
            $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
            $backup = "$target.bak-$timestamp"
            $n = 1
            while (Test-Path -LiteralPath $backup) {
                $backup = "$target.bak-$timestamp-$n"
                $n++
            }
            Copy-Item -LiteralPath $target -Destination $backup
            Write-Host "Backup: $backup" -ForegroundColor Yellow
        }
        Copy-Item -LiteralPath $source -Destination $target -Force
        Write-Host "Installed: $target" -ForegroundColor Green
    }

    Install-Theme $lightSource 'pdf-light.css'
    Install-Theme $darkSource 'pdf-dark.css'

    Write-Host "`nDone. Add the VS Code User settings shown in README.md (if not already configured)." -ForegroundColor Cyan
    Write-Host 'Light CSSPath: ~/.config/Code/markdown-themes/pdf-light.css'
    Write-Host 'Dark CSSPath:  ~/.config/Code/markdown-themes/pdf-dark.css'
} catch {
    Write-Error "Installation failed: $($_.Exception.Message)" -ErrorAction Continue
    exit 1
}
