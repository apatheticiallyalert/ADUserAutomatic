#Get the current date
$now = get-date
$message = ""
$newline = "<br>"
#Make sure the script runs in the correct place
cd "PATH TO SCRIPTS\Scripts\Excels"

#These will change in the future but for now it is best just to send them to myself until tested
$to = "iletourn <iletourneau@example.com>"
$from = "iletourn <iletourneau@example.com>"
$smtp = "caloutlook.newalta.com"

#Create my Signature as per how it is normally
$sig = $newline + $newline + "<b><span style='font-size:8.0pt;font-family:`"Verdana`",`"sans-serif`";color:blue;letter-spacing:1.0pt'>Iain Letourneau</span></b>"
$sig += "<span style='font-size:8.0pt;font-family:`"Verdana`",`"sans-serif`";color:blue'>&nbsp;</span>"
$sig += "<span style='font-size:8.0pt;font-family:`"Verdana`",`"sans-serif`";color:gray'>|</span>"
$sig += "<span style='font-size:8.0pt;font-family:`"Verdana`",`"sans-serif`";color:navy'>&nbsp;</span>"
$sig += "<span style='font-size:8.0pt;font-family:`"Verdana`",`"sans-serif`";color:gray;'>IT Security </span>"
$sig += "<span style='font-size:8.0pt;font-family:`"Verdana`",`"sans-serif`";color:gray'>Analyst | EXAMPLE</span>" + $newline + $newline
$sig += "<span style='font-size:8.0pt;font-family:`"Verdana`",`"sans-serif`";color:gray;'>Corporate Office | 211 - 11 Avenue SW |&nbsp;Calgary, AB&nbsp; T2R-0C6&nbsp;</span>"
$sig += $newline + $newline + "<span style='font-size:8.0pt;font-family:`"Verdana`",`"sans-serif`";color:gray;'>403-806-9915 Office"+$newline+"</span>"
$sig += "<span style='font-size:8.0pt;font-family:`"Verdana`",`"sans-serif`";color:gray;'><a href=`"http://www.example.com`">www.example.com</a></span>"




#Get all the open tickets waiting for approval
$tickets = Get-ChildItem | ?{$_.Name -like "Ticket ?????? - *"}

#Go through each excel file that is a ticket file
foreach($file in $tickets)
{
    #Get the ticket # out of the filename
    $namesplit = $file.Name.Split(" ")
    $ticknum = $namesplit[1]
    #Get the targetted user receiving permissions
    $target = $namesplit[3] + " " + $namesplit[4]
    #Get the user requesting the permissions be given
    $requsr = $namesplit[11] + " " + $namesplit[12]
    $requsr = $requsr.substring(0,$requsr.length-5)
    #Get the amount of time the file has been sitting there
    $length = new-timespan -start $file.creationTime -end $now
    
    
    #If the file is 7 days old then remind me to send 1 week notification
    if($length.days -eq 7 -or $length.days -ge 14)
    {
        $subject = "Email notification"
        
         #Get the excel information for reading from the files
        $strPath=$file.FullName
        $objExcel=New-Object -ComObject Excel.Application
        $objExcel.Visible=$false
        $WorkBook=$objExcel.Workbooks.Open($strPath)
        $WorkSheet=$WorkBook.sheets.item(1)
        $intRowMax=($WorkSheet.UsedRange.Rows).Count
        
        #this grabs all the names, descriptions, owners, and status
        for($intRow = 2; $intRow -le $intRowMax; $intRow++)
        {
            $gOwnr = $null
            #Only step into the cell if the status is null
            if($worksheet.cells.item($intRow,4).value2 -eq $null)
            {
                #Get the group name, description and owner
                $gName = $worksheet.cells.item($intRow,1).value2
                $gDesc = $worksheet.cells.item($intRow,2).value2
                $gOwnr = $worksheet.cells.item($intRow,3).value2
                $gLastOwnr = $worksheet.cells.item($intRow -1, 3).value2
                
                # Check to see if there is a gOwnr or not
                if($gOwnr -ne $null)
                {               
                    $gOwnrSplit = $gOwnr.Split(" ")
                    #Start structuring the message
                    #-- This section is temporary-----------------------------------------------
                    #-- State the Group Owner and the Requesting User---------------------------
                    #-- This is to make it easy to forward the message to the correct parties---
                    
                    $message += $newline + $newline + $gOwnrSplit[1] + " " + $gOwnrSplit[2]
                    $message += $newline + $newline + $requsr
                    $message += $newline + $newline + "Ticket #" + $ticknum 
                    $message += $newline + $newline + $newline
                    $message += "Morning " + $gOwnrSplit[1] + "," + $newline + $newline
                    if($length.days -eq 7)
                    {
                        $message += "This is a reminder as it has been 1 week since a request was sent on behalf of " + $requsr + " to grant " + $target + " access to the following"
                    }
                    if($length.days -ge 14)
                    {
                        $message += "It has been about 2 weeks since I initially sent a request on behalf of " + $requsr + " to grant " + $target + " access to the following"
                    }
                    $message +=  $newline + $newline + "Group Name: " + $gName + $newline
                    $message += "Description: " + $gDesc + $newline
                    $message += $gOwnr + $newline + $newline
                    
                    #Send a different message depending on the period of time the ticket has been open
                    if($length.days -eq 7)
                    {
                        $message += "As the listed owner do you APPROVE or DENY this request?" + $newline + $newline
                    }
                    if($length.days -ge 14)
                    {
                        $message += "As the listed owner I need your approval to grant this request.  If I do not hear back from you I will treat it as a denial." + $newline + $newline
                    }
                    $message += "Thanks,"
                    $message += $sig
                }
            }
        }
        #Close the excel object
        $workbook.Close()
        $objExcel.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($worksheet)
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook)
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($ObjExcel)
        Remove-Variable worksheet
        Remove-Variable workbook
        Remove-Variable ObjExcel
    }

    
}

if($to -eq $null)
{
    exit
}
send-mailmessage -to $to -from $from -subject $subject -BodyAsHtml $message -smtpServer $smtp
