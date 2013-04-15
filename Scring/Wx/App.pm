package Scring::Wx::App;

=head1 NAME

Scring::Wx::App

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx qw( wxID_ANY wxDefaultPosition );

use Scring::Util;
use Scring::Wx::Frame;

use parent -norequire => qw( Wx::App );
use Object::Tiny qw( frame );

=head2 OnInit

=cut

sub OnInit {
	my $this = shift;
	
	$logger->trace( '---' );
	
	$this->SetAppName( $config->get( 'app.name' ) );
	
	# wir können gleich alle ImageHandler initialisieren
	Wx::InitAllImageHandlers( );
	
	# Aufpassen, dass das Fenster
	# nie größer als das Display ist
	my $size        = $config->get( 'wx.frame.size' );
	my $displaySize = Wx::GetDisplaySize();
	 
	$size->[0] = $displaySize->GetWidth  if $size->[0] > $displaySize->GetWidth;
	$size->[1] = $displaySize->GetHeight if $size->[1] > $displaySize->GetHeight;
	
	$logger->trace( 'Fenstergröße: ', $size->[0], 'x', $size->[1] );
	
	# Erstellen des Frames
	my $frame = $this->{frame} = Scring::Wx::Frame->new(
		undef,							# kein Eltern Fenster
		wxID_ANY,
		$config->get( 'app.name' ),		# Fenstertitel
		wxDefaultPosition,				# wir zentrieren gleich unten
		$size,
	);
	
	$this->SetTopWindow( $frame );
	
	$frame->SetIcon( Scring::Util->getIcon );
	$frame->Centre;
	$frame->Show;
	
	1;	
}

1;