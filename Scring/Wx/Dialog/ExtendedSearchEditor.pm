package Scring::Wx::Dialog::ExtendedSearchEditor;

=head1 NAME

Scring::Wx::Dialog::ExtendedSearchEditor

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx qw( wxID_ANY wxDefaultPosition wxDEFAULT_DIALOG_STYLE wxRESIZE_BORDER wxDefaultSize wxTE_READONLY wxCB_READONLY 
		   wxEXPAND wxALL wxVERTICAL wxHORIZONTAL wxRIGHT wxBOTTOM wxOK wxCANCEL wxID_OK wxID_CANCEL wxFONTFAMILY_MODERN wxFONTSTYLE_NORMAL 
		   wxFONTWEIGHT_NORMAL wxTE_PROCESS_ENTER wxTE_PROCESS_TAB wxTE_MULTILINE );
use Wx::Event;
use Wx::ArtProvider qw( wxART_PLUS wxART_MINUS );

use Scring::Util;

use parent -norequire => qw( Wx::Dialog );

=head2 new

=cut

sub new {
	my ( $class, $parent ) = @_;
	
	my $this = $class->SUPER::new( 
		$parent, wxID_ANY, 'SQL bearbeiten',
		wxDefaultPosition,
		$config->get( 'wx.dialog.ExtendedSearchEditor.size' ),
		wxDEFAULT_DIALOG_STYLE | wxRESIZE_BORDER
	);
	
	$this->prepareGUI;
	
	$this->{W}{ED_sql}->SetFont( 
		Wx::Font->new( 10, wxFONTFAMILY_MODERN, wxFONTSTYLE_NORMAL, wxFONTWEIGHT_NORMAL ) 
	);
	
	$this->{W}{ED_sql}->SetFocus;
	
	return $this;
}

=head2 prepareGUI

=cut

sub prepareGUI {
	my $this = shift;
	
	my $S = {};
	my $W = $this->{W} = {};
	
	$W->{ED_name} = Wx::TextCtrl->new( $this, wxID_ANY, '' );
	
	# TODO send patch to wxWidgets
	$W->{BTN_Add}    = Wx::BitmapButton->new( $this, wxID_ANY, Wx::ArtProvider::GetBitmap( wxART_PLUS ), wxDefaultPosition, Wx::wxSIZE( 29, 29 ) );
	$W->{BTN_Remove} = Wx::BitmapButton->new( $this, wxID_ANY, Wx::ArtProvider::GetBitmap( wxART_MINUS ), wxDefaultPosition, Wx::wxSIZE( 29, 29 ) );

	$W->{ED_sql} = Wx::TextCtrl->new( $this, wxID_ANY, '', wxDefaultPosition, wxDefaultSize, wxTE_PROCESS_TAB | wxTE_MULTILINE );

	$S->{Main} = Wx::BoxSizer->new( wxVERTICAL );
	$S->{Rand} = Wx::BoxSizer->new( wxVERTICAL );
	$S->{Top}  = Wx::BoxSizer->new( wxHORIZONTAL );

	$S->{Top}->Add( $W->{ED_name}, 1, wxRIGHT, 10 );
	$S->{Top}->Add( $W->{BTN_Add}, 0, wxRIGHT, 5 );
	$S->{Top}->Add( $W->{BTN_Remove}, 0 );
	
	$S->{Rand}->Add( $S->{Top}, 0, wxEXPAND | wxBOTTOM, 10 );
	$S->{Rand}->Add( $W->{ED_sql}, 1, wxEXPAND | wxBOTTOM, 10 );
	$S->{Rand}->Add( $this->CreateSeparatedButtonSizer( wxOK | wxCANCEL ), 0, wxEXPAND );
	
	$S->{Main}->Add( $S->{Rand}, 1, wxEXPAND | wxALL, 10 );
	
	$this->SetSizer( $S->{Main} );
	$this->SetAutoLayout( 1 );
	
	Wx::Event::EVT_BUTTON( $this, $W->{BTN_Add}, sub{ $_[0]->Clear } );
	
	# erst fragen und dann gleich beenden und löschen
	#Wx::Event::EVT_BUTTON( $this, $W->{BTN_Add}, sub{ $_[0]->Clear } );
	
	1;
}

=head2 Accessors

=cut

sub setName { $_[0]->{W}{ED_name}->ChangeValue( $_[1] ) }
sub setSQL  { $_[0]->{W}{ED_sql}->ChangeValue( $_[1] ) }
sub getName { $_[0]->{W}{ED_name}->GetValue }
sub getSQL  { $_[0]->{W}{ED_sql}->GetValue }


=head2 Clear

=cut

sub Clear {
	my $this = shift;
	
	$this->{W}{ED_name}->Clear;
	$this->{W}{ED_sql}->Clear;
	
	1;
}

1;