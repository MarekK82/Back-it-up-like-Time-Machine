Back it up like Time Machine
============================

Backing up your data similar to Apple's Time Machine by making use of hard links and such...


Description
-----------

First a full backup is performed, followed by incremental backups hard linking
into the latest previous backup. That way each incremental backup is implicit a
full backup.


Setup
-----

For information about how to set up a Time Machine like backup read between the lines inside the `backitup` script file :-)


TODO
----

* Implement lock mechanism to prevent multiple instances.
* Implement error and/or signal handling for rsync.
* Implement algorithm to delete old backups for saving storage space.
