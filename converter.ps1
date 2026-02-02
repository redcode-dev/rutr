param ([Parameter(Mandatory)]$filename,$raceyear,$classlist)

# Demo call
#  ./converter.ps1 -filename '/Users/jonredstone/Downloads/raw_data-4.csv' -raceyear 2022 -classlist '/Users/jonredstone/Documents/RUTR2021/expertclasses.json'

# Outputs file with + prefix to input file name in same folder

$header = "Online entry","Sale ID","First Name","Last Name","Club Team Name","DOB","Is BC Member","Member No","Agree terms and conditions","Agree email confirmation","Agree email marketing","Licence Category","Gender","Email","Daytime phone","Address 1","Address 2","Town/City","Region","Country","Postcode","Emergency Contact Name","Emergency Contact Phone Number","Date Paid","Amount Paid","Refund Amount","Payment Type","Status","Plate Number"

$inputfile = $filename

$myfile = import-csv $inputfile -header $header

$eventname = $myfile[0].'Online entry'

$entries=@()

$classes = get-content -raw -path $classlist | convertfrom-json

$rownumber = 0

foreach($row in $myfile){

    if ($row.'Online entry' -eq $eventname){

        $class = $myfile[$rownumber +1].'online entry'

    }

    if ($row.'Online entry'.Replace('="',"").replace('"',"") -eq 'Yes' -or $row.'Online entry'.Replace('="',"").replace('"',"") -eq 'No'){

        #$objp = @{}

        # Remove all possible null values
        $OnlineEntry= $row.'Online entry' ?? ""
        $SaleID= $row.'Sale ID' ?? ""
        $FirstName= $row.'First Name' ?? ""
        $LastName=$row.'Last Name' ?? ""
        $ClubTeamName=$row.'Club Team Name' ?? ""
        $DOB=$row.'DOB' ?? ""
        $IsBCMember=$row.'Is BC Member' ?? ""
        $MemberNo=$row.'Member No' ?? ""
        $Agreetermsandconditions=$row.'Agree terms and conditions' ?? ""
        $Agreeemailconfirmation=$row.'Agree email confirmation' ?? ""
        $Agreeemailmarketing=$row.'Agree email marketing' ?? ""
        $LicenceCategory=$row.'Licence Category' ?? ""
        $Gender=$row.'Gender' ?? ""
        $Email=$row.'Email' ?? ""
        $Daytimephone=$row.'Daytime phone' ?? ""
        $Address1=$row.'Address 1' ?? ""
        $Address2=$row.'Address 2' ?? ""
        $TownCity=$row.'Town/City' ?? ""
        $Region=$row.'Region' ?? ""
        $Country=$row.'Country' ?? ""
        $Postcode=$row.'Postcode' ?? ""
        $EmergencyContactName=$row.'Emergency Contact Name' ?? ""
        $EmergencyContactPhoneNumber=$row.'Emergency Contact Phone Number' ?? ""
        $DatePaid=$row.'Date Paid' ?? ""
        $AmountPaid=$row.'Amount Paid' ?? ""
        $RefundAmount=$row.'Refund Amount' ?? ""
        $PaymentType=$row.'Payment Type' ?? ""
        $Status=$row.'Status' ?? ""
        $PlateNumber = $row.'Plate Number' ?? ""

        $realdob = $row.dob.Replace('="',"").replace('"',"").split("/")

        $raceage = [int] $raceyear - $realdob[2]

        $objp = [ordered]@{

        'Online Entry'= $onlineentry.Replace('="',"").replace('"',"")
        'Sale ID'= $saleid.Replace('="',"").replace('"',"")
        'First Name'= $firstname.Replace('="',"").replace('"',"")
        'Last Name'=$lastname.Replace('="',"").replace('"',"")
        'Club Team Name'=$clubteamname.Replace('="',"").replace('"',"")
        'DOB'=$dob.Replace('="',"").replace('"',"")
        'RaceAge'= $raceage
        'Class'=$Class
        'Is BC Member'=$isbcmember.Replace('="',"").replace('"',"")
        'Member No'=$memberno.Replace('="',"").replace('"',"")
        'Agree terms and conditions'=$agreetermsandconditions.Replace('="',"").replace('"',"")
        'Agree email confirmation'=$agreeemailconfirmation.Replace('="',"").replace('"',"")
        'Agree email marketing'=$agreeemailmarketing.Replace('="',"").replace('"',"")
        'Licence Category'=$licencecategory.Replace('="',"").replace('"',"")
        'Gender'=$gender.Replace('="',"").replace('"',"")
        'Email'=$email.Replace('="',"").replace('"',"")
        'Daytime phone'=$daytimephone.Replace('="',"").replace('"',"")
        'Address 1'=$address1.Replace('="',"").replace('"',"")
        'Address 2'=$address2.Replace('="',"").replace('"',"")
        'Town/City'=$towncity.Replace('="',"").replace('"',"")
        'Region'=$region.Replace('="',"").replace('"',"")
        'Country'=$country.Replace('="',"").replace('"',"")
        'Postcode'=$postcode.Replace('="',"").replace('"',"")
        'Emergency Contact Name'=$emergencycontactname.Replace('="',"").replace('"',"")
        'Emergency Contact Phone Number'=$emergencycontactphonenumber.Replace('="',"").replace('"',"")
        'Date Paid'=$datepaid.Replace('="',"").replace('"',"")
        'Amount Paid'=$amountpaid.Replace('="',"").replace('"',"")
        'Refund Amount'=$refundamount.Replace('="',"").replace('"',"")
        'Payment Type'=$paymenttype.Replace('="',"").replace('"',"")
        'Status'=$status.Replace('="',"").replace('"',"")
        'Plate Number'=$platenumber.Replace('="',"").replace('"',"")
        'Missing Plate'=""    
        'Duplicate Plate'=""    
        'Not Paid'=""    
        'Refunded'=""    
        'Age Problem'=""    
        'Duplicate Entry'=""    
        'Temp Licence'=""    
        }    
    

        $entry = new-object -TypeName psobject -Property $objp

   

   
        $entries += $entry


    }

    $rownumber++


}

