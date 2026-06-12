Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$envDir = Join-Path $repoRoot "infra\terraform\envs\dev"
$examplePath = Join-Path $envDir "dev.tfvars.example"
$devTfvarsPath = Join-Path $envDir "dev.tfvars"

if (-not (Test-Path -LiteralPath $examplePath)) {
  throw "Arquivo de exemplo nao encontrado: $examplePath"
}

if (-not (Test-Path -LiteralPath $devTfvarsPath)) {
  Copy-Item -LiteralPath $examplePath -Destination $devTfvarsPath
  Write-Host "[Mercantis] dev.tfvars criado a partir de dev.tfvars.example."
} else {
  Write-Host "[Mercantis] dev.tfvars ja existe. Nenhum valor local foi sobrescrito."
}

Write-Host ""
Write-Host "[Mercantis] Edite o arquivo local abaixo e substitua somente o valor de db_password."
Write-Host "[Mercantis] Nao informe a senha em prompt, README, commit ou arquivo versionado."
Write-Host "[Mercantis] Caminho: $devTfvarsPath"

Start-Process notepad.exe -ArgumentList "`"$devTfvarsPath`""
