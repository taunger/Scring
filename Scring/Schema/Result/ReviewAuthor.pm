package Scring::Schema::Result::ReviewAuthor;

use parent qw( DBIx::Class::Core );

__PACKAGE__->table( 'ReviewAuthor' );

__PACKAGE__->add_column( 'id'          => { data_type => 'integer'  } );
__PACKAGE__->add_column( 'Bezeichnung' => { data_type => 'varchar2' } );

__PACKAGE__->set_primary_key( 'id' );
__PACKAGE__->add_unique_constraint( [qw( Bezeichnung )] );

__PACKAGE__->has_many( 'Reviews' => 'Scring::Schema::Result::Review' => 'ReviewAuthor' );

1;