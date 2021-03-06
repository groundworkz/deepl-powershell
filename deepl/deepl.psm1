<#
 .Synopsis
  Translates your text into different languages.

 .Description
  Translates your text into different languages.
  Also allows you to specify input languages, fomrality, split sentences, get supported languages and check usage.

 .Parameter DeeplAuthKey
  Use your deepl API Key, which can be found here: https://www.deepl.com/pro-account/plan

 .Parameter InputText
  The text you wish to translate via deepl.
  Text to be translated. Only UTF8-encoded plain text is supported. 
  Each of the parameter values may contain multiple sentences.

 .Parameter SourceLanguage
  (Optional)
  Language of the text to be translated. Options currently available:

    "BG" - Bulgarian
    "CS" - Czech
    "DA" - Danish
    "DE" - German
    "EL" - Greek
    "EN" - English
    "ES" - Spanish
    "ET" - Estonian
    "FI" - Finnish
    "FR" - French
    "HU" - Hungarian
    "IT" - Italian
    "JA" - Japanese
    "LT" - Lithuanian
    "LV" - Latvian
    "NL" - Dutch
    "PL" - Polish
    "PT" - Portuguese (all Portuguese varieties mixed)
    "RO" - Romanian
    "RU" - Russian
    "SK" - Slovak
    "SL" - Slovenian
    "SV" - Swedish
    "ZH" - Chinese

  If this parameter is omitted, the API will attempt to detect the language of the text and translate it.

 .Parameter TargetLanguage
  The language into which the text should be translated. 
  Options currently available:

    "BG" - Bulgarian
    "CS" - Czech
    "DA" - Danish
    "DE" - German
    "EL" - Greek
    "EN-GB" - English (British)
    "EN-US" - English (American)
    "EN" - English (unspecified variant for backward compatibility; please select EN-GB or EN-US instead)
    "ES" - Spanish
    "ET" - Estonian
    "FI" - Finnish
    "FR" - French
    "HU" - Hungarian
    "IT" - Italian
    "JA" - Japanese
    "LT" - Lithuanian
    "LV" - Latvian
    "NL" - Dutch
    "PL" - Polish
    "PT-PT" - Portuguese (all Portuguese varieties excluding Brazilian Portuguese)
    "PT-BR" - Portuguese (Brazilian)
    "PT" - Portuguese (unspecified variant for backward compatibility; please select PT-PT or PT-BR instead)
    "RO" - Romanian
    "RU" - Russian
    "SK" - Slovak
    "SL" - Slovenian
    "SV" - Swedish
    "ZH" - Chinese

 .Parameter SplitSentences
  (Optional)
  Sets whether the translation engine should first split the input into sentences. This is enabled by default. Possible values are:

    "0" - no splitting at all, whole input is treated as one sentence
    "1" (default) - splits on interpunction and on newlines
    "nonewlines" - splits on interpunction only, ignoring newlines

  For applications that send one sentence per text parameter, it is advisable to set split_sentences=0, in order to prevent the engine from splitting the sentence unintentionally.

 .Parameter PreserverFormatting
  (Optional)
  Sets whether the translation engine should respect the original formatting, even if it would usually correct some aspects. Possible values are:

    "0" (default)
    "1"

  The formatting aspects affected by this setting include:

    Punctuation at the beginning and end of the sentence
    Upper/lower case at the beginning of the sentence

 .Parameter Formality
  (Optional)
  Sets whether the translated text should lean towards formal or informal language. 
  This feature currently only works for target languages: 
  "DE" (German), "FR" (French), "IT" (Italian), "ES" (Spanish), "NL" (Dutch), 
  "PL" (Polish), "PT-PT", "PT-BR" (Portuguese) and "RU" (Russian).

  Possible options are:

    "default" (default)
    "more" - for a more formal language
    "less" - for a more informal language

 .Parameter TagHandling
  (Optional)
  Sets which kind of tags should be handled. Options currently available:
    "xml"

 .Parameter NonSplittingTags
  (Optional)
  Comma-separated list of XML tags which never split sentences.

 .Parameter OutlineDetection
  (Optional)
  Please see the "Handling XML" section for further details.

 .Parameter SplittingTags
  (Optional)
  Comma-separated list of XML tags which always cause splits.

 .Parameter IgnoreTags
  (Optional)
  Comma-separated list of XML tags that indicate text not to be translated.

 .Parameter TranslatedTextOnly
  (Optional)
  Returns only the translated text.
  If set to $false, this module returns the full API response.

 .Parameter APIMode
  (Optional)
  Can be used to set the API to "free" mode.
  Defaults to Null.
  Valid entries are Null, "-free"

 .Parameter APIMode
  (Optional)
  Sets whether source or target languages should be listed. Possible options are:
  "source" (default) - For languages that can be used in the source_lang parameter of /translate requests.
  "target" - For languages that can be used in the target_lang parameter of /translate requests. 

 .Example
   # Translate text into English
   Get-DeeplTextTranslation -DeeplAuthKey "xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" -InputText "Hallo Wereld"

 .Example
   # Translate text into Dutch
   Get-DeeplTextTranslation -DeeplAuthKey "xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" -InputText "???????????? ??????" -SourceLanguage "RU" -TargetLanguage "NL" -Formality "more" -TranslatedTextOnly $false

 .Example
   # Get supported source languages
   Get-DeeplSupportedLanguages -DeeplAuthKey "xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" -Type "source"

 .Example
   # Check current usage
   Get-DeeplUsage -DeeplAuthKey "xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

   #>

