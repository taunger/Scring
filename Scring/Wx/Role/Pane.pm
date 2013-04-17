package Scring::Wx::Role::Pane;

=head1 NAME

Scring::Wx::Role::Pane

=head1 DESCRIPTION

Setzt und verwendet die editMode Instanzvariable

aui Membervariable muss für show gesetzt werden

=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Scring::Util;

sub aui      { if ( @_ > 1 ) { $_[0]->{aui}      = $_[1] } ; $_[0]->{aui}      }
sub editMode { if ( @_ > 1 ) { $_[0]->{editMode} = $_[1] } ; $_[0]->{editMode} }

=head2 show( show )

=cut

sub show {
	my ( $this, $show ) = @_;
	
	$logger->trace( '---' );

	$this->aui->showPane( $this, $show );
	
	1;
}

=head2 isShown

=cut

sub isShown {
	my $this = shift;
	
	return $this->aui->isPaneShown( $this );
}

=head2 toggleShow

=cut

sub toggleShow {
	my $this = shift;
	
	if ( $this->isShown ) {
		$logger->trace( 'hide' );
		$this->show( 0 );
		return 0;
	} 
	else {
		$logger->trace( 'show' );
		$this->show( 1 );
		return 1;
	}	
}

1;