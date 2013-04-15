package Scring::Schema::ResultSet::Video;

=head1 NAME

Scring::Schema::ResultSet::Video

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Scring::Util;

use parent qw( DBIx::Class::ResultSet );

=head2 allTitles

=cut

sub allTitles {
	my $this = shift;

	return
	[ 
		$this->search( undef, { order_by => 'Titel' } )
				->get_column( 'Titel' )
				->all
	];
}

=head2 findVideo

Sucht ein Video und prefetcht die Genre und
das Titelbild.

Mehrere has_many relationships zu prefatchen würde
eine Warnung erzeugen

=cut

sub findVideo {
	my ( $this, %args ) = @_;
	
	# suche das Video un prefetche 
	# die Genre (über VideoGenre)
	# und das Titelbild
	$this->find( \%args, 
		{ 
			prefetch => [
				{ 'VideoGenre' => 'Genre' },
				'CoverImage',
			] 
		} 
	);
}


1;