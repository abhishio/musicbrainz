#!/bin/bash
log=mbs`date '+%Y-%m-%d_%H-%M-%S'`
mkdir -p $HOME/mblog && touch $HOME/mblog/"$log"".txt"
echo "Check $HOME/mblog/$log.txt for logs"; sleep 5
node=`ps aux |grep node| grep musicbrainz| awk '{print $2}'`
plack=`ps aux |grep plackup| awk '{print $2}'`
sudo kill -9 $node $plack
cd /opt/musicbrainz/musicbrainz-server/ && exec `sudo plackup -Ilib -r &> $HOME/mblog/$log.txt`
