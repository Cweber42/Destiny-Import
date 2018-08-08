 do {
	& C:\scripts\CognosDownload.ps1 studentinfo C:\scripts\Destiny
	
	if ($LASTEXITCODE -ne 0) {
		write-host "Failed to download Cognos Report"
		$numtries++
		if ($numtries -gt 3) { exit }
		Start-Sleep 5s
	} else {
		$success = $true
	}
	
} while (!$success);


 #Csv Import File
       $FilePath = "c:\scripts\destiny\studentinfo.csv"

        #Output path for Destiny Import
        $Output = "c:\scripts\destiny\destinyupdate\destinyImport.csv"
        
        #New csv object
        $Destiny = @()

        #Import Csv
        $Students = Import-Csv $FilePath

        #Loop that runs code on each row of csv
        foreach($Student in $Students) {
            $StudentID = [int]$Student.StudentID

#Use Grade from csv file to find shortname
#Shortname provided by Destiny for each library location
            Switch($Student.Grade) {
                "12" { $ShortName = "DHS" }
                "11" { $ShortName = "DHS" }
                "10" { $ShortName = "DHS" }
                "09" { $ShortName = "DHS" }
                "08" { $ShortName = "DMS" }
                "07" { $ShortName = "DMS" }
                "06" { $ShortName = "DMS" }
                "05" { $ShortName = "DMS" }
                "04" { $ShortName = "DNE" }
                "03" { $ShortName = "DNE" }
                "02" { $ShortName = "DNE" }
                "01" { $ShortName = "DNE" }
                "KF" { $ShortName = "DNE" }
                Default { $ShortName = "DSD" }
            }

#If Student is Active use Student ID to find Username in AD
#If($Student.Status -eq "A") {
#Assumes that Student ID is in Title field of AD User account
#$ADUser = Get-ADUser -Filter { Title -Like $StudentID } -Properties * -ErrorAction SilentlyContinue
#If($ADUser -eq $Nul) { $Username = ""}
#Else { $UserName = $ADUser.sAMAccountName }
#Clear-Variable ADUser}
#Else { $Username = "" }

	    $Username = "$($Student.FirstName).$($Student.LastName)$(Student."Graduation Year").substring(2)"
           
	    #Add Password (you can also add code to generate a password here.
           # Do {
           #    $PassColor = Get-Random -Input "White", "Blue", "Red", "Yellow", "Green", "Orange", "Brown", "Pink", "Violet"
           # } Until ($FirstName -notmatch $PassColor -And $LastName -notmatch $PassColor)
           # $PassNum = [math]::Round((Get-Random -Max (([math]::pow(10,(8 - $PassColor.Length))) - 1) -Min ([math]::pow(10,(8 - $PassColor.Length - 1)))),0)
            $Password = "Temppass1"


            #Clean up a few fields in csv for import into Destiny
            #$Student.StudentID = $($Student.StudentID).Trim()
            $Student.FirstName = $($Student.FirstName).Trim()
            $Student.LastName = $($Student.LastName).Trim()

            #Email address
            $domain = "@school.com"
            $email = $username + $domain
            
            #Patron Type
            $Patron = "Student"

            #Add new fields to row object
            Add-Member -InputObject $Student -Name "UserName" -Value "$Username" -MemberType NoteProperty -Force
            Add-Member -InputObject $Student -Name "Password" -Value "$Password" -MemberType NoteProperty -Force
            Add-Member -InputObject $Student -Name "SiteShortName" -Value "$ShortName" -MemberType NoteProperty -Force
            Add-Member -InputObject $Student -Name "Email" -Value "$email" -MemberType NoteProperty -Force
            Add-Member -InputObject $Student -Name "PatronType" -Value "$Patron" -MemberType NoteProperty -Force
           
            #Add row object to new csv object
            $Destiny += $Student
        

        #Export Data to Destiny Server
        $Destiny | Export-Csv $Output -noType
}
