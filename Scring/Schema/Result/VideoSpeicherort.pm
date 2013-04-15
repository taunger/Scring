package Scring::Schema::Result::VideoSpeicherort;

use parent qw( DBIx::Class::Core );

__PACKAGE__->load_components( qw( TimeStamp ) );

__PACKAGE__->table( 'VideoSpeicherort' );

__PACKAGE__->add_column( 'id'          => { data_type => 'integer'  } );
__PACKAGE__->add_column( 'Video'       => { data_type => 'integer', is_foreign_key => 1 } );
__PACKAGE__->add_column( 'Speicherort' => { data_type => 'integer', is_foreign_key => 1 } );
__PACKAGE__->add_column( 'Inhalt'      => { data_type => 'varchar2' } );

__PACKAGE__->add_column( 'created' => { data_type => 'datetime', set_on_create => 1 } );
__PACKAGE__->add_column( 'updated' => { data_type => 'datetime', set_on_create => 1, set_on_update => 1 } );

__PACKAGE__->set_primary_key( 'id' );
__PACKAGE__->add_unique_constraint( [qw( Video Speicherort )] );

__PACKAGE__->belongs_to( 'Video' => 'Scring::Schema::Result::Video' );
__PACKAGE__->belongs_to( 'Speicherort' => 'Scring::Schema::Result::Speicherort' => 'Speicherort', { proxy => 'Bezeichnung' } );

1;