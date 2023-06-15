az login

#Format Date for proper logging
function Get-TimeStamp {
    
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
    
}

#Send an email alert
function Send-Email {

$fromaddress = "sender@domain.com" 
$toaddress = "receiver@domain.com" 
$Subject = "Email Subject" 
$body = "Email Body"
#grab a last written log file and attach to email
$attachment = gci -path 'C:\FilePath' -recurse -Filter *.log | sort LastWriteTime | select -Last 1 | %{$_.FullName}
$smtpserver = "your smtp server" 

$message = new-object System.Net.Mail.MailMessage 
$message.From = $fromaddress 
$message.To.Add($toaddress)
$message.IsBodyHtml = $True 
$message.Subject = $Subject 
$attach = new-object Net.Mail.Attachment($attachment) 
$message.Attachments.Add($attach) 
$message.body = $body 
$smtp = new-object Net.Mail.SmtpClient($smtpserver) 
$smtp.Send($message)
}

#Variables
$ResourceGRP = 'Name of your Azure Resource Group'
$VMName = 'Name of Your VM'

#Query the State of the VM, select only powerState then trim the table heading
$PowerState = az vm show -g $ResourceGRP -n $VMName -d --query '{Power:powerState}' -o table | ? {$_.trim() -ne 'Power' -and $_.trim() -ne '----------'}
#Write-Output $PowerState | ? {$_.trim() -ne 'Power' -and $_.trim() -ne '----------'}

#Write-Output $PowerState

#Check if VM is stopped (powered off), if it is then deallocate. 
if ($PowerState -eq 'VM stopped'){
    
    Write-Output "$(Get-TimeStamp) VM is now in stopped state! Will attempt to deallocate." | Out-File C:\FolderPath\$(get-date -f yyyy-MM-dd)-DeAllocateAZVM.log -Append
    
    az vm deallocate -g $ResourceGRP -n $VMName
    
    Send-Email
    
    } else {
    
    Write-Output "$(Get-TimeStamp) VM is not in stopped state or already deallocated. Will check in an hour"| Out-File C:\FolderPath\$(get-date -f yyyy-MM-dd)-DeAllocateAZVM.log -Append

    } 





