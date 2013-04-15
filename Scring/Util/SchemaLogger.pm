package Scring::Util::SchemaLogger;

=head1 NAME

Scring::Util::SchemaLogger

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Scring::Util;

use parent 'DBIx::Class::Storage::Statistics';

=head2 print

=cut

sub print {
	my ( $this, $msg ) = @_;

	return if $this->silence;
	
	$logger->debug( $msg );
	
	1;
}



1;