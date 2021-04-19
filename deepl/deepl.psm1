<#
 .Synopsis
  Translates your text into different languages.

 .Description
  Translates your text into different languages.
  Also allows you to specify input languages, fomrality and split sentences.

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

 .Example
   # Translate text into English
   Get-DeeplTranslation -DeeplAuthKey "xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" -InputText "Hallo Wereld"

 .Example
   # Translate text into Dutch
   Get-DeeplTranslation -DeeplAuthKey "xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" -InputText "Привет мир" -SourceLanguage "RU" -TargetLanguage "NL" -Formality "more" -TranslatedTextOnly $false

#>
function Get-DeeplTranslation {
    param (
        [Parameter(Mandatory = $true)][String]$DeeplAuthKey,
        [Parameter(Mandatory = $true)][string]$InputText,
        [Parameter(Mandatory = $false)][String]$TargetLanguage = "EN", # Default is English
        [Parameter(Mandatory = $false)][String]$SourceLanguage,
        [Parameter(Mandatory = $false)][String]$SplitSentences = "1",
        [Parameter(Mandatory = $false)][String]$PreserverFormatting = "0",
        [Parameter(Mandatory = $false)][String]$Formality= "default",
        [Parameter(Mandatory = $false)][String]$TagHandling,
        [Parameter(Mandatory = $false)][String]$NonSplittingTags,
        [Parameter(Mandatory = $false)][String]$OutlineDetection,
        [Parameter(Mandatory = $false)][String]$SplittingTags,
        [Parameter(Mandatory = $false)][String]$IgnoreTags,
        [Parameter(Mandatory = $false)][bool]$TranslatedTextOnly = $true
    )
    #Translate the description to english using deeply.
    $DeeplRequestBody = @{
        auth_key    = $DeeplAuthKey
        text        = $InputText
        # text        = $InputText2  <-- how to add multiple text objects? hashtables only allow 1 unique keyvalue
        target_lang = $TargetLanguage
        source_lang = $SourceLanguage
        split_sentences = $SplitSentences
        preserve_formatting = $PreserverFormatting
        formality = $Formality
        tag_handling = $TagHandling
        non_splitting_tags = $NonSplittingTags
        outline_detection = $OutlineDetection
        splitting_tags = $SplittingTags
        ignore_tags = $IgnoreTags
    }
    try {
        $Response = Invoke-WebRequest -Method POST -Uri https://api.deepl.com/v2/translate -body $DeeplRequestBody -ContentType "application/x-www-form-urlencoded" -ErrorAction Stop
    }
    catch [System.Net.WebException] { 
        $_.Exception.Message
    }
    if ($Response.StatusCode -eq 200) {
        if ($TranslatedTextOnly) {
        $TranslatedText = ($Response.Content | ConvertFrom-Json).translations.text
        Return $TranslatedText
        }
        else {
            Return $Response.Content
        }
    }
}
Export-ModuleMember -Function Get-DeeplTranslation