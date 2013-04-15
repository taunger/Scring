package Scring::Schema::Result::Speicherort;

use parent qw( DBIx::Class::Core );

__PACKAGE__->table( 'Speicherort' );

__PACKAGE__->add_column( 'id'          => { data_type => 'integer'  } );
__PACKAGE__->add_column( 'Bezeichnung' => { data_type => 'varchar2' } );
__PACKAGE__->add_column( 'Standort'    => { data_type => 'integer', is_foreign_key => 1 } );

__PACKAGE__->set_primary_key( 'id' );
__PACKAGE__->add_unique_constraint( [qw( Bezeichnung )] );

__PACKAGE__->has_many( 'VideoSpeicherorte' => 'Scring::Schema::Result::VideoSpeicherort' => 'Speicherort', { cascade_delete => 0, cascade_update => 0 } );
__PACKAGE__->belongs_to( 'Standort' => 'Scring::Schema::Result::Standort' => 'Standort' );

1;