#!/bin/bash

cluster_topology=$(redis-cli -h redis.marathon.l4lb.thisdcos.directory cluster nodes)
slaves=$(echo "${cluster_topology}" | grep slave | cut -d' ' -f2,4 | tr ' ' ',')
cd /backup

backup_path=/backup/redis-backup
mkdir -p $backup_path

for slave in ${slaves}
do
    master_id=$(echo "${slave}" | cut -d',' -f2)
    slave_ip=$(echo "${slave}" | cut -d':' -f1)
    slots=$(echo "${cluster_topology}" | grep "${master_id}" | grep "master" | cut -d' ' -f9)
    echo "Getting backup from slave : $slave_ip"
    if [ -z "$slave_ip" ] || [ -z "$slots" ]
    then
        printf "Can not find redis slave or slots in topology\n%s\n" $cluster_topology
        exit 1
    fi

    # Get last dump.rdb
    redis-cli --rdb dump.rdb -h ${slave_ip}

    # Check rdb file for consistency
    redis-check-rdb dump.rdb > /tmp/rdbCheck
    cat /tmp/rdbCheck | grep "Checksum OK" && cat /tmp/rdbCheck | grep "RDB looks OK!"

    # If rdb is consistent, compress it and move to backup directory. Fail otherwise.
    if [ $? -eq 0 ]
    then
        echo "dump.rdb is consistent, saving it to backup."
        backup_file=dump-${slots}-$(date '+%Y-%m-%d-%H%M%S').rdb
        mv dump.rdb ${backup_path}/${backup_file}
    else
        echo "dump.rdb is not consistent, saving it to backup with failed flag."
        failed_dump=dump-failed-${slots}-$(date '+%Y-%m-%d-%H%M%S').rdb
        printf "RDB check failed!"
        mv dump.rdb ${backup_path}/${failed_dump}
    fi
    echo "============================="
done

compressFileName=redis-backup-$(date '+%Y-%m-%d-%H%M%S').tar.gz
tar -zvcf $compressFileName redis-backup/
echo "Redis backup is compressed and stored at :"
readlink -e $compressFileName
rm -rf $backup_path
