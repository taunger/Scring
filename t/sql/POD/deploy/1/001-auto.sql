=pod

=head1 DESCRIPTION

Schema

=head1 TABLES

=head2 Genre

=head3 FIELDS

=head4 id

=over 4

=item * integer

=item * PRIMARY KEY

=item * Nullable 'No' 

=back

=head4 Bezeichnung

=over 4

=item * varchar2

=item * Nullable 'No' 

=back

=head3 CONSTRAINTS

=head4 PRIMARY KEY

=over 4

=item * Fields = id

=back

=head4 UNIQUE

=over 4

=item * Fields = Bezeichnung

=back

=head2 LinkBezeichnung

=head3 FIELDS

=head4 id

=over 4

=item * integer

=item * PRIMARY KEY

=item * Nullable 'No' 

=back

=head4 Bezeichnung

=over 4

=item * varchar2

=item * Nullable 'No' 

=back

=head3 CONSTRAINTS

=head4 PRIMARY KEY

=over 4

=item * Fields = id

=back

=head4 UNIQUE

=over 4

=item * Fields = Bezeichnung

=back

=head2 ReviewAuthor

=head3 FIELDS

=head4 id

=over 4

=item * integer

=item * PRIMARY KEY

=item * Nullable 'No' 

=back

=head4 Bezeichnung

=over 4

=item * varchar2

=item * Nullable 'No' 

=back

=head3 CONSTRAINTS

=head4 PRIMARY KEY

=over 4

=item * Fields = id

=back

=head4 UNIQUE

=over 4

=item * Fields = Bezeichnung

=back

=head2 Standort

=head3 FIELDS

=head4 id

=over 4

=item * integer

=item * PRIMARY KEY

=item * Nullable 'No' 

=back

=head4 Bezeichnung

=over 4

=item * varchar2

=item * Nullable 'No' 

=back

=head4 aktiv

=over 4

=item * boolean

=item * Nullable 'No' 

=back

=head4 Standort

=over 4

=item * integer

=item * Nullable 'Yes' 

=back

=head3 INDICES

=head4 NORMAL

=over 4

=item * Fields = Standort

=back

=head3 CONSTRAINTS

=head4 PRIMARY KEY

=over 4

=item * Fields = id

=back

=head4 UNIQUE

=over 4

=item * Fields = Bezeichnung

=back

=head4 FOREIGN KEY

=over 4

=item * Fields = Standort

=item * Reference Table = L</Standort>

=item * Reference Fields = L</id>

=item * On update = CASCADE

=item * On delete = CASCADE

=back

=head2 Image

=head3 FIELDS

=head4 id

=over 4

=item * integer

=item * PRIMARY KEY

=item * Nullable 'No' 

=back

=head4 Video

=over 4

=item * integer

=item * Nullable 'No' 

=back

=head4 image

=over 4

=item * blob

=item * Nullable 'No' 

=back

=head3 INDICES

=head4 NORMAL

=over 4

=item * Fields = Video

=back

=head3 CONSTRAINTS

=head4 PRIMARY KEY

=over 4

=item * Fields = id

=back

=head4 FOREIGN KEY

=over 4

=item * Fields = Video

=item * Reference Table = L</Video>

=item * Reference Fields = L</id>

=item * On update = CASCADE

=item * On delete = CASCADE

=back

=head2 Speicherort

=head3 FIELDS

=head4 id

=over 4

=item * integer

=item * PRIMARY KEY

=item * Nullable 'No' 

=back

=head4 Bezeichnung

=over 4

=item * varchar2

=item * Nullable 'No' 

=back

=head4 Standort

=over 4

=item * integer

=item * Nullable 'No' 

=back

=head3 INDICES

=head4 NORMAL

=over 4

=item * Fields = Standort

=back

=head3 CONSTRAINTS

=head4 PRIMARY KEY

=over 4

=item * Fields = id

=back

=head4 UNIQUE

=over 4

=item * Fields = Bezeichnung

