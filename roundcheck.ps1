param ([Parameter(Mandatory)]$roundlist)

$rounds = get-content -raw -path $roundlist | convertfrom-json

$entries=@()

$roundcount = $rounds.count

foreach($round in $rounds){

    write-host $round.filename

    #build unique rider list from rounds
    $thisround=@()

    $thisround = import-csv $round.filename 

    foreach ($roundentry in $thisround){

        $newentry = $entries | where-object {$_.'last name' -eq $roundentry.'last name' -and $_.'first name' -eq $roundentry.'first name' -and $_.'dob' -eq $roundentry.'dob'}  

        if ($newentry.count -eq 0){

            $objp = [ordered]@{

                'First Name'= $roundentry.'first name'
                'Last Name'=$roundentry.'last name'
                'DOB'=$roundentry.'dob'
                'Member No'=$roundentry.'member no'
                'Class'=$roundentry.'class'
                'Email'=$roundentry.'email'
                'Rounds'=0
                'Roundlist'=""
            }
        
            $entry = new-object -TypeName psobject -Property $objp
        
            $entries += $entry

        }



    }

write-host "Unique Riders " $entries.count


}

# count rounds per unqiue rider
foreach($rider in $entries){
    
    foreach($round in $rounds){

        $thisround=@()

        $thisround = import-csv $round.filename 

        $roundentry = $thisround | where-object {$_.'last name' -eq $rider.'last name' -and $_.'first name' -eq $rider.'first name' -and $_.'dob' -eq $rider.'dob'}  

        if ($roundentry.count -gt 0){

            $rider.'Rounds' ++
            $rider.'roundlist' = $rider.'roundlist' + $round.roundname + ","

        }

    }

}


$outputfile = Split-Path $round[0].filename -leaf

$outputpath = $round[0].filename.replace($outputfile,"R$roundcount-Priority-Checklist.csv")

$entries | export-csv -path $outputpath

write-host "Check Complete"
