package Scring::Wx::Pane::Speicherorte;

=head1 NAME

Scring::Wx::Pane::Speicherorte

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx qw( wxEXPAND wxALL wxID_ANY wxVERTICAL wxHORIZONTAL wxLIST_FORMAT_LEFT wxID_OK wxDefaultPosition 
		   wxLC_REPORT wxLC_SINGLE_SEL wxDefaultSize wxTE_READONLY wxBOTTOM wxRIGHT wxYES_NO wxYES wxNOT_FOUND );
use Wx::Event;
use Wx::ArtProvider qw( wxART_GO_FORWARD );

use Sort::Naturally;

use Scring::Util;
use Scring::Wx::Widget::LCBase;

use parent -norequire => qw( Wx::Panel );

#use Object::Tiny qw( ContextMenu W editSizer );
use Object::Tiny qw( 
	aui
	search
	
	listCtrl 
	ausgewaehlt 
	ausgewaehltId 
	inhalt 
	
	editSizer
	
	isLoaded
);

=head2 new( parent, AuiManager )

=cut

sub new {
	my ( $class, $parent, $aui, $search ) = @_;
	
	$logger->trace( '---' );
	
	my $this = $class->SUPER::new( $parent );

	$this->{aui} = $aui;
	$this->{search} = $search;

	$this->initialize;
	
	# editSizer Standardmäßig ausblenden
#	$this->{S}{Main}->Hide( $this->editSizer, 1 );
	
	return $this;
}

=head2 initialize

=cut

sub initialize {
	my $this = shift;
	
	my $W = $this->{W} = {};
	my $S = $this->{S} = {};
	my $P = $this;
	
	$this->{listCtrl} = Scring::Wx::Widget::LCBase->new( $P, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxLC_REPORT | wxLC_SINGLE_SEL );
	$this->{listCtrl}->AppendColumn( 'Speicherort', wxLIST_FORMAT_LEFT, 3 );
	$this->{listCtrl}->AppendColumn( 'Standort', wxLIST_FORMAT_LEFT, 6 );
	
	$W->{ST_Ausgewaehlt}   = Wx::StaticText->new( $P, wxID_ANY, 'Ausgewählt:' );
	$W->{ED_Ausgewaehlt}   = Wx::TextCtrl->new( $P, wxID_ANY, '', wxDefaultPosition, wxDefaultSize, wxTE_READONLY );
	$W->{ED_AusgewaehltId} = Wx::TextCtrl->new( $P, wxID_ANY, '', wxDefaultPosition, Wx::wxSIZE( 50, -1 ), wxTE_READONLY );
	$W->{ST_Inhalt}        = Wx::StaticText->new( $P, wxID_ANY, 'Inhalt:' );
	$W->{ED_Inhalt}        = Wx::TextCtrl->new( $P, wxID_ANY, '' );
	$W->{BTN_Add}          = Wx::BitmapButton->new( $P, wxID_ANY, Wx::ArtProvider::GetBitmap( wxART_GO_FORWARD ) );
	
	$this->{ausgewaehlt}   = $W->{ED_Ausgewaehlt};
	$this->{ausgewaehltId} = $W->{ED_AusgewaehltId};
	
	$S->{Main} = Wx::BoxSizer->new( wxVERTICAL );
	$S->{Rand} = Wx::BoxSizer->new( wxVERTICAL );
	$S->{Ausgewaehlt} = Wx::BoxSizer->new( wxHORIZONTAL );
	$S->{SubAusgewaehlt} = Wx::BoxSizer->new( wxHORIZONTAL );
	$S->{Inhalt} = Wx::BoxSizer->new( wxHORIZONTAL );
	$S->{Button} = Wx::BoxSizer->new( wxHORIZONTAL );

	$this->{editSizer} = $S->{edit} = Wx::BoxSizer->new( wxVERTICAL );
	
	$S->{SubAusgewaehlt}->Add( $W->{ED_Ausgewaehlt}, 1, wxRIGHT, 10 );
	$S->{SubAusgewaehlt}->Add( $W->{ED_AusgewaehltId}, 0 );
	$S->{Ausgewaehlt}->Add( $W->{ST_Ausgewaehlt}, 1 );
	$S->{Ausgewaehlt}->Add( $S->{SubAusgewaehlt}, 4, wxRIGHT, 20 );
	$S->{Inhalt}->Add( $W->{ST_Inhalt}, 1 );
	$S->{Inhalt}->Add( $W->{ED_Inhalt}, 4, wxRIGHT, 20 );
	$S->{Button}->AddStretchSpacer( 1 );
	$S->{Button}->Add( $W->{BTN_Add} );
	$S->{edit}->Add( $S->{Ausgewaehlt}, 0, wxEXPAND | wxBOTTOM, 5 );
	$S->{edit}->Add( $S->{Inhalt}, 0, wxEXPAND | wxBOTTOM, 5 );
	$S->{edit}->Add( $S->{Button}, 1, wxEXPAND );
	
	$S->{Rand}->Add( $this->listCtrl, 1, wxEXPAND | wxBOTTOM, 20);
	$S->{Rand}->Add( $S->{edit}, 0, wxEXPAND | wxBOTTOM, 10 );
	$S->{Main}->Add( $S->{Rand}, 1, wxEXPAND | wxALL, 10 );
	
	$this->SetSizer( $S->{Main} );
	$this->SetAutoLayout( 1 );
	
	Wx::Event::EVT_LIST_ITEM_ACTIVATED( $this, $this->listCtrl, \&OnActivated );
	
#	my $menu = $this->{ContextMenu} = Wx::Menu->new;
#	
#	my $showContent = Wx::MenuItem->new( $menu, wxID_ANY, 'Inhalt anzeigen' );
#	my $addEntry    = Wx::MenuItem->new( $menu, wxID_ANY, 'Neu' );
#	my $editEntry   = Wx::MenuItem->new( $menu, wxID_ANY, 'Bearbeiten' );
#	my $removeEntry = Wx::MenuItem->new( $menu, wxID_ANY, 'Löschen' );
#	
#	$menu->Append( $showContent );
#	$menu->AppendSeparator;
#	$menu->Append( $addEntry );
#	$menu->Append( $editEntry );
#	$menu->AppendSeparator;
#	$menu->Append( $removeEntry );
#	

#	Wx::Event::EVT_LIST_ITEM_SELECTED( $this, $W->{LC}, \&OnSelected );
#	Wx::Event::EVT_RIGHT_DOWN( $W->{LC}, \&OnRightClick );
#	Wx::Event::EVT_BUTTON( $this, $W->{BTN_Add}, \&OnClickedBTN_Add );
#	
#	Wx::Event::EVT_MENU( $W->{LC}, $addEntry   , \&OnMenu_Add );
#	Wx::Event::EVT_MENU( $W->{LC}, $editEntry  , \&OnMenu_Edit );
#	Wx::Event::EVT_MENU( $W->{LC}, $removeEntry, \&OnMenu_Delete );	
	
}

