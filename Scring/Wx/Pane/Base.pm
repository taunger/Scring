package Scring::Wx::Pane::Base;

=head1 NAME

Scring::Wx::Pane::Base

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx qw( 
	wxID_ANY wxDefaultPosition wxDefaultSize wxTE_READONLY wxHORIZONTAL wxEXPAND wxRIGHT wxBOTTOM wxALL 
	wxVERTICAL wxBORDER_NONE wxTE_MULTILINE wxSHAPED wxLEFT
);

use Scring::Util;
use Scring::Wx::Widget::TextCtrlGenre;

use parent -norequire => qw( Wx::Panel );

use Object::Tiny qw( W );

use constant SINGLELINE_FIELDS_EXCLUDE_GENRE => qw( Titel Originaltitel Erscheinungsjahr Produktionsland Regisseur Laufzeit IMDB OFDB Anisearch Bewertung );
use constant SINGLELINE_FIELDS              => qw( Titel Originaltitel Genre Erscheinungsjahr Produktionsland Regisseur Laufzeit IMDB OFDB Anisearch Bewertung );
use constant MULTILINE_FIELDS               => qw( Handlung Kommentar );

=head2 new

=cut

sub new {
	my $class = shift;
	
	$logger->trace( '---' );
	
	my $this = $class->SUPER::new( @_ );

	$this->initialize;
	$this->editMode( 0 );
	
	return $this;
}

=head2 initialize

=cut

