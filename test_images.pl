use 5.16.0;
use warnings;
$| = 1;
use Scring::Util;
Scring::Util->initialize;
Scring::Util->initializeSchema;

use Wx qw( :everything );
use Image::Info qw( image_type );

my %wxTypeMap = (
	JPEG => wxBITMAP_TYPE_JPEG,
	BMP  => wxBITMAP_TYPE_BMP,
	GIF  => wxBITMAP_TYPE_GIF,
	PNG  => wxBITMAP_TYPE_PNG,	
);

for my $rs ( $schema->resultset( 'Image' )->all ) {
	
	my $stream = \ $rs->image;
	
	open my $fh, '<', $stream or die "Bildstream konnte nicht geöffnet werden: $!";
	
	my $type = Image::Info::image_type( $stream );
	die "Konnte Bildtyp nicht ermitteln: $type->{error}" if ( $type->{error} );
	
	my $wxtype = $wxTypeMap{ $type->{file_type} };
	die "Konnte Bildtyp $type->{file_type} nicht mappen" if not $wxtype;
	
	my $image = Wx::Image->new( $fh, $wxtype );		
	if ( not $image->IsOk ) {
		say "print " . $rs->Video->Titel . '_' . $rs->id . '.' . $type->{file_type};
		open my $out, '>', $rs->Video->Titel . '_' . $rs->id . '.' . $type->{file_type} or die $!;
		binmode $out;
		print $out $rs->image;
		close $out;
	}	
}

