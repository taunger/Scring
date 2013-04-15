package Scring::Wx::Pane::Cover;

=head1 NAME

Scring::Wx::Pane::Cover

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx qw( wxVERTICAL wxEXPAND wxALL wxID_ANY );

use Scring::Util;
use Scring::Wx::Widget::Image;

use parent -norequire => qw( Wx::Panel );

use Object::Tiny qw( cover );

=head2 new

=cut

sub new {
	my $class = shift;
	
	$logger->trace( '---' );
	
	my $this = $class->SUPER::new( @_ );
	
	$this->initialize;
	
	return $this;
}

=head2 initialize

=cut

sub initialize {
	my $this = shift;
	
	$logger->trace( '---' );
	
	my $S = {};
	
	$this->{cover} = Scring::Wx::Widget::Image->new( $this, wxID_ANY );
	
	$S->{Main} = Wx::BoxSizer->new( wxVERTICAL );
	$S->{Main}->Add( $this->cover, 1, wxEXPAND | wxALL, 5 );
	
	$this->SetSizer( $S->{Main} );
	$this->SetAutoLayout( 1 );
	
	1;
}

=head2 loadFrom( relationship )

=cut

sub loadFrom {
	my ( $this, $rs ) = @_;

	$logger->trace( '---' );

	$this->cover->loadStream( \ $rs->CoverImageData );
	
	1;	
}

1;