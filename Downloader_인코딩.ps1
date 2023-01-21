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
    Read-Host -Prompt "�������� �ٿ�ε� ��θ� ������ �����Դϴ�. ���͸� ������ ��� ���� â�� ���ɴϴ�."
    $current_location = Get-Location 
    $current_location = Get-Folder $current_location
    $confirm_directory = Read-Host -Prompt "$current_location �� �ٿ�ε��ϰ� �˴ϴ�. �ٽ� ���Ϸ��� 'n'�� �Է��ϰ� ���͸�, �����Ϸ��� ���͸� ���� �ּ���."
}

Write-Host "�� ���� ��Һ��� �ٿ�ε�������� ���θ� Ȯ���մϴ�."

$directory_hash = @{ "MPQ ����" = "MPQ" ; "EUDDraft" = "EUDDraft" ; "SCMDraft" = "Scmdraft 2" ; 
    "EUD Editor 3" = "EUD Editor 3" ;  } # EUD Editor 2 / SE�� ����ó��

$items_to_download = @{}

foreach ($Key in $directory_hash.Keys) {
    # �̹� �ش� ���丮 �Ǵ� ������ �ִ��� üũ
    if (Test-Path "$current_location/$($directory_hash[$Key])") {
        Write-Host "'$Key'��(��) �̹� '$current_location/$($directory_hash[$Key])'�� �ٿ�ε�Ǿ� �ֽ��ϴ�."
        $answer = Read-Host "'$Key'�� �ٿ�ε带 �ǳʶ۱��? (�ǳʶ��� �������� 'n'�� �Է��ϰ� ���͸�, �����Ϸ��� ���͸� ���� �ּ���.)"
        $download_this = ($answer -eq 'n')
    }
    else {
        $answer = Read-Host -Prompt "'$Key'��(��) �ٿ�ε��ұ��? (�ٿ�ε��Ϸ��� ���͸�, �ٿ�ε����� �������� 'n'�� �Է��ϰ� ���͸� ���� �ּ���.)"
        $download_this = ($answer -ne 'n')
    }

    if ($download_this) {
        Write-Host "'$Key'��(��) �ٿ�ε��ϱ�� �����߽��ϴ�."
        $items_to_download.Add($Key, $directory_hash[$Key])
    }
    else {
        Write-Host "'$Key'��(��) �ٿ�ε����� �ʱ�� �����߽��ϴ�."
    }
}

$ee2_series = @("EUD Editor 2 SE", "EUD Editor 2") # EUD Editor 2 / SE�� ����ó��

# EUD Editor 2, 2 SE Ư��ó��

$ee2_exists = Test-Path "$current_location/EUD Editor 2"
$ee2se_exists = Test-Path "$current_location/EUD Editor 2 SE"
$download_this = $false

foreach ($Key in $ee2_series) {
    $already_exists = $true
    if ($ee2_exists) {
        Write-Host "'EUD Editor 2'��(��) �̹� '$current_location/EUD Editor 2'�� �ٿ�ε�Ǿ� �ֽ��ϴ�."
    }
    elseif ($ee2se_exists) {
        Write-Host "'EUD Editor 2 SE'��(��) �̹� '$current_location/EUD Editor 2 SE'�� �ٿ�ε�Ǿ� �ֽ��ϴ�."
    }
    elseif ($download_this) { # SE�� �ٿ�ޱ�� �� �� �׳� 2
        Write-Host "'EUD Editor 2 SE'�� �ٿ�ε��ϱ�� �����߽��ϴ�."
    }
    else {
        $already_exists = $false
    }

    if ($already_exists) {
        $answer = Read-Host -Prompt "'$Key'�� �ٿ�ε带 �ǳʶ۱��? (�ǳʶ��� �������� 'n'�� �Է��ϰ� ���͸�, �����Ϸ��� ���͸� ���� �ּ���.)"
        $download_this = ($answer -eq 'n')
        
    }
    else {
        $answer = Read-Host -Prompt "'$Key'��(��) �ٿ�ε��ұ��? (�ٿ�ε��Ϸ��� ���͸�, �ٿ�ε����� �������� 'n'�� �Է��ϰ� ���͸� ���� �ּ���.)"
        $download_this = ($answer -ne 'n')
    }

    if ($download_this) {
        Write-Host "'$Key'�� �ٿ�ε��ϱ�� �����߽��ϴ�."
        $items_to_download.Add($Key, $Key)
    }
    else {
        Write-Host "'$Key'�� �ٿ�ε����� �ʱ�� �����߽��ϴ�."
    }
}

foreach ($Key in $items_to_download.Keys) {
    Write-Host "$Key ������ �ٿ�ε��մϴ�."
    New-Item -Path "$current_location\" -Name $items_to_download[$Key] -ItemType "directory" # mkdir
    $archive_filename = ""
    switch ($Key) {
        # mpq (���۵���̺�)
        "MPQ ����" {
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
    Write-Host -Prompt "$Key ���� �ٿ�ε尡 �Ϸ�Ǿ����ϴ�. ������ �����մϴ�."
    Expand-Archive "$current_location/$archive_filename" -DestinationPath "$current_location/$($items_to_download[$Key])"
    Write-Host -Prompt "$Key ���� ���� ������ �Ϸ�Ǿ����ϴ�."
}

Read-Host -Prompt "��� �ٿ�ε尡 �Ϸ�Ǿ����ϴ�. ���͸� ������ �� â�� �����ϴ�."
$env:LC_ALL = $old_env
