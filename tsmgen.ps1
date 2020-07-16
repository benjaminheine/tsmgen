
<# 
.SYNOPSIS A summary of how the script works and how to use it. 
.DESCRIPTION A long description of how the script works and how to use it. 
.NOTES Information about the environment, things to need to be consider and other information. 
.COMPONENT Information about PowerShell Modules to be required. 
.LINK Useful Link to ressources or others. 
.Parameter ParameterName Description for a parameter in param definition section. Each parameter requires a separate description. 
The name in the description and the parameter section must match. 
#>

$DrivesSerialFile='tsm_sn_drivename.txt'
$DrivesDeviceNamesFile='windows_devices.txt'
$DevicesCleanFile='windows_devices_clean.txt'
$TSMCreatePathCommandFile='commands.txt'
$PortWWN='5002188709a141d4'

#grep -Ev '0a|Changer' ${DEV_FILENAME} > ${DEV_CLEAN_FILENAME}

Select-String -path $DrivesDeviceNamesFile -CaseSensitive -SimpleMatch -pattern  $PortWWN  | Select-String  -CaseSensitive -SimpleMatch -pattern "Changer" -NotMatch | select-object -ExpandProperty Line | out-file -FilePath $DevicesCleanFile



CLear-content $TSMCreatePathCommandFile

Get-Content $DrivesSerialFile | Select-Object -Skip 3 | Set-Content tsm_sn_drivename_skipped2lines.txt

foreach($Line in (get-content tsm_sn_drivename_skipped2lines.txt)) {
	Write-Output "Reading line from sn file: $Line"
    
	$SERIAL = $Line | Select-String -pattern  "S[0-9]{7,7}.." | % { $_.Matches } | % { $_.Value }
	#$SERIAL
    $DriveName = $Line | select-string 'drv\d\d' | % { $_.Matches } | % { $_.Value }
    #Write-Output $DriveName
    
	Write-Output "Serial number is: $SERIAL - Drive name is: $DriveName"
	$DEV_FILE_LINE=select-string -path $DevicesCleanFile -pattern $SERIAL 
	#Write-Output $?
	 $RET_VAL=$?
	if ( select-string -path $DevicesCleanFile -pattern $SERIAL)
	 {
		Write-Output "Found device line in dev file: `n $DEV_FILE_LINE"
		$DEV_PATH= $DEV_FILE_LINE | Select-String -pattern 'Tape[0-9][0-9]' -allmatches |% { $_.Matches } | % { $_.Value }
		write-output "Device is: $DEV_PATH"
	 } 
	 else
	 {
		Write-Output "No device entry found for serial $SERIAL. Skipping"
	 	
	 }
	# [ 0 -ne "$RET_VAL" ] && {
	# 	echo "No device entry found for serial (${SERIAL}). Skipping"	
	# 	continue
	# }
	# echo "Found device line in dev file: ${DEV_FILE_LINE}"
	# DEV_PATH=`echo "${DEV_FILE_LINE}"| awk '{print $3}'`
	# echo "Device path is: ${DEV_PATH}"
	# echo "Generating command: define path ${DRIVE_NAME} device=${DEV_PATH}"|tee -a ${COMMAND_FILE}
     
    }