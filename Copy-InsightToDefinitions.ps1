<#
.SYNOPSIS
    Copies the contents of Src/policyDefinitions/Insight to Definitions/policyDefintions/ (or policyDefinitions if typo is detected).

.DESCRIPTION
    Workspace-scoped helper to copy Insight policy definitions into the Definitions tree.
    - Supports optional mirroring (cleans destination before copy).
    - Auto-corrects the common destination folder typo "policyDefintions" to "policyDefinitions" by default when the correct folder exists.

.PARAMETER Source
    Source directory. Defaults to 'Src/policyDefinitions/Insight' relative to repo root.

.PARAMETER Destination
    Destination directory. Defaults to 'Definitions/policyDefintions' relative to repo root (as requested).

.PARAMETER Mirror
    If set, removes existing files/folders under the destination before copying.

.PARAMETER AutoCorrectTypo
    If true (default), when Destination contains 'policyDefintions' and a 'policyDefinitions' folder exists, copies to the correct folder instead.

.EXAMPLE
    ./Copy-InsightToDefinitions.ps1 -WhatIf

.EXAMPLE
    ./Copy-InsightToDefinitions.ps1 -Mirror

.NOTES
    Designed for PowerShell 7+ (pwsh) on macOS/Windows/Linux.
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [string]$Source = 'Src/policyDefinitions/Insight',
    [string]$Destination = 'Definitions/policyDefintions',
    [switch]$Mirror,
    [bool]$AutoCorrectTypo = $true
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-RepoPath {
    param([string]$RelativePath)
    # This script is placed in Scripts/Helpers, repo root is two levels up
    $repoRoot = (Get-Item $PSScriptRoot).Parent.Parent.FullName
    return (Join-Path $repoRoot $RelativePath)
}

# Resolve absolute paths
$srcPath = Resolve-RepoPath -RelativePath $Source
$dstPath = Resolve-RepoPath -RelativePath $Destination

# Auto-correct common typo if the correct folder exists
if ($AutoCorrectTypo -and ($dstPath -match 'policyDefintions')) {
    $corrected = $dstPath -replace 'policyDefintions', 'policyDefinitions'
    if (Test-Path (Split-Path -Parent $corrected)) {
        Write-Verbose "Destination contains common typo. Using corrected path: $corrected"
        $dstPath = $corrected
    }
}

if (-not (Test-Path -LiteralPath $srcPath)) {
    throw "Source path not found: $srcPath"
}

# Ensure destination exists (create if needed)
if (-not (Test-Path -LiteralPath $dstPath)) {
    if ($PSCmdlet.ShouldProcess($dstPath, 'Create destination directory')) {
        New-Item -ItemType Directory -Path $dstPath -Force | Out-Null
    }
}

# Optional mirror (clean destination contents first)
if ($Mirror.IsPresent -and (Test-Path -LiteralPath $dstPath)) {
    if ($PSCmdlet.ShouldProcess($dstPath, 'Mirror: remove existing contents')) {
        Get-ChildItem -LiteralPath $dstPath -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction Stop
    }
}

# Perform copy
$copySource = Join-Path $srcPath '*'
if ($PSCmdlet.ShouldProcess("$copySource -> $dstPath", 'Copy')) {
    Copy-Item -Path $copySource -Destination $dstPath -Recurse -Force
}

Write-Host "Copied: $srcPath -> $dstPath" -ForegroundColor Green
