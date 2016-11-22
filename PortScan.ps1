[cmdletbinding()]
param(
    [string[]]$PortRange=443,
    [string[]]$IP="www.google.com",
    [switch]$ShowAll,
    [ValidateSet('Tls11','Tls12','Tls','Ssl2','Ssl3','All')]
    [string[]]$Protocol=@('Tls11','Tls12','Tls','Ssl2','Ssl3'), # Scans all protocols
    [ValidateSet('Json','Object')]
    [string]$ResultView='Object'
)
foreach($o in $IP){
    $OutObj=@()
    $PortRange=$PortRange -split ","
    foreach($i in $PortRange){
        $sslData=@()
        $TempObj=@{"Port"="$i";"Result"="";"sslData"=@()}
        foreach($P in $Protocol){
            $Sock = New-Object System.Net.Sockets.TcpClient
            try {
                $Res=$Sock.ConnectAsync($o,$i).Wait(1000)
                $TempObj.Result="$Res"
                $Stream=$Sock.GetStream()
                $sslStream = New-Object System.Net.Security.SslStream($Stream,$false)
                try{
                    $sslStream.AuthenticateAsClient($o,$null,$P,$false)
                    $CN=($sslStream.RemoteCertificate.Subject -split " " | select -First 1).trim(",")
                    $CertData=$sslStream.RemoteCertificate.GetRawCertData()
                    $Rcert=[system.convert]::ToBase64String($CertData)
                    $TempObj.sslData+=@{"RemoteCert"=@{"Subject"=$CN;"Cert"="$Rcert"};
                        "Protocol"="$($sslStream.SslProtocol) : Success"}
                } catch {
                    $TempObj.sslData+=@{"Protocol"="$P : Failed";
                        "RemoteCert"="Could Not Establish SSL connection"}
                }
            } catch {
                $TempObj.Result="$Res"
            }
            $sock.Close()           
        }
        $OutObj+=$TempObj
        Write-Verbose "$o $i $Res $($sslData.Protocol)"
    }
    $PortResult=$OutObj | ConvertTo-Json -Depth 100 | ConvertFrom-Json
    $Result=@{"$o"=@($PortResult)}
    if($ResultView -match "Object"){
        $Result    
    } elseif($ResultView -match "Json") {
        $Result | ConvertTo-Json -Depth 100
    }
}
