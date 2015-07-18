#!/bin/sh

. /etc/utils/shell-utils.sh
#DEBUG=1

retVal=0
MOUNTS_CACHE="/ram/mounts.cache"
RDIR_SCRIPT="/home/default/rdir.cgi"
SATA_DEV="null"
MEDIA_TYPE="0"
DEV_PATH_ATTR_NAME="devPath"

filterSnString()
{
    SERIAL=`echo -n \"$1\" | strings | awk '{ s=$0; gsub(/[^a-zA-Z0-9_]/, "", s); printf s }'`
    if [ "$SERIAL" == "" ]; then
        SERIAL="UNASSIGNED"
    fi
}

# EXECUTION POINT

log "* devName='${DEV_NAME}', sn='${SERIAL}', pNum='${PNUM}', vendor='${uVendor}', model='${uModel}', DevPath='${DEVPATH}'"

case $1 in
    add)
        log "add command"

        SATA_DEV=`echo "'${DEVPATH}'" | awk '{ i1 = index($0, "/sata-stm/"); if(i1 > 0){print "sata"  }}'`;
        if [ "$SATA_DEV" == "sata" ]; then
           if [ "$PNUM" == "" ]; then
            echo "/dev/${DEV_NAME}" >/ram/satadev
           fi
        fi

        size=`cat /sys${DEVPATH}/size 2> /dev/null`;
        if [ -z "$size" ]; then
            log "Size read error!"
            return
        fi
        size=$(( size * 512 ));

        label=`blkid -c /ram/blkid.tab /dev/${DEV_NAME} | awk '{ i1 = index($0, " LABEL=\""); if(i1 > 0){ s1 = substr($0, i1 + 8); i2 = index(s1, "\""); if (i2 > 0){print substr(s1, 0, i2 - 1);} } }'`;
        fstype=`blkid -c /ram/blkid.tab /dev/${DEV_NAME} | awk '{ i1 = index($0, " TYPE=\""); if(i1 > 0){ s1 = substr($0, i1 + 7); i2 = index(s1, "\""); if (i2 > 0){print substr(s1, 0, i2 - 1);} } }'`;

        if [ "$fstype" == "" ]; then
            log "fstype is empty!"
            exit -1
        fi

        # count "entire disk" as single partition number 0
        if [ "$PNUM" == "" ]; then
            PNUM="0"
        fi

        # serial number conditioning
        filterSnString $SERIAL

        FULL_NAME="USB-${SERIAL}-${PNUM}"

        if [ "$SERIAL" == "UNASSIGNED" ]; then
          FULL_NAME="HDD-SATA-${PNUM}"
          SERIAL="HDD-SATA-${PNUM}"
          MEDIA_TYPE="1"
        else
            MEDIA_TYPE="2"
        fi

        FOLDER_TO_CREATE="/media/${FULL_NAME}"
        log "mount point '$FOLDER_TO_CREATE'"

        if [ ! -f "$FOLDER_TO_CREATE" ]; then
            log "Creating mount point..."
            mkdir "$FOLDER_TO_CREATE"
        fi

        IS_READ_ONLY="0"
        EXTRA_OPT="noatime,nodiratime"
        case $fstype in
            "ntfs")
                DEV_MODEL=`$RDIR_SCRIPT Model`
                if [ "$DEV_MODEL" != "MAG200" ]; then
                    mount -t tntfs -o rw,iocharset=utf8,$EXTRA_OPT $DEVNAME "$FOLDER_TO_CREATE"
                else
                    mount -o ro,iocharset=utf8,$EXTRA_OPT $DEVNAME "$FOLDER_TO_CREATE"
                    IS_READ_ONLY="1"
                fi
            ;;
            "ext2")
                mount -o rw,$EXTRA_OPT $DEVNAME "$FOLDER_TO_CREATE"
            ;;
            "ext3")
                mount -o rw,$EXTRA_OPT $DEVNAME "$FOLDER_TO_CREATE"
            ;;
            "vfat")
                mount -o rw,iocharset=utf8,$EXTRA_OPT $DEVNAME "$FOLDER_TO_CREATE"
            ;;
            *)
                mount -o rw,$EXTRA_OPT $DEVNAME "$FOLDER_TO_CREATE"
            ;;
        esac
        if [ "$?" != "0" ]; then
            log "mount error! removing mount point..."
            rmdir "$FOLDER_TO_CREATE"
            exit -1
        fi

        freeSize=`df -k | grep /ram/media/$FULL_NAME | awk '{print $4}'`
        freeSize=$((${freeSize}*1024))

        echo "key:${FULL_NAME}:{\"sn\":\"${SERIAL}\",\"vendor\":\"${uVendor}\",\"model\":\"${uModel}\",\"size\":${size},\"freeSize\":${freeSize},\"label\":\"${label}\",\"partitionNum\":${PNUM},\"isReadOnly\":${IS_READ_ONLY},\"mountPath\":\"${FOLDER_TO_CREATE}\",\"mediaType\":${MEDIA_TYPE},\"${DEV_PATH_ATTR_NAME}\":\"${DEVPATH}\"}" >> $MOUNTS_CACHE
        /usr/share/qt-4.6.0/sendqtevent -a -ks 0x70 -kqt 0x50
        /root/magtoken/timer.sh
    ;;
    remove)
        log "remove command"

        # count "entire disk" as single partition number 0
        if [ -z "$PNUM" ]; then
            PNUM="0"
        fi

        # serial number conditioning
        filterSnString $SERIAL

        MOUNT_POINT=$(getMountPointByDevPath ${DEVPATH})

        if [ -d ${MOUNT_POINT} ] && [ -n "${MOUNT_POINT}" ]; then
            log "Unmounting '${MOUNT_POINT}'..."
            umount -l "${MOUNT_POINT}"
            log "Removing '${MOUNT_POINT}'..."
            rmdir "${MOUNT_POINT}"
            excludeByDevPath ${MOUNTS_CACHE} ${DEVPATH}
            /usr/share/qt-4.6.0/sendqtevent -a -ks 0x71 -kqt 0x51
            killall timer.sh
        fi
        if [ "$SERIAL" == "UNASSIGNED" ]; then
           if [ -d /ram/media/HDD-SATA-${PNUM} ]; then
             FULL_NAME="HDD-SATA-${PNUM}"
             FOLDER_TO_DELETE="/media/${FULL_NAME}"
             log "Unmounting '$FOLDER_TO_DELETE'..."
             umount -l "$FOLDER_TO_DELETE"
             log "Removing '$FOLDER_TO_DELETE'..."
             rmdir "$FOLDER_TO_DELETE"
             excludeRaw $MOUNTS_CACHE $FULL_NAME
             /usr/share/qt-4.6.0/sendqtevent -a -ks 0x71 -kqt 0x51
            fi 
        fi
    ;;
    change)
        log "change command"

        label=`blkid -c /ram/blkid.tab /dev/${DEV_NAME}`;

        log "done"
    ;;
esac

exit 0