function Invoke-DeeplRequest {
    param (
        [Parameter(Mandatory = $true)][ValidateSet("translate", "usage", "languages")][string]$APIService,
        [Parameter(Mandatory = $true)][System.Collections.Hashtable]$DeeplRequestBody,
        [Parameter(Mandatory = $false)][String]$APIMode,
        [Parameter(Mandatory = $false)][String]$ContentType = "application/x-www-form-urlencoded"
    )
    try {
        $Response = Invoke-WebRequest -Method POST -Uri "https://api$($APIMode).deepl.com/v2/$($APIService)" -body $DeeplRequestBody -ContentType $ContentType -ErrorAction Stop
    }
    catch [System.Net.WebException] { 
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
    if ($Response.StatusCode -eq 200) {
        Return $Response.Content
    }
    elseif ($Response.StatusCode) {
        Write-Host "Error. HTTP Response code: [$($Response.StatusCode)]" -ForegroundColor Red
        Break
    }
}
function Get-DeeplTextTranslation {
    param (
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String]$DeeplAuthKey,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$InputText,
        [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][String]$TargetLanguage = "EN", # Default is English
        [Parameter(Mandatory = $false)][String]$SourceLanguage,
        [Parameter(Mandatory = $false)][ValidateSet("0", "1", "nonewlines")][String]$SplitSentences,
        [Parameter(Mandatory = $false)][ValidateSet("0", "1")][String]$PreserverFormatting,
        [Parameter(Mandatory = $false)][ValidateSet("default", "more", "less")][String]$Formality,
        [Parameter(Mandatory = $false)][String]$TagHandling,
        [Parameter(Mandatory = $false)][String]$NonSplittingTags,
        [Parameter(Mandatory = $false)][String]$OutlineDetection,
        [Parameter(Mandatory = $false)][String]$SplittingTags,
        [Parameter(Mandatory = $false)][String]$IgnoreTags,
        [Parameter(Mandatory = $false)][Bool]$TranslatedTextOnly = $true,
        [Parameter(Mandatory = $false)][ValidateSet($null, "-free")][string]$APIMode = $null
    )
    $DeeplRequestBody = @{
        auth_key            = $DeeplAuthKey
        text                = $InputText
        # text        = $InputText2  <-- how to add multiple text objects? hashtables only allow 1 unique keyvalue
        target_lang         = $TargetLanguage
        source_lang         = $SourceLanguage
        split_sentences     = $SplitSentences
        preserve_formatting = $PreserverFormatting
        formality           = $Formality
        tag_handling        = $TagHandling
        non_splitting_tags  = $NonSplittingTags
        outline_detection   = $OutlineDetection
        splitting_tags      = $SplittingTags
        ignore_tags         = $IgnoreTags
    }
    $TranslatedResponse = Invoke-DeeplRequest -DeeplRequestBody $DeeplRequestBody -APIService "translate" -APIMode $APIMode
    if ($TranslatedTextOnly) {
        Return ($TranslatedResponse | ConvertFrom-Json).translations.text
    }
    else {
        Return $TranslatedResponse
    }
}

