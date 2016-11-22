function hashFiles(){
    param(
        [string[]]$Directory="C:\Program Files\Venafi",
        [string]$String,
        [string[]]$OutFile="C:\VenHashScan.txt",
        [switch]$Compare,
        [switch]$Report
    )
    if(!$Compare){
    $FileList=Get-ChildItem -Recurse -Path $Directory -File
    $Sha=[Security.Cryptography.HashAlgorithm]::Create("SHA256")
    $NewFileList=@()
    foreach($F in $FileList.FullName){
        $Read=[System.IO.File]::ReadAllBytes($F)
        $Fb64=[System.Convert]::ToBase64String($sha.ComputeHash($Read))
        $OutF=@{"FileName"=$F;
            "Hash"=$Fb64}
        $NewFileList+=$OutF
    }
    }
    if($Compare -or $OutFile.Count -ge 2){
        $File1=[System.IO.File]::ReadAllLines($OutFile[0])
        $File2=[System.IO.File]::ReadAllLines($OutFile[1])
        $CompareContent=Compare-Object $File1 $File2
        if($Report){
            $CompareReport=$OutFile[0]+"-"+$OutFile[1]+"-Report"
            [System.IO.File]::WriteAllLines($CompareReport,$CompareContent)
        } else {
            $CompareContent
        }
    } elseif(!($Compare)){
        [System.IO.File]::WriteAllLines($OutFile[0],(ConvertTo-Json -Depth 3 $NewFileList))
    }

}