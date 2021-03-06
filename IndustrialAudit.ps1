$excel = new-object -comobject excel.application
#Open the excel layout sitting on my regular account desktop
$workbook = $excel.Workbooks.Open("PATH TO FILE LOCATION\Industrial Audit.xlsx")
#Select the first sheet
$ws = $workbook.WorkSheets.item(1)

# Populate an array with all user objects
$adlist = @()
for($row =2; $row -le $ws.UsedRange.Rows.Count; $row++)
{
    $username = $ws.Cells.Item($row, 9).text
    $adlist += Get-ADUser $username -properties Memberof
}

# Folder owner section ----------------------------
$owners = ""
$allgroups = Get-ADGroup -filter * -properties info
foreach($group in $allgroups)
{
    if($group.info -eq $null -or $group.info -eq "" -or $group.info -eq " ")
    {
        continue
    }
    $count = 0
    foreach($user in $adlist)
    {
        
        $name = $user.Givenname + " " + $user.Surname
        if($group.info -like "*"+$name+"*" -or $group.info -like "*"+$user.Name+"*")
        {
            if($count -eq 0)
            {
                $owners += $group.name + ";" + $name
                $count++
                continue
            }
            if($count -ge 1)
            {
                $owners += ";" + $name
            }
        }
    }
    if($count -ge 1)
    {
        $owners += "`r`n"
    }
}
#------------------------------------------

# Section to get all of the security groups that have an industrial member
# Initialize array
$groupArray = @()
# Step through each user in the list
foreach($user in $adlist)
{
    # Step through each security group this user is a member of
    foreach($group in $user.Memberof)
    {
        # If this security group is not in the array yet then add it and add a counter in the next element
        if($groupArray -notcontains $group)
        {
            $groupArray += $group
            $groupArray += 0
        }
        # If this group is already in the array then increment the counter for the group
        if($groupArray -contains $group)
        {
            $groupArray[([array]::indexof($groupArray, $group)) +1] += 1
        }
    }
}

foreach($group in $groupArray)
{
    if($group -like "CN*")
    {
        $holder = Get-ADGroup $group
        $groupArray[[array]::indexof($groupArray, $group)] = $holder.name
    }
}

[string]$out = "GROUP NAME;TOTAL USERS;DESCRIPTION;SIZE;INDUSTRIAL USERS`r`n"
for($row = 0; $row -lt $groupArray.length; $row++)
{
    $row
    if($row % 2 -eq 0)
    {
        $name = $groupArray[$row]
        $GetInfo = Get-ADGroup -filter {Name -eq $name} -properties Description, Members
        if($GroupArray[$row] -like "#*")
        {
            $out += $groupArray[$row] + ";" + $GetInfo.Members.Count + "; ; ;"
        }
        else
        {
            if($GetInfo.Description -ne $null)
            {if(test-path $GetInfo.Description)
            {
                $size = ((Get-ChildItem $GetInfo.Description -Recurse) | Measure-Object -sum length).sum
                if($size/1GB -ge 1)
                {
                    $outsize = "{0:N2}" -f ($size/1GB) + " GB"
                }
                elseif($size/1MB -ge 1)
                {
                    $outsize = "{0:N2}" -f ($size/1MB) + "MB"
                }
                elseif($size/1KB -ge 1)
                {
                    $outsize = "{0:N2}" -f ($size/1KB) + " KB"
                }
                else
                {
                    $outsize = [string]$size + " Bytes"
                }
            }}
            else{$outsize = "No Path Found"}
            $out += $groupArray[$row] + ";" + $GetInfo.Members.Count + ";" + $GetInfo.Description + ";" + $outsize + ";"
        }
    }
    else
    {
        $out += [string]$groupArray[$row] + "`r`n"
    }
}