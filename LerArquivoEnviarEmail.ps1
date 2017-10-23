#######################################################################################
# Objetivo: Lê um determinado arquivo, gera um array com as colunas dessa arquivo.
# verifica se na posição 18 do array se é igual a variavel CodigoRetorno, se for, grava
# um log com a rejeição.
# Caso não for rejeitado, envia o arquivo por email
#######################################################################################
Function Write-Log {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$False)]
    [ValidateSet("INFO","WARN","ERROR","FATAL","DEBUG")]
    [String]
    $Level = "INFO",

    [Parameter(Mandatory=$True)]
    [string]
    $Message,

    [Parameter(Mandatory=$False)]
    [string]
    $logfile
    )

    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $Line = "$Stamp $Level $Message"
    If($logfile) {
        Add-Content $logfile -Value $Line
    }
    Else {
        Write-Output $Line
    }
}

Function VerificaRejeicao {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True)]
    [string]
    $ArquivoRetorno,

    [Parameter(Mandatory=$True)]
    [string]
    $codigoRetorno
    )


    $rejeitou = 0
    $linhasArquivo = (Get-Content -Path $ArquivoRetorno | Measure-Object -Line).Lines
    For ($i=0; $i -le $linhasArquivo; $i++) 
    {
        $linhaArq = Get-Content -Path $ArquivoRetorno | Select-Object -Index $i
        if ($linhaArq -eq $null)
        {
            return 0
        }

        $arr = $linhaArq -split ','
        $colunaS = $arr[18]
        $colunaS = $colunaS -replace "\""", ""

        if ($colunaS -eq $codigoRetorno)
        {
           $rejeitou = $i +1
           return $rejeitou
        }

        $rejeitou = 0
    }

    return $rejeitou
}

Clear-Host
$pathSkyline = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$diretorio = "$pathSkyline\inbound\"
$arquivos = (Get-ChildItem -Path $diretorio -Filter 'MEUARQ*.RET' -Force)
$nroArquivos = $arquivos.Count


if ($arquivos.Count -gt 0)
{
    $Logfile = "$pathSkyline\$(gc env:computername).log"
}
else
{
    $Logfile = "$pathSkyline\$(gc env:computername)_temp.log"
    Remove-Item -Path $Logfile -Force
}


Write-Log "INFO" "Inicio do processamento. $pathSkyline" $Logfile
Write-Log "INFO" "Arquivos: $diretorio [ $nroArquivos ]" $Logfile


if ($arquivos.Count -gt 0)
{

    $SMTPServer = “Smtp.gmail.com”
    $Username = “Lincoln Zocateli”

    if ($env:COMPUTERNAME -eq 'MAQUINA01')
    {
        $to = “Teste <lincoln.zocateli@gmail.com>"
    }
    else
    {
        $to = “Fulano de Tal <fulano@seila.com.br>", "Bertrano <bertrano@citi.com>"
    }
    $cc = "Contas a Pagar <contas_a_pagar@gmail.com>”,“Lincoln <jose.silva@yahoo.com>"
    $subject = “Comunicado de documentos a pagar”
    $body = “Segue arquivo anexo.”


    foreach ($arquivo in $arquivos)  
    { 

        $linhaRejeitada = VerificaRejeicao "$($diretorio)\$($arquivo)" "R"
        if ($linhaRejeitada -eq 0)
        {

            Try 
            {

                $attachment = "$($diretorio)\$($arquivo)"
   
                Send-MailMessage -To $to -Cc $cc -from $Username -Subject $subject -Body $body -Verbose -SmtpServer $SMTPServer -Attachments $attachment -ErrorVariable mensagemErro -OutVariable out
                
                if (!$mensagemErro)
                {
                    Write-Log "INFO" "E-mail enviado. $attachment $out " $Logfile
                    Rename-Item -Path $attachment -NewName "$($attachment).sent" -Force
                    
                }
                else
                {
                    Write-Log "ERROR" "Arquivo [$($diretorio)\$($arquivo)] $mensagemErro " $Logfile
                }

            }
            Catch 
            {
                $mensagemErro = $_.Exception.Message
                Write-Log "ERROR" "Arquivo [$($diretorio)\$($arquivo)] erro no envio de email: $mensagemErro " $Logfile
            }
        }
        else
        {
            Write-Log "WARN" "Arquivo [$($diretorio)\$($arquivo)] possui rejeição na linha $linhaRejeitada" $Logfile
        }

    }

}
else
{
    Write-Log "INFO" "Não há arquivo para enviar" $Logfile
}

Write-Log "INFO" "Fim do processamento." $Logfile