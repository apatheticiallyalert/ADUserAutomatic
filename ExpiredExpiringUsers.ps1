#=======================================
# Created by: Iain Letourneau
# Last Updated: March 30 2016
# Contact: iain.letourneau@gmail.com
#=======================================

#====================================================================
# This script when run queries AD for all users with an expiration
# date, the script then gets how long until expiry and creates
# an email detailing both users expiring within 1 week and 2 weeks.
# Once the email is compiled and sent the script is done
# This script also checks to see if it is December 1st and sends out
# a month long expiration email.
#====================================================================


#====================================================================
# STEPS TAKEN WITHIN THIS SCRIPT
#====================================================================
# 1 - Get relevant AD users
# 1.1 - Import Active Directory module
# 1.2 - Get all users with an expiration date
#----------------------------------------------
# 2 - Gather data on users
# 2.1 - Step through each user
# 2.1.1 - Compare expiration date to current date
# 2.1.2 - Add users to arrays
# 2.2 - Sort arrays by expiration date then account
#----------------------------------------------
# 3 - Create table for displaying expiring users
# 3.1 - Start table and set style
# 3.2 - Add the table headers to the string
# 3.3 - Add the spanning cell to indicate 1 week users
# 3.4 - Step through each user with one week left
# 3.5 - Add the spanning cell to indicate 2 week users
# 3.6 - Go through each user with 2 weeks left
# 3.7 - End the table string
#----------------------------------------------
# 4 - Compile email message
# 4.1 - Configure sending options
# 4.2 - Compile a signature for Newalta Security Team
# 4.3 - Compile the body of the email
#----------------------------------------------
# SEND EMAIL / END OF SCRIPT
#====================================================================


#====================================================================
#Assigning any variables that need to be
#--------------------------------------------------------------------
import-module activedirectory
# Import all of the variables from the variable list
$getList = "PATH TO POWERSHELL FILE ON SERVER\VariablesChange.ps1"
# Enter in who the email is being sent by
$from = "security <security@example.com>"
. $getList
$Primary = Get-ADUser $PrimaryITAdmin -properties EmailAddress
$PrimaryEmail = $Primary.SAMAccountName + " <" + $Primary.EmailAddress + ">"
$Secondary = Get-ADUser $SecondaryITAdmin -properties EmailAddress
$SecondaryEmail = $Secondary.SAMAccountName + " <" + $Secondary.EmailAddress + ">"

# Get the time to compare against expiration date with
$now = (get-Date).AddDays(3)
$newline = "<br><br>"
$oneWeek = @()
$twoWeek = @()
$onemonth = @()
# Check to see if it is the week of December 1st or not
$December = $null
# Check to see if it is the closest monday to Dec 1st 20??
for($i = 0; $i -lt 7; $i++)
{
    if($now.AddDays($i).Month -eq 12 -and $now.AddDays($i).Day -eq 1)
    {
        # Assign December 1st to the December Variable
        $December = $now.AddDays($i)
    }
}
#====================================================================


#====================================================================
# STEP 1 - GET RELEVANT AD USERS
#====================================================================
# 1.1 - Import Active Directory module
#--------------------------------------------------------------------
#import-module activedirectory
#====================================================================


#====================================================================
# 1.2 - Get all users with an expiration date
#--------------------------------------------------------------------
$users = get-aduser -filter {AccountExpirationDate -like "*"} -properties AccountExpirationDate, description, Manager
#====================================================================


#====================================================================
# STEP 2 - GATHER DATA ON USERS
#====================================================================
# 2.1 - Step through each user
#--------------------------------------------------------------------

foreach($user in $users)
{
    #====================================================================
    # 2.1.1 - Compare expiration date to current date 
    #--------------------------------------------------------------------
    # Create a new timespan from current date and expiration date
    $span = New-Timespan  -Start $now -End $user.AccountExpirationDate
    #====================================================================

    #====================================================================
    # 2.1.2 - Add users to arrays
    #--------------------------------------------------------------------
    # If the expiration date is within 7 days
    if($span.days -ge 0 -and $span.days -lt 6)
    {
        # Add user to the oneWeek array
        $oneWeek += $user
    }
    # If the expiration date is within 7-14 days
    if($span.days -ge 6 -and $span.days -lt 14)
    {
        # Add user to the twoWeek array
        $twoWeek += $user
    }
    # Compile a list of December users
    if($December -ne $null)
    {
    	foreach($user in $users)
    	{
    		if($user.AccountExpirationDate -gt $December -and $user.AccountExpirationDate -le $December.AddMonths(1).AddDays)
    		{
    			$onemonth += $user
    		}
	   }
    }
    #====================================================================
}
#====================================================================

#====================================================================
# 2.2 - Sort arrays by expiration date then account
#--------------------------------------------------------------------
$oneWeek = $oneWeek | Sort-Object AccountExpirationDate,SamAccountName
$twoWeek = $twoWeek | Sort-Object AccountExpirationDate,SamAccountName
$onemonth = $onemonth | Sort-Object AccountExpirationDate,SamAccountName
#====================================================================

