-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Sat May  4 22:24:16 2013
-- 
;
--
-- Table: Genre.
--
CREATE TABLE "Genre" (
  "id" integer NOT NULL,
  "Bezeichnung" character varying NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "Genre_Bezeichnung" UNIQUE ("Bezeichnung")
);

;
--
-- Table: LinkBezeichnung.
--
CREATE TABLE "LinkBezeichnung" (
  "id" integer NOT NULL,
  "Bezeichnung" character varying NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "LinkBezeichnung_Bezeichnung" UNIQUE ("Bezeichnung")
);

;
--
-- Table: ReviewAuthor.
--
CREATE TABLE "ReviewAuthor" (
  "id" integer NOT NULL,
  "Bezeichnung" character varying NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "ReviewAuthor_Bezeichnung" UNIQUE ("Bezeichnung")
);

;
--
-- Table: Standort.
--
CREATE TABLE "Standort" (
  "id" integer NOT NULL,
  "Bezeichnung" character varying NOT NULL,
  "aktiv" boolean NOT NULL,
  "Standort" integer,
  PRIMARY KEY ("id"),
  CONSTRAINT "Standort_Bezeichnung" UNIQUE ("Bezeichnung")
);
CREATE INDEX "Standort_idx_Standort" on "Standort" ("Standort");

;
--
-- Table: Image.
--
CREATE TABLE "Image" (
  "id" integer NOT NULL,
  "Video" integer NOT NULL,
  "image" bytea NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "Image_idx_Video" on "Image" ("Video");

;
--
-- Table: Speicherort.
--
CREATE TABLE "Speicherort" (
  "id" integer NOT NULL,
  "Bezeichnung" character varying NOT NULL,
  "Standort" integer NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "Speicherort_Bezeichnung" UNIQUE ("Bezeichnung")
);
CREATE INDEX "Speicherort_idx_Standort" on "Speicherort" ("Standort");

;
--
-- Table: Video.
--
CREATE TABLE "Video" (
  "id" integer NOT NULL,
  "Titel" character varying NOT NULL,
  "Originaltitel" character varying NOT NULL,
  "isSerie" boolean NOT NULL,
  "isAnime" boolean NOT NULL,
  "Erscheinungsjahr" smallint,
  "Produktionsland" character varying,
  "Regisseur" character varying,
  "Minuten" character varying,
  "Episoden" character varying,
  "LaufzeitExtra" character varying,
  "IMDB" numeric,
  "OFDB" numeric,
  "Anisearch" numeric,
  "Bewertung" numeric,
  "Handlung" character varying,
  "Kommentar" character varying,
  "Info" character varying,
  "CoverImage" integer,
  "created" timestamp NOT NULL,
  "updated" timestamp NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "Video_Originaltitel" UNIQUE ("Originaltitel"),
  CONSTRAINT "Video_Titel" UNIQUE ("Titel")
);
CREATE INDEX "Video_idx_CoverImage" on "Video" ("CoverImage");

;
--
-- Table: Link.
--
CREATE TABLE "Link" (
  "id" integer NOT NULL,
  "Video" integer NOT NULL,
  "LinkBezeichnung" integer NOT NULL,
  "URL" character varying NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "Link_idx_LinkBezeichnung" on "Link" ("LinkBezeichnung");
CREATE INDEX "Link_idx_Video" on "Link" ("Video");

;
--
-- Table: Review.
--
CREATE TABLE "Review" (
  "id" integer NOT NULL,
  "Video" integer NOT NULL,
  "ReviewAuthor" integer NOT NULL,
  "Bewertung" numeric NOT NULL,
  "Review" clob NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "Review_idx_ReviewAuthor" on "Review" ("ReviewAuthor");
CREATE INDEX "Review_idx_Video" on "Review" ("Video");

;
--
-- Table: VideoGenre.
--
CREATE TABLE "VideoGenre" (
  "Video" integer NOT NULL,
  "Genre" integer NOT NULL,
  PRIMARY KEY ("Video", "Genre")
);
CREATE INDEX "VideoGenre_idx_Genre" on "VideoGenre" ("Genre");
CREATE INDEX "VideoGenre_idx_Video" on "VideoGenre" ("Video");

;
--
-- Table: VideoSpeicherort.
--
CREATE TABLE "VideoSpeicherort" (
  "id" integer NOT NULL,
  "Video" integer NOT NULL,
  "Speicherort" integer NOT NULL,
  "Inhalt" character varying NOT NULL,
  "created" timestamp NOT NULL,
  "updated" timestamp NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "VideoSpeicherort_Video_Speicherort" UNIQUE ("Video", "Speicherort")
);
CREATE INDEX "VideoSpeicherort_idx_Speicherort" on "VideoSpeicherort" ("Speicherort");
CREATE INDEX "VideoSpeicherort_idx_Video" on "VideoSpeicherort" ("Video");

;
--
-- Foreign Key Definitions
--

;
ALTER TABLE "Standort" ADD CONSTRAINT "Standort_fk_Standort" FOREIGN KEY ("Standort")
  REFERENCES "Standort" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "Image" ADD CONSTRAINT "Image_fk_Video" FOREIGN KEY ("Video")
  REFERENCES "Video" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "Speicherort" ADD CONSTRAINT "Speicherort_fk_Standort" FOREIGN KEY ("Standort")
  REFERENCES "Standort" ("id") DEFERRABLE;

;
ALTER TABLE "Video" ADD CONSTRAINT "Video_fk_CoverImage" FOREIGN KEY ("CoverImage")
  REFERENCES "Image" ("id") DEFERRABLE;

;
ALTER TABLE "Link" ADD CONSTRAINT "Link_fk_LinkBezeichnung" FOREIGN KEY ("LinkBezeichnung")
  REFERENCES "LinkBezeichnung" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "Link" ADD CONSTRAINT "Link_fk_Video" FOREIGN KEY ("Video")
  REFERENCES "Video" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "Review" ADD CONSTRAINT "Review_fk_ReviewAuthor" FOREIGN KEY ("ReviewAuthor")
  REFERENCES "ReviewAuthor" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "Review" ADD CONSTRAINT "Review_fk_Video" FOREIGN KEY ("Video")
  REFERENCES "Video" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "VideoGenre" ADD CONSTRAINT "VideoGenre_fk_Genre" FOREIGN KEY ("Genre")
  REFERENCES "Genre" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "VideoGenre" ADD CONSTRAINT "VideoGenre_fk_Video" FOREIGN KEY ("Video")
  REFERENCES "Video" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "VideoSpeicherort" ADD CONSTRAINT "VideoSpeicherort_fk_Speicherort" FOREIGN KEY ("Speicherort")
  REFERENCES "Speicherort" ("id") ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "VideoSpeicherort" ADD CONSTRAINT "VideoSpeicherort_fk_Video" FOREIGN KEY ("Video")
  REFERENCES "Video" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
