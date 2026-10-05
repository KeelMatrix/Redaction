[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PackagePath
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$packageProjectDirectory = Join-Path $repositoryRoot 'src/KeelMatrix.Redaction'
$packageProjectPath = Join-Path $packageProjectDirectory 'KeelMatrix.Redaction.csproj'
$sharedTargetsPath = Join-Path $repositoryRoot 'Directory.Build.targets'
$manifestPath = Join-Path $repositoryRoot 'keelmatrix.website.json'
$expectedRepositoryUrl = 'https://github.com/KeelMatrix/Redaction'

function Stop-Validation([string]$Message) {
    throw "Website package metadata validation failed: $Message"
}

function Get-ProjectProperty([xml]$Project, [xml]$SharedTargets, [string]$Name) {
    $projectNode = $Project.SelectSingleNode("/Project/PropertyGroup/$Name")
    if ($null -ne $projectNode -and -not [string]::IsNullOrWhiteSpace($projectNode.InnerText)) {
        return $projectNode.InnerText.Trim()
    }

    $sharedNode = $SharedTargets.SelectSingleNode("/Project/PropertyGroup/$Name")
    if ($null -ne $sharedNode) {
        return $sharedNode.InnerText.Trim()
    }

    return ''
}

function Get-MetadataValue([xml]$Nuspec, [string]$Name) {
    $node = $Nuspec.SelectSingleNode("/*[local-name()='package']/*[local-name()='metadata']/*[local-name()='$Name']")
    if ($null -eq $node) {
        return ''
    }

    return $node.InnerText.Trim()
}

function Get-WebsiteSentinels([string[]]$Tags, [string]$PackageId) {
    $allowed = @(
        'keelmatrix-public-product',
        'keelmatrix-internal-package',
        'keelmatrix-primary',
        'keelmatrix-component'
    )
    $websiteTags = @($Tags | Where-Object { $_ -match '^keelmatrix-' })
    foreach ($tag in $websiteTags) {
        if ($allowed -cnotcontains $tag) {
            Stop-Validation "Package '$PackageId' contains an unknown or incorrectly cased website tag '$tag'."
        }
    }

    $visibilityTags = @($websiteTags | Where-Object { $_ -cmatch '^keelmatrix-(public-product|internal-package)$' })
    $roleTags = @($websiteTags | Where-Object { $_ -cmatch '^keelmatrix-(primary|component)$' })
    if ($visibilityTags.Count -ne 1 -or $roleTags.Count -ne 1) {
        Stop-Validation "Package '$PackageId' must contain exactly one visibility sentinel and one role sentinel."
    }

    return [pscustomobject]@{
        Visibility = $visibilityTags[0]
        Role = $roleTags[0]
    }
}

if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
    Stop-Validation 'Root keelmatrix.website.json is missing.'
}
if (-not (Test-Path -LiteralPath $packageProjectPath -PathType Leaf)) {
    Stop-Validation 'The Redaction package project is missing.'
}
if (-not (Test-Path -LiteralPath $sharedTargetsPath -PathType Leaf)) {
    Stop-Validation 'Directory.Build.targets is missing.'
}

try {
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json -AsHashtable
}
catch {
    Stop-Validation "The root manifest is invalid JSON: $($_.Exception.Message)"
}

$rootKeys = @($manifest.Keys)
if ($rootKeys.Count -ne 2 -or -not ($rootKeys -ccontains 'schemaVersion') -or -not ($rootKeys -ccontains 'packages')) {
    Stop-Validation 'The manifest root must contain only schemaVersion and packages.'
}
if ($manifest.schemaVersion -ne 1) {
    Stop-Validation 'The manifest schemaVersion must be 1.'
}
if ($manifest.packages -isnot [System.Collections.IDictionary] -or $manifest.packages.Count -eq 0) {
    Stop-Validation 'The manifest packages value must be a non-empty object.'
}

$projectXml = [xml][System.IO.File]::ReadAllText($packageProjectPath)
$sharedTargetsXml = [xml][System.IO.File]::ReadAllText($sharedTargetsPath)
if ((Get-ProjectProperty $projectXml $sharedTargetsXml 'IsPackable') -ceq 'false') {
    Stop-Validation 'The Redaction project must remain packable.'
}

$sourceProjects = @(Get-ChildItem -LiteralPath (Join-Path $repositoryRoot 'src') -Filter '*.csproj' -File -Recurse)
foreach ($sourceProject in $sourceProjects) {
    if ([System.IO.Path]::GetFullPath($sourceProject.FullName) -eq [System.IO.Path]::GetFullPath($packageProjectPath)) {
        continue
    }

    $candidateXml = [xml][System.IO.File]::ReadAllText($sourceProject.FullName)
    if ((Get-ProjectProperty $candidateXml $sharedTargetsXml 'IsPackable') -cne 'false') {
        Stop-Validation "Packable project '$($sourceProject.FullName)' is not covered by this metadata check."
    }
}

