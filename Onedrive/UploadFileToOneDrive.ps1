
[CmdletBinding()]
Param
	(
    	[Parameter(Mandatory=$false)][String]$ClientId = "8e2c5a6a-9521-4ba7-b3d6-0d0dfd8b9a16",
		[Parameter(Mandatory=$false)][String]$SecretKey = "djkopertqzc>>>;;;837" ,
		[Parameter(Mandatory=$false)][String]$RedirectURI = "https://login.live.com/oauth20_desktop.srf",
		[Parameter(Mandatory=$true)][String]$FilePath,
		[Parameter(Mandatory=$false)][String]$OneDriveFilePath = "MinhaPasta/"
	)



Function Send-File
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$true)][String]$ClientId,
		[Parameter(Mandatory=$true)][String]$SecretKey,
		[Parameter(Mandatory=$true)][String]$RedirectURI,
		[Parameter(Mandatory=$true)][String]$LocalFilePath,
		[Parameter(Mandatory=$true)][String]$OneDriveTargetPath,
		[Parameter(Mandatory=$false)][Int]$UploadBulkCount = 1024 * 1024 * 50
	)

	# test the local file exists or not
	If (-Not (Test-Path $LocalFilePath))
	{
		Throw '"$LocalFilePath" does not exists!'
	}
	else
    {
        Write-Host "Arquivo encontrado: $($LocalFilePath)"
        $fileInfo = Get-Item $LocalFilePath
        $OneDriveFilePath = "$($OneDriveFilePath)$($fileInfo.Name)"
        $OneDriveTargetPath = "$($OneDriveTargetPath)$($fileInfo.Name)"
    }

	# load authentication module to ease the authentication process
	Import-Module "$PSScriptRoot\OneDriveAuthentication.psm1"
    Import-Module "$PSScriptRoot\GuardarToken.psm1"
	
    $LogFile = "$PSScriptRoot\TokenContainer.txt"
    $dataAtual = [System.DateTimeOffset]::Now

	$Token = New-Object PSObject
    $Token | Add-Member -Type NoteProperty -Name Expires -Value ""
	$Token | Add-Member -Type NoteProperty -Name AccessToken -Value ""
	$Token | Add-Member -Type NoteProperty -Name RefreshToken -Value ""


    ####################### Recuperar Token ################################
    $json = Read-Token $LogFile
    $expiration = $json.Expires

    if ($json.AccessToken -eq "" -or $json.RefreshToken -eq "")
    {
	    # get token
        Write-Host "Token expirado ou nao existe, obtendo token"
	    $NewToken = New-AccessTokenAndRefreshToken -ClientId $ClientId -RedirectURI $RedirectURI -SecretKey $SecretKey
        $Token.AccessToken = $NewToken.AccessToken
        $Token.RefreshToken = $NewToken.RefreshToken
        $Token.Expires = $NewToken.Expires
    }
    else
    {
        if ($expiration -ge $dataAtual.DateTime )
        {
            $Token.AccessToken = $json.AccessToken
            $Token.RefreshToken = $json.RefreshToken
            $Token.Expires = $json.Expires
        }
        else
        {
            $Token.RefreshToken = $json.RefreshToken
            $RefreshedToken = Update-AccessTokenAndRefreshToken -ClientId $ClientId -RedirectURI $RedirectURI -RefreshToken $Token.RefreshToken -SecretKey $SecretKey
            $Token.AccessToken = $RefreshedToken.AccessToken
            $Token.RefreshToken = $RefreshedToken.RefreshToken
            $Token.Expires = $RefreshedToken.Expires
        }
    }
	# you can store the token somewhere for the later usage, however the token will expired
	# if the token is expired, please call Update-AccessTokenAndRefreshToken to update token
	# e.g.
	# $RefreshedToken = Update-AccessTokenAndRefreshToken -ClientId $ClientId -RedirectURI $RedirectURI -RefreshToken $Token.RefreshToken -SecretKey $SecretKey
	
	# construct authentication header
	$Header = Get-AuthenticateHeader -AccessToken $Token.AccessToken



	# api root
	$ApiRootUrl = "https://api.onedrive.com/v1.0"

	# 1. Create an upload session
	$uploadSession = Invoke-RestMethod -Headers $Header -Method Post -Uri "$ApiRootUrl/drive/root:/${OneDriveTargetPath}:/upload.createSession"


    if ($uploadSession -eq "" -or $uploadSession -eq $Null)
    {
        Write-Host = "Sessao nao pode ser aberta, erro no token"
        
    }
    else
    {
        ####################### Guardar Token ################################
        Write-Token $Token.AccessToken $Token.RefreshToken $Token.Expires $LogFile



	    # 2. import the read file partial dll
	    Add-Type -Path "$PSScriptRoot\libs\ReadPartialFile.dll"

	    # 3. get file info
	    #$fileInfo = Get-Item $LocalFilePath
 
	    # 4. Upload fragments
	    $filePos = 0

	    Do {
		    $filePartlyBytes = [ReadPartialFile.Reader]::ReadFile($FilePath, $filePos, $UploadBulkCount);

		    If ($filePartlyBytes -eq $Null) {
			    Break
		    }

		    If ($filePartlyBytes.GetType() -eq [Byte]) {
			    $uploadCount = 1
		    } Else {
			    $uploadCount = $filePartlyBytes.Length
		    }

		    $Header["Content-Length"] = $uploadCount
		    $Header["Content-Range"] = "bytes $filePos-$($filePos + $uploadCount - 1)/$($fileInfo.Length)"

		    # print progress
		    Write-Host "Uploading block [$filePos - $($filePos + $uploadCount)] among total $($fileInfo.Length)"

		    # call upload api
		    $uploadResult = Invoke-RestMethod -Headers $Header -Method Put -Uri $uploadSession.uploadUrl -Body $filePartlyBytes

		    # proceed to next postion
		    $filePos += $UploadBulkCount

	    } While ($filePartlyBytes.GetType() -eq [Byte[]] -and $filePartlyBytes.Length -eq $UploadBulkCount)

	    Write-Host "Upload finished"
	    Write-Host ""
    }

	RETURN $uploadResult
}


$RES = Send-File -ClientId $ClientId -SecretKey $SecretKey -RedirectURI $RedirectURI -LocalFilePath $FilePath -OneDriveTargetPath $OneDriveFilePath

Write-Host "id: $($RES.id)"
Write-Host "name: $($RES.name)"
Write-Host "weburl: $($RES.webUrl)"
