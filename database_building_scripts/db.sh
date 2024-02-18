#/bin/sh

trap "echo Exited!; exit;" SIGINT SIGTERM

# song counts
# SELECT (SELECT COUNT(id) FROM songs), (SELECT COUNT(id) FROM plays), (SELECT SUM(delta) FROM plays);

# SELECT a.name, s.name, p.delta FROM songs s, artists a, plays p
# WHERE s.artistid=a.id AND p.songid=s.id

# artist, hours played, all tracks played
# SELECT a.name, SUM(s.duration * p.delta / 1000.0 / 60.0 / 60.0) AS hours, SUM(p.delta) AS playcount
# FROM plays p
# LEFT JOIN songs s
# ON p.songid=s.id
# LEFT JOIN artists a
# ON s.artistid=a.id
# GROUP BY a.name
# ORDER BY hours DESC;

# Items that have a playDate but not a playCount
# SELECT DISTINCT a.name, al.name AS album
# FROM (SELECT id, songid, delta FROM plays WHERE delta=0 ) p
# LEFT JOIN songs s ON p.songid=s.id
# LEFT JOIN artists a ON s.artistid=a.id
# LEFT JOIN albums al ON s.albumid=al.id
# ORDER BY a.name, al.name;

# Count of weird plays
# SELECT COUNT(*) FROM (SELECT DISTINCT a.name, al.name FROM (SELECT id, songid, delta FROM plays WHERE delta=0 ) p LEFT JOIN songs s ON p.songid=s.id LEFT JOIN artists a ON s.artistid=a.id LEFT JOIN albums al ON s.albumid=al.id ORDER BY a.name, al.name);

#Show weird plays
#SELECT DISTINCT a.name, al.name FROM (SELECT id, songid, delta FROM plays WHERE delta=0 ) p LEFT JOIN songs s ON p.songid=s.id LEFT JOIN artists a ON s.artistid=a.id LEFT JOIN albums al ON s.albumid=al.id ORDER BY a.name, al.name


# Get some of the Berlin Philamonic stuff:
#sqlite3 ../../dbs/iTunes-2023-10-24/*.db "SELECT a.name, s.name, p.date FROM (SELECT id, songid, delta, date FROM plays WHERE delta=0 ) p LEFT JOIN songs s ON p.songid=s.id LEFT JOIN artists a ON s.artistid=a.id LEFT JOIN albums al ON s.albumid=al.id WHERE a.name='Berlin Philharmonic & Herbert von Karajan';" | while IFS=$'\n' read -r line ; do ARTIST=$(echo $line | cut -f1 -d'|') && SONG=$(echo $line | cut -f2 -d'|') && PLAYDATE=$(echo $line | cut -f3 -d'|') && echo ", { \"fix\" : { \"playCount\" : $(sqlite3 ../../dbs/iTunes-2023-10-23/*.db "SELECT delta FROM plays WHERE songid=(SELECT id FROM songs WHERE name LIKE '$(echo $SONG | sed -e"s|'|''|g" | sed -e's|\(.*[IV]\.\).*|\1|')%' AND artistid=(SELECT id FROM artists WHERE name='$(echo $ARTIST | sed -e"s|'|''|g")'));") }, \"problem\" : { \"artist\" : \"$(echo $ARTIST | sed -e"s|\"|\\\\\"|g")\", \"name\" : \"$(echo $SONG | sed -e"s|\"|\\\\\"|g")\", \"playCount\" : 0, \"playDate\" : \"${PLAYDATE}\" } }" ; done

# Show new songs played
# SELECT a.name, al.name, s.name, p.date FROM (SELECT id, songid, delta FROM (SELECT * FROM newer.plays AS np WHERE date > (SELECT date FROM main.plays ORDER BY date DESC LIMIT 1))) p LEFT JOIN songs s ON p.songid=s.id LEFT JOIN artists a ON s.artistid=a.id LEFT JOIN albums al ON s.albumid=al.id ORDER BY p.date;

# CREATE VIEW last_played_date AS  SELECT date FROM plays ORDER BY date DESC LIMIT 1;
# SELECT * FROM newer.plays AS np WHERE date > (SELECT * FROM last_played_date);
# SELECT na.name AS artist, nal.name AS album, ns.name AS song, ns.trackNumber AS tracknumber, np.date AS date FROM (SELECT * FROM newer.plays WHERE date > (SELECT * FROM last_played_date)) np LEFT JOIN newer.songs ns ON np.songid=ns.id LEFT JOIN newer.artists na ON ns.artistid=na.id LEFT JOIN newer.albums nal ON ns.albumid=nal.id;

# This is getting there. The song names are on two different albums here:
# SELECT na.name AS artist, nal.name AS album, nal.id AS albumid, ns.name AS song, ns.id as songid, ns.trackNumber AS tracknumber, np.id AS newid, np.date AS date, np.delta AS newcount, op.id AS oldid, op.date AS olddate, op.delta AS oldcount FROM (SELECT * FROM newer.plays WHERE date > (SELECT * FROM last_played_date)) np LEFT JOIN newer.songs ns ON np.songid=ns.id LEFT JOIN newer.artists na ON ns.artistid=na.id LEFT JOIN newer.albums nal ON ns.albumid=nal.id LEFT JOIN main.songs os ON ns.name=os.name LEFT JOIN main.artists oa ON na.name=oa.name LEFT JOIN main.albums oal ON nal.name=oal.name LEFT JOIN main.plays op ON op.songid=os.id;

