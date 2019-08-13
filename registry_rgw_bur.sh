#!/bin/bash

set -e
set -o pipefail
#set -x

# initialization
initialize() {
	# sets colors for use in output
	GREEN='\e[32m'
	BLUE='\e[34m'
	YELLOW='\e[0;33m'
	RED='\e[31m'
	BOLD='\e[1m'
	CLEAR='\e[0m'

	# pre-configure ok, warning, and error output
	OK="[${GREEN}OK${CLEAR}]"
	INFO="[${BLUE}INFO${CLEAR}]"
	NOTICE="[${YELLOW}!!${CLEAR}]"
	ERROR="[${RED}ERROR${CLEAR}]"

	REGISTRY_REPOS="docker/registry/v2/repositories/"
	REGISTRY_BLOBS_PREFIX="docker/registry/v2/blobs/sha256"
}

wait_finished() {
	while true; do
		CURRENT=`ps -ef|grep "$1"|wc -l`
		if [ $CURRENT -ne 1 ]
		then
			echo -e "waiting ..."
			sleep 5
		else
			echo -e "finished!"
			break
		fi
	done
}

registry_rgw_upload() {
	start=`date +%s`
	s3cmd mb s3://$REGISTRY_BUCKET
	# upload registry repositories
	echo -e "${INFO} start to upload repositories ..." \
	&& s3cmd sync registry/$REGISTRY_REPOS s3://$REGISTRY_BUCKET/$REGISTRY_REPOS \
	&& echo -e "${OK} upload repositories successfully" &
	# upload registry blobs
	echo -e "${INFO} start to upload blobs ..."
	for d in registry/$REGISTRY_BLOBS_PREFIX/*; do
		blobs=${d##*/}
		running=($(jobs -rp))
		while [ ${#running[@]} -ge $REGISTRY_CONCURRENT ] ; do
			sleep 1   # this is not optimal, but you can't use wait here
			running=($(jobs -rp))
		done
		echo -e "${INFO} start to upload blobs $blobs ..." \
		&& s3cmd sync $d/ s3://$REGISTRY_BUCKET/$REGISTRY_BLOBS_PREFIX/$blobs/ \
		&& echo -e "${OK} upload blobs $blobs successfully" &
	done

	wait_finished "s3cmd sync"
	end=`date +%s`
	runtime=$((end-start))
	echo -e "${OK} upload registry successfully, and time taken: $runtime seconds"
}

registry_rgw_download() {
	start=`date +%s`
	# download registry repositories
	echo -e "${INFO} start to download repositories ..." \
	&& s3cmd sync s3://$REGISTRY_BUCKET/$REGISTRY_REPOS registry/$REGISTRY_REPOS \
	&& echo -e "${OK} download repositories successfully" &
	# download registry blobs
	echo -e "${INFO} start to download blobs ..."
	for d in `s3cmd ls s3://$REGISTRY_BUCKET/$REGISTRY_BLOBS_PREFIX/|awk '{print $2}'`; do
		d_split=${d::-1}
		blobs=${d_split##*/}
		running=($(jobs -rp))
		while [ ${#running[@]} -ge $REGISTRY_CONCURRENT ] ; do
			sleep 1   # this is not optimal, but you can't use wait here
			running=($(jobs -rp))
		done
		echo -e "${INFO} start to download blobs $blobs ..." \
		&& s3cmd sync $d registry/$REGISTRY_BLOBS_PREFIX/$blobs/ \
		&& echo -e "${OK} download blobs $blobs successfully" &
	done

	wait_finished "s3cmd sync"
	end=`date +%s`
	runtime=$((end-start))
	echo -e "${OK} download registry finished, and time token: $runtime seconds"
}

main() {
	initialize
	if [ "$1" == "-h" ] || [ "$1" != "download" ] && [ "$1" != "upload" ]; then
		echo -e "${NOTICE} Usage:"
		echo -e "${NOTICE} $0, download for registry-rgw"
		echo -e "${NOTICE} $0, upload for registry-rgw"
		exit 0
	fi

	# init registry rgw bucket
	if [ "$2" == "" ]; then
		echo -e "${NOTICE} registry rgw bucket is required"
		exit 0
	fi
	REGISTRY_BUCKET=$2

	# init registry sync concurrent
	if [ "$3" == "" ]; then
		echo -e "${NOTICE} registry sync concurrent is required"
		exit 0
	fi
	REGISTRY_CONCURRENT=$3

	if [ "$1" == "upload" ]; then
		registry_rgw_upload
		echo -e "${OK} registry_rgw_upload finished."
	else
		registry_rgw_download
		echo -e "${OK} registry_rgw_download finished."
	fi
}

main "$@"
