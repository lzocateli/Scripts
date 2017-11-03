Function List-SharedItem
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$true)][String]$ClientId,
		[Parameter(Mandatory=$true)][String]$SecretKey,
		[Parameter(Mandatory=$true)][String]$RedirectURI
	)

	# import the utils module
	Import-Module ".\OneDriveAuthentication.psm1"

	# get token
	$Token = New-AccessTokenAndRefreshToken -ClientId $ClientId -RedirectURI $RedirectURI -SecretKey $SecretKey

	# you can store the token somewhere for the later usage, however the token will expired
	# if the token is expired, please call Update-AccessTokenAndRefreshToken to update token
	# e.g.
	# $RefreshedToken = Update-AccessTokenAndRefreshToken -ClientId $ClientId -RedirectURI $RedirectURI -RefreshToken $Token.RefreshToken -SecretKey $SecretKey
	
	# construct authentication header
	$Header = Get-AuthenticateHeader -AccessToken $Token.AccessToken

	# api root
	$ApiRootUrl = "https://api.onedrive.com/v1.0"

	# call api
	$Response = Invoke-RestMethod -Headers $Header -Method GET -Uri "$ApiRootUrl/drive/shared"

	RETURN $Response.value
}

# call method to do job
$Results = List-SharedItem -ClientId $ClientId -SecretKey $SecretKey -RedirectURI $RedirectURI

# print results
$Results | ForEach-Object {
	Write-Host "ID: $($_.id)"
	Write-Host "Name: $($_.name)"
	Write-Host "ParentReference: $($_.parentReference)"
	Write-Host "Size: $($_.size)"
	Write-Host "WebURL: $($_.webUrl)"
	Write-Host
}
