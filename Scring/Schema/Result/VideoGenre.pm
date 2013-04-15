package Scring::Schema::Result::VideoGenre;

use parent qw( DBIx::Class::Core );

__PACKAGE__->table( 'VideoGenre' );

__PACKAGE__->add_column( 'Video' => { data_type => 'integer', is_foreign_key => 1 } );
__PACKAGE__->add_column( 'Genre' => { data_type => 'integer', is_foreign_key => 1 } );

__PACKAGE__->set_primary_key( 'Video', 'Genre' );

__PACKAGE__->belongs_to( 'Video' => 'Scring::Schema::Result::Video' );
__PACKAGE__->belongs_to( 'Genre' => 'Scring::Schema::Result::Genre' );

1;