$packageId = Get-ProjectProperty $projectXml $sharedTargetsXml 'PackageId'
if ([string]::IsNullOrWhiteSpace($packageId)) {
    Stop-Validation 'The packable project must declare PackageId.'
}
$manifestIds = @($manifest.packages.Keys)
if ($manifestIds.Count -ne 1 -or -not ($manifestIds -ccontains $packageId)) {
    Stop-Validation "The manifest must classify exactly the repository package '$packageId'."
}

$entry = $manifest.packages[$packageId]
if ($entry -isnot [System.Collections.IDictionary]) {
    Stop-Validation "Manifest entry '$packageId' must be an object."
}
$entryKeys = @($entry.Keys)
if ($entryKeys.Count -ne 2 -or -not ($entryKeys -ccontains 'visibility') -or -not ($entryKeys -ccontains 'role')) {
    Stop-Validation "Manifest entry '$packageId' must contain only visibility and role."
}
if (@('public-product', 'internal-package') -cnotcontains [string]$entry.visibility) {
    Stop-Validation "Manifest entry '$packageId' has an unsupported visibility classification."
}
if (@('primary', 'component') -cnotcontains [string]$entry.role) {
    Stop-Validation "Manifest entry '$packageId' has an unsupported artifact role."
}
if ($entry.visibility -ceq 'public-product' -and $entry.role -cne 'primary') {
    Stop-Validation "The public product family must have one primary package; '$packageId' is its only package."
}

$description = Get-ProjectProperty $projectXml $sharedTargetsXml 'Description'
$authors = Get-ProjectProperty $projectXml $sharedTargetsXml 'Authors'
$projectUrl = Get-ProjectProperty $projectXml $sharedTargetsXml 'PackageProjectUrl'
$repositoryUrl = Get-ProjectProperty $projectXml $sharedTargetsXml 'RepositoryUrl'
$repositoryType = Get-ProjectProperty $projectXml $sharedTargetsXml 'RepositoryType'
$license = Get-ProjectProperty $projectXml $sharedTargetsXml 'PackageLicenseExpression'
$readme = Get-ProjectProperty $projectXml $sharedTargetsXml 'PackageReadmeFile'
$packAsTool = Get-ProjectProperty $projectXml $sharedTargetsXml 'PackAsTool'
$packageType = Get-ProjectProperty $projectXml $sharedTargetsXml 'PackageType'
$tagText = Get-ProjectProperty $projectXml $sharedTargetsXml 'PackageTags'

if ([string]::IsNullOrWhiteSpace($description)) { Stop-Validation 'The package description is missing.' }
if ($authors -cne 'KeelMatrix') { Stop-Validation "Package '$packageId' must identify KeelMatrix as its author." }
if ($projectUrl -cne $expectedRepositoryUrl) { Stop-Validation "PackageProjectUrl must be '$expectedRepositoryUrl'." }
if ($repositoryUrl -cne $expectedRepositoryUrl) { Stop-Validation "RepositoryUrl must be '$expectedRepositoryUrl'." }
if ($repositoryType -cne 'git') { Stop-Validation "RepositoryType must be 'git'." }
if ([string]::IsNullOrWhiteSpace($license)) { Stop-Validation 'The package license expression is missing.' }
if ($readme -cne 'README.md' -or -not (Test-Path -LiteralPath (Join-Path $packageProjectDirectory $readme) -PathType Leaf)) {
    Stop-Validation 'PackageReadmeFile must resolve to the project README.md.'
}
if ($packAsTool -ceq 'true' -or ($packageType -and $packageType -cne 'Dependency')) {
    Stop-Validation "Package '$packageId' must remain a Dependency package, not a .NET tool or another package type."
}

$tags = @($tagText -split '[;\s,]+' | Where-Object { $_ })
$sentinels = Get-WebsiteSentinels $tags $packageId
$expectedVisibilityTag = if ($entry.visibility -ceq 'public-product') { 'keelmatrix-public-product' } else { 'keelmatrix-internal-package' }
$expectedRoleTag = if ($entry.role -ceq 'primary') { 'keelmatrix-primary' } else { 'keelmatrix-component' }
if ($sentinels.Visibility -cne $expectedVisibilityTag -or $sentinels.Role -cne $expectedRoleTag) {
    Stop-Validation "PackageTags for '$packageId' disagree with keelmatrix.website.json."
}