# Checks go here

# Missing Licence No

foreach($entry in $entries){
    
    if ($entry.'Member No' -eq ""){
        write-host "Missing Licence No" $entry.'Last Name' $entry.'First Name' $entry.'class' $entry.'Plate Number'

        [string]$first = $entry.'first name'
        $firstinit = $first.substring(0,1)

        [string]$last = $entry.'last name'
        $lastinit = $last.substring(0,1)
        
        [string]$tmpdob = $entry.'dob'
        $strdob = $tmpdob.replace("/","")


        $entry.'Temp Licence' = "Missing Licence Suggest," + "NV" + $firstinit + $lastinit + $strdob
    }

}


# Missing Number plates

foreach($entry in $entries){
    
    if ($entry.'Plate Number' -notmatch ".*\d+.*"){
        write-host "Missing Plate No" $entry.'Last Name' $entry.'First Name' $entry.'class' $entry.'Plate Number'
        $entry.'missing plate' = "Missing Plate No" 
    }

}

# Duplicate Plates

foreach($cls in $classes){

    $ridersinthisclass = $entries | where-object {$_.Class -eq $cls.name} 
    
    foreach($rider in $ridersinthisclass){

        $checkplate = $rider.'Plate Number'

        if($checkplate -ne ""){
      
            $duplicateplates = $ridersinthisclass | where-object {$_.'Plate Number' -eq $checkplate} 

            if ($duplicateplates.count -gt 1){

                    write-host "Duplicate Plate " $rider.'Last Name' $rider.'First Name' $rider.class $rider.'Plate Number'                
                    $rider.'duplicate plate' = "Duplicate Plate"
            }
        }


    }
 

}


# Not Paid
foreach($entry in $entries){
    
    if ([decimal]$entry.'Amount Paid' -eq 0){
        write-host "Not Paid" $entry.'Last Name' $entry.'First Name' $entry.'class' $entry.'Amount Paid'
        $entry.'not paid' = "Not Paid"        
    }

}

# Refunds
foreach($entry in $entries){
    
    if ([decimal]$entry.'Refund Amount' -ne 0){
        write-host "Refund Issued" $entry.'Last Name' $entry.'First Name' $entry.'class' $entry.'Refund Paid' $entry.'Status'
        $entry.'refunded' = "Refunded-" + $entry.'status' 
    }

}

# Wrong Age

foreach($entry in $entries){

    $thisclass = $classes | where-object {$_.Name -eq $entry.class}  
 
    
#write-host $entry.'First Name' $entry.'Last Name' $entry.'DOB' $entry.'RaceAge'  $thisclass.name $entry.class 

    if ($entry.raceage -lt $thisclass.min -or $entry.raceage -gt $thisclass.max){


            if($thisclass.min - [int]$entry.raceage -gt 3){

                write-host "To Young for Class" $entry.'Last Name' $entry.'First Name' $entry.'class' $entry.'raceage' $thisclass.min $thisclass.max
                $entry.'age problem' = "To Young for Class" 
            }
            elseif  ($entry.raceage -lt $thisclass.min){

                write-host "Riding Up" $entry.'Last Name' $entry.'First Name' $entry.'class' $entry.'raceage' $thisclass.min $thisclass.max
                $entry.'age problem' = "Riding Up"         
            }


        if ($entry.raceage -gt $thisclass.max){

            write-host 

            write-host "To Old for Class" $entry.'Last Name' $entry.'First Name' $entry.'class' $entry.'raceage' $thisclass.min $thisclass.max
            $entry.'age problem' = "To Old for Class"
        }

    }


}

# Duplicate Entries

foreach($entry in $entries){

    $id = $entry.'last name' + $entry.'dob'

    $duplicates = $entries | where-object {$_.'last name' -eq $entry.'last name' -and $_.'first name' -eq $entry.'first name' -and $_.'dob' -eq $entry.'dob'}  

    if($duplicates.count -gt 1){

        $classtype20 = 0
        $classtype24 = 0

        foreach($dupe in $duplicates){

            $thisclass = $classes | where-object {$_.Name -eq $dupe.class}  

            if($thisclass.wheel -eq 20){
                $classtype20 ++
            } 

            if($thisclass.wheel -eq 24){
                $classtype24 ++
            } 

        }

        if($classtype20 -gt 1 -or $classtype24 -gt 1){

            write-host "Possible Duplicate Entry " $entry.'Last Name' $entry.'First Name' $entry.class $entry.'Plate Number'                
            $entry.'duplicate entry' = "Possible Duplicate Entry"            
        }
      

    }

}

$outputfile = Split-Path $inputfile -leaf

$outputpath = $inputfile.replace($outputfile,"_$outputfile")

$entries | export-csv -path $outputpath

