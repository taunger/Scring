package Scring::Schema::Result::Image;

use parent qw( DBIx::Class::Core );

__PACKAGE__->table( 'Image' );

__PACKAGE__->add_column( 'id'    => { data_type => 'integer' } );
__PACKAGE__->add_column( 'Video' => { data_type => 'integer', is_foreign_key => 1 } );
__PACKAGE__->add_column( 'image' => { data_type => 'blob'    } );

__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->belongs_to( 'Video' => 'Scring::Schema::Result::Video' => 'Video' );

1;