=head2 OnActivated

event

=cut

sub OnActivated {
	my ( $this, $event ) = @_;
	
	$logger->debug( 'open Item: id '  . $event->GetData . ' - ' . $event->GetText );
	
	# Zeige die Search-Pane an und lade den Speicherort
	# anhand seiner ID
	$this->search->show( 1 );
	$this->search->loadVideoBySpeicherortId( $event->GetData );
	
	1;
}

=head2 show( show )

=cut

sub show {
	my ( $this, $show ) = @_;
	
	$this->aui->showPane( $this, $show );
	
	1;
}

=head2 toggleShow

=cut

sub toggleShow {
	my $this = shift;
	
	if ( $this->aui->isPaneShown( $this ) ) {
		$logger->trace( 'hide' );
		$this->show( 0 );
		return 0;		
	} else {
		$logger->trace( 'lazyload and show' );
		$this->load if not $this->isLoaded;
		$this->show( 1 );
		return 1;
	}
}

=head2 load

=cut

sub load {
	my $this = shift;
	
	$logger->trace( '---' );
	
	my $LC = $this->listCtrl;
	$LC->DeleteAllItems;
	
	# ausgewählt auch löschen
	$this->ausgewaehlt->Clear;
	$this->ausgewaehltId->Clear;
	
	my $rs = $schema->resultset( 'Speicherort' )
		->search( 
			undef, 
			{
				select       => [ qw( me.id me.Bezeichnung Standort.Bezeichnung ) ],
				join         => 'Standort',
				result_class => 'DBIx::Class::ResultClass::HashRefInflator',
			} 
		);
	
	my $i = 0;
	for my $row ( sort { Sort::Naturally::ncmp( $b->{Bezeichnung}, $a->{Bezeichnung} ) } $rs->all ) {
		$LC->InsertStringItem( $i, $row->{Bezeichnung} );
		$LC->SetItem( $i, 1, $row->{Standort}{Bezeichnung} );
		$LC->SetItemData( $i, $row->{id} );
		$i++;
	}
	
	$this->{isLoaded} = 1;
}

