package Scring::Schema::Result::Video;

use parent qw( DBIx::Class::Core );

__PACKAGE__->load_components( qw( TimeStamp FilterColumn ) );

__PACKAGE__->table( 'Video' );

__PACKAGE__->add_column( 'id'               => { data_type => 'integer'  } );
__PACKAGE__->add_column( 'Titel'            => { data_type => 'varchar2' } );
__PACKAGE__->add_column( 'Originaltitel'    => { data_type => 'varchar2' } );
__PACKAGE__->add_column( 'isSerie'          => { data_type => 'boolean'  } );
__PACKAGE__->add_column( 'isAnime'          => { data_type => 'boolean'  } );
__PACKAGE__->add_column( 'Erscheinungsjahr' => { data_type => 'integer' , is_nullable => 1, size => 4 } );
__PACKAGE__->add_column( 'Produktionsland'  => { data_type => 'varchar2', is_nullable => 1 } );
__PACKAGE__->add_column( 'Regisseur'        => { data_type => 'varchar2', is_nullable => 1 } );
__PACKAGE__->add_column( 'Minuten'          => { data_type => 'varchar2', is_nullable => 1 } ); # varchar2 um datatype missmatch zu verhindern
__PACKAGE__->add_column( 'Episoden'         => { data_type => 'varchar2', is_nullable => 1 } ); # varchar2 um datatype missmatch zu verhindern
__PACKAGE__->add_column( 'LaufzeitExtra'    => { data_type => 'varchar2', is_nullable => 1 } );
__PACKAGE__->add_column( 'IMDB'             => { data_type => 'real'    , is_nullable => 1, is_numeric => 0 } ); # is_numeric, damit bei vergleichen mit '' keine Warnung
__PACKAGE__->add_column( 'OFDB'             => { data_type => 'real'    , is_nullable => 1, is_numeric => 0 } ); # is_numeric, damit bei vergleichen mit '' keine Warnung
__PACKAGE__->add_column( 'Anisearch'        => { data_type => 'real'    , is_nullable => 1, is_numeric => 0 } ); # is_numeric, damit bei vergleichen mit '' keine Warnung
__PACKAGE__->add_column( 'Bewertung'        => { data_type => 'real'    , is_nullable => 1, is_numeric => 0 } ); # is_numeric, damit bei vergleichen mit '' keine Warnung
__PACKAGE__->add_column( 'Handlung'         => { data_type => 'varchar2', is_nullable => 1 } );
__PACKAGE__->add_column( 'Kommentar'        => { data_type => 'varchar2', is_nullable => 1 } );
__PACKAGE__->add_column( 'Info'             => { data_type => 'varchar2', is_nullable => 1 } );
__PACKAGE__->add_column( 'CoverImage'       => { data_type => 'integer' , is_nullable => 1, is_foreign_key => 1 } );

__PACKAGE__->add_column( 'created' => { data_type => 'datetime', set_on_create => 1 } );
__PACKAGE__->add_column( 'updated' => { data_type => 'datetime', set_on_create => 1, set_on_update => 1 } );

__PACKAGE__->set_primary_key( 'id' );
__PACKAGE__->add_unique_constraint( [qw( Titel )] );
__PACKAGE__->add_unique_constraint( [qw( Originaltitel )] );

# many to many relationship bridge, this is
# slightly complex, see DBIx::Class::Relationship
__PACKAGE__->has_many( 'VideoGenre' => 'Scring::Schema::Result::VideoGenre', 'Video' );
__PACKAGE__->many_to_many( 'Genre' => 'VideoGenre' => 'Genre' );

# Vordefiniertes relationship query
# selectiert nur id, Bewertung und Author (Bezeichnungs-Proxy)
# SELECT me.id, me.Bewertung, ReviewAuthor.Bezeichnung FROM Review me  JOIN ReviewAuthor ReviewAuthor ON ReviewAuthor.id = me.ReviewAuthor
__PACKAGE__->has_many( 'Reviews' => 'Scring::Schema::Result::Review' => 'Video', { 
	select => [ 'id', 'Bewertung' ] ,	
	join => 'ReviewAuthor',							 
	'+select' => [ 'ReviewAuthor.Bezeichnung' ], 	
	order_by => 'Bezeichnung' } 
);

# Das prefetchen könnte nicht immer eine gute idee sein
__PACKAGE__->has_many( 'Links' => 'Scring::Schema::Result::Link' => 'Video', { prefetch => 'LinkBezeichnung', order_by => 'Bezeichnung' } );
__PACKAGE__->has_many( 'Speicherorte' => 'Scring::Schema::Result::VideoSpeicherort' => 'Video', { prefetch => 'Speicherort' } );
#__PACKAGE__->has_many( 'Speicherorte' => 'Scring::Schema::Result::VideoSpeicherort' => 'Video' );

# Dieses hier hat ein TitleImage
# Titelimages müssen nicht vorhanden sein
# TODO anstatt belongs_to ein might_have? - Testen mit Eintrag ohne Bild
__PACKAGE__->belongs_to( 'CoverImage' => 'Scring::Schema::Result::Image', 'CoverImage', { join_type => 'left', proxy => { CoverImageData => 'image' } } );
__PACKAGE__->has_many( 'Images' => 'Scring::Schema::Result::Image', 'Video' );

# Dieses Filtern dient nur nochmal zu Absicherung,
# dass auch nur richtig separierte Werte eingetragen werden
# TODO:später kann das vielleicht entfernt werden
#__PACKAGE__->filter_column( IMDB      => { filter_to_storage => sub { $_[1] =~ s!,!.!r } } );
#__PACKAGE__->filter_column( OFDB      => { filter_to_storage => sub { $_[1] =~ s!,!.!r } } );
#__PACKAGE__->filter_column( Anisearch => { filter_to_storage => sub { $_[1] =~ s!,!.!r } } );
#__PACKAGE__->filter_column( Bewertung => { filter_to_storage => sub { $_[1] =~ s!,!.!r } } );

=head2 GenreAsString

=cut

sub GenreAsString {
	my $this = shift;
	
	warn 'XXX Funktion obsolete XXX';
	
	# Prefetch Limitierung bei many-to-many führt zu diesem Konstrukt
	# siehe http://lists.scsys.co.uk/pipermail/dbix-class/2006-August/002175.html
	return join ';', map { $_->Bezeichnung } $this->Genre;
}

=head2 LaufzeitAsString

=cut

sub LaufzeitAsString {
	my $this = shift;
	
	my $ret = '';
	
	$ret .= $this->Minuten . ' Min '             if $this->Minuten;
	$ret .= '(' . $this->Episoden . ' Episoden) ' if $this->Episoden;
	
	return $this->LaufzeitExtra if not $ret;
	
	$ret .= '/ ' . $this->LaufzeitExtra if $this->LaufzeitExtra;
	
	return $ret;
}

1;