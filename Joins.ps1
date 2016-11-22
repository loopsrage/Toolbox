function DatabasePlay(){
    param(
        [switch]$Execute
    )
    $Names=Invoke-Sqlcmd -Database Dictator -Query "select name from sys.tables"
    foreach($NI in $Names.name){
        $TBuild=Invoke-Sqlcmd -Database Dictator -Query "EXEC sp_fkeys '$NI'"
        $NOJ=@{"CurrentTable"=@($($TBuild.PKTABLE_NAME | Sort-Object -Unique));
            "CurrentColumn"=@($($TBuild.PKCOLUMN_NAME | Sort-Object -Unique));
            "ForeignTable"=@($($TBuild.FKTABLE_NAME | Sort-Object -Unique));
            "ForeignColumn"=@($($TBuild.FKCOLUMN_NAME | Sort-Object -Unique))}
        
        if($NOJ.CurrentTable){
            $TAC=@()
            $Query="select $(foreach($R in $NOJ.currentTable){
                        foreach($M in $NOJ.currentColumn){
                            $DD=$R+$M -split "_"
                            $AL=$DD[0][0]+$DD[1][-1]+"TMPA"
                            if($NOJ.currentColumn.indexof($M) -le $NOJ.currentcolumn.length-1){
                                $R+"."+$M+" as $AL "
                            } else {
                                $R+"."+$M+" as $AL, "
                            }
                        }
                    }) from $($NOJ.CurrentTable[0]),$($NOJ.ForeignTable |  `
                    %{
                        if($NOJ.ForeignTable.IndexOf($_) -le $NOJ.ForeignTable.Length-1){
                            $DBAlias=$(($NOJ.CurrentTable[0] -split "_") | %{$TAC+=$($_[0]+$_[-1])};$TAC[0]+"_"+$TAC[1])
                            $_
                        }else{
                            $_+","
                        }
                        " JOIN $_ as $DBAlias on $($_+"."+$NOJ.currentColumn[0])=$($DBAlias+"."+$NOJ.foreignColumn[0])"
                    })"
            
            if($Execute.IsPresent){
                Invoke-Sqlcmd -Query $Query -Database Dictator
            } else {
                $Query
            }
        }
    }
}