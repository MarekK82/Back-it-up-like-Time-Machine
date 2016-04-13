#!/bin/bash
#
# Backup solution to work like Apple's Time Machine. First a full backup is 
# performed, followed by incremental backups hard linking into the latest 
# previous backup. That way each incremental backup is implicit a full backup.
#
# Version 1.0


# Script must be executed with root privileges!
if [ "$(whoami)" != 'root' ]; then  # $USER is not set in cron context.
  >&2 echo "You ain't root!"        # Output also to STDERR.
  exit -1
fi

# Set up host specific directory for its backup collection (aka Timeline). The 
# mount point needs to be prepared in FSTAB(5) accordingly.
TIMELINE="/mnt/Time Machine HD/Backups.backupdb/$HOSTNAME"
if [ ! -d "$TIMELINE" ]; then
  mkdir --parents "$TIMELINE"
  if [ $? -ne 0 ]; then exit $?; fi
fi

# Check if the symbolic link pointing to the latest backup exists for hard 
# linking an incremental backup. If it does not exist a full backup will be 
# performed.
LATEST="${TIMELINE}/Latest"
if [ ! -L "$LATEST" ]; then
  # Full backup
  STRATEGY=0
else
  # Incremental backup
  STRATEGY=1
fi

# Prepare destination directory for an upcoming backup with "in progress" state.
DESTINATION="$TIMELINE/$(date +%Y%m%dT%H%M%S).inProgress"
mkdir "$DESTINATION"
if [ $? -ne 0 ]; then exit $?; fi

# Run rsync to perform a backup accordingly to the determined strategy.
if [ $STRATEGY -eq 0 ]; then
  # Full backup
  CMD="rsync --archive --inplace --exclude-from='/mnt/Time Machine HD/Backups.backupdb/exclude.lst' --verbose /home '$DESTINATION'"
  echo "Performing full backup: \`$CMD\`"
  eval $CMD
else
  # Incremental backup
  CMD="rsync --archive --inplace --exclude-from='/mnt/Time Machine HD/Backups.backupdb/exclude.lst' --verbose --delete --link-dest='$LATEST' /home '$DESTINATION'"
  echo "Performing Incremental backup: \`$CMD\`"
  eval $CMD
fi

# Remove "in progress" state of destination directory by renaming it.
OLD_DESTINATION=$DESTINATION
NEW_DESTINATION="$TIMELINE/$(date +%Y%m%dT%H%M%S)"
mv "$OLD_DESTINATION" "$NEW_DESTINATION"
if [ $? -ne 0 ]; then exit $?; fi

# Create a symbolic link indicating the most recent backup.
ln --symbolic --force --no-target-directory "$NEW_DESTINATION" "$LATEST"
if [ $? -ne 0 ]; then exit $?; fi


# All your data are belong to us
