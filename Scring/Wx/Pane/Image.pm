package Scring::Wx::Pane::Image;

=head1 NAME

Scring::Wx::Pane::Image

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx qw( wxVERTICAL wxEXPAND wxALL wxID_ANY );

use Scring::Util;
use Scring::Wx::Widget::Image;

use parent -norequire => qw( Wx::Panel );

use Object::Tiny qw( W );

=head2 new

=cut

sub new {
	my $class = shift;
	
	$logger->trace( '---' );
	
	my $this = $class->SUPER::new( @_ );
	
	$this->prepareGUI;
	
	return $this;
}

=head2 prepareGUI

=cut

sub prepareGUI {
	my $this = shift;
	
	$logger->trace( '---' );
	
	my $W = $this->{W} = {};
	my $S = {};
	my $P = $this;
	
	$W->{Image} = Scring::Wx::Widget::Image->new( $P, wxID_ANY );
	
	$S->{Main} = Wx::BoxSizer->new( wxVERTICAL );
	
	$S->{Main}->Add( $W->{Image}, 1, wxEXPAND | wxALL, 5 );
	
	$this->SetSizer( $S->{Main} );
	$this->SetAutoLayout( 1 );
	
	1;
}

=head2 loadFrom( relationship )

=cut

sub loadFrom {
	my ( $this, $rs ) = @_;

	$logger->trace( '---' );

	$this->W->{Image}->loadStream( \ $rs->TitleImage->image );
	
	1;	
}

1;