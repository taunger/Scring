package Scring::Schema::Result::VBewertungsliste;

use Scring::Util;

use parent qw( DBIx::Class::Core );

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('VBewertungsliste');
__PACKAGE__->result_source_instance->is_virtual( 1 );

__PACKAGE__->result_source_instance->view_definition( <<SQL );
SELECT 
Titel, Bewertung 
FROM Video
where Bewertung != ''
SQL

#WHERE VideoSpeicherort.Speicherort = ?

__PACKAGE__->add_columns(  
	Bewertung => { proportion => 1 },
	Titel     => { proportion => 6, titleColumn => 1 },
);



1;
