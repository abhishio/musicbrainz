#!/bin/bash
sudo mkdir -p /opt/musicbrainz/mbdump/
cd /opt/musicbrainz/mbdump/
latest=`curl ftp://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/LATEST`
a=ftp://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/
b=/mbdump
c=( "-cdstubs" "-editor" "-cover-art-archive" "-wikidocs"  "-derived" "-stats"  )
d=.tar.bz2
sudo  wget $a$latest$b$d
for x in ${c[@]}
do
sudo  wget $a$latest$b$x$d
done

sudo cp $HOME/startMusicBrainz.sh /bin/musicbrainz
echo "/bin/musicbrainz" | sudo tee -a /etc/rc.local

cd /opt/musicbrainz/musicbrainz-server/ && exec `./admin/InitDb.pl --createdb --import /opt/musicbrainz/mbdump/mbdump*.tar.bz2 --echo`
