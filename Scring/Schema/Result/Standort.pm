package Scring::Schema::Result::Standort;

use parent qw( DBIx::Class::Core );

__PACKAGE__->table( 'Standort' );

__PACKAGE__->add_column( 'id'          => { data_type => 'integer'  } );
__PACKAGE__->add_column( 'Bezeichnung' => { data_type => 'varchar2' } );
__PACKAGE__->add_column( 'aktiv'       => { data_type => 'boolean'  } );
__PACKAGE__->add_column( 'Standort'    => { data_type => 'integer', is_nullable => 1, is_foreign_key => 1 } );

__PACKAGE__->set_primary_key( 'id' );
__PACKAGE__->add_unique_constraint( [qw( Bezeichnung )] );

__PACKAGE__->has_many( 'Standorte' => 'Scring::Schema::Result::Standort' => 'Standort' );
__PACKAGE__->belongs_to( 'Standort' => 'Scring::Schema::Result::Standort' => 'Standort', 
	{ 
		join_type => 'left', # left wg. nullable 
	} 
);

1;