package Scring::Schema::ResultSet::Review;

=head1 NAME

Scring::Schema::ResultSet::Review

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use parent qw( DBIx::Class::ResultSet );

=head2 findReview( id )

Gibt nur die Reviewseite für die ReviewId zurück

=cut

sub findReview {
	my ( $this, $id ) = @_;
	
	return $this->find( $id, { select => 'Review' } )->Review;
}

1;