sudo mkdir -p /opt/musicbrainz/mblog 
mkdir $HOME/mblog
home=/opt/musicbrainz

> $HOME/mblog/log.txt
a=$HOME/mblog/log.txt
b="tee  -a $HOME/mblog/log.txt"
server=$home/musicbrainz-server/

Result(){
if [ $? == 0 ]
then
echo "
###############################################################################
# $1
###############################################################################
" 2>&1 | $b
else
echo "
##############################################################################
#  Error: $2
##############################################################################
" 2>&1 | $b
fi
}

Msg(){
echo "
##############################################################################
# $@
##############################################################################
" 2>&1 | $b

}
##############################################################################
Msg Installing Postgres
##############################################################################
#Add the postgresql repository
#use xenial-pgdg for Xenial (16.04) 
#	wily-pgdg for Wily warewolf (15.04)
#	trusty-pgdg for Trusty (14.04)
#	precise-pgdg for precise (12.04)
##############################################################################
Msg Adding Postgres Repo
echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" | sudo tee   /etc/apt/sources.list.d/pgdg.list     2>>  $a
Result "Repo Added" "Adding Repo"

##############################################################################
Msg Downloading the repo key
##############################################################################
sudo wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -      2>>  $a
Result "Key Added" "Adding Key"

##############################################################################
Msg Udating Repo
##############################################################################
sudo apt-get update  2>>  $a

##############################################################################
Msg postgresql
##############################################################################
sudo apt-get install postgresql-9.5 postgresql-server-dev-9.5 postgresql-contrib-9.5   -y    2>>  $a
Result "Installed Postgres 9.5" "Installing"

##############################################################################
Msg Installing GIT
##############################################################################
sudo apt-get install git-core -y    2>>  $a
Result "Installed Git" "Installing GIT"

##############################################################################
Msg Installing Memcached
# You can change the memcached server name and
#port or configure other datastores in lib/DEDefs.pm
##############################################################################
sudo apt-get install memcached -y    2>>  $a
Result "Installed Memcached" "Installing Memcached"

##############################################################################
Msg Installing Redis sever
##############################################################################
#MusicBrainz sessions are stored in Redis so running Redis server is required.
#The databases and kye prefix used by musicbrainz can be configured in lib/DBDefs.pm
#Defaults should be fine if you dont use your own session.
sudo apt-get install redis-server -y    2>>  $a
Result "Installed Redis Server" "Installing Redis Server"

##############################################################################
Msg Installing Node and Dependencies
##############################################################################
#Node.js is required to build (and optionally minify) Javascript and css. 
#isntall node and its package manager npm
#Depending on musicbrainz version this package might be needed

sudo apt-get install nodejs npm nodejs-legacy -y   2>>  $a
Result "Install Node & Dependencies" "Installing Node & Dependencies"

##############################################################################
Msg Standard Development Tools
##############################################################################
sudo apt-get install build-essential -y    2>>  $a
sudo apt-get install libxml2-dev libpq-dev libexpat1-dev libdb-dev  -y  2>>  $a
sudo apt-get install libicu-dev automake make gcc gcc-multilib -y   2>>  $a
sudo apt-get install autoconf2.13 autoconf-archive gnu-standards libtool  -y  2>>  $a
Result "Installed Standard Dev Tools" "Installing Standard Dev Tools"

##############################################################################
Msg Downloading the Source Code of MusicBrainz From GitHub
cd  $home/
sudo git clone --recursive git://github.com/metabrainz/musicbrainz-server.git   2>>  $a
Result "Downloaded Source Code" "Downloading"
cd $home/musicbrainz-server    


#==============================================================================
Msg Modifing the server configuration
#Server configuration file is $HOME/musicbrainz-server/lib/DBDefs.pm 
sudo cp $server/lib/DBDefs.pm.sample $server/lib/DBDefs.pm   2>&1 | $b
#==============================================================================
# Change script here
# Change WEB_SERVER {"localhost"} to Your Server Domain Name
#==============================================================================

