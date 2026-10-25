#requires -Version 7.0
[CmdletBinding(SupportsShouldProcess)]
param([string]$DshHome=$(if($env:DSH_HOME){$env:DSH_HOME}else{Join-Path $env:USERPROFILE '.dsh'}))
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'scripts/package-utils.ps1')
$manifest=Read-ReleaseManifest $PSScriptRoot
$paths=Get-SkillTarget $DshHome
if(Test-Path -LiteralPath $paths.Target){
    if(Test-SkillTree $paths.Target $manifest.tree){Write-Output 'Skill already matches; no files changed.';return}
    throw 'A different or modified online-doc-editor already exists. Back it up and review it before replacing it; no files were changed.'
}
if(-not $PSCmdlet.ShouldProcess($paths.Target,'Install online-doc-editor skill')){return}
$source=Join-Path $PSScriptRoot 'skills/online-doc-editor'
$staging=Join-Path $paths.Parent ('.online-doc-editor-staging-'+[guid]::NewGuid().ToString('N'))
Assert-ScopedPath $staging $paths.Parent
Assert-ScopedPath $paths.Target $paths.Parent
try{
    New-Item -ItemType Directory -Path $staging -Force|Out-Null
    foreach($item in Get-ChildItem -LiteralPath $source -Force){Copy-Item -LiteralPath $item.FullName -Destination $staging -Recurse}
    if(-not (Test-SkillTree $staging $manifest.tree)){throw 'Staged skill verification failed.'}
    $record=@{package=$manifest.package;skill=$manifest.skill;version=$manifest.version;tree=$manifest.tree}
    $record|ConvertTo-Json -Depth 8|Set-Content -LiteralPath (Join-Path $staging '.online-doc-editor-install.json') -Encoding utf8NoBOM
    # Same-parent rename fails if the destination appeared concurrently; never nests or overwrites it.
    Rename-Item -LiteralPath $staging -NewName 'online-doc-editor'
    Write-Output ('Installed online-doc-editor '+$manifest.version+' at '+$paths.Target)
}finally{
    if(Test-Path -LiteralPath $staging){
        Assert-ScopedPath $staging $paths.Parent
        if(Test-RedirectingLink (Get-Item -LiteralPath $staging -Force)){throw 'Unexpected linked staging directory.'}
        Remove-Item -LiteralPath $staging -Recurse -Force
    }
}