1;

__END__

=head2 prepareGUI

=cut

sub prepareGUI {
	my $this = shift;
	
	my $W = $this->{W} = {};
	my $S = $this->{S} = {};
	my $P = $this;
	
	$W->{LC} = Scring::Wx::Widget::LCBase->new( $P, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxLC_REPORT | wxLC_SINGLE_SEL );
	$W->{LC}->InsertColumn( 1, 'Speicherort', wxLIST_FORMAT_LEFT, 200 );
	$W->{LC}->InsertColumn( 2, 'Standort', wxLIST_FORMAT_LEFT, -1 );
	
	$W->{ST_Ausgewaehlt} = Wx::StaticText->new( $P, wxID_ANY, 'Ausgewählt:' );
	$W->{ED_Ausgewaehlt} = Wx::TextCtrl->new( $P, wxID_ANY, '', wxDefaultPosition, wxDefaultSize, wxTE_READONLY );
	$W->{ED_AusgewaehltID} = Wx::TextCtrl->new( $P, wxID_ANY, '', wxDefaultPosition, Wx::wxSIZE( 50, -1 ), wxTE_READONLY );
	$W->{ST_Inhalt} = Wx::StaticText->new( $P, wxID_ANY, 'Inhalt:' );
	$W->{ED_Inhalt} = Wx::TextCtrl->new( $P, wxID_ANY, '' );
	$W->{BTN_Add} = Wx::BitmapButton->new( $P, wxID_ANY, Wx::ArtProvider::GetBitmap( wxART_GO_FORWARD ) );
	
	$S->{Main} = Wx::BoxSizer->new( wxVERTICAL );
	$S->{Rand} = Wx::BoxSizer->new( wxVERTICAL );
	$S->{Ausgewaehlt} = Wx::BoxSizer->new( wxHORIZONTAL );
	$S->{SubAusgewaehlt} = Wx::BoxSizer->new( wxHORIZONTAL );
	$S->{Inhalt} = Wx::BoxSizer->new( wxHORIZONTAL );
	$S->{Button} = Wx::BoxSizer->new( wxHORIZONTAL );
	$this->{editSizer} = $S->{edit} = Wx::BoxSizer->new( wxVERTICAL );
	
	$S->{SubAusgewaehlt}->Add( $W->{ED_Ausgewaehlt}, 1, wxRIGHT, 10 );
	$S->{SubAusgewaehlt}->Add( $W->{ED_AusgewaehltID}, 0 );
	$S->{Ausgewaehlt}->Add( $W->{ST_Ausgewaehlt}, 1 );
	$S->{Ausgewaehlt}->Add( $S->{SubAusgewaehlt}, 4, wxRIGHT, 20 );
	$S->{Inhalt}->Add( $W->{ST_Inhalt}, 1 );
	$S->{Inhalt}->Add( $W->{ED_Inhalt}, 4, wxRIGHT, 20 );
	$S->{Button}->AddStretchSpacer( 1 );
	$S->{Button}->Add( $W->{BTN_Add} );
	$S->{edit}->Add( $S->{Ausgewaehlt}, 0, wxEXPAND | wxBOTTOM, 5 );
	$S->{edit}->Add( $S->{Inhalt}, 0, wxEXPAND | wxBOTTOM, 5 );
	$S->{edit}->Add( $S->{Button}, 1, wxEXPAND );
	
	$S->{Rand}->Add( $W->{LC}, 1, wxEXPAND | wxBOTTOM, 20);
	$S->{Rand}->Add( $S->{edit}, 0, wxEXPAND | wxBOTTOM, 10 );
	$S->{Main}->Add( $S->{Rand}, 1, wxEXPAND | wxALL, 10 );
	
	$this->SetSizer( $S->{Main} );
	$this->SetAutoLayout( 1 );
	
	my $menu = $this->{ContextMenu} = Wx::Menu->new;
	
	my $showContent = Wx::MenuItem->new( $menu, wxID_ANY, 'Inhalt anzeigen' );
	my $addEntry    = Wx::MenuItem->new( $menu, wxID_ANY, 'Neu' );
	my $editEntry   = Wx::MenuItem->new( $menu, wxID_ANY, 'Bearbeiten' );
	my $removeEntry = Wx::MenuItem->new( $menu, wxID_ANY, 'Löschen' );
	
	$menu->Append( $showContent );
	$menu->AppendSeparator;
	$menu->Append( $addEntry );
	$menu->Append( $editEntry );
	$menu->AppendSeparator;
	$menu->Append( $removeEntry );
	
	Wx::Event::EVT_LIST_ITEM_ACTIVATED( $this, $W->{LC}, \&OnActivated );
	Wx::Event::EVT_LIST_ITEM_SELECTED( $this, $W->{LC}, \&OnSelected );
	Wx::Event::EVT_RIGHT_DOWN( $W->{LC}, \&OnRightClick );
	Wx::Event::EVT_BUTTON( $this, $W->{BTN_Add}, \&OnClickedBTN_Add );
	
	Wx::Event::EVT_MENU( $W->{LC}, $addEntry   , \&OnMenu_Add );
	Wx::Event::EVT_MENU( $W->{LC}, $editEntry  , \&OnMenu_Edit );
	Wx::Event::EVT_MENU( $W->{LC}, $removeEntry, \&OnMenu_Delete );	
	
	# Die Größenberechnung von LCBase scheint hier irgendwie
	# nicht zu funktionieren
	Wx::Event::EVT_SIZE( $W->{LC}, sub { $_[0]->SetColumnWidth( 1, $_[1]->GetSize->GetWidth - $_[0]->GetColumnWidth( 0 ) - 30 ); } );
		
	1;
}

