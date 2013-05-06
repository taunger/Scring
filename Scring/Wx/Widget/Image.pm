package Scring::Wx::Widget::Image;

=head1 NAME

Scring::Wx::Widget::Image

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx qw( wxBITMAP_TYPE_ANY wxBITMAP_TYPE_JPEG wxBITMAP_TYPE_BMP wxBITMAP_TYPE_GIF wxBITMAP_TYPE_PNG );
use Wx::Event;

use Image::Info;

use Scring::Util;

use parent -norequire => qw( Wx::Window );

use Object::Tiny qw( Image Bitmap );

# nur ein nackt schwarzes default-Bild
my $defaultImage = Wx::Image->newWH( 300, 400 );

=head2 new

=cut

sub new {
	my $class = shift;
	
	$logger->trace( '---' );
	
	my $this = $class->SUPER::new( @_ );
	
	# mein aktuelles Bild ist das default-Bild
	# daraus wird auch gleich ein bitmap gemacht
	$this->{Image} = $defaultImage;
	$this->{Bitmap} = Wx::Bitmap->new( $defaultImage );
	
	# Die benötigten Events verknüpfen
	Wx::Event::EVT_PAINT( $this, \&OnPaint );
	Wx::Event::EVT_SIZE( $this, \&OnSize );
	
	return $this;
}

=head2 OnSize

=cut

sub OnSize {
	my ( $this, $event ) = @_;

	$logger->trace( '---' );

	$this->resizeBitmap( $event->GetSize );
	
	1;
}

=head2 OnPaint

=cut

sub OnPaint {
	my ( $this, $event ) = @_;
	
	# Zugriff auf die Zeichenfläche des Fensters verschaffen
	# Es *muss* auf jeden Fall in diesen Handler generiert werden
	# siehe wxPaintDC Doku
	my $DC = Wx::PaintDC->new( $this );

	# Hier wird das Bitmap zentriert
	# auf die verfügbare Fläche gezeichnet
	$DC->DrawBitmap( 
		$this->{Bitmap},
		( $this->GetSize->GetWidth  - $this->{Bitmap}->GetWidth  ) / 2,		# x, zentriert 
		( $this->GetSize->GetHeight - $this->{Bitmap}->GetHeight ) / 2,		# y, zentirert
		0 																	# Transparenz
	);
}

=head2 resizeBitmap( wxSize )

Das Bitmap wird aus dem Image an die übergebene Größe
angepasst und neu generiert.

=cut

sub resizeBitmap {
	my ( $this, $size ) = @_;
	
	# Dies sind die aktuellen Fensterwerte
	my $windowHeight = $size->GetHeight;
	my $windowWidth	 = $size->GetWidth;
	
	# In diesen werten werden die endgültigen
	# Werte für das neue Bitmap stehen
	my $newHeight = $windowHeight;
	my $newWidth  = $windowWidth;
	
	# und das ist die größe des aktuellen Bildes
	my $imageHeight	= $this->{Image}->GetHeight;
	my $imageWidth	= $this->{Image}->GetWidth;
	
	# Skalierung berechnen ( aktuelle Fehsterbreite / Imagebreite )
	my $scale = $newWidth / $imageWidth;

	# Höhe an Skalierung anpassen
	$newHeight = $imageHeight * $scale;
	
	# Sollte die Neue Imagehöhe noch über der Fensterhöhe liegen
	# Dann wird dasselbe nochmal mit der Breite gemacht
	if ( $newHeight > $windowHeight ) {
		$scale = $windowHeight / $newHeight;
		$newHeight = $windowHeight;
		$newWidth *= $scale;
	}	
	
	# Und hier wird dann das neue zu zeichnende Bitmap erstellt
	$this->{Bitmap} = Wx::Bitmap->new( $this->{Image}->Scale( $newWidth, $newHeight ) );
	
	1;
}

=head2 loadStream( stream )

stream ist eine Scalar-Reference auf ein Bild-Binärblob

Sollte stream auf undef referenzieren, wird Clear aufgerufen


=cut

my %wxTypeMap = (
	JPEG => wxBITMAP_TYPE_JPEG,
	BMP  => wxBITMAP_TYPE_BMP,
	GIF  => wxBITMAP_TYPE_GIF,
	PNG  => wxBITMAP_TYPE_PNG,	
);

sub loadStream {
	my ( $this, $stream ) = @_;
	
	$logger->trace( $stream );
	
	# Wenn kein Bild hinterlegt ist, das aktuelle Bild
	# zurücksetzen
	if ( not $$stream ) {
		$this->Clear;
		return 0;
	}
		
	eval {
		open my $fh, '<', $stream or die "Bildstream konnte nicht geöffnet werden: $!";

		# Mit wxWidgets < 2.9 hat das folgende funktioniert,
		# aber seitdem eine Überprüfung auf die "Seekbarkeit" des
		# Streams gemacht wird, scheint es nicht mehr zu funktionieren,
		# obwohl sich der Stream eigentlich nicht verändert hat

		#$this->{Image} = Wx::Image->new( $fh, wxBITMAP_TYPE_ANY );

		# also dieser Workaround hier
		# Allerdings liefert Image::Info::image_type nicht
		# in allen Situationen dieselben Resultate wie wxBITMAP_TYPE_ANY
		my $type = Image::Info::image_type( $stream );
		die "Konnte Bildtyp nicht ermitteln: $type->{error}" if ( $type->{error} );
		
		my $wxtype = $wxTypeMap{ $type->{file_type} };
		die "Konnte Bildtyp $type->{file_type} nicht mappen" if not $wxtype;
		
		$this->{Image} = Wx::Image->new( $fh, $wxtype );		
		die 'Image ist nicht ok' if not $this->{Image}->IsOk;
		
		close $fh or die $!;
	};
	
	# alles ok, zeichne Bitmap
	if ( not $@ ) {
		
		$this->resizeBitmap( $this->GetSize );
		$this->Refresh;		
	} 

	# falls ein Fehler aufgetreten ist, wollen
	# wir noch mit einen blauen Auge davon kommen
	else {
		$logger->error( $@ );
		$this->Clear;
	}
	
	1;
}

=head2 Clear

=cut

sub Clear {
	my $this = shift;
	
	$this->{Image} = $defaultImage;
	$this->resizeBitmap( $this->GetSize );
	$this->Refresh;
}

1;