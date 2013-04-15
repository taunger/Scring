package Scring::Schema::Result::VVideoBySpeicherortId;

use parent qw( DBIx::Class::Core );

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('VVideoBySpeicherortId');
__PACKAGE__->result_source_instance->is_virtual( 1 );

__PACKAGE__->result_source_instance->view_definition( <<SQL );
SELECT 
Video.id, Video.Titel, 
VideoSpeicherort.Speicherort as SpeicherortId
FROM Video
JOIN VideoSpeicherort ON ( Video.id = VideoSpeicherort.Video )
ORDER BY Video.id
SQL

#WHERE VideoSpeicherort.Speicherort = ?

__PACKAGE__->add_columns(  
	id            => { proportion => 1 },
	Titel         => { proportion => 6, titleColumn => 1 },
	SpeicherortId => { ignore => 1 },
#	Speicherort   => { ignore => 1 },
);

1;
