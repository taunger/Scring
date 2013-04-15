package Scring::Wx::Dialog::EditSpeicherort;

=head1 NAME

Scring::Wx::Dialog::EditSpeicherort

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx qw( wxID_ANY wxDefaultPosition wxDEFAULT_DIALOG_STYLE wxRESIZE_BORDER wxDefaultSize wxTE_READONLY wxCB_READONLY 
		   wxEXPAND wxALL wxVERTICAL wxHORIZONTAL wxRIGHT wxBOTTOM wxOK wxCANCEL wxID_OK wxID_CANCEL );
use Wx::Event;

use Scring::Util;

use parent -norequire => qw( Wx::Dialog );

=head2 new

=cut

sub new {
	my ( $class, $parent ) = @_;
	
	my $this = $class->SUPER::new( 
		$parent, wxID_ANY, 'Speicherort bearbeiten',
		wxDefaultPosition,
		$config->get( 'wx.dialog.EditSpeicherort.size' ),
		wxDEFAULT_DIALOG_STYLE | wxRESIZE_BORDER
	);
	
	$this->prepareGUI;
	
	$this->LoadCB;
	
	$this->{W}{ED_Speicherort}->SetFocus;
	
	return $this;
}

=head2 prepareGUI

=cut

sub prepareGUI {
	my $this = shift;
	
	my $S = {};
	my $W = $this->{W} = {};
	
	$W->{ED_ID}               = Wx::TextCtrl->new( $this, wxID_ANY, '', wxDefaultPosition, Wx::wxSIZE( 50, -1 ), wxTE_READONLY );
	$W->{ED_Speicherort}      = Wx::TextCtrl->new( $this, wxID_ANY, '' );
	$W->{CB_Standort}         = Wx::ComboBox->new( $this, wxID_ANY, '', wxDefaultPosition, wxDefaultSize, [], wxCB_READONLY );
	$W->{ED_Referenzstandort} = Wx::TextCtrl->new( $this, wxID_ANY, '', wxDefaultPosition, wxDefaultSize, wxTE_READONLY );
	$W->{BTN_AutoInc}         = Wx::Button  ->new( $this, wxID_ANY, 'AutoInc' ); 
	$W->{ST_Speicherort}      = Wx::StaticText->new( $this, wxID_ANY, 'Speicherort:' );
	$W->{ST_Standort}         = Wx::StaticText->new( $this, wxID_ANY, 'Standort:' );
		
	$S->{Main}   = Wx::BoxSizer->new( wxVERTICAL );
	$S->{Rand}   = Wx::BoxSizer->new( wxVERTICAL );
	$S->{Top}    = Wx::BoxSizer->new( wxHORIZONTAL );
	$S->{Center} = Wx::BoxSizer->new( wxHORIZONTAL );
	$S->{Bottom} = Wx::BoxSizer->new( wxHORIZONTAL );
	$S->{SubBottom} = Wx::BoxSizer->new( wxHORIZONTAL );
	
	$S->{Top}->AddStretchSpacer( 1 );
	$S->{Top}->Add( $W->{ED_ID}, 0, wxRIGHT, 30 );
	$S->{Top}->Add( $W->{BTN_AutoInc}, 0 );
	
	$S->{Center}->Add( $W->{ST_Speicherort}, 1, wxRIGHT, 10 );
	$S->{Center}->Add( $W->{ED_Speicherort}, 4 );
	
	$S->{SubBottom}->Add( $W->{CB_Standort}, 1, wxRIGHT, 10 );
	$S->{SubBottom}->Add( $W->{ED_Referenzstandort}, 1 );
	
	$S->{Bottom}->Add( $W->{ST_Standort}, 1, wxRIGHT, 10 );
	$S->{Bottom}->Add( $S->{SubBottom}, 4 );
	
	$S->{Rand}->Add( $S->{Top}, 0, wxEXPAND | wxBOTTOM, 10 );
	$S->{Rand}->Add( $S->{Center}, 0, wxEXPAND | wxBOTTOM, 10 );
	$S->{Rand}->Add( $S->{Bottom}, 0, wxEXPAND | wxBOTTOM, 10 );
	$S->{Rand}->AddStretchSpacer( 1 );
	$S->{Rand}->Add( $this->CreateSeparatedButtonSizer( wxOK | wxCANCEL ), 0, wxEXPAND );
	
	$S->{Main}->Add( $S->{Rand}, 1, wxEXPAND | wxALL, 10 );
	
	$this->SetSizer( $S->{Main} );
	$this->SetAutoLayout( 1 );
	
	Wx::Event::EVT_COMBOBOX( $this, $W->{CB_Standort}, \&OnSelChangeCB_Standort );
	Wx::Event::EVT_BUTTON( $this, wxID_OK, \&OnOK );
	Wx::Event::EVT_BUTTON( $this, $W->{BTN_AutoInc}, \&OnClickedBTN_AutoInc );
	
	1;
}

=head2 ShowModal

=cut

sub ShowModal {
	my $this = shift;
	
	$logger->trace( '---' );
	
	if ( not $this->{W}{CB_Standort}->GetCount ) {
		$logger->error( 'Es werden zunächst Standorte benötigt, um Speicherorte hinzuzufügen!' );
		return $this->EndModal( wxID_CANCEL );		
	}
	
	# wenn schon einer vorhanden, nichts tun (beim editieren)
	return $this->SUPER::ShowModal( @_ ) if $this->{W}{CB_Standort}->GetValue;
	
	# Den letzten Standort auswählen
	# wenn nicht definiert, den ersten
	$config->get( 'user.editSpeicherort.lastStandort' )
		? $this->SetStandort( $config->get( 'user.editSpeicherort.lastStandort' ) )
		: $this->{W}{CB_Standort}->SetSelection( 0 )
	; 
	
	return $this->SUPER::ShowModal( @_ );
}

