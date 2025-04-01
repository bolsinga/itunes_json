ATTACH DATABASE '/Users/bolsinga/Desktop/flat-dbs/13.fix.13.db' AS existing;

PRAGMA foreign_keys = ON;

-- Tear them down in reverse because of FOREIGN KEYS.
DROP TABLE IF EXISTS actualplaydates;
DROP TABLE IF EXISTS songs;
DROP TABLE IF EXISTS albums;
DROP TABLE IF EXISTS artists;

CREATE TEMPORARY TABLE added (
  itunesid TEXT NOT NULL PRIMARY KEY,
  date TEXT NOT NULL DEFAULT ''
);

-- Get first dates added. Ignores all the subsequent DST changes.
INSERT OR IGNORE INTO added (itunesid, date) SELECT itunesid, dateadded FROM existing.tracks ORDER BY tag;

CREATE TEMPORARY TABLE released (
  itunesid TEXT NOT NULL PRIMARY KEY,
  date TEXT NOT NULL DEFAULT ''
);

-- Get first date released. Ignores all the subsequent DST changes.
INSERT OR IGNORE INTO released (itunesid, date) SELECT itunesid, datereleased FROM existing.tracks ORDER BY tag;

CREATE TEMPORARY TABLE latestalbums (
  itunesid TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  sortname TEXT NOT NULL DEFAULT '',
  trackcount INTEGER NOT NULL,
  disccount INTEGER NOT NULL,
  discnumber INTEGER NOT NULL,
  compilation INTEGER NOT NULL
);

-- Get album data. Last one in wins.
INSERT INTO latestalbums (itunesid, name, sortname, trackcount, disccount, discnumber, compilation) SELECT DISTINCT itunesid, album, sortalbum, trackcount, disccount, discnumber, compilation FROM existing.tracks ORDER BY tag
  ON CONFLICT (itunesid) DO UPDATE SET
    name = EXCLUDED.name,
    sortname = EXCLUDED.sortname,
    trackcount = EXCLUDED.trackcount,
    disccount = EXCLUDED.disccount,
    discnumber = EXCLUDED.discnumber,
    compilation = EXCLUDED.compilation;

CREATE TABLE IF NOT EXISTS artists (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  sortname TEXT NOT NULL DEFAULT '',
  CHECK(length(name) > 0),
  CHECK(name != sortname),
  UNIQUE(name, sortname)
);

-- Get artist, sortartist, ensuring that if there are artists with different sorts, the ones with sorts are used.
WITH normalizedartists AS (
  WITH artistpairs AS (SELECT DISTINCT artist, sortartist FROM existing.tracks ORDER BY tag)
    SELECT DISTINCT a.artist AS artist, COALESCE(NULLIF(a.sortartist, ''), NULLIF(o.sortartist, ''), '') AS sortartist FROM artistpairs AS a LEFT JOIN artistpairs o ON a.artist=o.artist AND a.sortartist!=o.sortartist ORDER BY artist)
INSERT INTO artists (name, sortname) SELECT * FROM normalizedartists ORDER BY IIF(sortartist='', artist, sortartist);

CREATE TEMPORARY TABLE artistids (
  itunesid TEXT NOT NULL,
  artistid INTEGER NOT NULL,
  UNIQUE(itunesid)
);

INSERT INTO artistids (itunesid, artistid) SELECT DISTINCT e.itunesid, a.id FROM existing.tracks e LEFT JOIN artists a ON e.artist = a.name ORDER BY tag;

CREATE TABLE IF NOT EXISTS albums (
  id INTEGER PRIMARY KEY,
  artistid INTEGER NOT NULL,
  name TEXT NOT NULL,
  sortname TEXT NOT NULL DEFAULT '',
  trackcount INTEGER NOT NULL,
  disccount INTEGER NOT NULL,
  discnumber INTEGER NOT NULL,
  compilation INTEGER NOT NULL,
  FOREIGN KEY(artistid) REFERENCES artists(id),
  CHECK(length(name) > 0),
  CHECK(name != sortname),
  CHECK(trackcount > 0),
  CHECK(disccount > 0),
  CHECK(discnumber > 0),
  CHECK(compilation = 0 OR compilation = 1),
  UNIQUE(artistid, name, trackcount, disccount, discnumber, compilation)
);

INSERT INTO albums (artistid, name, sortname, trackcount, disccount, discnumber, compilation) SELECT DISTINCT a.artistid, e.name, e.sortname, e.trackcount, e.disccount, e.discnumber, e.compilation FROM latestalbums e LEFT JOIN artistids a ON e.itunesid = a.itunesid;

