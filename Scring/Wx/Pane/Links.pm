package Scring::Wx::Pane::Links;

=head1 NAME

Scring::Wx::Pane::Links

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx qw(  wxID_ANY wxEXPAND wxALL wxVERTICAL wxDefaultPosition wxDefaultSize wxTE_READONLY wxTE_MULTILINE wxLIST_FORMAT_LEFT wxLC_SINGLE_SEL wxLC_REPORT 
			wxID_OK wxNOT_FOUND );
use Wx::Event;

use Scring::Util;
use Scring::Wx::Widget::LCBase;

use parent -norequire => qw( Scring::Wx::Widget::LCBase Scring::Wx::Role::Pane );

use Object::Tiny qw( contextMenu );

=head2 new

=cut

sub new {
	my ( $class, $parent ) = @_;
	
	$logger->trace( '---' );
	
	my $this = $class->SUPER::new( $parent, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxLC_REPORT | wxLC_SINGLE_SEL );

	$this->AppendColumn( 'Bezeichnung', wxLIST_FORMAT_LEFT, 1 );
	$this->AppendColumn( 'URL'        , wxLIST_FORMAT_LEFT, 2 );
	
	my $menu = $this->{contextMenu} = Wx::Menu->new;
		
	my $addEntry    = Wx::MenuItem->new( $menu, wxID_ANY, 'Neu' );
	my $editEntry   = Wx::MenuItem->new( $menu, wxID_ANY, 'Bearbeiten' );
	my $removeEntry = Wx::MenuItem->new( $menu, wxID_ANY, 'Löschen' );
	
	$menu->Append( $addEntry );
	$menu->Append( $editEntry );
	$menu->AppendSeparator;
	$menu->Append( $removeEntry );
	
	Wx::Event::EVT_LIST_ITEM_ACTIVATED( $this, $this, \&OnActivated );
	Wx::Event::EVT_RIGHT_DOWN( $this, \&OnRightClick );
		
	Wx::Event::EVT_MENU( $this, $addEntry   , \&OnMenu_Add );
	Wx::Event::EVT_MENU( $this, $editEntry   , \&OnMenu_Edit );
	Wx::Event::EVT_MENU( $this, $removeEntry, sub { $this->RemoveSelected } );	
	
	return $this;
}

=head2 loadFrom( resultset )

=cut

sub loadFrom {
	my ( $this, $rs ) = @_;
	
	$logger->trace( '---' );
	
	$this->DeleteAllItems;
	
	my $i = 0;
	for my $_ ( $rs->Links ) {
		$this->InsertStringItem( $i, $_->Bezeichnung );
		$this->SetItem( $i, 1, $_->URL );
		$this->SetItemData( $i, $_->id );
		$i++;
	}
	
	1;
}

=head2 storeTo( resultset )

=cut

sub storeTo {
	my ( $this, $rs ) = @_;
	
	# erst mal alle Links aus der LB ziehen
	my %newLinks;
	my @newLinks;
	
	for ( my $i = 0; $i < $this->GetItemCount; $i++ ) {
		my $id = $this->GetItemData( $i );
		
		if ( not $id ) {
			push @newLinks, {
				Bezeichnung => $this->GetItem( $i )->GetText,
				URL         => $this->GetItem( $i, 1 )->GetText,
			};
			next;
		}
		
		$newLinks{ $id }{Bezeichnung} = $this->GetItem( $i )   ->GetText;
		$newLinks{ $id }{URL}         = $this->GetItem( $i, 1 )->GetText;
	}
	
	# gespeicherte Links holen
	my @links = $rs->Links;

	for my $_ ( @links ) {
		
		# wenn die Id existiert -> update ( nur url )
		if ( exists $newLinks{ $_->id } ) {
			$_->URL        ( $newLinks{ $_->id }{ URL } );
			$_->update;
		}
		
		# wenn nicht -> delete
		else {
			$_->delete;
		}
	}
	
	# alles andere wird neu Hinzugefügt
	for my $_ ( @newLinks ) {
		$rs->create_related( 
			'Links',
			{
				LinkBezeichnung => $schema->resultset( 'LinkBezeichnung' )->find( { Bezeichnung => $_->{Bezeichnung} } )->id,
				URL => $_->{URL},
			} 
		);
	}
	
	1;
}

