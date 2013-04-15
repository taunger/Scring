use 5.16.0;
use warnings;

use DBI;
use Data::Dumper;

use Scring::Util;
Scring::Util->initialize;
Scring::Util->initializeSchema;

$schema->storage->debug( 0 );

my $dbh  = DBI->connect( 'dbi:SQLite:dbname=Video.db', '', '', { RaiseError => 1, sqlite_unicode => 1 } ) or die DBI::errstr();
my $dbhI = DBI->connect( 'dbi:SQLite:dbname=Image.db', '', '', { RaiseError => 1, sqlite_unicode => 1 } ) or die DBI::errstr();
my $dbhR = DBI->connect( 'dbi:SQLite:dbname=Review.db', '', '', { RaiseError => 1, sqlite_unicode => 1 } ) or die DBI::errstr();

$schema->txn_begin;

my $sth = $dbh->prepare( 'select * from genre' );
$sth->execute;

while ( my $fetch = $sth->fetchrow_hashref ) {
	$schema->resultset( 'Genre' )->create( {
		'id' => $fetch->{ID},
		'Bezeichnung' => $fetch->{Bezeichnung},
	} );
}

$sth = $dbh->prepare( 'select * from video' );
$sth->execute;

while ( my $fetch = $sth->fetchrow_hashref ) {
	$schema->resultset( 'Video' )->create( {
		'id'               => $fetch->{ID},
		'Titel'            => $fetch->{Titel},
		'Originaltitel'    => $fetch->{Originaltitel},
		'isSerie'          => $fetch->{Serie},
		'isAnime'          => $fetch->{Anime},
		'Erscheinungsjahr' => $fetch->{Erscheinungsjahr},
		'Produktionsland'  => $fetch->{Produktionsland},
		'Regisseur'        => $fetch->{Regisseur},
		'Laufzeit'         => $fetch->{Laufzeit},
		'Folgen'           => $fetch->{Folgen},
		'IMDB'             => $fetch->{IMDB},
		'OFDB'             => $fetch->{OFDB},
		'Anisearch'        => $fetch->{Anisearch},
		'Bewertung'        => $fetch->{Bewertung},
		'Handlung'         => $fetch->{Handlung},
		'Kommentar'        => $fetch->{Kommentar},
		'Info'             => $fetch->{Zusatz},
	} );	
}

$sth = $dbh->prepare( 'select * from video_genre' );
$sth->execute;

while ( my $fetch = $sth->fetchrow_hashref ) {
	$schema->resultset( 'VideoGenre' )->create( {
		'Video' => $fetch->{video_id},
		'Genre' => $fetch->{genre_id},
	} );
}

$sth = $dbh->prepare( 'select * from link_bezeichnung' );
$sth->execute;

while ( my $fetch = $sth->fetchrow_hashref ) {
	$schema->resultset( 'LinkBezeichnung' )->create( {
		'id' => $fetch->{ID},
		'Bezeichnung' => $fetch->{Bezeichnung},
	} );
}


$sth = $dbh->prepare( 'select * from link' );
$sth->execute;

while ( my $fetch = $sth->fetchrow_hashref ) {

	$schema->resultset( 'Link' )->create( {
		'id' => $fetch->{ID},
		'Video' => $fetch->{video_id},
		'LinkBezeichnung' => $fetch->{link_bezeichnung_id},
		'URL' => $fetch->{url},
	} );
}

$sth = $dbh->prepare( 'select * from review_autor' );
$sth->execute;

while ( my $fetch = $sth->fetchrow_hashref ) {

	$schema->resultset( 'ReviewAuthor' )->create( {
		'id' => $fetch->{ID},
		'Bezeichnung' => $fetch->{Bezeichnung},
	} );
}

$sth = $dbh->prepare( 'select * from review' );
$sth->execute;

while ( my $fetch = $sth->fetchrow_hashref ) {

	my $fetch2 = $dbhR->selectrow_arrayref( 'select text from review where id = ' . $fetch->{ID} );
	
	die unless $fetch2->[0];

	$schema->resultset( 'Review' )->create( {
		'id' => $fetch->{ID},
		'Video' => $fetch->{video_id},
		'ReviewAuthor' => $fetch->{review_autor_id},
		'Bewertung' => $fetch->{Bewertung},
		'Review' => $fetch2->[0],
	} );
}

$sth = $dbh->prepare( 'select * from standort' );
$sth->execute;

while ( my $fetch = $sth->fetchrow_hashref ) {

	$schema->resultset( 'Standort' )->create( {
		'id' => $fetch->{ID},
		'Bezeichnung' => $fetch->{Bezeichnung},
		'aktiv' => $fetch->{aktiv},
		'Standort' => $fetch->{standort_id},
	} );
}

$sth = $dbh->prepare( 'select * from speicherort' );
$sth->execute;

while ( my $fetch = $sth->fetchrow_hashref ) {

	$schema->resultset( 'Speicherort' )->create( {
		'id' => $fetch->{ID},
		'Bezeichnung' => $fetch->{Bezeichnung},
		'Standort' => $fetch->{standort_id},
	} );
}

$sth = $dbh->prepare( 'select * from video_speicherort' );
$sth->execute;

while ( my $fetch = $sth->fetchrow_hashref ) {

	$schema->resultset( 'VideoSpeicherort' )->create( {
		'id' => $fetch->{ID},
		'Video' => $fetch->{video_id},
		'Speicherort' => $fetch->{speicherort_id},
		'Inhalt' => $fetch->{Inhalt},
	} );
}

$sth = $dbhI->prepare( 'select * from image' );
$sth->execute;

while ( my $fetch = $sth->fetchrow_hashref ) {
	$schema->resultset( 'Image' )->create( {
		'id'    => $fetch->{ID},
		'Video' => $fetch->{video_id},
		'image' => $fetch->{image},
	} );
}

$sth = $dbhI->prepare( 'select * from title_image' );
$sth->execute;

while ( my $fetch = $sth->fetchrow_hashref ) {
	my $rs = $schema->resultset( 'Video' )->find( $fetch->{video_id} );
	$rs->CoverImage( $fetch->{title_image_id} );
	$rs->update;
}

$schema->txn_commit;
