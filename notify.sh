#!/bin/bash
echo -n "dst=mail&to=$MYMAIL&subject=Torrent descargado&txt=Se ha descargado el torrent $TR_TORRENT_NAME&_cid=AAAAA" | nc localhost 30000
