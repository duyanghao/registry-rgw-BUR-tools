#!/bin/bash

#check upload blobs
blobs_num=`ls registry/docker/registry/v2/blobs/sha256/|wc -l`
upload_blobs=`cat log |grep 'upload blobs'|grep OK|wc -l`
if [ $blobs_num -eq $upload_blobs ]
then
	echo "upload registry rgw blobs successfully"
else
	echo "upload registry rgw blobs failure"
fi
#check upload repository
upload_repo=`cat log |grep 'upload repo'|grep OK|wc -l`
if [ $upload_repo -eq 1 ]
then
	echo "upload registry rgw repositories successfully"
else
	echo "upload registry rgw repositories failure"
fi

