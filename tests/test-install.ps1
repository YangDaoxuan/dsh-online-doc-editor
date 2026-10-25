#requires -Version 7.0
param([string]$TestRoot=(Join-Path ([IO.Path]::GetTempPath()) ('dsh-skill-tests-'+[guid]::NewGuid().ToString('N'))))
$ErrorActionPreference='Stop'
$repo=Split-Path $PSScriptRoot -Parent
New-Item -ItemType Directory -Path $TestRoot|Out-Null
$passed=0
function Assert-True($Condition,[string]$Message){if(-not $Condition){throw $Message}}
function Expect-Failure([scriptblock]$Action){$failed=$false;try{&$Action}catch{$failed=$true};Assert-True $failed 'Expected refusal did not occur.'}

$fresh=Join-Path $TestRoot 'fresh-home'
& (Join-Path $repo 'install.ps1') -DshHome $fresh
$target=Join-Path $fresh 'skills/online-doc-editor'
New-Item -ItemType Directory -Path (Join-Path $fresh 'skills/unrelated') -Force|Out-Null
Set-Content -LiteralPath (Join-Path $fresh 'skills/unrelated/SKILL.md') -Value 'Keep this skill'
Assert-True (Test-Path -LiteralPath (Join-Path $target 'SKILL.md')) 'Initial install failed.'
Assert-True (Test-Path -LiteralPath (Join-Path $target '.online-doc-editor-install.json')) 'Install record missing.'
$passed++
$before=(Get-FileHash -LiteralPath (Join-Path $target 'SKILL.md')).Hash
& (Join-Path $repo 'install.ps1') -DshHome $fresh
Assert-True ($before -eq (Get-FileHash -LiteralPath (Join-Path $target 'SKILL.md')).Hash) 'Repeat install changed the skill.'
$passed++
& (Join-Path $repo 'uninstall.ps1') -DshHome $fresh
Assert-True (-not (Test-Path -LiteralPath $target)) 'Managed uninstall failed.'
Assert-True (Test-Path -LiteralPath (Join-Path $fresh 'skills/unrelated/SKILL.md')) 'Unrelated skill was removed.'
$passed++

$modified=Join-Path $TestRoot 'modified-home'
& (Join-Path $repo 'install.ps1') -DshHome $modified
$modifiedTarget=Join-Path $modified 'skills/online-doc-editor'
Add-Content -LiteralPath (Join-Path $modifiedTarget 'SKILL.md') -Value 'Local user edit'
$changed=(Get-FileHash -LiteralPath (Join-Path $modifiedTarget 'SKILL.md')).Hash
Expect-Failure {& (Join-Path $repo 'install.ps1') -DshHome $modified}
Expect-Failure {& (Join-Path $repo 'uninstall.ps1') -DshHome $modified}
Assert-True ($changed -eq (Get-FileHash -LiteralPath (Join-Path $modifiedTarget 'SKILL.md')).Hash) 'User edits were changed.'
$passed++

$foreign=Join-Path $TestRoot 'foreign-home'
$foreignTarget=Join-Path $foreign 'skills/online-doc-editor'
New-Item -ItemType Directory -Path $foreignTarget -Force|Out-Null
Set-Content -LiteralPath (Join-Path $foreignTarget 'SKILL.md') -Value 'Foreign manual install'
Expect-Failure {& (Join-Path $repo 'install.ps1') -DshHome $foreign}
Expect-Failure {& (Join-Path $repo 'uninstall.ps1') -DshHome $foreign}
Assert-True ((Get-Content -LiteralPath (Join-Path $foreignTarget 'SKILL.md') -Raw).Trim() -eq 'Foreign manual install') 'Foreign skill was changed.'
$passed++

$dry=Join-Path $TestRoot 'dry-run-home'
& (Join-Path $repo 'install.ps1') -DshHome $dry -WhatIf
Assert-True (-not (Test-Path -LiteralPath $dry)) 'WhatIf wrote files.'
$passed++
[pscustomobject]@{Passed=$passed;Failed=0;TestRoot=$TestRoot}|ConvertTo-Json