=back

=head4 FOREIGN KEY

=over 4

=item * Fields = Standort

=item * Reference Table = L</Standort>

=item * Reference Fields = L</id>

=back

=head2 Video

=head3 FIELDS

=head4 id

=over 4

=item * integer

=item * PRIMARY KEY

=item * Nullable 'No' 

=back

=head4 Titel

=over 4

=item * varchar2

=item * Nullable 'No' 

=back

=head4 Originaltitel

=over 4

=item * varchar2

=item * Nullable 'No' 

=back

=head4 isSerie

=over 4

=item * boolean

=item * Nullable 'No' 

=back

=head4 isAnime

=over 4

=item * boolean

=item * Nullable 'No' 

=back

=head4 Erscheinungsjahr

=over 4

=item * integer(4)

=item * Nullable 'Yes' 

=back

=head4 Produktionsland

=over 4

=item * varchar2

=item * Nullable 'Yes' 

=back

=head4 Regisseur

=over 4

=item * varchar2

=item * Nullable 'Yes' 

=back

=head4 Minuten

=over 4

=item * varchar2

=item * Nullable 'Yes' 

=back

=head4 Episoden

=over 4

=item * varchar2

=item * Nullable 'Yes' 

=back

=head4 LaufzeitExtra

=over 4

=item * varchar2

=item * Nullable 'Yes' 

=back

=head4 IMDB

=over 4

=item * real

=item * Nullable 'Yes' 

=back

=head4 OFDB

=over 4

=item * real

=item * Nullable 'Yes' 

=back

=head4 Anisearch

=over 4

=item * real

=item * Nullable 'Yes' 

=back

=head4 Bewertung

=over 4

=item * real

=item * Nullable 'Yes' 

=back

=head4 Handlung

=over 4

=item * varchar2

=item * Nullable 'Yes' 

=back

=head4 Kommentar

=over 4

=item * varchar2

=item * Nullable 'Yes' 

=back

=head4 Info

=over 4

=item * varchar2

=item * Nullable 'Yes' 

=back

=head4 CoverImage

=over 4

=item * integer

=item * Nullable 'Yes' 

=back

=head4 created

=over 4

=item * datetime

=item * Nullable 'No' 

=back

=head4 updated

=over 4

=item * datetime

=item * Nullable 'No' 

=back

=head3 INDICES

=head4 NORMAL

=over 4

=item * Fields = CoverImage

=back

=head3 CONSTRAINTS

=head4 PRIMARY KEY

=over 4

=item * Fields = id

=back

=head4 UNIQUE

=over 4

=item * Fields = Originaltitel

=back

=head4 UNIQUE

=over 4

=item * Fields = Titel

=back

=head4 FOREIGN KEY

=over 4

=item * Fields = CoverImage

=item * Reference Table = L</Image>

=item * Reference Fields = L</id>

=back

=head2 Link

=head3 FIELDS

=head4 id

=over 4

=item * integer

=item * PRIMARY KEY

=item * Nullable 'No' 

=back

=head4 Video

=over 4

=item * integer

=item * Nullable 'No' 

=back

=head4 LinkBezeichnung

=over 4

=item * integer

=item * Nullable 'No' 

=back

=head4 URL

=over 4

=item * varchar2

=item * Nullable 'No' 

=back

=head3 INDICES

=head4 NORMAL

=over 4

=item * Fields = LinkBezeichnung

=back

=head4 NORMAL

=over 4

=item * Fields = Video

=back

=head3 CONSTRAINTS

=head4 PRIMARY KEY

=over 4

=item * Fields = id

=back

=head4 FOREIGN KEY

=over 4

=item * Fields = LinkBezeichnung

=item * Reference Table = L</LinkBezeichnung>

=item * Reference Fields = L</id>

=item * On update = CASCADE

=item * On delete = CASCADE

=back

=head4 FOREIGN KEY

=over 4

=item * Fields = Video

=item * Reference Table = L</Video>

