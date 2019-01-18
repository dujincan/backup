#!/bin/bash 
count=0
log=/tmp/backup.log
server=10.64.80.222
backup=/backup
user=root
passwd=123456


if [ $# -eq 1 ]
then
    tarfile=`echo "$1" |awk -F "/" '{print $NF}'`.`date +%F-%H`.tar.gz 
    tar czf $tarfile $1 &>/$log
    retval=$?
    if [ $retval -eq 0 ]
    then
        sshpass -p $passwd ssh $server "ls /backup" &>$log
        retval=$?
        if [ $retval -ne 0  ]
        then
            sshpass -p $passwd ssh $server "mkdir /backup"
        fi
        sshpass -p $passwd scp $tarfile $server:$backup/ &>$log
        retval=$?
        if [ $retval -eq 0 ]
        then
            md5s=`md5sum $tarfile|awk '{print $1}'`
            md5d=`sshpass -p $passwd ssh $server "md5sum $backup/$tarfile" |awk '{print $1}'`
            if [ $md5s == $md5d ]
            then
               echo "backup successful"
               rm -rf $tarfile
            else
               echo "backup fail"
               exit 1
            fi
        else
            echo "scp file fail"
            echo "please check $log"
            exit $retval
        fi
            
    else
       echo "tar fail"
       echo "please check $log"
       exit $retval
    fi
 else
     echo "Usage:$0 file_path/file_name or folder_path/folder"
     exit 1
fi
