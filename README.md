# Scripts
PowerShell, Oracle, SqlServer scripts

- bkpProjeto
    Execute: bkpProjeto.bat 
             Será executado o arquivo .ps1, que ira compactar arquivos e pastas do diretorio atual, excluindo
             arquivos/pastas contidos no arquivo de configuração bkpProjeto.txt
             Depois, copia o arquivo compactado para uma pasta de rede, utilizando a biblioteca BitsTransfer

- CopiarComRobocopy
    Execute: CopiarComRobocopy.bat
             Será copiado arquivos da origem para o destino com robocopy, mostrando grafico de andamento da copia.

- LerArquivoEnviarEmail.ps1 
    Le o arquivo de origem, jogando seu conteudo para um Array, depois
    verifica se a posição 18 do array é igual ao parametro passado, se 
    for, grava um log com a rejeição.
    Caso não for, envia o arquivo por email.

- AlterarWebConfig.ps1
    É util para ser executado durante um build, onde é necessario alterar algum arquivo de configuração.

- DownloadingBuildArtifacts.ps1
    Faz donwload do arquivo zip de artefatos do servidor de build (nesse exemplo o VSTS), depois descompacta
    o arquivo na pasta de destino.

- Oracle - EF6.1.3 FluentApi.sql
    Execute esse script no seu banco oracle, sera gerado um retorno, onde é possivel copiar seu conteudo e colar
    no seu projeto dotnet, contendo fluent api da tabela selecionada.
    O segundo script, gera uma clase de dominio com os atributos da tabela.

