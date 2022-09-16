#!/bin/sh
#
# Very simple script to dump all available PostgreSQL databases
#

set -eu

retention=10
dump_dir=/data/backup/dump/
date_str=$(date +%Y%m%d)

if [ ! -d $dump_dir ]; then
        echo "Create missing dump directoy '${dump_dir}'"
        mkdir -p $dump_dir
fi

su - postgres -c "pg_dumpall -h /var/run/postgresql/" > $dump_dir/pg_all-${date_str}.sql
xz $dump_dir/pg_all-${date_str}.sql
find $dump_dir -mtime +$retention -delete