=item * Reference Fields = L</id>

=item * On update = CASCADE

=item * On delete = CASCADE

=back

=head2 Review

=head3 FIELDS

=head4 id

=over 4

=item * integer

=item * PRIMARY KEY

=item * Nullable 'No' 

=back

=head4 Video

=over 4

=item * integer

=item * Nullable 'No' 

=back

=head4 ReviewAuthor

=over 4

=item * integer

=item * Nullable 'No' 

=back

=head4 Bewertung

=over 4

=item * real

=item * Nullable 'No' 

=back

=head4 Review

=over 4

=item * clob

=item * Nullable 'No' 

=back

=head3 INDICES

=head4 NORMAL

=over 4

=item * Fields = ReviewAuthor

=back

=head4 NORMAL

=over 4

=item * Fields = Video

=back

=head3 CONSTRAINTS

=head4 PRIMARY KEY

=over 4

=item * Fields = id

=back

=head4 FOREIGN KEY

=over 4

=item * Fields = ReviewAuthor

=item * Reference Table = L</ReviewAuthor>

=item * Reference Fields = L</id>

=item * On update = CASCADE

=item * On delete = CASCADE

=back

=head4 FOREIGN KEY

=over 4

=item * Fields = Video

=item * Reference Table = L</Video>

=item * Reference Fields = L</id>

=item * On update = CASCADE

=item * On delete = CASCADE

=back

=head2 VideoGenre

=head3 FIELDS

=head4 Video

=over 4

=item * integer

=item * PRIMARY KEY

=item * Nullable 'No' 

=back

=head4 Genre

=over 4

=item * integer

=item * PRIMARY KEY

=item * Nullable 'No' 

=back

=head3 INDICES

=head4 NORMAL

=over 4

=item * Fields = Genre

=back

=head4 NORMAL

=over 4

=item * Fields = Video

=back

=head3 CONSTRAINTS

=head4 PRIMARY KEY

=over 4

=item * Fields = Video, Genre

=back

=head4 FOREIGN KEY

=over 4

=item * Fields = Genre

=item * Reference Table = L</Genre>

=item * Reference Fields = L</id>

=item * On update = CASCADE

=item * On delete = CASCADE

=back

=head4 FOREIGN KEY

=over 4

=item * Fields = Video

=item * Reference Table = L</Video>

=item * Reference Fields = L</id>

=item * On update = CASCADE

=item * On delete = CASCADE

=back

=head2 VideoSpeicherort

=head3 FIELDS

=head4 id

=over 4

=item * integer

=item * PRIMARY KEY

=item * Nullable 'No' 

=back

=head4 Video

=over 4

=item * integer

=item * Nullable 'No' 

=back

=head4 Speicherort

=over 4

=item * integer

=item * Nullable 'No' 

=back

=head4 Inhalt

=over 4

=item * varchar2

=item * Nullable 'No' 

=back

=head4 created

=over 4

=item * datetime

=item * Nullable 'No' 

=back

=head4 updated

=over 4

=item * datetime

=item * Nullable 'No' 

=back

=head3 INDICES

=head4 NORMAL

=over 4

=item * Fields = Speicherort

=back

=head4 NORMAL

=over 4

=item * Fields = Video

=back

=head3 CONSTRAINTS

=head4 PRIMARY KEY

=over 4

=item * Fields = id

=back

=head4 UNIQUE

=over 4

=item * Fields = Video, Speicherort

=back

=head4 FOREIGN KEY

=over 4

=item * Fields = Speicherort

=item * Reference Table = L</Speicherort>

=item * Reference Fields = L</id>

=item * On update = CASCADE

=back

=head4 FOREIGN KEY

=over 4

=item * Fields = Video

=item * Reference Table = L</Video>

=item * Reference Fields = L</id>

=item * On update = CASCADE

=item * On delete = CASCADE

=back

=head1 PRODUCED BY

SQL::Translator::Producer::POD

=cut;
