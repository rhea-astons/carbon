#!/bin/bash

SCRIPT_NAME=$0

DEF_SOURCE=/home/$USER
DEF_TARGET=/media/$USER/backups
DEF_EXCLUDE_FILE=excludelist
DEF_EXCLUDE=$DEF_TARGET/$DEF_EXCLUDE_FILE

usage() {
    echo "usage: $SCRIPT_NAME [-s SOURCE] [-t TARGET] [-e EXCLUDEFILE]"
    echo "  -s, --source    DIR     Specify the directory to backup (default to $DEF_SOURCE)"
    echo "  -t, --target    DIR     Specify the target of backups (default to $DEF_TARGET)"
    echo "  -e, --exclude   FILE    Specify an exclude file (default to $DEF_EXCLUDE)"
    echo "  -f, --force-full        Forces to do a full backup"
    echo "  -d, --dereference       Follow symlinks when using tar"
    echo "  -n, --dry-run           Outputs the commands without executing them"
    echo "  -h, --help              Display help"
    echo ""
    echo "To restore backups, extract a full backup and every incremental backup needed with:"
    echo "tar Gxzvf backup.tar.gz"
    exit 1
}

run_cmd() {
    if [ $DRY_RUN ]; then
        echo "Dry run:"
        echo "> $1"
    else
        $($1)
    fi
}

#######################
# Parse parameters
#######################
while [ "$1" != "" ]; do
    case $1 in
        -s | --source )
            shift
            SOURCE=$1
            ;;
        -t | --target )
            shift
            TARGET=$1
            ;;
        -e | --exclude )
            shift
            EXCLUDE=$1
            ;;
        -f | --force-full )
            FORCE_FULL=true
            ;;
        -d | --dereference )
            DEREFERENCE=true
            ;;
        -n | --dry-run )
            DRY_RUN=true
            ;;
        -h | --help )
            usage
            exit
            ;;
        * )
            usage
            exit 1
            ;;
    esac
    shift
done

#######################
# Check parameters
#######################
if [ ! $SOURCE ]; then
    SOURCE=$DEF_SOURCE
    if [ ! -d $SOURCE ]; then
        echo "Source directory does not exist ($SOURCE)."
        exit 1
    fi
fi

if [ ! $TARGET ]; then
    TARGET=$DEF_TARGET
    if [ ! -d $TARGET ]; then
        echo "Target directory does not exist ($TARGET)."
        exit 1
    fi
fi

if [ ! $EXCLUDE ]; then
    if [ -a $TARGET/$DEF_EXCLUDE_FILE ]; then
        EXCLUDE=$TARGET/$DEF_EXCLUDE_FILE
    fi
fi

#######################
# Prepare backup
#######################
YEAR=$(date +'%Y')
MONTH=$(date +'%m')

BKP_DEST=$TARGET/$YEAR/$MONTH
BKP_NAME=$(basename $SOURCE)
SNAP=$BKP_DEST/$BKP_NAME.snar
BKP_STYLE='incr'

if [ ! -d $BKP_DEST ]; then
# If backup directory for current month doesn't exist, create one and perform full backup.
    echo 'No full backup found. Performing full backup.'
    run_cmd "mkdir -p $BKP_DEST"
    BKP_STYLE='full'
elif [ ! -f $SNAP ]; then
# If snapshot for current month doesn't exist, perform full backup.
    echo 'Snapshot file not found. Performing full backup.'
    BKP_STYLE='full'
elif [ $FORCE_FULL ]; then
# If full backup is forced, delete current month snapshot and perform full backup.
    echo 'Forced full backup.'
    run_cmd "rm $SNAP"
    BKP_STYLE='full'
else
# Otherwise perform incremental backup.
    echo 'Performing incremental backup.'
fi

#######################
# Perform backup
#######################
NOW=$(date +'%Y%m%d%H%M')
BKP=$BKP_DEST/$BKP_NAME-$NOW-$BKP_STYLE.tar.gz

cmd="tar"

if [ $EXCLUDE ]; then
    cmd="$cmd -X $EXCLUDE"
fi
if [ $DEREFERENCE ]; then
    cmd="$cmd -h"
fi

cmd="$cmd -g $SNAP -C $SOURCE -czf $BKP ."
run_cmd "$cmd"

