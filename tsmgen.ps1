
<# 
.SYNOPSIS This script creates a command file for drivepaths with the right devices.
.DESCRIPTION 
.NOTES 
.COMPONENT No modules required.
.LINK 
.Parameter ParameterName Description for a parameter in param definition section. Each parameter requires a separate description. 
The name in the description and the parameter section must match. 
#>
<# Param(
	[switch]$c = $false
) #>

#region varibales
$tsmuser = Read-host "Please enter tsm username:"
$tsmpassword=read-host "Please enter your password" -AsSecureString
$tsmpassword=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($tsmpassword))
$ScriptPath = $PWD.Path
$DrivesSerialFile='tsm_sn_drivename.txt'
$DrivesDeviceNamesFile='windows_devices.txt'
$DevicesCleanFile='windows_devices_clean.txt'
$TSMCreatePathCommandFile='tsm_define_path_commands.txt'
#endregion variables


#region functions
function connect-tsm($arg1,$arg2,$arg3){
    & $dsmadmc -id="$tsmuser" -password="$tsmpassword" -tcps="$TCPIPServeraddress" -optfile="$tsmoptfile" $arg1 $arg2 $arg3
    }
#endregion functions

#
# Main
#

# Check for config file and ask for creating it. If not only fill configs for this run.
if (test-path -path "$ScriptPath\tsmgen_conf.ps1") {
	write-host "Config file $ScriptPath\tsmgen_conf.ps1 does exist:"
	Get-Content "tsmgen_conf.ps1"
	# Source config file
	. $ScriptPath\tsmgen_conf.ps1
}else {
	$title = "Config file does not exist!"
    $message = "Do you want to go through creation process or? If not you will be asked for configuarations without creating config file"
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $choice=$host.ui.PromptForChoice($title, $message, $options, 1)
	if ($choice -eq '0') {
		New-Item -Path . -Name "tsmgen_conf.ps1" -ItemType "file" | Out-Null
		$TCPIPServeraddress = Read-host "Please enter TCP Server address (Defaul value is localhost):" 
		if(-not($TCPIPServeraddress)){
			$TCPIPServeraddress = 'localhost'
		}
		Add-Content -Path .\tsmgen_conf.ps1 -Value "`$TCPIPServeraddress = `'$TCPIPServeraddress`'"
		$tsmoptfile = read-host 'Please enter path to dsm.opt (Defaul value is "C:\Program Files\Tivoli\TSM\baclient\dsm.opt"):' 
		if(-not($tsmoptfile)){
			$tsmoptfile = 'C:\Program Files\Tivoli\TSM\baclient\dsm.opt'
		}
		Add-Content -Path .\tsmgen_conf.ps1 -Value "`$tsmoptfile = `'$tsmoptfile`'"
		$SourceName = read-host 'please enter TSM source name for creating drive path command (Default value is "TSMLM_DMZ"):' 
		if(-not($tsmoptfile)){
			$SourceName = 'TSMLM_DMZ'
		}
		Add-Content -Path .\tsmgen_conf.ps1 -Value "`$SourceName = `'$SourceName`'"
		$LibraryName = read-host 'Please enter Libraryname (Deafult value is "DD01"):' 
		if(-not($LibraryName)){
			$LibraryName = 'DD01'
		}
		Add-Content -Path .\tsmgen_conf.ps1 -Value "`$LibraryName = `'$LibraryName`'" 
		$PortWWN = read-host 'Please enter last 4 digits from WWN (default value is "41d4"):' 
		if(-not($PortWWN)){
			$PortWWN = '41d4'
		}
		Add-Content -Path .\tsmgen_conf.ps1 -Value "`$PortWWN = `'$PortWWN`'"   
		$TsmDlst = read-host 'Please enter path to tsmdlst (default value is "C:\Program Files\Tivoli\TSM\server\tsmdlst.exe"):' 
		if(-not($TsmDlst)){
			$TsmDlst = 'C:\Program Files\Tivoli\TSM\server\tsmdlst.exe'
		}
		Add-Content -Path .\tsmgen_conf.ps1 -Value "`$TsmDlst = `'$TsmDlst`'"
		$dsmadmc = Read-Host 'Please enter path to dsmadmc.exe (Default value is: "C:\Program Files\Tivoli\TSM\baclient\dsmadmc.exe"):' 
		if(-not($dsmadmc)){
			$dsmadmc = 'C:\Program Files\Tivoli\TSM\baclient\dsmadmc.exe'
		}
		Add-Content -Path .\tsmgen_conf.ps1 -Value "`$dsmadmc = `'$dsmadmc`'" 
		# Source config file
		. $ScriptPath\tsmgen_conf.ps1
	} else {
		$TCPIPServeraddress = Read-host "Please enter TCP Server address (Defaul value is localhost):" 
		if(-not($TCPIPServeraddress)){
			$TCPIPServeraddress = 'localhost'
		}
		$tsmoptfile = read-host 'Please enter path to dsm.opt (Defaul value is "C:\Program Files\Tivoli\TSM\baclient\dsm.opt"):' 
		if(-not($tsmoptfile)){
			$tsmoptfile = 'C:\Program Files\Tivoli\TSM\baclient\dsm.opt'
		}
		$SourceName = read-host 'please enter TSM source name for creating drive path command (Default value is "TSMLM_DMZ"):' 
		if(-not($tsmoptfile)){
			$SourceName = 'TSMLM_DMZ'
		} 
		$LibraryName = read-host 'Please enter Libraryname (Deafult value is "DD01"):' 
		if(-not($LibraryName)){
			$LibraryName = 'DD01'
		} 
		$PortWWN = read-host 'Please enter last 4 digits from WWN (default value is "41d4"):' 
		if(-not($PortWWN)){
			$PortWWN = '41d4'
		}   
		$TsmDlst = read-host 'Please enter path to tsmdlst (default value is "C:\Program Files\Tivoli\TSM\server\tsmdlst.exe"):' 
		if(-not($TsmDlst)){
			$TsmDlst = 'C:\Program Files\Tivoli\TSM\server\tsmdlst.exe'
		} 
		$dsmadmc = Read-Host 'Please enter path to dsmadmc.exe (Default value is: "C:\Program Files\Tivoli\TSM\baclient\dsmadmc.exe"):' 
		if(-not($dsmadmc)){
			$dsmadmc = 'C:\Program Files\Tivoli\TSM\baclient\dsmadmc.exe'
		}
	}
}