=head2 LoadCB

=cut

sub LoadCB {
	my $this = shift;
	
	$logger->trace( '---' );
	
	$this->{W}{CB_Standort}->Clear; 
	$this->{W}{CB_Standort}->Append( [
		$schema->resultset( 'Standort' )
			->search( undef, { order_by => 'Bezeichnung' } )
			->get_column( 'Bezeichnung' )
			->all
	] );
	
	1;
}

=head2 OnSelChangeCB_Standort

=cut

sub OnSelChangeCB_Standort {
	my ( $this, $event ) = @_;
	
	my $string = $event->GetString; 
	
	$logger->trace( "Selection: $string" );
	
	my $rs = $schema->resultset( 'Standort' )
				->search( 
					{ 'me.Bezeichnung' => $string },
					{ 
						join    => 'Standort',
						columns => [ qw( Standort.Bezeichnung ) ]
					}
				)
				->single
	;
	
	# Nur, wenn auch ein Referenzstandort hinterlegt ist,
	# ansonsten leeren
	$this->{W}{ED_Referenzstandort}->ChangeValue( 
		$rs->Standort ? $rs->Standort->Bezeichnung : '' 
	);
	
	1;
}

=head2 SetSpeicherort( id )

=cut

sub SetSpeicherort {
	my ( $this, $id ) = @_;
	
	return if not defined $id;
	
	$logger->trace( "Fülle mit $id" );
	
	my $W = $this->{W};
	
	my $rs = $schema->resultset( 'Speicherort' )->find( 
		$id, 
		{
			prefetch => { 'Standort' => 'Standort' }
		}
	);
	
	$W->{ED_ID}->ChangeValue( $rs->id );
	$W->{ED_Speicherort}->ChangeValue( $rs->Bezeichnung );
	
	$this->SetStandort( 
		$rs->Standort->Bezeichnung,
		$rs->Standort->Standort ? $rs->Standort->Standort->Bezeichnung : ''
	);
	
	1;
}

=head2 SetStandort

=cut

sub SetStandort {
	my ( $this, $Standort, $Referenzstandort ) = @_;
	
	if ( not defined $Referenzstandort ) {
		my $rs = $schema->resultset( 'Standort' )
					->search( 
						{ 'me.Bezeichnung' => $Standort },
						{ 
							join    => 'Standort',
							columns => [ qw( Standort.Bezeichnung ) ]
						}
					)
					->single
		;
		$Referenzstandort = $rs->Standort ? $rs->Standort->Bezeichnung : ''
	}
	
	$this->{W}{CB_Standort}->SetValue( $Standort );
	$this->{W}{ED_Referenzstandort}->ChangeValue( $Referenzstandort );
	
	1;
}

=head2 GetSpeicherort

=cut

sub GetSpeicherort {
	my $this = shift;
	
	return $this->{W}{ED_Speicherort}->GetValue;
}

=head2 GetStandort

=cut

sub GetStandort {
	my $this = shift;
	
	return $this->{W}{CB_Standort}->GetValue;
}

=head2 OnOK

=cut

sub OnOK {
	my ( $this, $event ) = @_;
	
	$logger->trace( '---' );
	
	my $W = $this->{W};
	
	my $id          = $W->{ED_ID}->GetValue;
	my $Speicherort = $W->{ED_Speicherort}->GetValue;
	my $Standort    = $W->{CB_Standort}->GetValue;

	# den zuletzt ausgewehlten Standort Speichern
	$config->set( 'user.editSpeicherort.lastStandort' => $Standort );
	
	my $rs = $schema->resultset( 'Standort' )->find( { Bezeichnung => $Standort } );
	$Standort = $rs->id;
	
	# update
	if ( $id ) {
		$rs = $schema->resultset( 'Speicherort' )->find( $id );
		$rs->Bezeichnung( $Speicherort );
		$rs->Standort( $Standort );
		$rs->update;
		
		$logger->info( join ' ', 'Speicherort update:', $rs->id, $rs->Bezeichnung );
	} 
	# create
	else {
		$rs = $schema->resultset( 'Speicherort' )->create( {
			Bezeichnung => $Speicherort,
			Standort => $Standort
		} );
		
		$logger->info( join ' ', 'Speicherort insert:', $rs->id, $rs->Bezeichnung );
	}	
	
	return $this->EndModal( wxID_OK );
}

=head2 OnBTN_AutoInc

=cut

sub OnClickedBTN_AutoInc {
	my ( $this, $event ) = @_;
	
	$logger->trace( '---' );
	
	my $s = 'DVD ';
	my $l = length( $s ) + 1;
	
	my $rs = $schema->resultset( 'Speicherort' )->search(
		{ 'Bezeichnung' => { 'like', $s . '%' } },
		{
			'select' => [
				# abs macht einen integer aus dem string
				"max( abs( substr( me.Bezeichnung, $l ) ) )"
			],
			'as' => [ 'last_autoinc_number' ]
		}		 
	)->single;
	
	my $inc = $rs->get_column( 'last_autoinc_number' ) + 1;
	
	$logger->debug( 'result autoinc: ',  $s, $inc);
	
	$this->{W}{ED_Speicherort}->ChangeValue( $s . $inc );
		
	1;
}

1;