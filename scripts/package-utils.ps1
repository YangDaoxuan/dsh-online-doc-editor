#requires -Version 7.0
Set-StrictMode -Version Latest

function Test-RedirectingLink {
    param($Item)
    # Cloud-sync directories may carry ReparsePoint without redirecting their path.
    $linkType=$Item.PSObject.Properties['LinkType']
    return ($null -ne $linkType -and $linkType.Value -in @('SymbolicLink','Junction'))
}

function Assert-ScopedPath {
    param([string]$Path,[string]$Parent)
    $resolvedPath=[IO.Path]::GetFullPath($Path)
    $resolvedParent=[IO.Path]::GetFullPath($Parent).TrimEnd([IO.Path]::DirectorySeparatorChar)+[IO.Path]::DirectorySeparatorChar
    if(-not $resolvedPath.StartsWith($resolvedParent,[StringComparison]::OrdinalIgnoreCase)){
        throw 'Target path is outside the expected directory.'
    }
}

function Get-SkillTarget {
    param([string]$DshHome)
    if([string]::IsNullOrWhiteSpace($DshHome)){throw 'DshHome cannot be empty.'}
    $root=[IO.Path]::GetFullPath($DshHome)
    $parent=Join-Path $root 'skills'
    $target=Join-Path $parent 'online-doc-editor'
    Assert-ScopedPath $target $parent
    # Refuse linked parents rather than resolving an operation outside its declared root.
    $cursor=$target
    while($cursor){
        if(Test-Path -LiteralPath $cursor){
            $item=Get-Item -LiteralPath $cursor -Force
            if(Test-RedirectingLink $item){throw 'Linked destination paths require manual installation.'}
        }
        $next=[IO.Path]::GetDirectoryName($cursor.TrimEnd([IO.Path]::DirectorySeparatorChar))
        if($next -eq $cursor){break}; $cursor=$next
    }
    return @{Parent=$parent;Target=$target}
}

function Get-SkillTree {
    param([string]$Root)
    if(-not (Test-Path -LiteralPath $Root -PathType Container)){throw 'Skill directory is missing.'}
    $items=@(Get-ChildItem -LiteralPath $Root -Force -Recurse)
    $entries=foreach($item in $items){
        if(Test-RedirectingLink $item){throw 'Linked skill files are not supported.'}
        $relative=[IO.Path]::GetRelativePath($Root,$item.FullName).Replace('\','/')
        if($relative -eq '.online-doc-editor-install.json'){continue}
        if($item.PSIsContainer){'D:'+ $relative}
        else{'F:'+ $relative + ':' + (Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash.ToLowerInvariant()}
    }
    return @($entries|Sort-Object)
}

function Test-SkillTree {
    param([string]$Root,[string[]]$Expected)
    $actual=@(Get-SkillTree $Root)
    return ($actual.Count -eq $Expected.Count -and -not (Compare-Object -ReferenceObject $Expected -DifferenceObject $actual))
}

function Read-ReleaseManifest {
    param([string]$RepositoryRoot)
    $manifest=Get-Content -LiteralPath (Join-Path $RepositoryRoot 'skill-manifest.json') -Raw|ConvertFrom-Json -AsHashtable
    if($manifest.package -ne 'dsh-online-doc-editor' -or $manifest.skill -ne 'online-doc-editor'){throw 'Unexpected skill manifest.'}
    $source=Join-Path $RepositoryRoot 'skills/online-doc-editor'
    if(-not (Test-SkillTree $source $manifest.tree)){throw 'Skill source differs from the release manifest. Rebuild the manifest after reviewing changes.'}
    return $manifest
}