sub initialize {
	my $this = shift;
	
	$logger->trace( '---' );
	
	my $W = $this->{W} = {};
	my $S = {};
	my $P = $this;
	
	# Als erstes alle Eingabefelder in der richtigen Reihenfolge
	# definieren, um die Tab-Order zu wahren
	for ( qw( Titel Originaltitel ) ) {
		$W->{ "ED_$_" } = Wx::TextCtrl->new( $P, wxID_ANY, '', wxDefaultPosition, $config->get( 'wx.panel.base.textctrlSize' ), wxBORDER_NONE | wxTE_READONLY );
	}
	
	$W->{ "ED_Genre" } = Scring::Wx::Widget::TextCtrlGenre->new( $P, wxID_ANY, '', wxDefaultPosition, $config->get( 'wx.panel.base.textctrlSize' ), wxBORDER_NONE | wxTE_READONLY );
	
	$W->{CH_Anime} = Wx::CheckBox->new( $this, wxID_ANY, '' ); $W->{CH_Anime}->SetToolTip( 'Anime' );
	
	for ( qw( Erscheinungsjahr Produktionsland Regisseur Laufzeit ) ) {
		$W->{ "ED_$_" } = Wx::TextCtrl->new( $P, wxID_ANY, '', wxDefaultPosition, $config->get( 'wx.panel.base.textctrlSize' ), wxBORDER_NONE | wxTE_READONLY );
	}

	$W->{CH_Serie} = Wx::CheckBox->new( $this, wxID_ANY, '' ); $W->{CH_Serie}->SetToolTip( 'Serie' );
	
	$W->{ED_Minuten}       = Wx::TextCtrl->new( $P, wxID_ANY, '', wxDefaultPosition, [ 40, 22 ], wxBORDER_NONE );
	$W->{ED_Episoden}      = Wx::TextCtrl->new( $P, wxID_ANY, '', wxDefaultPosition, [ 40, 22 ], wxBORDER_NONE );
	$W->{ED_LaufzeitExtra} = Wx::TextCtrl->new( $P, wxID_ANY, '', wxDefaultPosition, $config->get( 'wx.panel.base.textctrlSize' ), wxBORDER_NONE );
		
	for ( qw( IMDB OFDB Anisearch Bewertung ) ) {
		$W->{ "ED_$_" } = Wx::TextCtrl->new( $P, wxID_ANY, '', wxDefaultPosition, $config->get( 'wx.panel.base.textctrlSize' ), wxBORDER_NONE | wxTE_READONLY );
	}
	
	for ( qw( Handlung Kommentar ) ) {
		$W->{ "ED_$_" } = Wx::TextCtrl->new( $P, wxID_ANY, '', wxDefaultPosition, wxDefaultSize, wxBORDER_NONE | wxTE_READONLY | wxTE_MULTILINE );
	}
	
	# Und ab hier bauen wir uns das Layout auf
	$S->{Main} = Wx::BoxSizer->new( wxVERTICAL );
	$S->{Rand} = Wx::BoxSizer->new( wxVERTICAL );
		
	for ( SINGLELINE_FIELDS_EXCLUDE_GENRE ) {
		$W->{ "ST_$_" } = Wx::StaticText->new( $P, wxID_ANY, "$_:" );
		$S->{ $_ } = Wx::BoxSizer->new( wxHORIZONTAL );
		$S->{ $_ }->Add( $W->{ "ST_$_" }, 1, wxRIGHT, 5 );
		$S->{ $_ }->Add( $W->{ "ED_$_" }, 3 );
		$S->{Rand}->Add( $S->{ $_ }, 0, wxEXPAND | wxBOTTOM, 5 );
	}
		
	$W->{ "ST_Genre" } = Wx::StaticText->new( $P, wxID_ANY, "Genre:" );
	
	$S->{ Genre } = Wx::BoxSizer->new( wxHORIZONTAL );
	$S->{ "Sub_Genre" } = Wx::BoxSizer->new( wxHORIZONTAL );
	$S->{ "Sub_Genre" }->Add( $W->{ "ED_Genre" }, 1 );
	$S->{ "Sub_Genre" }->Add( $W->{CH_Anime}, 0, wxLEFT, 10 ); # wxLEFT hier, ansonsten werden bei Hide die Pixel nicht mit versteckt
	$S->{ Genre }->Add( $W->{ "ST_Genre" }, 1, wxRIGHT, 5 );
	$S->{ Genre }->Add( $S->{ "Sub_Genre" }, 3 );
	$S->{Rand}->Insert( 2, $S->{ Genre }, 0, wxEXPAND | wxBOTTOM, 5 );

	$W->{ST_editLaufzeit} = Wx::StaticText->new( $P, wxID_ANY, 'Laufzeit: ' );
	$W->{ST_Minuten}          = Wx::StaticText->new( $P, wxID_ANY, 'Min,' );
	$W->{ST_Episoden}     = Wx::StaticText->new( $P, wxID_ANY, 'Episoden,' );

	$S->{editLaufzeit} = Wx::BoxSizer->new( wxHORIZONTAL );
	$S->{subEditLaufzeit} = Wx::BoxSizer->new( wxHORIZONTAL );
	
	$S->{subEditLaufzeit}->Add( $W->{ED_Minuten}, 0, wxRIGHT, 5 );
	$S->{subEditLaufzeit}->Add( $W->{ST_Minuten}, 0, wxRIGHT, 10 );
	$S->{subEditLaufzeit}->Add( $W->{ED_Episoden}, 0, wxRIGHT, 5 );
	$S->{subEditLaufzeit}->Add( $W->{ST_Episoden}, 0, wxRIGHT, 10 );
	$S->{subEditLaufzeit}->Add( $W->{ED_LaufzeitExtra}, 1, wxRIGHT, 10 );
	$S->{subEditLaufzeit}->Add( $W->{CH_Serie}, 0 );
	
	$S->{editLaufzeit}->Add( $W->{ST_editLaufzeit}, 1, wxRIGHT, 5 );
	$S->{editLaufzeit}->Add( $S->{subEditLaufzeit}, 3 );
	
	$S->{Rand}->Insert( 7, $S->{editLaufzeit}, 0, wxEXPAND | wxBOTTOM, 5 );
	
	for ( MULTILINE_FIELDS ) {
		$W->{ "ST_$_" } = Wx::StaticText->new( $P, wxID_ANY, "$_:" );

		# Es scheint einen Resize-Bug zu geben, 
		# wenn eines der beiden Textfelder mehr gefüllt ist,
		# erhält es Priorität. Dies lässt sich offensichtlich
		# mit einem fixes setzen der MinSize ausschalten		
		$W->{ "ED_$_" }->SetMinSize( Wx::wxSIZE( 0, 0 ) );
		###
		
		$S->{ $_ } = Wx::BoxSizer->new( wxHORIZONTAL );
		$S->{ $_ }->Add( $W->{ "ST_$_" }, 1, wxRIGHT, 5 );
		$S->{ $_ }->Add( $W->{ "ED_$_" }, 3, wxEXPAND );
		$S->{Rand}->Add( $S->{ $_ }, 1, wxEXPAND | wxBOTTOM, 8 );
	}
	
	# Die Hintergrundfarbe der Singleline Fields
	# genau wie die der Multilines setzen
	my $colour = $W->{ED_Handlung}->GetBackgroundColour;
	for ( SINGLELINE_FIELDS ) {
		$W->{ "ED_$_" }->SetBackgroundColour( $colour );
	}
	
	$S->{Main}->Add( $S->{Rand}, 1, wxEXPAND | wxALL, 10 );
	
	$this->SetSizer( $S->{Main} );
	$this->SetAutoLayout( 1 );

	
	1;
}

