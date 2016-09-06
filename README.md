# musicbrainz
This documentation is for installation of MusicBrainz server on Ubuntu 14.04 or above on AWS EC2 Instance.
This overview guide explains how to use the server installaion and 
configuration.


In this page:

    -Introduction
    -Minimum System Requirements
    -Prerequisties and Initial Configuration
    -Server Installation
    -MusicBrainz Configuration
    -Postgresql Configuration
    -Data Dump restoration
    -Managing Replication
    -Related Links

#####################################################################
#	1. Introduction
#####################################################################

MusicBrainz is a project that aims to create an open content music 
database. MusicBrainz captures information about artists, their 
recorded works, and the relationships between them.

MusicBrainz Server can be installed in three Mode:

  	1. RT_MASTER
  	2. RT_SLAVE
  	3. RT_STANDALONE

RT_MASTER: This is what the main musicbrainz.org site runs on. If 
you want to setup your own dedicated Musicbrainz server which act 
as master to other mirror server.

RT_SLAVE:  If you only need a replicated database, then RT_SLAVE 
mode is used to act as mirror server which replicates the database 
from the MusicBrainz server.

RT_STANDALONE: A stand alone server is recommended if you are 
setting up a server for development purposes. 

In these we are going to setup the MusicBrainz server in RT_SLAVE mode.

#####################################################################
#	2. Minimum System Requirements
#####################################################################

For RT_SLAVE, the Instance must have these following requirments

  - Ubuntu 12.04 or above ( Ubuntu 14.04 is recommended )
  - Minimum 4GB RAM.
  - Minimum 60GB Volume
  - Other configure will work fine on AWS EC2.


#####################################################################
#	3. Prerequisties and Initial Configuration
#####################################################################

	- Perl ( 5.18.2 or above )
	- PostgreSQL (9.5 or above )
	- GIT
	- Memcached
	- Redis
	- Node.js
	- Standard Development Tools

This Tools and their dependecies will be automatically Installed 
through the musicbrain.sh 


#####################################################################
#	4. Server Installation
#####################################################################

The musicbrain.sh script will download the Source code from the 
github and will autmaticaly install. You can check the script for 
more detailed working.

 
  + NOTE 
 

	Run all the shell scripts in terminal with this format.
	
	
    	# . ./install.sh
    	# . ./restore.sh
    	# . ./runMusicBrainz.sh

	Notice that there are two dots "." and there is space 	
	between them. Missing the two dots or space between them 
	can cause improper installation.

	The scripts maintains the log of the installation process 
	of  script which will be saved at $HOME/mblog/log.txt
	
	$HOME is your home directory i.e, if user is Ubuntu the 
	home directory will be $HOME will be /home/ubuntu. So your log file will be /home/ubuntu/mblog/log.txt

	

#####################################################################
#	5. MusicBrainz Configuration
#####################################################################

The configuration of musicbrainz server is in musicbrainz-server/lib/DBDefs.pm

For RT_SLAVE mode following changes needed to be made in the DBDefs.pm

  	- sub MB_SERVER_ROOT to be set to the directory where the musicbrainz-server is installed
  	- sub MB_SERVER_ROOT to be set to RT_SLAVE 
  	- sub REPLICATION_ACCESS_TOKEN to set to your Token key for replication authentication from musicbrainz server.
  	- sub DB_STAGING_SERVER to be set to 0
  	- sub WEB_SERVER to set to the domain name of the server
  	- MUSICBRAINZ_USE_PROXY to be set to 1 If you are using a reverse proxy. This makes the server aware of it when checking for the canonical uri.
  	- READONLY and READWRITE section describe the database in postgresql which the musicbrainz server will use.


#####################################################################
#	6. Postgresql Configuration 
#####################################################################

For normal operation, the server only needs to connect from one or
two OS users (whoever your web server/crontabs run as), to one
database (the MusicBrainz Database), as one PostgreSQL user. The 
PostgreSQL database name and user name are given in DBDefs.pm (look 
for the READWRITE key). 

The pg_hba.conf and pg_ident will define the access to the 
postgresql server.
You can customize the setting but dont forget to update the DBDefs.pm

The default password for musicbrainz user in postgresql can be changed by following command in the psql:


      postgres=# ALTER USER musicbrainz UNENCRYPTED PASSWORD 'musicbrainz';


The MusicBrainz database and user in postgresql will be 
automatically created when the dumps are restored for the first 
time.

Read Next section for more information on Restoring of dumps.


#####################################################################
#	7. Data Dump restoration.
#####################################################################

The restoration of dumps can take a lot of time depending on your 
Instance configuration.
During the Dump restoration don't interrupt or cancel the the process.

For restoring, latest dumps need to be download form the offcial Musicbrainz server which are updated twice a week.

The restore.sh script will download the latest dumps and will restore the dumps in postgresql.

If restoration gets interrupted anyhow, then drop the musicbrainz_db and try again the restoration.

The Restoration needs to be done only the first time.

Check the restore.sh for more details.


#####################################################################
#	8. Managing Replication 
#####################################################################

The replication will work only if the musicbrainz_db has proper 
data in it.

musicbrainz-server/admin/cron/slave.sh will start the replication 
process in the background.

when slave.sh file is executed, it will first check the 
schema_sequence in the replication_control table in musicbrainz_db.
If the Values is NULL or missing the replication process will 
create error.

Also if the value in replication_control is missing or incorrect the
musicbrainz server will not start. So check the database, before 
starting the server or Replication process.

The replication process can be made automated by creating a entry in the crontab.

The restore.sh script will create an entry in the crontab for which will check for replication at 2AM every day.


 
  + NOTE: 
 
The replicaiton process will stop if the schema_sequence 
change. In this case you need to update the database and the server.
upgrade.sh in the musicbrainz-server director will upgrade the 
database with the latest changes.

The change in schema is announced at blog.musicbrainz.org, so keep 
checking  it. There is no automated way to check for the schema change.

#####################################################################
#	Starting the server
#####################################################################

The server can be start by executing the command in the musicbrainz-server directory:

	# sudo plackup -Ilib -r



The runMusicBrainz.sh script will run the sever without going or 
change the directory and will add a copy of in the /bin/ directory 
so the musicbrainz server can run by running the following command 
at the terminal

To run the server with runMusicBrainz.sh script, execute this command as

  	# . ./runMusicBrainz.sh

NOTE: There are two dots and which are separated by a space.

or you can run the server directy by call this command in your terminal

  	# musicbrainz

#####################################################################
#	9. Related Links
#####################################################################

- Official Server
https://musicbrainz.org

- Official Github repo:
https://github.com/metabrainz/musicbrainz-server

- Official Installation Readme file:
https://github.com/metabrainz/musicbrainz-server/blob/master/INSTALL.md

- Official Dump database:
ftp://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/
