function fusionLogs(){
    param(
        [ValidateSet("on","off","show")]
        [string]$Status="show",
        [string[]]$Name=@('ForceLog','LogFailures','LogResourceBinds','LogPath'),
        [string]$Path="HKLM:\Software\Microsoft\Fusion",
        [string]$Directory="C:\FusionLogs"
    )
    $OldPath=pwd
    if($Status -match "on"){
        $nVal=1
    } elseif($Status -match "off") {
        $nVal=0
    } else {
        $nVal="Show"
    }
    $RegPath="HKLM:\Software\Microsoft\Fusion"
    $Keys=@(
        @{"Name"="ForceLog";"Value"=$nVal;"Type"="DWord"},
        @{"Name"="LogFailures";"Value"=$nVal;"Type"="DWord"},
        @{"Name"="LogResourceBinds";"Value"=$nVal;"Type"="DWord"},
        @{"Name"="LogPath";"Value"="$Directory";"Type"="String"})
    cd HKLM:\
    $ShowObj=@()
    foreach($H in $Keys){
        $H.add("Path",$RegPath)
        if($nVal -match "Show"){
            $H.Remove("Value")
            $H.Remove("Type")
            Get-ItemProperty @H
        } else {
            Set-ItemProperty @H
        }
    }
    if($Status -match "on|off"){
        fusionLogs -Status show
    }
    cd $OldPath
}