=head2 loadFrom( resultset )

=cut

sub loadFrom {
	my ( $this, $rs ) = @_;
	
	$logger->trace( '---' );
	
	my $W = $this->W;
	
	for ( qw(Titel Originaltitel Erscheinungsjahr Produktionsland Regisseur LaufzeitExtra IMDB OFDB Anisearch Bewertung), MULTILINE_FIELDS ) {
		$W->{ "ED_$_" }->ChangeValue( $rs->get_column( $_ ) );
	}

	$W->{ED_Minuten}->ChangeValue( $rs->Minuten );
	$W->{ED_Episoden}->ChangeValue( $rs->Episoden );
	$W->{ED_Laufzeit}->ChangeValue( $rs->LaufzeitAsString );
		
	$W->{CH_Anime}->SetValue( $rs->isAnime );
	$W->{CH_Serie}->SetValue( $rs->isSerie );
	
	$W->{ED_Genre}->loadFrom( $rs );

	1;
}

=head2 editMode

=cut

sub editMode {
	my ( $this, $set ) = @_;
	
	return $this->{editMode} if not defined $set;
	
	# Alle Felder editierbar machen
	for ( qw(Titel Originaltitel Erscheinungsjahr Produktionsland Regisseur IMDB OFDB Anisearch Bewertung), MULTILINE_FIELDS ) {
		$this->{W}{ "ED_$_" }->SetEditable( $set );
	}
	
	# Zusätzliche nur-edit-Fenster einblenden
	$this->{W}{CH_Anime}->Show( $set );
	$this->{W}{CH_Serie}->Show( $set );
	$this->{W}{ST_editLaufzeit}->Show( $set );
	$this->{W}{ST_Minuten}->Show( $set );
	$this->{W}{ST_Episoden}->Show( $set );
	$this->{W}{ED_LaufzeitExtra}->Show( $set );
	$this->{W}{ED_Minuten}->Show( $set );
	$this->{W}{ED_Episoden}->Show( $set );
	
	# Das einzelne Laufzeitfenster im entgegengesetzt einblenden
	$this->{W}{ST_Laufzeit}->Show( ! $set );
	$this->{W}{ED_Laufzeit}->Show( ! $set );
	
	$this->Layout;
	
	$this->{editMode} = $set;
	
	1;
}

=head2 clear

=cut

sub clear {
	my $this = shift;
	
	for ( qw(Titel Originaltitel Erscheinungsjahr Produktionsland Regisseur LaufzeitExtra IMDB OFDB Anisearch Bewertung Genre Minuten Episoden Laufzeit), MULTILINE_FIELDS ) {
		$this->{W}{"ED_$_"}->Clear;
	}
	
	$this->{W}{CH_Anime}->SetValue( 0 );
	$this->{W}{CH_Serie}->SetValue( 0 );
	
	1;
}

=head2 storeTo( resultset )

=cut

sub storeTo {
	my ( $this, $rs ) = @_;
	
	my $W = $this->{W};
	
	for ( qw(Titel Originaltitel Erscheinungsjahr Produktionsland Regisseur LaufzeitExtra IMDB OFDB Anisearch Bewertung Episoden Minuten ), MULTILINE_FIELDS ) {
		$rs->set_column( $_ => $W->{ "ED_$_" }->GetValue );
	}
	
	$rs->isAnime( $W->{CH_Anime}->GetValue ? 1 : 0 );
	$rs->isSerie( $W->{CH_Serie}->GetValue ? 1 : 0 );
	
	# Ein Speichern tut damit zumindest immer den Zeitstempel aktualisieren
	$rs->updated( $rs->get_timestamp );
	
	$rs->in_storage 
		? $rs->update 
		: $rs->insert
	;
	
	# Genre speichern lassen
	$W->{ED_Genre}->storeTo( $rs );
	
	1;
}


1;