#====================================================================
# STEP 3 - CREATE TABLE FOR DISPLAYING USER INFORMATION
#====================================================================
# 3.1 - Start table and set style
#--------------------------------------------------------------------
# Start the table output string
$table = "<table style='border:1px solid black;border-collapse:collapse;width:1200px;'>"
#====================================================================

#====================================================================
# 3.2 - Add the table headers to the string
#--------------------------------------------------------------------
# Add the table headers
$table += "<tr><th bgcolor=#00B0F0 style='border:1px solid black;'>Employee</th>"
$table += "<th bgcolor=#00B0F0 style='border:1px solid black;'>User ID</th>"
$table += "<th bgcolor=#00B0F0 style='border:1px solid black;'>Description</th>"
$table += "<th bgcolor=#00B0F0 style='border:1px solid black;'>Manager</th>"
$table += "<th bgcolor=#00B0F0 style='border:1px solid black;'>Last Working Day</th></tr>"
#====================================================================

$DecTable = $table
$DecTable += "<tr><td colspan=5 style='text-align:center;border:1px solid black;'>December Expirations</td></tr>"

if($oneMonth -ne $null){
foreach($cell in $oneMonth)
{
    # Set the date to be the last working day as opposed to date of expiration
    $date = (Get-Date $cell.AccountExpirationDate).AddDays(-1)
    # Get a nice looking date back from AccountExpirationDate
    $date = (Get-Date $date -format D).substring(0,(Get-Date $date -format D).length -6)
    
    # Check if manager field is blank or not
    if($cell.Manager -ne $null)
    {
        # Get the manager 
        $managerString = $cell.Manager
        $managerString = $managerString.substring(3,$managerString.length -3)
        $manager = $managerString.split("=")[0]
        $manager = $manager.substring(0,$manager.length -3)
        # Check to see if the manager has standard naming convention or not
        if($manager -like "*\*")
        {
            $manLast = $manager.split("\")[0]
            $manFirst = ($manager -split ", ")[1]
            $manager = $manFirst + " " + $manLast
        }
    }
    else
    {
        $manager = "No Manager"
    }
    

    # Add row to table
    $Dectable += "<tr><td bgcolor=#FFC000 style='border:1px solid black;'>"+$cell.Name+"</td>"
    $Dectable += "<td bgcolor=#FFC000 style='border:1px solid black;'>"+ $cell.SamAccountName +"</td>"
    $Dectable += "<td bgcolor=#FFC000 style='border:1px solid black;'>"+ $cell.Description +"</td>"
    $Dectable += "<td bgcolor=#FFC000 style='border:1px solid black;'>"+ $manager + "</td>"
    $Dectable += "<td bgcolor=#FFC000 style='border:1px solid black;'>"+ $date +"</td></tr>"
}
}

#====================================================================
# 3.3 - Add the spanning cell to indicate 1 week users
#--------------------------------------------------------------------
$table += "<tr><td colspan=5 style='text-align:center;border:1px solid black;'>1 Week Until Expiration</td></tr>"
#====================================================================

#====================================================================
# 3.4 - Step through each user with one week left
#--------------------------------------------------------------------

# Check to make sure a user is expiring within 1 week
if($oneWeek -ne $null)
{
foreach($cell in $oneWeek)
{
    # Set the date to be the last working day as opposed to date of expiration
    $date = (Get-Date $cell.AccountExpirationDate).AddDays(-1)
    # Get a nice looking date back from AccountExpirationDate
    $date = (Get-Date $date -format D).substring(0,(Get-Date $date -format D).length -6)
    
    # Check if manager field is blank or not
    if($cell.Manager -ne $null)
    {
        # Get the manager 
        $managerString = $cell.Manager
        $managerString = $managerString.substring(3,$managerString.length -3)
        $manager = $managerString.split("=")[0]
        $manager = $manager.substring(0,$manager.length -3)
        # Check to see if the manager has standard naming convention or not
        if($manager -like "*\*")
        {
            $manLast = $manager.split("\")[0]
            $manFirst = ($manager -split ", ")[1]
            $manager = $manFirst + " " + $manLast
        }
    }
    else
    {
        $manager = "No Manager"
    }
    

    # Add row to table
    $table += "<tr><td bgcolor=#FFC000 style='border:1px solid black;'>"+$cell.Name+"</td>"
    $table += "<td bgcolor=#FFC000 style='border:1px solid black;'>"+ $cell.SamAccountName +"</td>"
    $table += "<td bgcolor=#FFC000 style='border:1px solid black;'>"+ $cell.Description +"</td>"
    $table += "<td bgcolor=#FFC000 style='border:1px solid black;'>"+ $manager + "</td>"
    $table += "<td bgcolor=#FFC000 style='border:1px solid black;'>"+ $date +"</td></tr>"
}
}
# If no user is expiring then state it and move on
else
{
    $table += "<tr><td colspan=5 bgcolor=#FFC000 style='text-align:center;border:1px solid black;'>No users expiring this week</td></tr>"
}
#====================================================================

#====================================================================
# 3.5 - Add the spanning cell to indicate 2 week users
#--------------------------------------------------------------------
$table += "<tr><td colspan=5 style='text-align:center;border:1px solid black;'>2 Weeks Until Expiration</td></tr>"
#====================================================================

#====================================================================
# 3.6 - Go through each user with 2 weeks left
#--------------------------------------------------------------------

# Make sure that there is a user expiring within 2 weeks before outputting cells
if($twoWeek -ne $null)
{
foreach($cell in $twoWeek)
{
    # Set the date to be the last working day as opposed to date of expiration
    $date = (Get-Date $cell.AccountExpirationDate).AddDays(-1)
    # Get a nice looking date back from AccountExpirationDate
    $date = (Get-Date $date -format D).substring(0,(Get-Date $date -format D).length -6)
    
    # Check if manager field is blank or not
    if($cell.Manager -ne $null)
    {
        # Get the manager 
        $managerString = $cell.Manager
        $managerString = $managerString.substring(3,$managerString.length -3)
        $manager = $managerString.split("=")[0]
        $manager = $manager.substring(0,$manager.length -3)
        # Check to see if the manager has standard naming convention or not
        if($manager -like "*\*")
        {
            $manLast = $manager.split("\")[0]
            $manFirst = ($manager -split ", ")[1]
            $manager = $manFirst + " " + $manLast
        }
    }
    else
    {
        $manager = "No Manager"
    }
    
    # Add row to table
    $table += "<tr><td bgcolor=#92D050 style='border:1px solid black;'>"+$cell.Name+"</td>"
    $table += "<td bgcolor=#92D050 style='border:1px solid black;'>"+ $cell.SamAccountName +"</td>"
    $table += "<td bgcolor=#92D050 style='border:1px solid black;'>"+ $cell.Description +"</td>"
    $table += "<td bgcolor=#92D050 style='border:1px solid black;'>"+ $manager +"</td>"
    $table += "<td bgcolor=#92D050 style='border:1px solid black;'>"+ $date +"</td></tr>"
}
}
# If no user is expiring then state it and move on
else
{
    $table += "<tr><td colspan=5 bgcolor=#92D050 style='text-align:center;border:1px solid black;'>No users expiring in 2 weeks</td></tr>"
}
#====================================================================

#====================================================================
# 3.7 - End the table string
#--------------------------------------------------------------------
$table += "</table>"
$DecTable += "</table>"
#====================================================================

#====================================================================
# STEP 4- COMPILE THE EMAIL MESSAGE
#====================================================================
# 4.1 - Configure sending options
#--------------------------------------------------------------------
# Enter in who the email is sent to
[string[]]$to = $PrimaryEmail, "servicedesk <servicedesk@example.com>"
[string[]]$cc = $SecondaryEmail
# Enter in who the email is being sent by
$from = "security <security@example.com>"
# Enter the server smtp address
$smtp = "smtp.example.com"
# Compile the subject string
$subject = "Account Expiration Notice: " + (Get-Date -format D)
#====================================================================

#====================================================================
# 4.2 - Compile a signature for Newalta Security Team
#--------------------------------------------------------------------
$sig = "<b><span style='font-size:8.0pt;font-family:`"Verdana`",`"sans-serif`";color:blue;letter-spacing:1.0pt'>EXAMPLE COMPANY Security Team</span></b>"
$sig += "<span style='font-size:8.0pt;font-family:`"Verdana`",`"sans-serif`";color:blue'>&nbsp;</span>"
$sig += "<span style='font-size:8.0pt;font-family:`"Verdana`",`"sans-serif`";color:gray'>|</span>"
$sig += "<span style='font-size:8.0pt;font-family:`"Verdana`",`"sans-serif`";color:navy'>&nbsp;</span>"
$sig += "<span style='font-size:8.0pt;font-family:`"Verdana`",`"sans-serif`";color:gray;'>IT Security </span>"
$sig += "<span style='font-size:8.0pt;font-family:`"Verdana`",`"sans-serif`";color:gray'>| EXAMPLE COMPANY</span>"
#====================================================================

#====================================================================
# 4.3 - Compile the body of the email
#--------------------------------------------------------------------
$message = "Greetings," + $newline
if($December -ne $null)
{
    $message += "Below is a list of all the Active Directory accounts that will expire within the month of December." + $newline
    $message += $DecTable + $newline
}
else
{
    $message += "Below is a list of all the Active Directory accounts that will expire within 1 and 2 weeks respectively." + $newline
    $message += $table + $newline
}
$message += "Regards," + $newline
$message += $sig
#====================================================================

#====================================================================
# SEND EMAIL / END OF SCRIPT
send-mailmessage -to $to -Cc $cc -from $from -subject $subject -BodyAsHtml $message -smtpServer $smtp
#====================================================================