function Get-DeeplUsage {
    param (
        [Parameter(Mandatory = $true)][String]$DeeplAuthKey,
        [Parameter(Mandatory = $false)][ValidateSet($null, "-free")][string]$APIMode = $null
    )
    $DeeplRequestBody = @{
        auth_key = $DeeplAuthKey
    }
    Return (Invoke-DeeplRequest -DeeplRequestBody $DeeplRequestBody -APIService "usage" -APIMode $APIMode)
}
function Get-DeeplSupportedLanguages {
    param (
        [Parameter(Mandatory = $true)][String]$DeeplAuthKey,
        [Parameter(Mandatory = $false)][ValidateSet("source", "target")][String]$Type,
        [Parameter(Mandatory = $false)][ValidateSet($null, "-free")][string]$APIMode = $null
    )
    $DeeplRequestBody = @{
        auth_key = $DeeplAuthKey
        type     = $type
    }
    Return (Invoke-DeeplRequest -DeeplRequestBody $DeeplRequestBody -APIService "languages" -APIMode $APIMode)
}

# Not working at the moment
# function Get-DeeplDocumentTranslation {
#     param (
#         [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String]$DeeplAuthKey,
#         [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][String]$TargetLanguage = "EN", # Default is English
#         [Parameter(Mandatory = $false)][String]$SourceLanguage,
#         [Parameter(Mandatory = $true)][String]$File,
#         [Parameter(Mandatory = $false)][String]$FileName,
#         [Parameter(Mandatory = $false)][ValidateSet($null, "-free")][string]$APIMode = $null
#     )
#     $DeeplRequestBody = @{
#         auth_key    = $DeeplAuthKey
#         target_lang = $TargetLanguage
#         source_lang = $SourceLanguage
#         file        = $File
#         filename    = $FileName
#     }
#     $TranslatedResponse = Invoke-DeeplRequest -DeeplRequestBody $DeeplRequestBody -APIService "document" -APIMode $APIMode -ContentType "multipart/form-data"
#     if ($TranslatedTextOnly) {
#         Return ($TranslatedResponse | ConvertFrom-Json).translations.text
#     }
#     else {
#         Return $TranslatedResponse
#     }
# }

function get-deepldocumentstatus {
    param (
        [Parameter(Mandatory = $true)][String]$DeeplAuthKey,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String]$DocumentKey,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String]$DocumentId,
        [Parameter(Mandatory = $false)][ValidateSet($null, "-free")][string]$APIMode = $null
    )
    $DeeplRequestBody = @{
        auth_key     = $DeeplAuthKey
        document_key = $DocumentKey
    }
    Return (Invoke-DeeplRequest -DeeplRequestBody $DeeplRequestBody -APIService "document/$($DocumentId)" -APIMode $APIMode)
}

function get-deepldocumentresult {
    param (
        [Parameter(Mandatory = $true)][String]$DeeplAuthKey,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String]$DocumentKey,
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String]$DocumentId,
        [Parameter(Mandatory = $false)][ValidateSet($null, "-free")][string]$APIMode = $null
    )
    $DeeplRequestBody = @{
        auth_key     = $DeeplAuthKey
        document_key = $DocumentKey
    }
    Return (Invoke-DeeplRequest -DeeplRequestBody $DeeplRequestBody -APIService "document/$($DocumentId)/result" -APIMode $APIMode)
}

Export-ModuleMember -Function Get-DeeplTextTranslation, Get-DeeplUsage, Get-DeeplSupportedLanguages, Get-DeeplDocumentTranslation, get-deepldocumentstatus, get-deepldocumentresult