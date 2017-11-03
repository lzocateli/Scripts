Function Get-AuthroizeCode
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$true)][String]$ClientId,
		[Parameter(Mandatory=$true)][String]$RedirectURI
	)
	# the login url
	$loginUrl = "https://login.live.com/oauth20_authorize.srf?client_id=$ClientId&scope=onedrive.readwrite offline_access&response_type=code&redirect_uri=$RedirectURI";

	# open ie to do authentication
	$ie = New-Object -ComObject "InternetExplorer.Application"
	$ie.Navigate2($loginUrl) | Out-Null
	$ie.Visible = $True

	While($ie.Busy -Or -Not $ie.LocationURL.StartsWith($RedirectURI)) {
		Start-Sleep -Milliseconds 500
	}

	# get authorizeCode
	$authorizeCode = $ie.LocationURL.SubString($ie.LocationURL.IndexOf("=") + 1).Trim();
	$ie.Quit() | Out-Null

    Write-Host "AuthorizeCode: $($authorizeCode)"	

	RETURN $authorizeCode
}

# get access token and refresh token
Function New-AccessTokenAndRefreshToken
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$true)][String]$ClientId,
		[Parameter(Mandatory=$true)][String]$RedirectURI,
		[Parameter(Mandatory=$true)][String]$SecretKey
	)
	# get authorize code firstly
	$AuthorizeCode = Get-AuthroizeCode -ClientId $ClientId -RedirectURI $RedirectURI

	$redeemURI = "https://login.live.com/oauth20_token.srf"
	$header = @{"Content-Type"="application/x-www-form-urlencoded"}


    Write-Host "code: $($AuthorizeCode)"


    $postBody = "client_id=$ClientId&redirect_uri=$RedirectURI&code=$AuthorizeCode&grant_type=authorization_code"
	$response = Invoke-RestMethod -Headers $header -Method Post -Uri $redeemURI -Body $postBody
    $dataAtual = (get-date).AddSeconds($response.expires_in) 

	$AccessRefreshToken = New-Object PSObject
	$AccessRefreshToken | Add-Member -Type NoteProperty -Name Expires -Value $dataAtual
	$AccessRefreshToken | Add-Member -Type NoteProperty -Name AccessToken -Value $response.access_token
	$AccessRefreshToken | Add-Member -Type NoteProperty -Name RefreshToken -Value $response.refresh_token


    Write-Host "AccessRefreshToken: $($AccessRefreshToken)"		

    RETURN $AccessRefreshToken
}

# refresh token
Function Update-AccessTokenAndRefreshToken
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$true)][String]$ClientId,
		[Parameter(Mandatory=$true)][String]$RedirectURI,
		[Parameter(Mandatory=$true)][String]$RefreshToken,
		[Parameter(Mandatory=$true)][String]$SecretKey
	)
	$redeemURI = "https://login.live.com/oauth20_token.srf"
	$header = @{"Content-Type"="application/x-www-form-urlencoded"}

	$postBody = "client_id=$ClientId&redirect_uri=$RedirectURI&refresh_token=$RefreshToken&grant_type=refresh_token"
	$response = Invoke-RestMethod -Headers $header -Method Post -Uri $redeemURI -Body $postBody
    $dataAtual = (get-date).AddSeconds($response.expires_in) 
     	
	$AccessRefreshToken = New-Object PSObject
	$AccessRefreshToken | Add-Member -Type NoteProperty -Name Expires -Value $dataAtual
    $AccessRefreshToken | Add-Member -Type NoteProperty -Name AccessToken -Value $response.access_token
	$AccessRefreshToken | Add-Member -Type NoteProperty -Name RefreshToken -Value $response.refresh_token

    Write-Host "TokenExpires: $($dataAtual)"

    RETURN $AccessRefreshToken
}

# get autheticate header
Function Get-AuthenticateHeader
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$true)][String]$AccessToken
	)

	RETURN @{"Authorization" = "bearer $AccessToken"}
}

Export-ModuleMember -Function "New-AccessTokenAndRefreshToken", "Update-AccessTokenAndRefreshToken", "Get-AuthenticateHeader"
