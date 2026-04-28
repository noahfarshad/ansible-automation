
function Enable-TLS {

    function RegistryEntry($path, $name, $value) {

        if(test-path $path) {
            New-ItemProperty -Path $path -Name $name -Value $value -PropertyType DWord -Force | Out-Null
        }
    }

    ### Turn on TLS1.2 for IE WinHTTP
    $registryPathWinHTTP = ".\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHTTP\"
    $registryPathWinHTTP64Bit = ".\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHTTP\"
    $nameWinHTTP = "DefaultSecureProtocols"
    $valueWinHTTP = "0xA80"

    ### Turn on TLS1.2 for IE
    $registryPathIE = ".\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\"
    $registryPathIE64Bit = ".\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\"
    $nameIE = "SecureProtocols"
    $valueIE = "0xA80"

    ### Turn on TLS1.2 at the machine level
    $registryPathComponent1 = ".\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2"
    $registryPathComponent2Client = ".\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client"
    $registryPathComponent3Server = ".\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server"
    $nameComp1 = "DisabledByDefault"
    $nameComp2 = "Enabled"
    $valueComp1 = "0"
    $valueComp2 = "1"

    Set-Location HKLM:

    ### Turn on TLS1.2 for IE WinHTTP
    RegistryEntry $registryPathWinHTTP $nameWinHTTP $valueWinHTTP
    RegistryEntry $registryPathWinHTTP64Bit $nameWinHTTP $valueWinHTTP

    ### Turn on TLS1.2 for IE
    RegistryEntry $registryPathIE $nameIE $valueIE
    RegistryEntry $registryPathIE64Bit $nameIE $valueIE

    ### Turn on TLS1.2 at the machine level
    if ( -not (Test-Path $registryPathComponent1)) {
         New-Item -Path $registryPathComponent1 
    }
    if ( -not (Test-Path $registryPathComponent2Client)) { 
        New-Item -Path $registryPathComponent2Client
    }        
    if ( -not (Test-Path $registryPathComponent3Server)) { 
        New-Item -Path $registryPathComponent3Server 
    }

    RegistryEntry $registryPathComponent2Client $nameComp1 $valueComp1
    RegistryEntry $registryPathComponent2Client $nameComp2 $valueComp2
    RegistryEntry $registryPathComponent3Server $nameComp1 $valueComp1
    RegistryEntry $registryPathComponent3Server $nameComp2 $valueComp2


    ### Turn on TLS1.2 for IE on Current User hive
    Set-Location HKCU:

    RegistryEntry $registryPathIE $nameIE $valueIE
    RegistryEntry $registryPathIE64Bit $nameIE $valueIE

    Set-Location c:
}

Enable-TLS

Restart-Computer -Force