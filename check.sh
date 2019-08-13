#!/bin/bash

#check download blobs
blobs_num=`s3cmd ls s3://$1/docker/registry/v2/blobs/sha256/|wc -l`
download_blobs=`cat log |grep 'download blobs'|grep OK|wc -l`
if [ $blobs_num -eq $download_blobs ]
then
	echo "download blobs successfully"
else
	echo "download blobs failure"
fi
#check download repository
download_repo=`cat log |grep 'download repo'|grep OK|wc -l`
if [ $download_repo -eq 1 ]
then
	echo "download repositories successfully"
else
	echo "download repositories failure"
fi
#check upload blobs
blobs_num=`ls registry/docker/registry/v2/blobs/sha256/|wc -l`
upload_blobs=`cat log |grep 'upload blobs'|grep OK|wc -l`
if [ $blobs_num -eq $upload_blobs ]
then
	echo "upload blobs successfully"
else
	echo "upload blobs failure"
fi
#check upload repository
upload_repo=`cat log |grep 'upload repo'|grep OK|wc -l`
if [ $upload_repo -eq 1 ]
then
	echo "upload repositories successfully"
else
	echo "upload repositories failure"
fi