=head2 loadLC

=cut

sub loadLC {
	my $this = shift;
	
	$logger->trace( '---' );
	
	my $LC = $this->W->{LC};
	$LC->DeleteAllItems;
	
	# ausgewählt auch löschen
	$this->W->{ED_Ausgewaehlt}->Clear;
	$this->W->{ED_AusgewaehltID}->Clear;
	
	my $rs = $schema->resultset( 'Speicherort' )
		->search( 
			undef, 
			{
				select       => [ qw( me.id me.Bezeichnung Standort.Bezeichnung ) ],
				join         => 'Standort',
				result_class => 'DBIx::Class::ResultClass::HashRefInflator',
			} 
		);
	
	my $i = 0;
	for my $row ( sort { Sort::Naturally::ncmp( $b->{Bezeichnung}, $a->{Bezeichnung} ) } $rs->all ) {
		$LC->InsertStringItem( $i, $row->{Bezeichnung} );
		$LC->SetItem( $i, 1, $row->{Standort}{Bezeichnung} );
		$LC->SetItemData( $i, $row->{id} );
		$i++;
	}
}

=head2 lazyLoad

=cut

sub lazyLoad {
	my $this = shift;
	
	return if $this->{lazyLoad};
	
	# Das wird in loadLC benötigt
	require Sort::Naturally;
	
	$this->loadLC;
	$this->{lazyLoad} = 1;
	
	1;
}

=head2 OnActivated

=cut

sub OnActivated {
	my ( $this, $event ) = @_;
	
	$logger->trace( '---' );
	
	$logger->debug( 'edit Item: id '  . $event->GetData . ' - ' . $event->GetText );
	
	$this->editSpeicherort( $event->GetData );
	
	1;
}

=head2 OnSelected

=cut

sub OnSelected {
	my ( $this, $event ) = @_;
	
	return if not $this->editMode;
	
	$this->{W}{ED_AusgewaehltID}->ChangeValue( $event->GetData );
	$this->{W}{ED_Ausgewaehlt}->ChangeValue( $this->W->{LC}->GetItem( $event->GetIndex )->GetText );	
}

=head2 OnRightClick

=cut

sub OnRightClick {
	my ( $this, $event ) = @_; # $this == $this->LC
	
	my $foundItem = $this->SelectItemAtPos( $this->ScreenToClient( Wx::GetMousePosition() ) );
	
	my $menu = $this->GetParent->ContextMenu;
	
	# Aktiviere löschen und Bearbeiten nur,
	# wenn auch ein Item ausgewählt wird
	$menu->Enable( $menu->FindItemByPosition( 1 )->GetId, $foundItem );
	$menu->Enable( $menu->FindItemByPosition( 3 )->GetId, $foundItem );
	$this->PopupMenu( $menu, wxDefaultPosition );
	
	1;
}

=head2 SelectItemByData( data )

Suche die hinterlegten Daten einer item-row und markiere diese

=cut

