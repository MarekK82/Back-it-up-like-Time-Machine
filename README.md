Back it up like Time Machine
============================

Backing up your data similar to Apple's Time Machine by making use of hard links and such...


Description
-----------

First a full backup is performed, followed by incremental backups hard linking into the latest previous backup. That way each incremental backup is implicit a full backup.


### Timeline ###

The timeline consists of a folder containing all the backups made.


### Backup ###

A backup is a folder inside the timeline, whose name is given with the format `YYYYMMDDTHHMMSS`, which is according to the [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) specificartion.
Each backup is an *hard linked* incremental backup of the previous backup in the timeline, which means every backup is a full backup.


Setup
-----

For information about how to set up a Time Machine like backup read between the lines inside the `backitup` script file :-)


TODO
----

* Implement lock mechanism to prevent multiple instances.
* Implement error and/or signal handling for rsync.
* Implement algorithm to delete old backups for saving storage space.
* Implement external configuration file for environment related settings.
* Build in a logger.