$resolvedPackagePath = (Resolve-Path -LiteralPath $PackagePath).Path
if (Test-Path -LiteralPath $resolvedPackagePath -PathType Container) {
    $packageFiles = @(Get-ChildItem -LiteralPath $resolvedPackagePath -Filter "$packageId.*.nupkg" -File)
    if ($packageFiles.Count -ne 1) {
        Stop-Validation "Expected exactly one '$packageId' .nupkg in '$resolvedPackagePath'; found $($packageFiles.Count)."
    }
    $resolvedPackagePath = $packageFiles[0].FullName
}
if (-not [System.IO.Path]::GetFileName($resolvedPackagePath).StartsWith("$packageId.", [System.StringComparison]::OrdinalIgnoreCase) -or
    -not $resolvedPackagePath.EndsWith('.nupkg', [System.StringComparison]::OrdinalIgnoreCase)) {
    Stop-Validation 'PackagePath must identify the generated .nupkg, not a symbol package.'
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::OpenRead($resolvedPackagePath)
try {
    $nuspecEntries = @($archive.Entries | Where-Object { $_.FullName.EndsWith('.nuspec', [System.StringComparison]::OrdinalIgnoreCase) })
    if ($nuspecEntries.Count -ne 1) { Stop-Validation 'The package must contain exactly one .nuspec file.' }
    $stream = $nuspecEntries[0].Open()
    try {
        $nuspecXml = [xml]::new()
        $nuspecXml.Load($stream)
    }
    finally {
        $stream.Dispose()
    }

    $nuspecId = Get-MetadataValue $nuspecXml 'id'
    $nuspecDescription = Get-MetadataValue $nuspecXml 'description'
    $nuspecProjectUrl = Get-MetadataValue $nuspecXml 'projectUrl'
    $nuspecAuthors = Get-MetadataValue $nuspecXml 'authors'
    $nuspecTagText = Get-MetadataValue $nuspecXml 'tags'
    $nuspecTags = @($nuspecTagText -split '\s+' | Where-Object { $_ })
    $repositoryNode = $nuspecXml.SelectSingleNode("/*[local-name()='package']/*[local-name()='metadata']/*[local-name()='repository']")
    $nuspecRepositoryUrl = if ($null -ne $repositoryNode) { $repositoryNode.GetAttribute('url') } else { '' }
    $nuspecRepositoryType = if ($null -ne $repositoryNode) { $repositoryNode.GetAttribute('type') } else { '' }

    if ($nuspecId -cne $packageId) { Stop-Validation 'The packed NuGet ID does not match the project and manifest.' }
    if ($nuspecDescription -cne $description) { Stop-Validation 'The packed description does not match the project description.' }
    if ($nuspecProjectUrl -cne $expectedRepositoryUrl) { Stop-Validation 'The packed project URL is not the canonical Redaction repository URL.' }
    if ($nuspecRepositoryUrl -cne $expectedRepositoryUrl -or $nuspecRepositoryType -cne 'git') {
        Stop-Validation 'The packed repository metadata must point to the canonical Redaction git repository.'
    }
    if ($nuspecAuthors -cne 'KeelMatrix') { Stop-Validation 'The packed authors field must be KeelMatrix.' }
    $packedSentinels = Get-WebsiteSentinels $nuspecTags $packageId
    if ($packedSentinels.Visibility -cne $expectedVisibilityTag -or $packedSentinels.Role -cne $expectedRoleTag) {
        Stop-Validation 'The packed NuGet sentinels disagree with the manifest.'
    }

    $packageTypesNode = $nuspecXml.SelectSingleNode("/*[local-name()='package']/*[local-name()='metadata']/*[local-name()='packageTypes']")
    if ($null -ne $packageTypesNode) {
        $packageTypeNames = @($packageTypesNode.SelectNodes("./*[local-name()='packageType']") | ForEach-Object { $_.GetAttribute('name') })
        if ($packageTypeNames.Count -ne 1 -or $packageTypeNames[0] -cne 'Dependency') {
            Stop-Validation 'The packed NuGet package type must be Dependency.'
        }
    }

    $packedReadme = Get-MetadataValue $nuspecXml 'readme'
    if ($packedReadme -cne $readme -or -not (@($archive.Entries | ForEach-Object { $_.FullName }) -ccontains $readme)) {
        Stop-Validation 'The packed package must declare and include its project README.'
    }
}
finally {
    $archive.Dispose()
}

Write-Output "Website metadata validated for $packageId ($expectedVisibilityTag, $expectedRoleTag, Dependency)."