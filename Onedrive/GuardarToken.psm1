Function Write-Token {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True)]
    [string]
    $AccessToken,

    [Parameter(Mandatory=$True)]
    [string]
    $RefreshToken,

    [Parameter(Mandatory=$True)]
    [System.DateTimeOffset]
    $Expiration,

    [Parameter(Mandatory=$True)]
    [string]
    $logfile
    )

    $Line = "{ ""Expires"" : ""$Expiration"", ""AccessToken"" : ""$AccessToken"", ""RefreshToken"" : ""$RefreshToken"" }"
    Set-Content $logfile -Value $Line 

}

Function Read-Token {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True)]
    [string]
    $logfile
    )

    $json = (Get-Content $logfile -Raw) | ConvertFrom-Json
    
    #$json.psobject.properties.name
    return $json
}