CREATE TEMPORARY TABLE albumids (
  itunesid TEXT NOT NULL,
  albumid INTEGER NOT NULL,
  UNIQUE(itunesid)
);

INSERT INTO albumids SELECT arids.itunesid AS itunesid, al.id AS albumid FROM artistids arids INNER JOIN albums al ON arids.artistid = al.artistid INNER JOIN latestalbums lal ON arids.itunesid = lal.itunesid AND al.name = lal.name AND al.sortname = lal.sortname AND al.trackcount = lal.trackcount AND al.disccount = lal.disccount AND al.discnumber = lal.discnumber AND al.compilation = lal.compilation;

CREATE TEMPORARY TABLE latestsongs (
  itunesid TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  sortname TEXT NOT NULL DEFAULT '',
  composer TEXT NOT NULL DEFAULT '',
  tracknumber INTEGER NOT NULL,
  year INTEGER NOT NULL,
  duration INTEGER NOT NULL,
  comments TEXT NOT NULL DEFAULT ''
);

-- Get song data. Last one in wins.
INSERT INTO latestsongs (itunesid, name, sortname, composer, tracknumber, year, duration, comments) SELECT DISTINCT itunesid, name, sortname, composer, tracknumber, year, duration, comments FROM existing.tracks ORDER BY tag
  ON CONFLICT (itunesid) DO UPDATE SET
    name = EXCLUDED.name,
    sortname = EXCLUDED.sortname,
    composer = EXCLUDED.composer,
    tracknumber = EXCLUDED.tracknumber,
    year = EXCLUDED.year,
    duration = EXCLUDED.duration,
    comments = EXCLUDED.comments;

CREATE TABLE IF NOT EXISTS songs (
  itunesid TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  sortname TEXT NOT NULL DEFAULT '',
  artistid INTEGER NOT NULL,
  albumid INTEGER NOT NULL,
  composer TEXT NOT NULL DEFAULT '',
  tracknumber INTEGER NOT NULL,
  year INTEGER NOT NULL,
  duration INTEGER NOT NULL,
  dateadded TEXT NOT NULL,
  datereleased TEXT NOT NULL DEFAULT '',
  comments TEXT NOT NULL DEFAULT '',
  UNIQUE(itunesid, name, sortname, artistid, albumid, composer, tracknumber, year, duration, dateadded, datereleased, comments),
  FOREIGN KEY(artistid) REFERENCES artists(id),
  FOREIGN KEY(albumid) REFERENCES albums(id),
  CHECK(length(name) > 0),
  CHECK(name != sortname),
  CHECK(tracknumber > 0),
  CHECK(year >= 0),
  CHECK(duration > 0)
  UNIQUE(itunesid, name),
  UNIQUE(itunesid, duration)
);

INSERT INTO songs (itunesid, name, sortname, artistid, albumid, composer, tracknumber, year, duration, dateadded, datereleased, comments) SELECT DISTINCT e.itunesid, e.name, e.sortname, ar.artistid, al.albumid, e.composer, e.tracknumber, e.year, e.duration, added.date, released.date, e.comments FROM latestsongs e LEFT JOIN artistids ar ON e.itunesid = ar.itunesid LEFT JOIN albumids al ON e.itunesid = al.itunesid LEFT JOIN added ON e.itunesid = added.itunesid LEFT JOIN released ON e.itunesid = released.itunesid;

CREATE TABLE IF NOT EXISTS actualplaydates (
  id INTEGER PRIMARY KEY,
  itunesid TEXT NOT NULL,
  date TEXT NOT NULL,
  count INTEGER NOT NULL,
  FOREIGN KEY(itunesid) REFERENCES songs(itunesid),
  CHECK(length(date) > 0)
);

INSERT INTO actualplaydates (itunesid, date, count) SELECT DISTINCT itunesid, playdate, playcount FROM existing.tracks WHERE length(playdate) > 0 ORDER BY tag;

.quit

CREATE TABLE IF NOT EXISTS noquirksplaydates (
  id INTEGER PRIMARY KEY,
  itunesid TEXT NOT NULL,
  date TEXT NOT NULL,
  count INTEGER NOT NULL,
  FOREIGN KEY(itunesid) REFERENCES songs(itunesid),
  UNIQUE(itunesid, count)
  CHECK(length(date) > 0)
);

INSERT INTO noquirksplaydates(id, itunesid, date, count) SELECT id, itunesid, date, count FROM actualplaydates
  ON CONFLICT (itunesid, count) DO UPDATE SET
    date =
