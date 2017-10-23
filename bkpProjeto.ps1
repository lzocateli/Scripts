########################################################################################
# Compacta os arquivos da pasta atual, excluindo os arquivos conforme arquivo 
# bkpProjetos.txt
# Copia o arquivo compactado para a pasta de destino, utilizando BitsTransfer
########################################################################################
[CmdletBinding()] 
 
param ( 
        [Parameter(Mandatory = $true)] 
        [string] $destino) 


Import-Module BitsTransfer    
Clear-Host


$diretorioDeBackup = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$nomeArquivo = (Get-Item $diretorioDeBackup).Name
$arquivoDeExcecao = "bkpProjeto.txt"

$compactador = "C:\Program Files\7-Zip\7z"
$compactadorParametros = "a -t7z -mx=5 -mmt=on -xr@""$($arquivoDeExcecao)"" ""$($nomeArquivo).7z"" ""$($diretorioDeBackup)"""
$comando = "$($compactador) $($compactadorParametros)"

CD $diretorioDeBackup
Write-Host "Executando $($comando) ..."
$ps = new-object System.Diagnostics.Process
$ps.StartInfo.FileName = $compactador
$ps.StartInfo.Arguments = $compactadorParametros
$ps.StartInfo.WorkingDirectory = $diretorioDeBackup
$ps.StartInfo.RedirectStandardOutput = $true
$ps.StartInfo.RedirectStandardError = $true
$ps.StartInfo.UseShellExecute = $false

if (Test-Path "$($nomeArquivo).7z") {
    Remove-Item "$($nomeArquivo).7z"
}

if ($ps.Start() -eq $true) {
	Write-Host "Campactacao iniciada em $($ps.StartTime)"
	$ps.WaitForExit()
	Write-Host "Compactacao finalizada em $($ps.ExitTime)"
	$ps.StandardOutput.ReadToEnd()
	$ps.StandardError.ReadToEnd()
	$exiteCode = $ps.ExitCode 


    if (Test-Path "$($destino)") {
        Write-Host "Transferencia iniciada para " $($destino) 
        $bitsjob = Start-BitsTransfer -Source "$($nomeArquivo).7z" -Destination "$($destino)" -Asynchronous
        while ( ($bitsjob.JobState.ToString() -eq 'Transferring') -or ($bitsjob.JobState.ToString() -eq 'Connecting') ) {
           Write-Host $bitsjob.JobState.ToString()
           $proc = ($bitsjob.BytesTransferred / $bitsjob.BytesTotal) * 100
           Write-Host $proc "%"
           Start-Sleep 3
        }
        Complete-BitsTransfer -BitsJob $bitsjob
        Write-Host "Transferencia finalizada para " $($destino) 
    }
    else {
        Write-Host "Destino nao disponivel " $($destino) 
    }


} else { 
	Write-Host "Erro executando compactador."
} 
