package Scring::Wx::Pane::VideoSpeicherorte;

=head1 NAME

Scring::Wx::Pane::VideoSpeicherorte

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx qw(  wxID_ANY wxEXPAND wxALL wxVERTICAL wxDefaultPosition wxDefaultSize wxTE_READONLY wxTE_MULTILINE wxLIST_FORMAT_LEFT wxLC_SINGLE_SEL wxLC_REPORT
			wxNOT_FOUND wxYES_NO wxYES );
use Wx::Event;

use Scring::Util;
use Scring::Wx::Widget::LCBase;

use parent -norequire => qw( Scring::Wx::Widget::LCBase );


=head2 new

=cut

sub new {
	my ( $class, $parent ) = @_;
	
	my $this = $class->SUPER::new( $parent, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxLC_REPORT | wxLC_SINGLE_SEL );
	
	$this->AppendColumn( 'Speicherort', wxLIST_FORMAT_LEFT, 1 );
	$this->AppendColumn( 'Inhalt', wxLIST_FORMAT_LEFT     , 2 );
	
	my $menu = $this->{ContextMenu} = Wx::Menu->new;
		
#	my $addEntry    = Wx::MenuItem->new( $menu, wxID_ANY, 'Neu' );
#	my $editEntry   = Wx::MenuItem->new( $menu, wxID_ANY, 'Bearbeiten' );
#	my $removeEntry = Wx::MenuItem->new( $menu, wxID_ANY, 'L�schen' );
#	
#	$menu->Append( $addEntry );
#	$menu->Append( $editEntry );
#	$menu->AppendSeparator;
#	$menu->Append( $removeEntry );
#	
#	Wx::Event::EVT_LIST_ITEM_ACTIVATED( $this, $this, \&OnActivated );
#	Wx::Event::EVT_RIGHT_DOWN( $this, \&OnRightClick );
#		
#	Wx::Event::EVT_MENU( $this, $addEntry   , \&OnMenu_Add );
#	Wx::Event::EVT_MENU( $this, $editEntry  , \&OnMenu_Edit );
#	Wx::Event::EVT_MENU( $this, $removeEntry, sub { $this->RemoveSelected } );	
	
	return $this;
}

=head2 loadFrom( resultset )

=cut

sub loadFrom {
	my ( $this, $rs ) = @_;
	
	$logger->trace( '---' );
	
	$this->DeleteAllItems;
	
	my $i = 0;
	for ( $rs->Speicherorte ) {
		$this->InsertStringItem( $i, $_->Bezeichnung );
		$this->SetItem( $i, 1, $_->Inhalt );
		$this->SetItemData( $i, $_->id );
		$i++;
	}
	
	# Wenn ein Titel geladen wird,
	# dessen Speicherorte nicht in die Box passen,
	# wird dadurch leider nicht OnSize ausgel�st,
	# und die Darstellung ist daher noch auf den "alten"
	# Stand ohne verticale Scrollbar
	# Fix durch manuelles aufrufen von OnSize
	# funktioniert leider auch nicht richtig
	# $this->OnSize;
	
	1;
}

=head2 clear

=cut

sub clear {
	my $this = shift;
	
	$this->DeleteAllItems;
}

1;

__END__
=head2 add( speicherort_resultset )

F�gt ein VideoSpeicherort resultset in die Tabelle ein.
Achtet dabei darauf, dass der Eintrag nicht schon vorhanden ist
und gibt in diesem Fall eine Warnung/Frage ab.

Der R�ckgabewert ist nicht verwertbar.

=cut

