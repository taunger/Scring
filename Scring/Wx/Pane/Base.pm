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
	wxVERTICAL wxBORDER_NONE wxTE_MULTILINE wxSHAPED  
);

use Scring::Util;

use parent -norequire => qw( Wx::Panel );

use Object::Tiny qw( W );

use constant SINGLELINE_FIELDS_EXCLUE_GENRE => qw( Titel Originaltitel Erscheinungsjahr Produktionsland Regisseur Laufzeit IMDB OFDB Anisearch Bewertung );
use constant SINGLELINE_FIELDS              => qw( Titel Originaltitel Genre Erscheinungsjahr Produktionsland Regisseur Laufzeit IMDB OFDB Anisearch Bewertung );
use constant MULTILINE_FIELDS               => qw( Handlung Kommentar );


=head2 new

=cut

sub new {
	my $class = shift;
	
	$logger->trace( '---' );
	
	my $this = $class->SUPER::new( @_ );

	$this->initialize;
	
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
	
	$S->{Main} = Wx::BoxSizer->new( wxVERTICAL );
	$S->{Rand} = Wx::BoxSizer->new( wxVERTICAL );
		
	for my $_ ( SINGLELINE_FIELDS ) {
		$W->{ "ST_$_" } = Wx::StaticText->new( $P, wxID_ANY, "$_:" );
		$W->{ "ED_$_" } = Wx::TextCtrl->new( $P, wxID_ANY, '', wxDefaultPosition, $config->get( 'wx.panel.base.textctrlSize' ), wxBORDER_NONE | wxTE_READONLY );
		$S->{ $_ } = Wx::BoxSizer->new( wxHORIZONTAL );
		$S->{ $_ }->Add( $W->{ "ST_$_" }, 1, wxRIGHT, 5 );
		$S->{ $_ }->Add( $W->{ "ED_$_" }, 3 );
		$S->{Rand}->Add( $S->{ $_ }, 0, wxEXPAND | wxBOTTOM, 5 );
	}
	
	for my $_ ( MULTILINE_FIELDS ) {
		$W->{ "ST_$_" } = Wx::StaticText->new( $P, wxID_ANY, "$_:" );
		$W->{ "ED_$_" } = Wx::TextCtrl->new( $P, wxID_ANY, '', wxDefaultPosition, wxDefaultSize, wxBORDER_NONE | wxTE_READONLY | wxTE_MULTILINE );
		
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
	for my $_ ( SINGLELINE_FIELDS ) {
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
	
	for my $_ ( SINGLELINE_FIELDS_EXCLUE_GENRE, MULTILINE_FIELDS ) {
		$W->{ "ED_$_" }->ChangeValue( $rs->get_column( $_ ) );
	}

	$W->{ED_Genre}->ChangeValue( $rs->GenreAsString );

	1;
}

=head2 editMode

=cut

sub editMode {
	my ( $this, $set ) = @_;
	
	return $this->{editMode} if not defined $set;
	
	for my $_ ( SINGLELINE_FIELDS, MULTILINE_FIELDS ) {
		$this->{W}{ "ED_$_" }->SetEditable( $set );
	}
}

1;