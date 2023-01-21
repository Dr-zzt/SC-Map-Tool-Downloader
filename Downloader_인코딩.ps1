# Set download path

# Function for letting the user select a folder to download
# Credits to https://stackoverflow.com/questions/25690038/how-do-i-properly-use-the-folderbrowserdialog-in-powershell .
Function Get-Folder($initialDirectory) {
    [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
    $FolderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $FolderBrowserDialog.RootFolder = 'MyComputer'
    if ($initialDirectory) { $FolderBrowserDialog.SelectedPath = $initialDirectory }
    [void] $FolderBrowserDialog.ShowDialog()
    return $FolderBrowserDialog.SelectedPath
}

$confirm_directory = 'n'

while ($confirm_directory -eq 'n') {
    Read-Host -Prompt "이제부터 다운로드 경로를 설정할 예정입니다. 엔터를 누르면 경로 설정 창이 나옵니다."
    $current_location = Get-Location 
    $current_location = Get-Folder $current_location
    $confirm_directory = Read-Host -Prompt "$current_location 에 다운로드하게 됩니다. 다시 정하려면 'n'을 입력하고 엔터를, 진행하려면 엔터를 눌러 주세요."
}

Write-Host "각 구성 요소별로 다운로드받을지의 여부를 확인합니다."

$directory_hash = @{ "MPQ 파일" = "MPQ" ; "EUDDraft" = "EUDDraft" ; "SCMDraft" = "Scmdraft 2" ; 
    "EUD Editor 3" = "EUD Editor 3" ;  } # EUD Editor 2 / SE는 예외처리

$items_to_download = @{}

foreach ($Key in $directory_hash.Keys) {
    # 이미 해당 디렉토리 또는 파일이 있는지 체크
    if (Test-Path "$current_location/$($directory_hash[$Key])") {
        Write-Host "'$Key'이(가) 이미 '$current_location/$($directory_hash[$Key])'에 다운로드되어 있습니다."
        $answer = Read-Host "'$Key'의 다운로드를 건너뛸까요? (건너뛰지 않으려면 'n'을 입력하고 엔터를, 진행하려면 엔터를 눌러 주세요.)"
        $download_this = ($answer -eq 'n')
    }
    else {
        $answer = Read-Host -Prompt "'$Key'을(를) 다운로드할까요? (다운로드하려면 엔터를, 다운로드하지 않으려면 'n'을 입력하고 엔터를 눌러 주세요.)"
        $download_this = ($answer -ne 'n')
    }

    if ($download_this) {
        Write-Host "'$Key'을(를) 다운로드하기로 결정했습니다."
        $items_to_download.Add($Key, $directory_hash[$Key])
    }
    else {
        Write-Host "'$Key'을(를) 다운로드하지 않기로 결정했습니다."
    }
}

$ee2_series = @("EUD Editor 2 SE", "EUD Editor 2") # EUD Editor 2 / SE는 예외처리

# EUD Editor 2, 2 SE 특수처리

$ee2_exists = Test-Path "$current_location/EUD Editor 2"
$ee2se_exists = Test-Path "$current_location/EUD Editor 2 SE"
$download_this = $false

foreach ($Key in $ee2_series) {
    $already_exists = $true
    if ($ee2_exists) {
        Write-Host "'EUD Editor 2'이(가) 이미 '$current_location/EUD Editor 2'에 다운로드되어 있습니다."
    }
    elseif ($ee2se_exists) {
        Write-Host "'EUD Editor 2 SE'이(가) 이미 '$current_location/EUD Editor 2 SE'에 다운로드되어 있습니다."
    }
    elseif ($download_this) { # SE를 다운받기로 할 때 그냥 2
        Write-Host "'EUD Editor 2 SE'를 다운로드하기로 결정했습니다."
    }
    else {
        $already_exists = $false
    }

    if ($already_exists) {
        $answer = Read-Host -Prompt "'$Key'의 다운로드를 건너뛸까요? (건너뛰지 않으려면 'n'을 입력하고 엔터를, 진행하려면 엔터를 눌러 주세요.)"
        $download_this = ($answer -eq 'n')
        
    }
    else {
        $answer = Read-Host -Prompt "'$Key'을(를) 다운로드할까요? (다운로드하려면 엔터를, 다운로드하지 않으려면 'n'을 입력하고 엔터를 눌러 주세요.)"
        $download_this = ($answer -ne 'n')
    }

    if ($download_this) {
        Write-Host "'$Key'를 다운로드하기로 결정했습니다."
        $items_to_download.Add($Key, $Key)
    }
    else {
        Write-Host "'$Key'를 다운로드하지 않기로 결정했습니다."
    }
}

foreach ($Key in $items_to_download.Keys) {
    Write-Host "$Key 파일을 다운로드합니다."
    New-Item -Path "$current_location\" -Name $items_to_download[$Key] -ItemType "directory" # mkdir
    $archive_filename = ""
    switch ($Key) {
        # mpq (구글드라이브)
        "MPQ 파일" {
            $file_url = 'https://docs.google.com/uc?export=download&id=14-cQq20uL2gpKIfu6hMidH9Ue-drM-d3&confirm=t'
            $archive_filename = "MPQ.zip"
        }
        "EUDDraft" {
            $archive_filename = "EUDDraft.zip"
            $latest_version = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/armoha/euddraft/master/latest/VERSION").Content
            $file_url = 'https://github.com/armoha/euddraft/releases/download/v{0}/euddraft{0}.zip' -f $latest_version
        }
        "SCMDraft" {
            $file_url = 'http://www.stormcoast-fortress.net/Irregularies/?action=DownloadAlpha&ID=2020.06.24(W)'
            $archive_filename = "SCMDraft 2.zip"
        }
        "EUD Editor 3" {
            $archive_filename = "EUD Editor 3.zip"
            $file_url = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Buizz/EUD-Editor-3/master/EUD%20Editor%203/Version.txt").Content.Split()[1]
        }
        "EUD Editor 2" {
            $archive_filename = "EUD Editor 2.zip"
            $file_url = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/armoha/EUDEditor/master/version/version").Content.Split()[1]
        }
        "EUD Editor 2 SE" {
            $archive_filename = "EUD Editor 2 SE.zip"
            $file_url = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/iDoodler-DS/EUDEditor/master/version/version").Content.Split()[1]
        }        
    }
    Invoke-WebRequest -Uri $file_url -OutFile "$current_location/$archive_filename"
    Write-Host -Prompt "$Key 파일 다운로드가 완료되었습니다. 압축을 해제합니다."
    Expand-Archive "$current_location/$archive_filename" -DestinationPath "$current_location/$($items_to_download[$Key])"
    Write-Host -Prompt "$Key 파일 압축 해제가 완료되었습니다."
}

Read-Host -Prompt "모든 다운로드가 완료되었습니다. 엔터를 누르면 이 창이 닫힙니다."
$env:LC_ALL = $old_env
