package Scring::Wx::Dialog::Preferences::Expert;

=head1 NAME

Scring::Wx::Dialog::Preferences::Expert

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx;

use Scring::Util;

use parent -norequire => qw( Wx::Panel );

=head2 new

=cut

sub new {
	my ( $class, $parent ) = @_;
	
	my $this = $class->SUPER::new( $parent );
	
	return $this;
}

1;