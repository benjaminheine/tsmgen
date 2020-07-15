
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
$DevicesCleanFile='windows_devices_clean'
$TSMCreatePathCommandFile='commands.txt'

#grep -Ev '0a|Changer' ${DEV_FILENAME} > ${DEV_CLEAN_FILENAME}

Select-String -path $DrivesDeviceNamesFile -CaseSensitive -SimpleMatch -pattern  "5002188709a141d4"  | Select-String  -CaseSensitive -SimpleMatch -pattern "Changer" -NotMatch | select-object -ExpandProperty Line | out-file -FilePath $DevicesCleanFile



CLear-content $TSMCreatePathCommandFile

foreach($Line in (get-content $DrivesSerialFile)) {
	Write-Output "Reading line from sn file: $Line"
    
	$SERIAL = $Line | Select-String -pattern  "S[0-9]{7,7}.." | % { $_.Matches } | % { $_.Value }
	#$SERIAL
    $DriveName = $Line | select-string 'drv\d\d' | % { $_.Matches } | % { $_.Value }
    #Write-Output $DriveName
    
	Write-Output "Serial number is: $SERIAL - Drive name is: $DriveName"
# DEV_FILE_LINE=`grep ${SERIAL} ${DEV_CLEAN_FILENAME}`
	$DEV_FILE_LINE=select-string -path $DevicesCleanFile -pattern $SERIAL 
	
	$RET_VAL=$?
	if ( 0 -ne $RET_VAL)
	{
		Write-Output No device entry found for serial $SERIAL. Skipping"
	} 
	else
	{}
	# [ 0 -ne "$RET_VAL" ] && {
	# 	echo "No device entry found for serial (${SERIAL}). Skipping"	
	# 	continue
	# }
	# echo "Found device line in dev file: ${DEV_FILE_LINE}"
	# DEV_PATH=`echo "${DEV_FILE_LINE}"| awk '{print $3}'`
	# echo "Device path is: ${DEV_PATH}"
	# echo "Generating command: define path ${DRIVE_NAME} device=${DEV_PATH}"|tee -a ${COMMAND_FILE}
    
    }