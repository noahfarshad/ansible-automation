$current_working=Get-Location
$savepath="$current_working\jenkins_updates\"
New-Item -ItemType directory $savepath

$baseurl="{{ remote_jenkins_update_url }}"
$jenkinsurl="{{ jenkins_repo_url }}"
$dls=Get-Content "$current_working\{{ jenkins_plugins_list_name }}"
$updateCenter="update-center.actual.json"
$date = Get-Date -format ddMMyyHH
$path= "$current_working\logfile-$date.txt"
$logfile =  New-Item -Path $path -ItemType File

#Set up webclient
$client = New-Object system.net.webclient
$client.UseDefaultCredentials = $true
$client.Proxy.Credentials = $client.Credentials

#Loop through the list and download the rpms
foreach ($dl in $dls) {
  #Doing this allows us to add the jenkins.war to the download file
  if (!$dl.EndsWith(".war")) {
    $dl = "$dl.hpi"
  }
  try {
    $client.DownloadFile("$baseurl$dl","$savepath$dl")
  } catch {
    Out-File -FilePath $path -InputObject "Error downloading $dl"
  }
}

#Get the update-center json
$client.DownloadFile("$jenkinsurl$updateCenter","$savepath$updateCenter")

# DEBUG
#Write-Host -NoNewLine 'Press any key to continue...';
#$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');