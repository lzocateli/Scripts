####################################################################
# Altera o arquivo web.config durante uma publicacao
####################################################################
Clear-Host

$diretorioDoProjeto = $Env:BUILD_SOURCESDIRECTORY


CD $diretorioDoProjeto
Write-Host "Alterando web.config..."

$webConfig = "$($diretorioDoProjeto)\src\CBL.PenfWebApi.WebApi\web.config"
$doc = (Get-Content $webConfig) -as [Xml]
$obj = $doc.configuration.'system.webServer'.aspNetCore.environmentVariables.environmentVariable | where {$_.name -eq 'ASPNETCORE_ENVIRONMENT'}
$obj.value = 'Staging'
 
$doc.Save($webConfig)

Write-Host "Concluido."