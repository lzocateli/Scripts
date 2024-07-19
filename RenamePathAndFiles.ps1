
<#PSScriptInfo

.VERSION 1.0

.GUID f74f6a57-bbd4-4d24-8906-3e3e93a559c2

.AUTHOR lincoln@zocate.li

.COMPANYNAME Lincoln Zocateli

.COPYRIGHT ©2024, Lincoln Zocateli. Todos os direitos reservados.

.TAGS Rename, Files, Folders, Content

.LICENSEURI https://github.com/lzocateli/Scripts?tab=MIT-1-ov-file#readme

.PROJECTURI https://github.com/lzocateli/Scripts

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>

<#
.SYNOPSIS
Este script renomeia pastas, subpastas e arquivos, e substitui o conteúdo dos arquivos.
This script renames folders, subfolders and files, and replaces the contents of the files.
use: Get-Help .\RenamePathAndFiles.ps1

.DESCRIPTION
O script recebe tres parâmetros, pathName, sourceName e targetName. Ele procura por pastas, subpastas e arquivos que começam com sourceName e os renomeia para começar com targetName. Além disso, ele substitui qualquer conteúdo de arquivo que comece com sourceName por targetName.
Rename folders, subfolders, files and file contents that match the given parameters 
The script receives three parameters, pathName, sourceName and targetName. It looks for folders, subfolders, and files that start with sourceName and renames them to start with targetName. Additionally, it replaces any file contents that begin with sourceName with targetName.

.PARAMETER pathName
A pasta raiz do seu projeto, onde normalmente esta a solution.
The root folder of your project, where the solution is normally located.

.PARAMETER sourceName
O nome original que você deseja alterar.
The original name you want to change.

.PARAMETER targetName
O novo nome que você deseja usar em vez do nome original.
The new name you want to use instead of the original name.

.EXAMPLE
.\RenamePathAndFiles.ps1 -pathName C:/Projetos/TemplateDotnetWorker -sourceName "CBL.Template.NomeProcesso" -targetName "CBL.Projeto.Processo"
#>

param(
    [Parameter(Mandatory=$true, HelpMessage="Qual o nome da pasta raiz do projeto (onde esta a solution).")]
    [string]$pathName,

    [Parameter(Mandatory=$true, HelpMessage="Insira o nome original que você deseja alterar.")]
    [string]$sourceName,
    
    [Parameter(Mandatory=$true, HelpMessage="Insira o novo nome que você deseja usar em vez do nome original.")]
    [string]$targetName
)


Clear-Host


$osLanguage = (Get-Culture).Name

$messages = @{
    "en-US" = @{
        "Help_pathName" = "What is the name of the project's root folder (where the solution is located)."
        "Help_sourceName" = "Enter the original name you want to change."
        "Help_targetName" = "Enter the new name you want to use instead of the original name."
        "UpdatingFileContent" = "Updating file content in: "
        "RenamingFolders" = "Renaming folders and subfolders in: "
        "RenamingFiles" = "Renaming files in: "
        "RenamingSolution" = "Renaming solution in: "
        "Completed" = "Completed."
        "ErrorDeterminingSolutionName" = "Could not determine the name of the new solution"
        "NoSlnFilesFound" = "No .sln files found in directory "
        "FileRenamedTo" = "File renamed to "
    }
    "pt-BR" = @{
        "Help_pathName" = "Qual o nome da pasta raiz do projeto (onde esta a solution)."
        "Help_sourceName" = "Insira o nome original que você deseja alterar."
        "Help_targetName" = "Insira o novo nome que você deseja usar em vez do nome original."
        "UpdatingFileContent" = "Atualizando conteudo dos arquivos em: "
        "RenamingFolders" = "Renomeando pastas e subpastas em: "
        "RenamingFiles" = "Renomeando arquivos em: "
        "RenamingSolution" = "Renomeando solution em: "
        "Completed" = "Concluido."
        "ErrorDeterminingSolutionName" = "Não foi possivel determinar o nome da nova soluction"
        "NoSlnFilesFound" = "Nenhum arquivo .sln encontrado no diretório "
        "FileRenamedTo" = "Arquivo renomeado para "
    }
}


if ($osLanguage -eq "pt-BR") {
    $msg = $messages["pt-BR"]
} else {
    $msg = $messages["en-US"]
}



function Update-FileContent {
    param(
        [string]$pathName,
        [string]$sourceName,
        [string]$targetName
    )

    try {
        Write-Host "$($msg["UpdatingFileContent"]) $pathName ..."
        Get-ChildItem -Path $pathName -Recurse -File | ForEach-Object {
            (Get-Content $_.FullName) | ForEach-Object { 
                $_ -replace [regex]::Escape($sourceName), $targetName 
            } | Set-Content $_.FullName
        }
    }
    catch {
        $Error[0] | Format-List -Force
        break
    }
}




try {
    Write-Host "$($msg["RenamingFolders"]) $pathName ..."
    Get-ChildItem -Path $pathName -Recurse -Directory | Where-Object { $_.Name -like "$sourceName*" } | ForEach-Object {
        $newName = $_.FullName -replace [regex]::Escape($sourceName), $targetName
        Rename-Item -Path $_.FullName -NewName $newName -Force
    }
    
}
catch {
    $Error[0] | Format-List -Force
    break
}

$newSoluction = ""

try {
    Write-Host "$($msg["RenamingFiles"]) $pathName ..."
    Get-ChildItem -Path $pathName -Recurse -File | Where-Object { $_.Name -like "$sourceName*" } | ForEach-Object {
        $newName = $_.FullName -replace [regex]::Escape($sourceName), $targetName
        if ($_.FullName.EndsWith("Worker.csproj")) {
            $newSoluction = $targetName.Replace("CBL.","").Replace(".","")
            $newSoluction += "Worker"
        }
        elseif ($_.FullName.EndsWith("Api.csproj")) {
            $newSoluction = $targetName.Replace("CBL.","").Replace(".","")
            $newSoluction += "Api"
        }
        elseif ($_.FullName.EndsWith("UI.csproj")) {
            $newSoluction = $targetName.Replace("CBL.","").Replace(".","")
            $newSoluction += "UI"
        }
        Rename-Item -Path $_.FullName -NewName $newName -Force
    }
}
catch {
    $Error[0] | Format-List -Force
    break
}


Update-FileContent -pathName $pathName -sourceName $sourceName -targetName $targetName


if ([string]::IsNullOrWhiteSpace($newSoluction)) {
    Write-Error "$($msg["ErrorDeterminingSolutionName"])"
}
else {
    Write-Host "$($msg["RenamingSolution"]) $pathName ..."

    $files = Get-ChildItem -Path $pathName -Filter *.sln

    if ($files) {
        foreach ($file in $files) {
            $newPathSolution = Join-Path -Path $pathName -ChildPath $newSoluction
            Rename-Item -Path $file.FullName -NewName "$newPathSolution.sln" -Force
            Write-Output "$($msg["FileRenamedTo"]) $newPathSolution.sln"

            $fileNameOnly = [System.IO.Path]::GetFileName($file.FullName).Replace(".sln", "")
            $newFileSolution = [System.IO.Path]::GetFileName($newPathSolution)

            Update-FileContent -pathName $pathName -sourceName $fileNameOnly -targetName $newFileSolution
        }

    } else {
        Write-Output "$($msg["NoSlnFilesFound"]) $pathName"
    }
}

Write-Host "$($msg["Completed"])"
