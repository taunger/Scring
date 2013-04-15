package Scring::Wx::Pane::Info;

=head1 NAME

Scring::Wx::Pane::Info

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx;
use Wx::Event;

use Scring::Util;

use parent -norequire => qw( Wx::TextCtrl );

=head2 new

=cut

sub new {
	my $class = shift;
	
	$logger->trace( '---' );
	
	my $this = $class->SUPER::new( @_ );
	
	return $this;	
}

=head2 loadFrom( resultset )

=cut

sub loadFrom {
	my ( $this, $rs ) = @_;
	
	$logger->trace( '---' );
	
	$this->ChangeValue( $rs->Info );
	
	1;
}

1;