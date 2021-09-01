# 파판스샷! 파일 이름을 연월일로!

param(
    [Parameter(Mandatory = $false, HelpMessage = '스크린샷 경로')]
    [string]$Path,
    [Parameter(Mandatory = $false, HelpMessage = '소스 형식')]
    [string]$Type = "mdy",
    [Parameter(Mandatory = $false, HelpMessage = '도움말')]
    [switch]$Help
)

function New-Question([string] $msg) {
    do {
        $m = '{0} (Y/0=계속, N=그만)' -f $msg
        $i = (Read-Host $m).ToUpper()

        if ($i -eq 'Y') { return $true }
        if ($i -eq '0') { return $true }

        if ($i -eq 'N') { return $false }
        if ($i -eq ' ') { return $false }
    } while ($true)
}

function ParseAndConvertMdyToYmd([string] $name) {
    if ($name.Length -lt 14) {
        return $null
    }

    $extend = $name.Substring(14)
    $ls = $name.Substring(6, 8)

    [int]$year = 0
    [int]$month = 0
    [int]$day = 0

    if (-not ([int]::TryParse($ls.Substring(4, 4), [ref]$year))) {
        return $null
    }

    # 지금은 2000년대라 2000이상이면 ㅇㅋ
    # 왜냐하면 월이 20월은 없으니깐
    if ($year -lt 2000) {
        # ymd
        # ...는 할필요가 없지
        return $null
    }
    
    # mdy
    $month = [int]::Parse($ls.Substring(0, 2))
    $day = [int]::Parse($ls.Substring(2, 2))

    # combine
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.Append("ffxiv_")
    [void]$sb.AppendFormat("{0:D4}{1:D2}{2:D2}", $year, $month, $day);
    [void]$sb.Append($extend);
    $ret = $sb.ToString()

    return $ret
}

function ParseAndConvertDmyToYmd([string] $name) {
    if ($name.Length -lt 14) {
        return $null
    }

    $extend = $name.Substring(14)
    $ls = $name.Substring(6, 8)

    [int]$year = 0
    [int]$month = 0
    [int]$day = 0

    if (-not ([int]::TryParse($ls.Substring(4, 4), [ref]$year))) {
        return $null
    }

    # 지금은 2000년대라 2000이상이면 ㅇㅋ
    # 왜냐하면 월이 20월은 없으니깐
    if ($year -lt 2000) {
        # ymd
        # ...는 할필요가 없지
        return $null
    }
    
    # dmy
    $month = [int]::Parse($ls.Substring(2, 2))
    $day = [int]::Parse($ls.Substring(0, 2))

    # combine
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.Append("ffxiv_")
    [void]$sb.AppendFormat("{0:D4}{1:D2}{2:D2}", $year, $month, $day);
    [void]$sb.Append($extend);
    $ret = $sb.ToString()

    return $ret
}

# 여기가 시작
'찍어둔 FFXIV 스크린샷의 파일 이름을 년월일로 바꿀겁니다!!!'
''

# 도움말
if ($Help) {
    '-Path (스크린샷 경로)    스크린샷 경로를 지정합니다'
    '-Type (형식)             월일년의 경우 mdy(기본값), 일월년의 경우 dmy 입니다'
    '-Help                    이 도움말을 출력합니다'
    exit 0
}

# ss 경로
$sspath = $Path

if ($sspath.Length -eq 0) {
    # 윈도우 10밖에 테스트 안해봄
    $document = $env:USERPROFILE + '\Documents'
    $ff14home = $document + '\My Games\FINAL FANTASY XIV - A Realm Reborn'
    $sspath = $ff14home + '\screenshots';
}

if (-not (Test-Path $sspath)) {
    "스크린샷 디렉토리가 없어요! $sspath"
    exit 0;
}

# 형식 검사
$utype = $Type.ToUpper()

if ($utype -eq "MDY") {
    [scriptblock]$pncfunc = $function:ParseAndConvertMdyToYmd
}
elseif ($utype -eq "DMY") {
    [scriptblock]$pncfunc = $function:ParseAndConvertDmyToYmd
}
else {
    "알수없는 형식입니다: $Type"
    exit 0
}

"스크린샷 디렉토리 : $sspath"
"스크린샷 이름형식 : $($Type.ToUpper())"
''

# 작업해보자
$files = Get-ChildItem $sspath
$items = @()

# 파일 확인
foreach ($f in $files) {
    if ($f.Name.StartsWith('ffxiv_')) {
        $ret = $pncfunc.Invoke($f.Name)[0]
        if ($null -ne $ret) {
            $items += [PSCustomObject]@{
                Src = $f;
                Dst = $ret
            };
        }
    }
}

"총 파일은 $($files.Count)개이며 변경할 수 있는 파일은 $($items.Count)개입니다"

if ($items.Count -eq 0) {
    '... 결과적으로 변경할 파일이 없네요'
    exit 0
}

# 변경
if ((New-Question "계속하실건가요?") -eq $false) { exit 0 }
''

#$items.ForEach({"$($PSItem.Src) -> $($PSItem.Dst)"})

for ($i = 0; $i -lt $items.Count; $i++) {
    $f = $items[$i].Src
    $d = $items[$i].Dst
    "[$($i+1)] $($f.Name) → $d"
    Rename-Item $f.FullName $d    
}

# 끗
''
'끝났습니다!!!'
