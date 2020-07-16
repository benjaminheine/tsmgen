
<# 
.SYNOPSIS This script creates a command file for drivepaths with the right devices.
.DESCRIPTION First you need to create a file named tsm_sn_drivename.txt by running the command "select drive_name,drive_serial from drives where library_name='...'" . You also need to create a file named windows_devices.txt by running tsmdlst.exe. Then start the script. It will search for the devices which WWN is ending on d4 and creating a command file for defining the right path to the library.
.NOTES You need to create the files tsm_sn_drivename.txt and windows_devices.txt first.
.COMPONENT No modules required.
.LINK 
.Parameter ParameterName Description for a parameter in param definition section. Each parameter requires a separate description. 
The name in the description and the parameter section must match. 
#>



$DrivesSerialFile='tsm_sn_drivename.txt'
$DrivesDeviceNamesFile='windows_devices.txt'
$DevicesCleanFile='windows_devices_clean.txt'
$TSMCreatePathCommandFile='commands.txt'
$PortWWN='41d4'


Select-String -path $DrivesDeviceNamesFile -CaseSensitive -SimpleMatch -pattern  $PortWWN  | Select-String  -CaseSensitive -SimpleMatch -pattern "Changer" -NotMatch | select-object -ExpandProperty Line | out-file -FilePath $DevicesCleanFile

CLear-content $TSMCreatePathCommandFile
clear-content tsm_sn_drivename_skipped2lines.txt
Get-Content $DrivesSerialFile | Select-Object -Skip 3 | Set-Content tsm_sn_drivename_skipped2lines.txt

foreach($Line in (get-content tsm_sn_drivename_skipped2lines.txt)) {
	$SERIAL = $Line | Select-String -pattern  "S[0-9]{7,7}.." | % { $_.Matches } | % { $_.Value }
    $DriveName = $Line | select-string 'drv\d\d' | % { $_.Matches } | % { $_.Value }
	Write-Output "Serial number is: $SERIAL - Drive name is: $DriveName"
	$DEV_FILE_LINE=select-string -path $DevicesCleanFile -pattern $SERIAL 
	if ( select-string -path $DevicesCleanFile -pattern $SERIAL)
	 {
		$DEV_PATH= $DEV_FILE_LINE | out-string | Select-String 'Tape[0-9][0-9]' |% { $_.Matches } | % { $_.Value }
		write-output "Device is: $DEV_PATH"
		write-output "define path ${DRIVE_NAME} device=$DEV_PATH"|Tee-object -filepath  $TSMCreatePathCommandFile -Append
	 } 
	 else
	 {
		Write-Output "No device entry found for serial $SERIAL. Skipping"
	 	
	 }
	
	}
	