# Clear file and query tsm server for drives and serials and store result in file.
Clear-Content $DrivesSerialFile
connect-tsm "select drive_name,drive_serial from drives where library_name=$LibraryName" | out-file $DrivesSerialFile

# Clear file and create file with output from tsmdlst.exe
clear-content $DrivesDeviceNamesFile
& $TsmDlst | out-file $DrivesDeviceNamesFile

# Clear file and create file filtered only lines with the right WWN ending.
Clear-Content $DevicesCleanFile
Select-String -path $DrivesDeviceNamesFile -CaseSensitive -SimpleMatch -pattern  $PortWWN  | Select-String  -CaseSensitive -SimpleMatch -pattern "Changer" -NotMatch | select-object -ExpandProperty Line | out-file -FilePath $DevicesCleanFile

# Clear command file and help file
CLear-content $TSMCreatePathCommandFile
clear-content tsm_sn_drivename_skipped2lines.txt

# Create help file with drives and associated serial number
Get-Content $DrivesSerialFile | Select-Object -Skip 3 | Set-Content tsm_sn_drivename_skipped2lines.txt

# Iterate through each line from helpfile with drivename and serial, take serial and drivename, search in device list for aossociated device and create path
foreach ( $Line in ( get-content tsm_sn_drivename_skipped2lines.txt ) ) {
	$SERIAL = $Line | Select-String -pattern  "S[0-9]{7,7}.." | % { $_.Matches } | % { $_.Value }
    $DriveName = $Line | select-string 'drv\d+' | % { $_.Matches } | % { $_.Value }
	Write-Output "Serial number is: $SERIAL - Drive name is: $DriveName"
	$DEV_FILE_LINE = select-string -path $DevicesCleanFile -pattern $SERIAL 
	if ( select-string -path $DevicesCleanFile -pattern $SERIAL)
	 {
		$DEV_PATH = $DEV_FILE_LINE | out-string | Select-String 'Tape[0-9]+' | % { $_.Matches } | % { $_.Value }
		write-output "Device is: $DEV_PATH"
		write-output "define path $SourceName $DriveName srctype=Server destt=drive library=$LibraryName device=\\.\$DEV_PATH" | Add-content -path  $TSMCreatePathCommandFile 
	 } 
	 else
	 {
		Write-Output "No device entry found for serial $SERIAL. Skipping"
	 	
	 }
}
	