#This is it!
#SELECT na.name AS artist, nal.name AS album, ns.name AS song, np.date AS date, np.delta AS newcount, op.date AS olddate, op.delta AS oldcount FROM (SELECT * FROM newer.plays WHERE date > (SELECT date FROM main.plays ORDER BY date DESC LIMIT 1)) np LEFT JOIN newer.songs ns ON np.songid=ns.id LEFT JOIN newer.artists na ON ns.artistid=na.id LEFT JOIN newer.albums nal ON ns.albumid=nal.id LEFT JOIN main.songs os ON ns.name=os.name LEFT JOIN main.artists oa ON na.name=oa.name LEFT JOIN main.albums oal ON nal.name=oal.name LEFT JOIN main.plays op ON op.songid=os.id WHERE os.albumid=oal.id;

#this almost can tell if dates and counts are "bad"
#SELECT na.name AS artist, nal.name AS album, ns.name AS song, op.date AS olddate, np.date AS date, (CASE WHEN op.date IS NULL THEN "n/a" ELSE (CASE WHEN np.date > op.date THEN "OK" ELSE "badDate" END) END) AS dateCheck, op.delta AS oldcount, np.delta AS newcount, (CASE WHEN op.delta IS NULL THEN "n/a" ELSE (CASE WHEN np.delta > op.delta THEN "OK" ELSE "badCount" END) END) AS countCheck FROM (SELECT * FROM newer.plays WHERE date > (SELECT date FROM main.plays ORDER BY date DESC LIMIT 1)) np LEFT JOIN newer.songs ns ON np.songid=ns.id LEFT JOIN newer.artists na ON ns.artistid=na.id LEFT JOIN newer.albums nal ON ns.albumid=nal.id LEFT JOIN main.songs os ON ns.name=os.name LEFT JOIN main.artists oa ON na.name=oa.name LEFT JOIN main.albums oal ON nal.name=oal.name LEFT JOIN main.plays op ON op.songid=os.id WHERE os.albumid=oal.id;




# SELECT
#   n.song AS song,
#   n.artist AS artist,
#   n.album AS album,
#   (CASE WHEN o.date IS NULL THEN "n/a" ELSE (CASE WHEN n.date > o.date THEN "OK" ELSE "badDate" END) END) AS dateCheck,
#   (CASE WHEN o.delta IS NULL THEN 0 ELSE o.delta END) AS odelta,
#   n.date AS ndate,
#   n.delta AS ndelta,
#   (CASE WHEN o.delta IS NULL THEN "n/a" ELSE (CASE WHEN n.delta > o.delta THEN "OK" ELSE "badCount" END) END) AS countCheck
# FROM newer.tracks n
#   LEFT JOIN main.tracks o
#   ON (n.song=o.song AND n.track=o.track AND n.artist=o.artist AND n.album=o.album)
#   WHERE (n.date IS NOT NULL AND (o.date IS NULL OR n.date!=o.date))
#   ORDER BY ndate;

# This finds where plays do not increase in count or date.
#read -d '' sql << EOF
#SELECT * 
#FROM
#(SELECT 
#  n.pid AS npid,
#  o.pid AS opid,
#  n.date > o.date AS dateCheck,
#  n.delta > o.delta AS deltaCheck
#FROM newer.tracks n
#  LEFT JOIN main.tracks o
#  ON (n.song=o.song AND n.track=o.track AND n.artist=o.artist AND n.album=o.album)
#  WHERE (n.date IS NOT NULL AND (o.date IS NULL OR n.date!=o.date))
#)
#  WHERE (dateCheck!=1 OR deltaCheck!=1)
#  ;
#EOF

read -d '' sql << EOF
SELECT *
FROM
(SELECT
  n.artist AS nartist,
  o.artist AS oartist
FROM newer.tracks n
  LEFT JOIN main.tracks o
  ON (n.song=o.song AND n.track=o.track AND n.album=o.album)
)
  GROUP BY nartist
  ;
EOF

OUT_DIR=/tmp/findings/
mkdir -p $OUT_DIR

OLD=""
COUNT=0
for F in `find ~/Documents/code/dbs/ -type f -name "*.db" | sort` ; do 
  NAME=`basename -s".db" $F`
  echo "- $NAME -"
  if [ -z $OLD ] ; then
    OLD=$F
  else
    sqlite3 -readonly -column -header $OLD "ATTACH DATABASE \"$F\" AS newer; $sql" > $OUT_DIR/$NAME.txt &
    OLD=$F

    let COUNT++
    if [ $COUNT -eq 7 ]; then
      echo Waiting for Batch
      wait
      let COUNT=0
    fi
  fi
done
