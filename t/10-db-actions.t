use 5.16.0;
use warnings;

use Test::More;

use lib '..';

use Scring::Util;

Scring::Util->initialize;
Scring::Util->initializeSchema;

# drop
$schema->resultset( 'Video' )->delete;
$schema->resultset( 'Genre' )->delete;

$schema->resultset( 'Genre' )->create( { Bezeichnung => 'Komödie' } );
$schema->resultset( 'Genre' )->create( { Bezeichnung => 'Zeichentrick' } );
$schema->resultset( 'Genre' )->create( { Bezeichnung => 'Drama' } );
$schema->resultset( 'Genre' )->create( { Bezeichnung => 'Aktion' } );

# video leer
my $count = $schema->resultset( 'Video' )->count;
cmp_ok( $count, '==', 0, 'video leer' );

# create simple video
my $video = $schema->resultset( 'Video' )->new( {} );

$video->Titel( 'T' );
$video->Originaltitel( 'O' );
$video->isSerie( 1 );
$video->isAnime( 0 );

$video->insert;

ok( $video->in_storage, 'in_storage ok' );

$video = $schema->resultset( 'Video' )->find( { Titel => 'T' } );

is( $video->Titel, 'T' );
is( $video->Originaltitel, 'O' );
cmp_ok( $video->isSerie, '==', 1 );
cmp_ok( $video->isAnime, '==', 0 );

# update
$video->Bewertung( 8.5 );
$video->update;

$video = $schema->resultset( 'Video' )->find( { Titel => 'T' } );

cmp_ok( $video->Bewertung, '==', 8.5 );

# generate genre map
my %genreMap;
for my $_ ( $schema->resultset( 'Genre' )->all ) {
	$genreMap{ $_->Bezeichnung } = $_->id;
}

# genre
$video->create_related( 'VideoGenre', { Genre => $genreMap{'Zeichentrick'} } );
$video->create_related( 'VideoGenre', { Genre => $genreMap{'Komödie'} } );

my @newGenre = qw( Drama Aktion Zeichentrick );
my @genre = map{ $_->Bezeichnung } $video->Genre;
# lösche überflüssige
for my $_ ( @genre ) {
	$video->delete_related( 'VideoGenre', { Genre => $genreMap{$_} } )
		if not $_ ~~ \@newGenre;
}

# füge neue hinzu
for my $_ ( @newGenre ) {
	$video->create_related( 'VideoGenre', { Genre => $genreMap{$_} } )
		if not $_ ~~ \@genre;
}

@genre = map{ $_->Bezeichnung } $video->Genre;
ok( 'Zeichentrick' ~~ \@genre );
ok( 'Drama' ~~ \@genre );
ok( 'Aktion' ~~ \@genre );




done_testing();

