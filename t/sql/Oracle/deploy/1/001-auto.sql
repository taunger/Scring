-- 
-- Created by SQL::Translator::Producer::Oracle
-- Created on Sat May  4 22:24:15 2013
-- 
;
--
-- Table: Genre
--;
CREATE TABLE "Genre" (
  "id" number NOT NULL,
  "Bezeichnung" varchar2(4000) NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "Genre_Bezeichnung" UNIQUE ("Bezeichnung")
);
--
-- Table: LinkBezeichnung
--;
CREATE TABLE "LinkBezeichnung" (
  "id" number NOT NULL,
  "Bezeichnung" varchar2(4000) NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "LinkBezeichnung_Bezeichnung" UNIQUE ("Bezeichnung")
);
--
-- Table: ReviewAuthor
--;
CREATE TABLE "ReviewAuthor" (
  "id" number NOT NULL,
  "Bezeichnung" varchar2(4000) NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "ReviewAuthor_Bezeichnung" UNIQUE ("Bezeichnung")
);
--
-- Table: Standort
--;
CREATE TABLE "Standort" (
  "id" number NOT NULL,
  "Bezeichnung" varchar2(4000) NOT NULL,
  "aktiv" number NOT NULL,
  "Standort" number,
  PRIMARY KEY ("id"),
  CONSTRAINT "Standort_Bezeichnung" UNIQUE ("Bezeichnung")
);
--
-- Table: Image
--;
CREATE TABLE "Image" (
  "id" number NOT NULL,
  "Video" number NOT NULL,
  "image" blob NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: Speicherort
--;
CREATE TABLE "Speicherort" (
  "id" number NOT NULL,
  "Bezeichnung" varchar2(4000) NOT NULL,
  "Standort" number NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "Speicherort_Bezeichnung" UNIQUE ("Bezeichnung")
);
--
-- Table: Video
--;
CREATE TABLE "Video" (
  "id" number NOT NULL,
  "Titel" varchar2(4000) NOT NULL,
  "Originaltitel" varchar2(4000) NOT NULL,
  "isSerie" number NOT NULL,
  "isAnime" number NOT NULL,
  "Erscheinungsjahr" number(4),
  "Produktionsland" varchar2(4000),
  "Regisseur" varchar2(4000),
  "Minuten" varchar2(4000),
  "Episoden" varchar2(4000),
  "LaufzeitExtra" varchar2(4000),
  "IMDB" real,
  "OFDB" real,
  "Anisearch" real,
  "Bewertung" real,
  "Handlung" varchar2(4000),
  "Kommentar" varchar2(4000),
  "Info" varchar2(4000),
  "CoverImage" number,
  "created" date NOT NULL,
  "updated" date NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "Video_Originaltitel" UNIQUE ("Originaltitel"),
  CONSTRAINT "Video_Titel" UNIQUE ("Titel")
);
--
-- Table: Link
--;
CREATE TABLE "Link" (
  "id" number NOT NULL,
  "Video" number NOT NULL,
  "LinkBezeichnung" number NOT NULL,
  "URL" varchar2(4000) NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: Review
--;
CREATE TABLE "Review" (
  "id" number NOT NULL,
  "Video" number NOT NULL,
  "ReviewAuthor" number NOT NULL,
  "Bewertung" real NOT NULL,
  "Review" clob NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: VideoGenre
--;
CREATE TABLE "VideoGenre" (
  "Video" number NOT NULL,
  "Genre" number NOT NULL,
  PRIMARY KEY ("Video", "Genre")
);
--
-- Table: VideoSpeicherort
--;
CREATE TABLE "VideoSpeicherort" (
  "id" number NOT NULL,
  "Video" number NOT NULL,
  "Speicherort" number NOT NULL,
  "Inhalt" varchar2(4000) NOT NULL,
  "created" date NOT NULL,
  "updated" date NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "VideoSpeicherort_Video_Speicherort" UNIQUE ("Video", "Speicherort")
);
ALTER TABLE "Standort" ADD CONSTRAINT "Standort_Standort_fk" FOREIGN KEY ("Standort") REFERENCES "Standort" ("id") ON DELETE CASCADE;
ALTER TABLE "Image" ADD CONSTRAINT "Image_Video_fk" FOREIGN KEY ("Video") REFERENCES "Video" ("id") ON DELETE CASCADE;
ALTER TABLE "Speicherort" ADD CONSTRAINT "Speicherort_Standort_fk" FOREIGN KEY ("Standort") REFERENCES "Standort" ("id");
ALTER TABLE "Video" ADD CONSTRAINT "Video_CoverImage_fk" FOREIGN KEY ("CoverImage") REFERENCES "Image" ("id");
ALTER TABLE "Link" ADD CONSTRAINT "Link_LinkBezeichnung_fk" FOREIGN KEY ("LinkBezeichnung") REFERENCES "LinkBezeichnung" ("id") ON DELETE CASCADE;
ALTER TABLE "Link" ADD CONSTRAINT "Link_Video_fk" FOREIGN KEY ("Video") REFERENCES "Video" ("id") ON DELETE CASCADE;
ALTER TABLE "Review" ADD CONSTRAINT "Review_ReviewAuthor_fk" FOREIGN KEY ("ReviewAuthor") REFERENCES "ReviewAuthor" ("id") ON DELETE CASCADE;
ALTER TABLE "Review" ADD CONSTRAINT "Review_Video_fk" FOREIGN KEY ("Video") REFERENCES "Video" ("id") ON DELETE CASCADE;
ALTER TABLE "VideoGenre" ADD CONSTRAINT "VideoGenre_Genre_fk" FOREIGN KEY ("Genre") REFERENCES "Genre" ("id") ON DELETE CASCADE;
ALTER TABLE "VideoGenre" ADD CONSTRAINT "VideoGenre_Video_fk" FOREIGN KEY ("Video") REFERENCES "Video" ("id") ON DELETE CASCADE;
ALTER TABLE "VideoSpeicherort" ADD CONSTRAINT "VideoSpeicherort_Speicherort_f" FOREIGN KEY ("Speicherort") REFERENCES "Speicherort" ("id");
ALTER TABLE "VideoSpeicherort" ADD CONSTRAINT "VideoSpeicherort_Video_fk" FOREIGN KEY ("Video") REFERENCES "Video" ("id") ON DELETE CASCADE;
CREATE INDEX "Standort_idx_Standort" on "Standort" ("Standort");
CREATE INDEX "Image_idx_Video" on "Image" ("Video");
CREATE INDEX "Speicherort_idx_Standort" on "Speicherort" ("Standort");
CREATE INDEX "Video_idx_CoverImage" on "Video" ("CoverImage");
CREATE INDEX "Link_idx_LinkBezeichnung" on "Link" ("LinkBezeichnung");
CREATE INDEX "Link_idx_Video" on "Link" ("Video");
CREATE INDEX "Review_idx_ReviewAuthor" on "Review" ("ReviewAuthor");
CREATE INDEX "Review_idx_Video" on "Review" ("Video");
CREATE INDEX "VideoGenre_idx_Genre" on "VideoGenre" ("Genre");
CREATE INDEX "VideoGenre_idx_Video" on "VideoGenre" ("Video");
CREATE INDEX "VideoSpeicherort_idx_Speichero" on "VideoSpeicherort" ("Speicherort");
CREATE INDEX "VideoSpeicherort_idx_Video" on "VideoSpeicherort" ("Video");
