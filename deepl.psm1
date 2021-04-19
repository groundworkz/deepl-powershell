function Get-DeeplTranslation {
    param (
        [Parameter(Mandatory = $true)][String]$DeeplAuthKey,
        [Parameter(Mandatory = $true)][string]$InputText,
        [Parameter(Mandatory = $false)][String]$TargetLanguage = "EN" # Default is English
    )
    #Translate the description to english using deeply.
    $DeeplRequestBody = @{
        auth_key    = $DeeplAuthKey
        text        = $InputText
        # text        = $InputText2  <-- how to add multiple text objects? hashtables only allow 1 unique keyvalue
        target_lang = $TargetLanguage
    }
    try {
        $Response = Invoke-WebRequest -Method POST -Uri https://api.deepl.com/v2/translate -body $DeeplRequestBody -ContentType "application/x-www-form-urlencoded" -ErrorAction Stop
    }
    catch [System.Net.WebException] { 
        Write-Host $Error[0].Exception.Message  -ForegroundColor Red
    }
    if ($Response.StatusCode -eq 200) {
        $OutputText = ($Response.Content | ConvertFrom-Json).translations.text
        Return $OutputText
    }
}