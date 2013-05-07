-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Sat May  4 22:24:15 2013
-- 

;
BEGIN TRANSACTION;
--
-- Table: Genre
--
CREATE TABLE Genre (
  id INTEGER PRIMARY KEY NOT NULL,
  Bezeichnung varchar2 NOT NULL
);
CREATE UNIQUE INDEX Genre_Bezeichnung ON Genre (Bezeichnung);
--
-- Table: LinkBezeichnung
--
CREATE TABLE LinkBezeichnung (
  id INTEGER PRIMARY KEY NOT NULL,
  Bezeichnung varchar2 NOT NULL
);
CREATE UNIQUE INDEX LinkBezeichnung_Bezeichnung ON LinkBezeichnung (Bezeichnung);
--
-- Table: ReviewAuthor
--
CREATE TABLE ReviewAuthor (
  id INTEGER PRIMARY KEY NOT NULL,
  Bezeichnung varchar2 NOT NULL
);
CREATE UNIQUE INDEX ReviewAuthor_Bezeichnung ON ReviewAuthor (Bezeichnung);
--
-- Table: Standort
--
CREATE TABLE Standort (
  id INTEGER PRIMARY KEY NOT NULL,
  Bezeichnung varchar2 NOT NULL,
  aktiv boolean NOT NULL,
  Standort integer,
  FOREIGN KEY (Standort) REFERENCES Standort(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX Standort_idx_Standort ON Standort (Standort);
CREATE UNIQUE INDEX Standort_Bezeichnung ON Standort (Bezeichnung);
--
-- Table: Image
--
CREATE TABLE Image (
  id INTEGER PRIMARY KEY NOT NULL,
  Video integer NOT NULL,
  image blob NOT NULL,
  FOREIGN KEY (Video) REFERENCES Video(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX Image_idx_Video ON Image (Video);
--
-- Table: Speicherort
--
CREATE TABLE Speicherort (
  id INTEGER PRIMARY KEY NOT NULL,
  Bezeichnung varchar2 NOT NULL,
  Standort integer NOT NULL,
  FOREIGN KEY (Standort) REFERENCES Standort(id)
);
CREATE INDEX Speicherort_idx_Standort ON Speicherort (Standort);
CREATE UNIQUE INDEX Speicherort_Bezeichnung ON Speicherort (Bezeichnung);
--
-- Table: Video
--
CREATE TABLE Video (
  id INTEGER PRIMARY KEY NOT NULL,
  Titel varchar2 NOT NULL,
  Originaltitel varchar2 NOT NULL,
  isSerie boolean NOT NULL,
  isAnime boolean NOT NULL,
  Erscheinungsjahr integer(4),
  Produktionsland varchar2,
  Regisseur varchar2,
  Minuten varchar2,
  Episoden varchar2,
  LaufzeitExtra varchar2,
  IMDB real,
  OFDB real,
  Anisearch real,
  Bewertung real,
  Handlung varchar2,
  Kommentar varchar2,
  Info varchar2,
  CoverImage integer,
  created datetime NOT NULL,
  updated datetime NOT NULL,
  FOREIGN KEY (CoverImage) REFERENCES Image(id)
);
CREATE INDEX Video_idx_CoverImage ON Video (CoverImage);
CREATE UNIQUE INDEX Video_Originaltitel ON Video (Originaltitel);
CREATE UNIQUE INDEX Video_Titel ON Video (Titel);
--
-- Table: Link
--
CREATE TABLE Link (
  id INTEGER PRIMARY KEY NOT NULL,
  Video integer NOT NULL,
  LinkBezeichnung integer NOT NULL,
  URL varchar2 NOT NULL,
  FOREIGN KEY (LinkBezeichnung) REFERENCES LinkBezeichnung(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (Video) REFERENCES Video(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX Link_idx_LinkBezeichnung ON Link (LinkBezeichnung);
CREATE INDEX Link_idx_Video ON Link (Video);
--
-- Table: Review
--
CREATE TABLE Review (
  id INTEGER PRIMARY KEY NOT NULL,
  Video integer NOT NULL,
  ReviewAuthor integer NOT NULL,
  Bewertung real NOT NULL,
  Review clob NOT NULL,
  FOREIGN KEY (ReviewAuthor) REFERENCES ReviewAuthor(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (Video) REFERENCES Video(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX Review_idx_ReviewAuthor ON Review (ReviewAuthor);
CREATE INDEX Review_idx_Video ON Review (Video);
--
-- Table: VideoGenre
--
CREATE TABLE VideoGenre (
  Video integer NOT NULL,
  Genre integer NOT NULL,
  PRIMARY KEY (Video, Genre),
  FOREIGN KEY (Genre) REFERENCES Genre(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (Video) REFERENCES Video(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX VideoGenre_idx_Genre ON VideoGenre (Genre);
CREATE INDEX VideoGenre_idx_Video ON VideoGenre (Video);
--
-- Table: VideoSpeicherort
--
CREATE TABLE VideoSpeicherort (
  id INTEGER PRIMARY KEY NOT NULL,
  Video integer NOT NULL,
  Speicherort integer NOT NULL,
  Inhalt varchar2 NOT NULL,
  created datetime NOT NULL,
  updated datetime NOT NULL,
  FOREIGN KEY (Speicherort) REFERENCES Speicherort(id) ON UPDATE CASCADE,
  FOREIGN KEY (Video) REFERENCES Video(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX VideoSpeicherort_idx_Speicherort ON VideoSpeicherort (Speicherort);
CREATE INDEX VideoSpeicherort_idx_Video ON VideoSpeicherort (Video);
CREATE UNIQUE INDEX VideoSpeicherort_Video_Speicherort ON VideoSpeicherort (Video, Speicherort);
COMMIT;