=head2 clear

=cut

sub clear {
	my $this = shift;
	
	$this->DeleteAllItems;
}

1;

=head2 OnActivated

=cut

sub OnActivated {
	my ( $this, $event ) = @_;

	# Link öffnen anzeigen
	# im edit-mode bearbeiten	
	if ( not $this->editMode ) {
		my $url = $this->GetItem( $event->GetIndex, 1 )->GetText; 
		$logger->debug( "öffne Standartbrowser mit url: $url" );
		
		Wx::LaunchDefaultBrowser( $url )
			or $logger->error( 'Standardbrowser konnte nicht gestartet werden' );
	} 
	else {
		$this->editLink( $event->GetIndex );
	}

	
	1;
}

=head2 OnRightClick

=cut

sub OnRightClick {
	my ( $this, $event ) = @_;
	
	# ohne editMode machen wir erst mal gar nix
	return $event->Skip if not $this->editMode;
	
	my $foundItem = $this->SelectItemAtPos( $this->ScreenToClient( Wx::GetMousePosition() ) );
	
	# Aktiviere löschen nur,
	# wenn auch ein Item ausgewählt wird
	$this->contextMenu->Enable( $this->contextMenu->FindItemByPosition( 1 )->GetId, $foundItem );
	$this->contextMenu->Enable( $this->contextMenu->FindItemByPosition( 3 )->GetId, $foundItem );
	$this->PopupMenu( $this->contextMenu, wxDefaultPosition );
	
	1;
}

=head2 OnMenu_Add

=cut

sub OnMenu_Add {
	my ( $this, $event ) = @_;
	
	$logger->trace( '---' );
	
	$this->editLink;
	
}

=head2 OnMenu_Edit

=cut

sub OnMenu_Edit {
	my ( $this, $event ) = @_;
	
	$logger->trace( '---' );

	$this->editLink( $this->GetFirstSelected );
	
	1;
}

=head2 editLink( Index? )

Wird ein Index übergeben, wird editiert, ansonsten neu

=cut

sub editLink {
	my ( $this, $index ) = @_;
	
	$logger->trace( 'Übergebener Index: ', $index // '' );
	
	require Scring::Wx::Dialog::EditLink;
	
	my $dlg = Scring::Wx::Dialog::EditLink->new( Wx::wxTheApp->frame ); # parent wg. Centre
	$dlg->Centre;
	
	
	my ( $id, $bez, $item, $url );
	
	if ( defined $index ) {
		$item = $this->GetItem( $index );
		$id   = $item->GetData;
		$bez  = $item->GetText;
		$url  = $this->GetItem( $index, 1 )->GetText;
	
		$logger->trace( 'ID: ' . defined $id ? $id : 'keine!' );
		$logger->trace( "Bez: $bez" );
		$logger->trace( "URL: $url" );
		
		$dlg->Bezeichnung( $bez );
		$dlg->url( $url )
	}
	# Im new-Mode Clipboard Text verwenden
	# Bezeicnnung wird automatisch gesetzt
	else {
		$dlg->LoadFromClipboard;
	}
	
	if ( $dlg->ShowModal == wxID_OK ) {
		$bez = $dlg->Bezeichnung;
		$url = $dlg->url;
		$dlg->Destroy;
	}
	else {
		$dlg->Destroy;
		return;
	}
	
	$logger->trace( "zurück Bez: $bez, url: $url" );
	
	# Link wird nach der Bezeichnung eingefügt
	$item = $this->FindItem( -1, $bez );
	
	# wenn nicht gefunden am Ende einfügen
	if ( $item == wxNOT_FOUND ) {
		$logger->debug( "Bezeichner $bez nicht gefunden, append" );
		
		$index = $this->GetItemCount;
		$this->InsertStringItem( $index, $bez );
		$this->SetItem( $index, 1, $url ); 
	}
	# ansonsten url ersetzen, id bleibt gleich
	else {
		$logger->debug( "Bezeichner $bez an Stelle " . $item . ' gefunden, ersetze url' );
		$this->SetItem( $item, 1, $url );
	}
	
	
	1;
}

1;
