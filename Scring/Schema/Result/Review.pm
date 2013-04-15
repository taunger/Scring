package Scring::Schema::Result::Review;

use parent qw( DBIx::Class::Core );

__PACKAGE__->load_components( qw( FilterColumn ) );

__PACKAGE__->table( 'Review' );

__PACKAGE__->add_column( 'id'           => { data_type => 'integer' } );
__PACKAGE__->add_column( 'Video'        => { data_type => 'integer', is_foreign_key => 1 } );
__PACKAGE__->add_column( 'ReviewAuthor' => { data_type => 'integer', is_foreign_key => 1 } );
__PACKAGE__->add_column( 'Bewertung'    => { data_type => 'real' } );
__PACKAGE__->add_column( 'Review'       => { data_type => 'clob' } );

__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->belongs_to( 'Video' => 'Scring::Schema::Result::Video' );
__PACKAGE__->belongs_to( 'ReviewAuthor' => 'Scring::Schema::Result::ReviewAuthor' => 'ReviewAuthor', { proxy => { 'Author' => 'Bezeichnung' } } );


# Die Bewertung soll immer mit /10 angezeigt werden
# TODO, dass kann dann irgendwann nach dem Datenimport weg
__PACKAGE__->filter_column( Bewertung => {
     filter_to_storage   => sub { $_[1] =~ s!/10!!r },
     filter_from_storage => sub { $_[1] . '/10' },
 } );


1;