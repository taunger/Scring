package Scring::Schema::ResultSet::VBewertungsliste;

=head1 NAME

Scring::Schema::ResultSet::Video

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Sort::Naturally;

use Scring::Util;

use parent qw( DBIx::Class::ResultSet );

=head2 search

=cut

sub search {
	my $this = shift;
	
	$logger->trace( '---' );
	
	my $rs = $this->next::method( @_ );
	
	#sort { Sort::Naturally::ncmp( $b->Bewertung, $a->Bewertung }->all
}


1;