sub SelectItemByData {
	my ( $this, $data ) = @_;
	
	my $item = $this->{W}{LC}->FindItemData( -1, $data );
	
	if ( $item != wxNOT_FOUND ) {
		$this->{W}{LC}->SetFocus;
		$this->{W}{LC}->Select( $item, 1 );
		$this->{W}{LC}->EnsureVisible( $item );
		
		$logger->debug( "markiere $item" );
	}
	else {
		$logger->warn( "item-data $data nicht gefunden!" );
	}
	
	1;
}

=head2 SetInhalt( inhalt )

=cut

sub SetInhalt {
	my ( $this, $inhalt ) = @_;
	
	$this->{W}{ED_Inhalt}->ChangeValue( $inhalt );
	
	1;
}

=head2 OnMenu_Add

=cut

sub OnMenu_Add {
	my ( $this, $event ) = @_; # $this == $this->LC
	
	$logger->trace( '---' );
	
	my $newSpeicherort = $this->GetParent->editSpeicherort;
	
	# Beim Hinzufügen und im editMode, gleich eintragen
	if ( $this->GetParent->editMode ) {
		my $item = $this->FindItem( -1, $newSpeicherort );
		
		if ( $item != wxNOT_FOUND ) {
			$this->SetFocus;
			$this->Select( $item, 1 );
			$this->EnsureVisible( $item );
		}
	}
	
	1;
}

=head2 OnMenu_Edit

=cut

sub OnMenu_Edit {
	my ( $this, $event ) = @_; # $this == $this->LC
	
	my $item = $this->GetItem( $this->GetFirstSelected );
	
	$logger->debug( 'edit Item: id '  . $item->GetData . ' - ' . $item->GetText );
	
	$this->GetParent->editSpeicherort( $item->GetData );

}

=head2 OnMenu_Delete

=cut

sub OnMenu_Delete {
	my ( $this, $event ) = @_; # $this == $this->LC
	
	my $item = $this->GetItem( $this->GetFirstSelected );
	
	$logger->debug( 'delete Item: id '  . $item->GetData . ' - ' . $item->GetText );
	
	$this->GetParent->deleteSpeicherort( $item->GetData );
	
	
}

=head2 editSpeicherort

=cut

sub editSpeicherort {
	my ( $this, $editID ) = @_;
	
	$logger->trace( '---' );
	
	require Scring::Wx::Dialog::EditSpeicherort;
	my $dlg = Scring::Wx::Dialog::EditSpeicherort->new( $this );
	
	$dlg->Centre;
	
	if ( $editID ) {
		$dlg->SetSpeicherort( $editID );
	}	
	
	# Ums Speichern kümmert sich der Dialog
	if ( $dlg->ShowModal == wxID_OK ) {
		$this->loadLC;
	}
	
	my $newSpeicherort = $dlg->GetSpeicherort;
	
	$dlg->Destroy;
	
	return $newSpeicherort;
}

=head2 deleteSpeicherort

=cut

sub deleteSpeicherort {
	my ( $this, $deleteID ) = @_;
	
	$logger->trace( '---' );
	
	my $rs = $schema->resultset( 'Speicherort' )->find( $deleteID );
	my $Bezeichnung = $rs->Bezeichnung;
		
	my $ret = Wx::MessageBox( "Soll der Speicherort: $deleteID, $Bezeichnung wirklich gelöscht werden?", 'Löschen bestätigen', wxYES_NO, Wx::wxTheApp->Frame );
	
	if ( $ret == wxYES ) {
		$logger->info( "Lösche Speicherort: $deleteID, $Bezeichnung" );
		
		eval {
			$rs->delete;
		} or do {
			$logger->error( $@ );
		};
		$this->loadLC;
		
	}
}

=head2 editMode

=cut

sub editMode {
	my ( $this, $set ) = @_;
	
	return $this->{editMode} if not defined $set;
	
	$this->{S}{Main}->Show( $this->editSizer, $set, 1 ); 
	
	$this->{editMode} = $set;
	return $set;
}

=head2 OnClickedBTN_Add

=cut

sub OnClickedBTN_Add {
	my ( $this, $event ) = @_;
	
	$logger->trace( '---' );
	
	my $rs = Wx::wxTheApp->Frame->GetVideo;
	
	my $v = $rs->find_or_new_related( 'Speicherorte',
		{ Speicherort => $this->{W}{ED_AusgewaehltID}->GetValue },
		{ key => 'VideoSpeicherort_Video_Speicherort' }
	);
	
	$v->Inhalt( $this->{W}{ED_Inhalt}->GetValue );
	
	Wx::wxTheApp->Frame->Info->addSpeicherort( $v );
}

1;