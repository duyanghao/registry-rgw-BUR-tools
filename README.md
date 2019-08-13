# registry-rgw-BUR-tools 

registry-rgw-BUR-tools is a concurrent [s3cmd](https://github.com/s3tools/s3cmd) tool of BUR(backup and restore) for registry ceph-rgw data.

## Introdution

Normally, we use s3cmd tool to do BUR(backup and restore) for registry rgw data, which is inefficient especially When massive data is involved because `s3cmd tool` is not concurrent itself.

So wo need to execute multiple s3cmd by spliting registry rgw data in order to speed up, and `registry-rgw-BUR-tools` helps to do this.

## Usage

* download registry rgw data

```bash
bash start.sh download $rgw_bucket $concurrent
```

* upload registry rgw data

```bash
bash start.sh upload $rgw_bucket $concurrent
```

after `download` or `upload` registry rgw data, you need to check for success as below:

```bash
bash check.sh $rgw_bucket
```
And the result will show as below:

```bash
# bash check.sh tmpbucket
upload blobs successfully
upload repositories failure
```