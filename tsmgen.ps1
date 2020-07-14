
<# 
.SYNOPSIS A summary of how the script works and how to use it. 
.DESCRIPTION A long description of how the script works and how to use it. 
.NOTES Information about the environment, things to need to be consider and other information. 
.COMPONENT Information about PowerShell Modules to be required. 
.LINK Useful Link to ressources or others. 
.Parameter ParameterName Description for a parameter in param definition section. Each parameter requires a separate description. 
The name in the description and the parameter section must match. 
#>

$DrivesSerialFile='tsm_sn_drivename'
$DrivesDeviceNamesFile='windows_devices'
$DevicesCleanFile='windows_devices_clean'
$TSMCreatePathCommandFile='commands.txt'

#grep -Ev '0a|Changer' ${DEV_FILENAME} > ${DEV_CLEAN_FILENAME}

Select-String -path $DrivesDeviceNamesFile -CaseSensitive -SimpleMatch -pattern  "0a","Changer" -NotMatch | select-object -ExpandProperty Line| out-file -FilePath $DevicesCleanFile
                        
CLear-content $TSMCreatePathCommandFile

foreach($Line in (get-content $DrivesSerialFile)) {
	Write-Output "Reading line from sn file: $Line"
    #$SERIAL=$line.split(" ")[0]
    #Write-Output  $SERIAL
    $SERIAL=$line.split(' ')[0]
    $SERIAL
    $Line | select-string 'drv\d\d' | select Matches
    #Write-Output $DriveName
    
	#Write-Output "Serial number is: $SERIAL - Drive name is: $DriveName"
	# DEV_FILE_LINE=`grep ${SERIAL} ${DEV_CLEAN_FILENAME}`
	# RET_VAL=$?
	# [ 0 -ne "$RET_VAL" ] && {
	# 	echo "No device entry found for serial (${SERIAL}). Skipping"	
	# 	continue
	# }
	# echo "Found device line in dev file: ${DEV_FILE_LINE}"
	# DEV_PATH=`echo "${DEV_FILE_LINE}"| awk '{print $3}'`
	# echo "Device path is: ${DEV_PATH}"
	# echo "Generating command: define path ${DRIVE_NAME} device=${DEV_PATH}"|tee -a ${COMMAND_FILE}
    
    }