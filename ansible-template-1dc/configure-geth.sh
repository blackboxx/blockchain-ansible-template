#!/bin/bash

# Utility function to exit with message
unsuccessful_exit()
{
  echo "FATAL: Exiting script due to: $1, error code: $2";
  exit $2;
}


#############
# Parameters
#############
# Validate that all arguments are supplied
if [ $# -lt 4 ]; then unsuccessful_exit "Insufficient parameters supplied. Exiting" 30; fi

AZUREUSER=$1;
ARTIFACTS_URL_PREFIX=$4

###########
# Constants
###########
HOMEDIR="/home/$AZUREUSER";
CONFIG_LOG_FILE_PATH="$HOMEDIR/config.log";

#############
# Get the script for running as Azure user
#############
cd "/home/$AZUREUSER";

sudo -u $AZUREUSER /bin/bash -c "wget -N ${ARTIFACTS_URL_PREFIX}configure-geth-azureuser.sh";

##################################
# Initiate loop for error checking
##################################
FAILED_EXITCODE=0
for LOOPCOUNT in `seq 1 5`; do
	sudo -u $AZUREUSER /bin/bash /home/$AZUREUSER/configure-geth-azureuser.sh "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "${10}" "${11}" "${12}" "${13}" "${14}" "${15}">> $CONFIG_LOG_FILE_PATH 2>&1;
	FAILED_EXITCODE=$?
	if [ $FAILED_EXITCODE -ne 0 ]; then
		echo "Exit code: $FAILED_EXITCODE, Command failed on try $LOOPCOUNT, retrying..." >> $CONFIG_LOG_FILE_PATH;
		sleep 5;
		continue;
	else
		echo "======== Deployment successful! ======== " >> $CONFIG_LOG_FILE_PATH;
		exit 0;
	fi
done

echo "One or more commands failed after 5 tries. Deployment failed." >> $CONFIG_LOG_FILE_PATH;
unsuccessful_exit "One or more commands failed after 5 tries. Deployment failed." $FAILED_EXITCODE