
<# 
.SYNOPSIS This script creates a command file for drivepaths with the right devices.
.DESCRIPTION First you need to create a file named tsm_sn_drivename.txt by running the command "select drive_name,drive_serial from drives where library_name='...'" . You also need to create a file named windows_devices.txt by running tsmdlst.exe. Then start the script. It will search for the devices which WWN is ending on d4 and creating a command file for defining the right path to the library.
.NOTES You need to create the files tsm_sn_drivename.txt and windows_devices.txt first.
.COMPONENT No modules required.
.LINK 
.Parameter ParameterName Description for a parameter in param definition section. Each parameter requires a separate description. 
The name in the description and the parameter section must match. 
#>
Param(
    [string]$tsmoptfile = 'C:\Program Files\Tivoli\TSM\baclient\dsm.opt',
    [string]$tsmuser,
    [int]$IntegerParameter = 10,
    [switch]$SwitchParameter
)

#region varibales
$tsmpassword=read-host "Please enter your password for User tapeachanger" -AsSecureString
$tsmpassword=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($tsmpassword))
$dsmadmc=read-host "Please enter dsm.opt pathname:"'C:\Program Files\Tivoli\TSM\baclient\dsmadmc.exe'
$DrivesSerialFile='tsm_sn_drivename.txt'
$DrivesDeviceNamesFile='windows_devices.txt'
$DevicesCleanFile='windows_devices_clean.txt'
$TSMCreatePathCommandFile='commands.txt'
$PortWWN='41d4'
$LibraryName='DD01'
$SourceName='TSMLM_DMZ'
#endregion variables
#region functions
function connect-tsm($arg1,$arg2,$arg3){
    & $dsmadmc -id="$tsmuser" -password="$tsmpassword" -tcps="$TCPIPServeraddress" -optfile="$tsmoptfile" $arg1 $arg2 $arg3
    }


#endregion functions

#
# Main
#
# Create file filtered only lines with the right WWN ending
Select-String -path $DrivesDeviceNamesFile -CaseSensitive -SimpleMatch -pattern  $PortWWN  | Select-String  -CaseSensitive -SimpleMatch -pattern "Changer" -NotMatch | select-object -ExpandProperty Line | out-file -FilePath $DevicesCleanFile

# Clear command file and help file
CLear-content $TSMCreatePathCommandFile
clear-content tsm_sn_drivename_skipped2lines.txt

# Create help file with drives and associated serial number
Get-Content $DrivesSerialFile | Select-Object -Skip 3 | Set-Content tsm_sn_drivename_skipped2lines.txt

# Iterate through each line from helpfile with drivename and serial, take serial and drivename, search in device list for aossociated device and create path
foreach($Line in (get-content tsm_sn_drivename_skipped2lines.txt)) {
	$SERIAL = $Line | Select-String -pattern  "S[0-9]{7,7}.." | % { $_.Matches } | % { $_.Value }
    $DriveName = $Line | select-string 'drv\d+' | % { $_.Matches } | % { $_.Value }
	Write-Output "Serial number is: $SERIAL - Drive name is: $DriveName"
	$DEV_FILE_LINE=select-string -path $DevicesCleanFile -pattern $SERIAL 
	if ( select-string -path $DevicesCleanFile -pattern $SERIAL)
	 {
		$DEV_PATH= $DEV_FILE_LINE | out-string | Select-String 'Tape[0-9]+' |% { $_.Matches } | % { $_.Value }
		write-output "Device is: $DEV_PATH"
		write-output "define path $SourceName $DriveName srctype=Server destt=drive library=$LibraryName device=\\.\$DEV_PATH"|Add-content -path  $TSMCreatePathCommandFile 
	 } 
	 else
	 {
		Write-Output "No device entry found for serial $SERIAL. Skipping"
	 	
	 }
	
	}
	