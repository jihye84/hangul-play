$soundDir = Join-Path $PSScriptRoot "sounds"
if (-not (Test-Path $soundDir)) {
    New-Item -ItemType Directory -Path $soundDir | Out-Null
}

$CHO = [System.Collections.ArrayList]@('gg', 'gg2', 'n', 'd', 'dd', 'r', 'm', 'b', 'bb', 's', 'ss', 'ng', 'j', 'jj', 'ch', 'k', 't', 'p', 'h')
$JUNG = [System.Collections.ArrayList]@('a', 'ae', 'ya', 'yae', 'eo', 'e', 'yeo', 'ye', 'o', 'wa', 'wae', 'oe', 'yo', 'u', 'wo', 'we', 'wi', 'yu', 'eu', 'ui', 'i')

$cMap = @{
    'gg' = 'gg'; 'n' = 'n'; 'd' = 'd'; 'r' = 'r'; 'm' = 'm'; 'b' = 'b';
    's' = 's'; 'ng' = 'ng'; 'j' = 'j'; 'ch' = 'ch'; 'k' = 'k'; 't' = 't'; 'p' = 'p'; 'h' = 'h'
}

$CHO_REAL = [System.Collections.ArrayList]@([char]0xAC00, [char]0xAC00, [char]0xB098 - 1, [char]0xB2E4 - 1, [char]0xAC00, [char]0xB77C - 1, [char]0xB9C8 - 1, [char]0xBC14 - 1, [char]0xAC00, [char]0xC0AC - 1, [char]0xAC00, [char]0xC544 - 1, [char]0xC790 - 1, [char]0xAC00, [char]0xCC28 - 1, [char]0xCE74 - 1, [char]0xD0C0 - 1, [char]0xD30C - 1, [char]0xD558 - 1)
$JUNG_REAL = [System.Collections.ArrayList]@([char]0xAC00, [char]0xAC00, [char]0xAC00, [char]0xAC00, [char]0xAC00, [char]0xAC00, [char]0xAC00, [char]0xAC00, [char]0xAC00, [char]0xAC00, [char]0xAC00, [char]0xAC00, [char]0xAC00, [char]0xAC00, [char]0xAC00, [char]0xAC00, [char]0xAC00, [char]0xAC00, [char]0xAC00, [char]0xAC00, [char]0xAC00)

$CHO_IDX = @('gg', 'gg2', 'n', 'd', 'dd', 'r', 'm', 'b', 'bb', 's', 'ss', 'ng', 'j', 'jj', 'ch', 'k', 't', 'p', 'h')
$JUNG_IDX = @('a', 'ae', 'ya', 'yae', 'eo', 'e', 'yeo', 'ye', 'o', 'wa', 'wae', 'oe', 'yo', 'u', 'wo', 'we', 'wi', 'yu', 'eu', 'ui', 'i')

$consonants = @('gg', 'n', 'd', 'r', 'm', 'b', 's', 'ng', 'j', 'ch', 'k', 't', 'p', 'h')
$vowels = @('a', 'ya', 'eo', 'yeo', 'o', 'yo', 'u', 'yu', 'eu', 'i')

$ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'
$ref = 'https://translate.google.com/'

$total = $consonants.Count * $vowels.Count
$cnt = 0

function Get-Syllable {
    param($c, $v)
    $ci = [Array]::IndexOf($CHO_IDX, $c)
    $vi = [Array]::IndexOf($JUNG_IDX, $v)
    if ($ci -lt 0 -or $vi -lt 0) { return [char]0x003F }
    $code = 0xAC00 + $ci * 21 * 28 + $vi * 28
    return [char]$code
}

foreach ($c in $consonants) {
    foreach ($v in $vowels) {
        $syl = Get-Syllable $c $v
        $cnt++

        $cp = [int]$syl
        $fileName = "$cp.mp3"
        $filePath = Join-Path $soundDir $fileName

        if (Test-Path $filePath) {
            Write-Host "[$cnt/$total] $syl skip"
            continue
        }

        $enc = [Uri]::EscapeDataString($syl)
        $p1 = 'https://translate.google.com/translate_tts?ie=UTF-8'
        $p2 = 'q=' + $enc
        $p3 = 'tl=ko'
        $p4 = 'client=tw-ob'
        $p5 = 'ttsspeed=0.7'
        $url = $p1 + '&' + $p2 + '&' + $p3 + '&' + $p4 + '&' + $p5

        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add('User-Agent', $ua)
        $wc.Headers.Add('Referer', $ref)

        try {
            $wc.DownloadFile($url, $filePath)
            Write-Host "[$cnt/$total] $syl OK"
        }
        catch {
            Write-Host "[$cnt/$total] $syl FAIL"
        }
        finally {
            $wc.Dispose()
        }

        Start-Sleep -Milliseconds 250
    }
}

Write-Host "DONE"
$n = (Get-ChildItem $soundDir -Filter "*.mp3").Count
Write-Host "Files: $n / $total"
