#!/bin/bash

#check download blobs
blobs_num=`s3cmd ls s3://$1/docker/registry/v2/blobs/sha256/|wc -l`
download_blobs=`cat log |grep 'download blobs'|grep OK|wc -l`
if [ $blobs_num -eq $download_blobs ]
then
	echo "download registry rgw blobs successfully"
else
	echo "download registry rgw blobs failure"
fi
#check download repository
download_repo=`cat log |grep 'download repo'|grep OK|wc -l`
if [ $download_repo -eq 1 ]
then
	echo "download registry rgw repositories successfully"
else
	echo "download registry rgw repositories failure"
fi
