#Requires -Version 5.1
<#
.SYNOPSIS
    Deploy Copilot skills/instructions to their target workspace, or harvest live files back into this repo.

.PARAMETER Workspace
    Absolute path to the target workspace root (the folder containing .github/).
    Defaults to E:\agent_workspace if not specified.

.PARAMETER Harvest
    Reverse direction: pull live Copilot files FROM the target workspace INTO this repo.

.EXAMPLE
    .\sync.ps1                                          # deploy to default workspace
    .\sync.ps1 -Workspace "C:\Projects\MyRepo"         # deploy to specific workspace
    .\sync.ps1 -Harvest                                 # harvest from default workspace
    .\sync.ps1 -Harvest -Workspace "C:\Projects\MyRepo"
#>
param(
    [string]$Workspace = "E:\agent_workspace",
    [switch]$Harvest
)

$ErrorActionPreference = 'Stop'

$ROOT          = $PSScriptRoot
$SRC_PROMPTS   = Join-Path $ROOT ".github\prompts"
$SRC_INSTRUCT  = Join-Path $ROOT ".github\instructions"
$SRC_MAIN      = Join-Path $ROOT ".github\copilot-instructions.md"

$DST_PROMPTS   = Join-Path $Workspace ".github\prompts"
$DST_INSTRUCT  = Join-Path $Workspace ".github\instructions"
$DST_MAIN      = Join-Path $Workspace ".github\copilot-instructions.md"

function Sync-Dir {
    param([string]$Src, [string]$Dst, [string]$Label)
    if (-not (Test-Path $Src)) { Write-Host "  [SKIP] $Label source not found: $Src"; return }
    if (-not (Test-Path $Dst)) { New-Item -ItemType Directory -Path $Dst -Force | Out-Null }
    $files = Get-ChildItem -Path $Src -Filter "*.md" -File
    if ($files.Count -eq 0) { Write-Host "  [SKIP] $Label — no .md files in $Src"; return }
    foreach ($f in $files) {
        Copy-Item -Path $f.FullName -Destination (Join-Path $Dst $f.Name) -Force
        Write-Host "  [COPY] $Label  $($f.Name)"
    }
    Write-Host "  [DONE] $Label — $($files.Count) file(s) -> $Dst"
}

function Harvest-Dir {
    param([string]$Src, [string]$Dst, [string]$Label)
    if (-not (Test-Path $Src)) { Write-Host "  [SKIP] $Label live dir not found: $Src"; return }
    if (-not (Test-Path $Dst)) { New-Item -ItemType Directory -Path $Dst -Force | Out-Null }
    $files = Get-ChildItem -Path $Src -Filter "*.md" -File
    if ($files.Count -eq 0) { Write-Host "  [SKIP] $Label — no .md files in $Src"; return }
    foreach ($f in $files) {
        Copy-Item -Path $f.FullName -Destination (Join-Path $Dst $f.Name) -Force
        Write-Host "  [PULL] $Label  $($f.Name)"
    }
    Write-Host "  [DONE] $Label — $($files.Count) file(s) <- $Src"
}

if ($Harvest) {
    Write-Host "`nHarvesting live Copilot files into repo...`n"
    if (Test-Path $DST_MAIN) {
        Copy-Item -Path $DST_MAIN -Destination $SRC_MAIN -Force
        Write-Host "  [PULL] root  copilot-instructions.md"
    }
    Harvest-Dir $DST_PROMPTS  $SRC_PROMPTS  "prompts"
    Harvest-Dir $DST_INSTRUCT $SRC_INSTRUCT "instructions"
    Write-Host "`nHarvest complete. Review changes with: git diff`n"
} else {
    Write-Host "`nDeploying Copilot skills to: $Workspace`n"
    $dstGithub = Join-Path $Workspace ".github"
    if (-not (Test-Path $dstGithub)) { New-Item -ItemType Directory -Path $dstGithub -Force | Out-Null }
    if (Test-Path $SRC_MAIN) {
        Copy-Item -Path $SRC_MAIN -Destination $DST_MAIN -Force
        Write-Host "  [COPY] root  copilot-instructions.md -> $DST_MAIN"
    }
    Sync-Dir $SRC_PROMPTS  $DST_PROMPTS  "prompts"
    Sync-Dir $SRC_INSTRUCT $DST_INSTRUCT "instructions"
    Write-Host "`nDeploy complete.`n"
    Write-Host "Files are now live in: $Workspace\.github\"
    Write-Host "Copilot will pick them up automatically in VS Code.`n"
}
