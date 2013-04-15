package Scring::Schema::Result::Link;

use parent qw( DBIx::Class::Core );

__PACKAGE__->table( 'Link' );

__PACKAGE__->add_column( 'id'              => { data_type => 'integer' } );
__PACKAGE__->add_column( 'Video'           => { data_type => 'integer', is_foreign_key => 1 } );
__PACKAGE__->add_column( 'LinkBezeichnung' => { data_type => 'integer', is_foreign_key => 1 } );
__PACKAGE__->add_column( 'URL'             => { data_type => 'varchar2' } );

__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->belongs_to( 'Video' => 'Scring::Schema::Result::Video' );
__PACKAGE__->belongs_to( 'LinkBezeichnung' => 'Scring::Schema::Result::LinkBezeichnung' => 'LinkBezeichnung', { proxy => 'Bezeichnung' } );

1;