sudo sed -i '42s!.*!sub MB_SERVER_ROOT {"/opt/musicbrainz/musicbrainz-server/"}!'   $home/musicbrainz-server/lib/DBDefs.pm 2>>  $a
Result "Modified MB_SERVER_ROOT Configuration" "Configuring mb_server_root DBDefs.pm"
sudo sed -i '117s/.*/sub REPLICATION_TYPE { RT_SLAVE } /'  $home/musicbrainz-server/lib/DBDefs.pm 2>>  $a
Result "Modified Replication Configuration" "Configuring Replication Type DBDefs.pm"
sudo sed -i '189s/.*/sub DB_STAGING_SERVER { 0 }/' $home/musicbrainz-server/lib/DBDefs.pm 2>>  $a
Result "Modified Staging server Configuration" "Configuring db_staging_server DBDefs.pm"
sudo sed -i '153s/.*/sub WEB_SERVER  { "localhost" }/'  $home/musicbrainz-server/lib/DBDefs.pm 2>>  $a
Result "Modified web_server Configuration" "Configuring web_server DBDefs.pm"
sudo sed -i '124s/.*/sub REPLICATION_ACCESS_TOKEN { "YOUR-TOKEN" }/'  $home/musicbrainz-server/lib/DBDefs.pm 2>>  $a
Result "Modified Token", "Configuring Token DBDefs.pm"


##############################################################################
Msg "Installing perl and dependenciess"
##############################################################################
Msg "Configure local::lib"
sudo apt-get install libxml2-dev libpq-dev libexpat1-dev libdb-dev libicu-dev liblocal-lib-perl cpanminus -y    2>>  $a
#Enable local::lib
sudo echo 'eval $( perl -Mlocal::lib )' >> ~/.bashrc   2>>  $a
Result "Local Lib entry added to bashrc" "Adding Entry to .bashrc"
#reconfigure bashrc
source  ~/.bashrc   2>>  $a
Result "Compiled .bashrc" "Compling .bashrc"
cd $home/musicbrainz-server/    

sudo cpanm --installdeps --notest .    2>>  $a
Result "Install perl and Dependencies" "cpanm Installation"

##############################################################################
Msg Install node.js dependencies
#******************************************************************************
#* Run these commands inside musicbrainz-server 
#******************************************************************************
cd $home/musicbrainz-server/   

sudo npm install   
Result "NPM Install Successfull" "npm install,Run Manually to troubleshoot"
#______________________________________________________________________________
#node dependencies are install under ./node_modules
#To buil everything for nodejs run this,
#______________________________________________________________________________
sudo ./script/compile_resources.sh    2>>  $a
Result "Installed Node and Dependencies" "Installing Node and Dependencies"

##############################################################################
Msg Installing Postgres Extension
Msg building musicbrainz_unaccent extension
##############################################################################
cd $home/musicbrainz-server/postgresql-musicbrainz-unaccent    

sudo make    2>>  $a
sudo make install    2>>  $a
Result "Installed Musicbrainz_unaccent Extension" "Installing Musicbrainz_unaccent Extension"

cd $home/musicbrainz-server/    

##############################################################################
Msg Building musicbrainz_collate Extension
#To build collate extension, libicu and its development header are needed
# to install run this
##############################################################################
sudo apt-get install libicu-dev -y   2>>  $a
Result "Installed Libicu-dev" "Installing Libicu-dev"

# When libicu is installed collate extension can be build and installed by running this
cd $home/musicbrainz-server/postgresql-musicbrainz-collate/    

sudo make    2>>  $a
sudo make install   2>>  $a
Result "Installed Musicbrainz_collate Extension" "Installing musicbrainz_collate Extension"
cd $home/musicbrainz-server/    

##############################################################################
Msg setup PostgreSql Database and Authentication
##############################################################################
sudo sed -i '85ilocal all all ident'    /etc/postgresql/9.5/main/pg_hba.conf.b   2>>  $a 
Result "Local all trust" "Editing pg_hba.conf"
sudo sed -i '86ilocal    musicbrainz_db    ubuntu    ident    map=mb_map'     /etc/postgresql/9.5/main/pg_hba.conf.b	 2>>  $a
Result "Musicbrainz_db ident" "Adding Musicbrainz in pg_ident.conf"
echo "mb_map    ubuntu    musicbrainz" | sudo tee -a  /etc/postgresql/9.5/main/pg_ident.conf.b	 2>>  $a
Result "Add system user in Ident.conf" "Adding user in pg_ident.conf"



##############################################################################
Msg "Setup is complete! Check log file for  any error"
Msg "If Everything  is successfull then run latest.sh file to setup Musicbrainz_DB "
Msg "and Run the server.!"
##############################################################################
