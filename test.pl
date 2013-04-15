use 5.14.0;
use warnings;
$| = 1;


exit;

use Wx;
use Wx::Locale;

use POSIX;

POSIX::setlocale( LC_NUMERIC, "C" );

say 1.1;

POSIX::setlocale( LC_NUMERIC, "de-DE" );

say 1.1;

exit;

#say Wx::Locale::GetSystemLanguage();
#say Wx::Locale::GetSystemEncoding();

# while ( my ( $key, $value ) = each %ENV ) {
	# say $key, ' --- ', $value;
# }

#use Scring::Util;
# Scring::Util->initialize;
# Scring::Util->initializeSchema;
my $rs;

# $rs = $schema->resultset( 'Video' )->find( 39 );

# say $rs->Bewertung;

# $rs->Bewertung( 8.3 );

# $rs->update;
# say $rs->Bewertung;

use DBI;

my $dbh = DBI->connect( 'dbi:SQLite:dbname=userdata/Scring.db', '', '', { RaiseError => 1, ReadOnly => 1 } ) or die DBI::errstr;


$rs = $dbh->selectrow_hashref( <<SQL );
SELECT me.id, me.Titel, me.Originaltitel, me.isSerie, me.isAnime, me.Erscheinungsjahr, 
me.Produktionsland, me.Regisseur, me.Laufzeit, me.Folgen, me.IMDB, 
me.OFDB, me.Anisearch, me.Bewertung, me.Handlung, me.Kommentar, 
me.Info, me.TitleImage, me.created, me.updated 
FROM Video me WHERE ( me.id = 39 )
SQL

say $rs->{Bewertung};