sub add {
	my ( $this, $v ) = @_;
	
	$logger->trace( '---' );
	
	my $item = $this->FindItem( -1, $v->Bezeichnung );
	
	# Sollte ein item gefunden wurden sein,
	# Frage ob der Inhalt ersetzt werden soll, wenn der
	# Inhalt sich ge�ndert hat!
	if ( $item != wxNOT_FOUND ) {
		
		$logger->debug( 'Item ' . $v->Bezeichnung . ' in LC gefunden: ' . $item );
		
		# �berpr�fe die ID, sollte nie fehlschlagen
		if ( $this->GetItemData( $item ) and $this->GetItemData( $item ) != $v->id ) {
			$logger->error( 'Fehler Speicherort id ' . $this->GetItemData( $item ) . ' != ' . $v->id . 'Speicherort wird nicht ver�ndert' );
			return 0;
		}
		
		# bei gleichen Inhalt machen wir erst mal gar nix
		return if $v->Inhalt eq $this->GetItem( $item, 1 );
		
		my $ret = Wx::MessageBox( 
			'Soll der Inhalt des Speicherortes: ' . $v->Bezeichnung . ' wirklich �berschrieben werden?', 
			'�berschreiben best�tigen',
			wxYES_NO, Wx::wxTheApp->Frame 
		);
		
		if ( $ret == wxYES ) {
			$this->SetItem( $item, 0, $v->Bezeichnung );
			$this->SetItem( $item, 1, $v->Inhalt );
			
			$logger->debug( 'Item angepasst' );
		} 
		else {
			$logger->trace( 'Dialog Nein - kein Einf�gen' );
		}
	} 
	# Neues Item hinzuf�gen
	# ist unsortiert - egal
	else {
		my $i = $this->GetItemCount;
		$this->InsertStringItem( $i, $v->Bezeichnung );
		$this->SetItem( $i, 1, $v->Inhalt );
		
		$logger->debug( 'Item ' . $v->Bezeichnung . ' mit ' . $v->Inhalt . "an Position $i hinzugef�gt" );
	}
		
	
	return 1;
}

=head2 OnActivated

=cut

sub OnActivated {
	my ( $this, $event ) = @_;

	$logger->trace( '---' );

	my $id     = $this->GetItem( $event->GetIndex )->GetData;
	my $inhalt = $this->GetItem( $event->GetIndex, 1 )->GetText; 
	
	$logger->trace( "Video Speicherort ID: $id, Inhalt: $inhalt" );
	
	my $rs = Wx::wxTheApp->Frame->GetVideo->find_related( 'Speicherorte', $id );
	
	$this->editMode
		? Wx::wxTheApp->Frame->ShowSpeicherorte( $rs->Speicherort->id, $rs->Inhalt )
		: Wx::wxTheApp->Frame->ShowSpeicherorte( $rs->Speicherort->id ),
	
	
	1;
}

=head2 OnRightClick

=cut

sub OnRightClick {
	my ( $this, $event ) = @_;
	
	# ohne editMode machen wir erst mal gar nix
	return $event->Skip if not $this->editMode;
	
	my $foundItem = $this->SelectItemAtPos( $this->ScreenToClient( Wx::GetMousePosition() ) );
	
	# Aktiviere l�schen nur,
	# wenn auch ein Item ausgew�hlt wird
	$this->ContextMenu->Enable( $this->ContextMenu->FindItemByPosition( 1 )->GetId, $foundItem );
	$this->ContextMenu->Enable( $this->ContextMenu->FindItemByPosition( 3 )->GetId, $foundItem );
	$this->PopupMenu( $this->ContextMenu, wxDefaultPosition );
	
	1;
}

=head2 OnMenu_Add

=cut

sub OnMenu_Add {
	my ( $this, $event ) = @_;
	
	$logger->trace( '---' );

	Wx::wxTheApp->Frame->ShowSpeicherorte();
}

=head2 OnMenu_Edit

=cut

sub OnMenu_Edit {
	my ( $this, $event ) = @_;
	
	my $id     = $this->GetItem( $this->GetFirstSelected )->GetData;
	my $inhalt = $this->GetItem( $this->GetFirstSelected, 1 )->GetText; 
	
	$logger->trace( "Video Speicherort ID: $id, Inhalt: $inhalt" );
	
	my $rs = Wx::wxTheApp->Frame->GetVideo->find_related( 'Speicherorte', $id );
	
	Wx::wxTheApp->Frame->ShowSpeicherorte( $rs->Speicherort->id, $rs->Inhalt );
}

1;


1;