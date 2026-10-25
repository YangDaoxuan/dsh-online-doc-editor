#requires -Version 7.0
[CmdletBinding(SupportsShouldProcess)]
param([string]$DshHome=$(if($env:DSH_HOME){$env:DSH_HOME}else{Join-Path $env:USERPROFILE '.dsh'}))
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'scripts/package-utils.ps1')
$paths=Get-SkillTarget $DshHome
if(-not (Test-Path -LiteralPath $paths.Target)){Write-Output 'Skill is not installed; no files changed.';return}
$recordPath=Join-Path $paths.Target '.online-doc-editor-install.json'
if(-not (Test-Path -LiteralPath $recordPath -PathType Leaf)){throw 'No matching installer record; this script will not remove a manually installed skill.'}
if(Test-RedirectingLink (Get-Item -LiteralPath $recordPath -Force)){throw 'Linked installer records are not supported.'}
$record=Get-Content -LiteralPath $recordPath -Raw|ConvertFrom-Json -AsHashtable
if($record.package -ne 'dsh-online-doc-editor' -or $record.skill -ne 'online-doc-editor'){throw 'Unexpected installer record.'}
if(-not (Test-SkillTree $paths.Target $record.tree)){throw 'Skill files changed after installation; preserve or back them up manually. Nothing was removed.'}
if($PSCmdlet.ShouldProcess($paths.Target,'Remove unchanged installer-managed skill')){
    Assert-ScopedPath $paths.Target $paths.Parent
    Remove-Item -LiteralPath $paths.Target -Recurse -Force
    Write-Output 'Installer-managed skill removed. Other skills and configuration were preserved.'
}
