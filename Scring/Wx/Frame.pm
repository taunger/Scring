package Scring::Wx::Frame;

=head1 NAME

Scring::Wx::Frame

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx qw( wxID_ANY wxID_ABOUT wxID_EXIT wxDefaultPosition wxDefaultSize wxITEM_CHECK wxTB_FLAT wxTB_DOCKABLE );
use Wx::Event;
use Wx::AUI;
use Wx::Html;
use Wx::ArtProvider qw( :artid );

use Scring::Util;

use Scring::Wx::AuiManager;
use Scring::Wx::Menu;

use parent -norequire => qw( Wx::Frame );

use Object::Tiny qw( 
	aui 
	menu
	
	base
	videoList
	cover
	misc
	info
	links
	reviews
	videoSpeicherorte
	speicherorte
	search
	toolbar
);	
#	Base Search Image Info
#	Review ExtendedSearch Toolbar Speicherorte menuShowSpeicherorte menuShowExtendedSearch 
#					 resultset menuEnableEdit defaultPerspective );

=head2 new

=cut

sub new {
	my $class = shift;
	
	$logger->trace( '---' );
	
	my $this = $class->SUPER::new( @_ );
	
	# Font Size auf einen nutzerspezifischen Wert setzen. 
	# Wird in alle Kindfenster vererbt
	if ( my $fontSize = $config->get( 'wx.defaultFontPointSize' ) ) {
		$logger->debug( "setze Font Size auf: $fontSize"  );
		my $font = $this->GetFont;
		$font->SetPointSize( $fontSize );
		$this->SetFont( $font );
	}
	
	# initialize Panes
	# and default Perspective
	$this->{aui}   = Scring::Wx::AuiManager->new( $this );
	
	# Aliasing Panes
	$this->{base}      = $this->aui->base;
	$this->{videoList} = $this->aui->videoList; 
	$this->{cover}     = $this->aui->cover;
	
	$this->{misc}   = $this->aui->misc;
	$this->{info}   = $this->misc->info;
	$this->{links}  = $this->misc->links;
	$this->{reviews} = $this->misc->reviews;
	$this->{videoSpeicherorte} = $this->misc->videoSpeicherorte;
	
	
	$this->{speicherorte} = $this->aui->speicherorte;
	$this->{search} = $this->aui->search;

	# Und Verweise in den Panes auf die anderen benötigten Panes
	$this->reviews->reviewViewer( $this->aui->reviewViewer );
	
	# Einige Panes benötigen auch den AuiManager
	$this->reviews->aui( $this->aui );

	# ACHTUNG
	# in den Toolbars und
	# dem Menu sind Events für das Frame
	# verknüpft und auch die Implementierung hinterlegt
	$this->{menu}    = Scring::Wx::Menu->new( $this ); # ruft $frame->SetMenuBar auf 
	$this->{toolbar} = $this->aui->toolbar;

	Wx::Event::EVT_CLOSE( $this, \&OnClose  );
	
	# lade letzten Titel
	$this->videoList->setSelectedTitle( $config->get( 'user.lastTitle' ) );
	$this->loadVideo( Titel => $config->get( 'user.lastTitle' ) );
	
	# Misc Tab setzen
	$this->misc->SetSelection( $config->get( 'user.lastMiscTab' ) );
	
	#$this->videoList->focusFilter; 	# starte in der suchbox
	$this->videoList->focusList;
	
	return $this;	
}

=head2 loadVideo( args )

Args wird in find von resultset( 'Video' ) übergeben
Sinnvolle Keys sind id oder Titel.


=cut

sub loadVideo {
	my ( $this, %args ) = @_;
	
	$logger->trace( join ' - ', %args );
	
	my $rs = $schema->resultset( 'Video' )->findVideo( %args );
	
	return if not $rs;
	
	$this->base ->loadFrom( $rs );
	$this->cover->loadFrom( $rs );
	$this->reviews->loadFrom( $rs );
	$this->links->loadFrom( $rs );
	$this->info ->loadFrom( $rs );
	$this->videoSpeicherorte->loadFrom( $rs );
}

=head2 OnClose

event

=cut

sub OnClose {
	my ( $this, $event ) = @_;
	
	$logger->trace( '---' ); 
	
	if ( $this->editMode ) {
		# TODO fragen, ob schließen?
		$this->editMode( 0 );
	}

	# Den zuletzt selektierten Titel Speichern
	$config->set( 'user.lastTitle'   => $this->videoList->currentSelection );
	$config->set( 'user.lastMiscTab' => $this->misc->GetSelection );

	# Das ist enorm wichtig, 
	# um einen Absturz zu vermeiden
	# Außerdem werden hier die Perspektiven gesichert 
	$this->aui->UnInit;
	$this->Destroy;
}

=head2 editMode( set? )

returns editMode

=cut

sub editMode {
	my ( $this, $set ) = @_;
	
	return $this->{editMode} if not defined $set;
	
	$logger->trace( $set ? 1 : 0 );
	
	$this->{editMode} = $set;
	
	$this->videoList->editMode( $set );
	$this->toolbar->editMode( $set );
	
	return $set;
}

=head2 newEntry

=cut

sub newEntry {
	my $this = shift;
		
	$logger->trace( '---' );
}

=head2 toggleEditMode

=cut

sub toggleEditMode {
	my $this = shift;
	
	$logger->trace( '---' );
	
	$this->editMode( ! $this->editMode );
	
	1;
}

=head2 showPreferences

=cut

sub showPreferences {
	my $this = shift;
	
	$logger->trace( '---' );
	
	require Scring::Wx::Dialog::Preferences;
	
	my $dlg = Scring::Wx::Dialog::Preferences->new( $this );
	$dlg->ShowModal;
	$dlg->Destroy;
	
	1;
}

1;

__END__

# -------

=head2 prepareGUI

=cut

sub prepareGUI {
	my $this = shift;
	
	$logger->trace( '---' );
	
	$this->{aui} = Wx::AuiManager->new( $this );
	
	
	
	return 0;
	# AUI
	# Manager initialisieren und gemanagtes Fenster übergeben 
	my $manager = $this->{manager} = Wx::AuiManager->new;
	$manager->SetManagedWindow( $this );
	
	# Die einzelnen Panes mit ein paar 
	# sinnvollen Voreinstellungen hinzufügen
	
	# Base - Wx::Panel
	$this->{Base} = Scring::Wx::Pane::Base  ->new( $this, wxID_ANY );
	$manager->AddPane( $this->{Base}, Wx::AuiPaneInfo->new->CenterPane->Name( 'Base' )->Caption( 'Base' )->CaptionVisible( 0 )->PaneBorder( 0 )	);
	
	# Search - Wx::Panel
	$this->{Search} = Scring::Wx::Pane::Search->new( $this, wxID_ANY );
	$manager->AddPane( $this->{Search},	Wx::AuiPaneInfo->new->Left->Name( 'Search' )->Caption( 'Search' )->CaptionVisible( 0 )->CloseButton( 0 )
															->MinSize( Wx::wxSIZE( 360, -1 ) )->PaneBorder( 0 )->Layer( 1 ) );
	
	# Image - Wx::Panel
	$this->{Image} = Scring::Wx::Pane::Image->new( $this, wxID_ANY );
	$manager->AddPane( $this->{Image}, Wx::AuiPaneInfo->new->Right->Name( 'Image' )->Caption( 'Image' )->CaptionVisible( 0 )->CloseButton( 0 )
														   ->MinSize( Wx::wxSIZE( 320, 420 ) )->PaneBorder( 0 )->Layer( 1 ) );
	
	# Info - Wx::AuiNotebook, 0 == style
	$this->{Info} = Scring::Wx::Pane::Info->new( $this, wxID_ANY, wxDefaultPosition, wxDefaultSize, 0 ); 
	$manager->AddPane( $this->{Info}, Wx::AuiPaneInfo->new->Right->Name( 'Info' )->Caption( 'Info' )->CaptionVisible( 0 )->CloseButton( 0 )
														  ->MinSize( Wx::wxSIZE( 320, -1 ) )->PaneBorder( 0 )->Layer( 1 ) );
	
	
	# diese könnten evtl, dynamisch Nachgeladen werden
	# ein Verbindung mit DestroyOnClose wäre zu analysieren
	$this->{Review}         = Wx::HtmlWindow->new( $this, wxID_ANY );
	$manager->AddPane( $this->Review, Wx::AuiPaneInfo->new->CenterPane->Name( 'Review' )->Caption( 'Review' )->CaptionVisible( 1 )->CloseButton( 1 )
														  ->PaneBorder( 1 )->Show( 0 ) );
	
	$this->{ExtendedSearch} = Scring::Wx::Pane::ExtendedSearch->new( $this, wxID_ANY ); # Wx::Panel
	$manager->AddPane( $this->ExtendedSearch, Wx::AuiPaneInfo->new->Left->Name( 'ExtendedSearch' )->Caption( 'ExtendedSearch' )->CaptionVisible( 0 )->CloseButton( 0 )
																  ->MinSize( Wx::wxSIZE( 360, -1 ) )->PaneBorder( 0 )->Show( 0 ) );
	
	$this->{Speicherorte} = Scring::Wx::Pane::Speicherorte->new( $this, wxID_ANY ); # Wx::Panel
	$manager->AddPane( $this->Speicherorte, Wx::AuiPaneInfo->new->CenterPane->Name( 'Speicherorte' )->Caption( 'Speicherorte' )->CaptionVisible( 1 )->CloseButton( 1 )
																->PaneBorder( 1 )->Show( 0 ) );	
	
	####################
	### Menüs
	####################
	my $MenuBar = Wx::MenuBar->new;
	
	# Menü Programm
	my $menu = Wx::Menu->new;
	
	my $preferences = Wx::MenuItem->new( $menu, wxID_ANY  , 'Einstellungen' );
	my $exit        = Wx::MenuItem->new( $menu, wxID_EXIT , "&Beenden\tALT-F4" );
	
	$menu->Append( $preferences );
	$menu->AppendSeparator;
	$menu->Append( $exit );

	Wx::Event::EVT_MENU( $this, wxID_EXIT, sub{ $_[0]->Close } );

	$MenuBar->Append( $menu, '&Scring' );
	
	# Menü Bearbeiten
	$menu = Wx::Menu->new;
	
	my $newEntry   = Wx::MenuItem->new( $menu, wxID_ANY, "Neuer Eintrag\tCTRL-N", '', wxITEM_CHECK );
	my $enableEdit = Wx::MenuItem->new( $menu, wxID_ANY, "Eintrag editieren\tCTRL-E", '', wxITEM_CHECK );
	
	$menu->Append( $newEntry );
	$menu->Append( $enableEdit );
	
	$MenuBar->Append( $menu, '&Bearbeiten' );
	
	Wx::Event::EVT_MENU( $this, $newEntry, sub { $this->Clear; $this->editMode( ! $this->editMode ) } );
	Wx::Event::EVT_MENU( $this, $enableEdit, sub { $this->editMode( ! $this->editMode ) } );
	
	$this->{menuEnableEdit} = $enableEdit;
	
	# Menü Extras
	$menu = Wx::Menu->new;
	
	my $showSpeicherorte   = Wx::MenuItem->new( $menu, wxID_ANY, "Speicherorte\tCTRL-S", '', wxITEM_CHECK );
	my $showExtendedSearch = Wx::MenuItem->new( $menu, wxID_ANY, "Erweiterte Suche\tCTRL-F", '', wxITEM_CHECK  );
	my $showID = Wx::MenuItem->new( $menu, wxID_ANY, 'Datensatz-ID' );
	
	$this->{menuShowSpeicherorte}   = $showSpeicherorte;
	$this->{menuShowExtendedSearch} = $showExtendedSearch;
	
	$menu->Append( $showSpeicherorte );
	$menu->Append( $showExtendedSearch );
	$menu->AppendSeparator;
	$menu->Append( $showID );
	
	$MenuBar->Append( $menu, '&Extras' );
	
	# check nicht nötig?
	Wx::Event::EVT_MENU( $this, $showSpeicherorte, \&OnMenuShowSpeicherorte ); # $event stört sonst in ShowSpeicherorte
	Wx::Event::EVT_MENU( $this, $showExtendedSearch, sub { $showExtendedSearch->Check( $this->SwitchPane( $this->Search, $this->ExtendedSearch ) ) } );
	Wx::Event::EVT_MENU( $this, $showID, sub { Wx::MessageBox( $this->Base->id ) } );
	
	# Menü Hilfe
	$menu = Wx::Menu->new;
	
	my $about = Wx::MenuItem->new( $menu, wxID_ABOUT, 'Über' );
	my $savePerpective   = Wx::MenuItem->new( $menu, wxID_ANY, 'Perspektive speichern' );
	# Untermenü mit den gespeicherten Perpektiven automatisch generieren
	my $submenu = Wx::Menu->new;
	my $defaultPerspective = Wx::MenuItem->new( $menu, wxID_ANY, 'Default' );
	$submenu->Append( $defaultPerspective );
	
	$menu->Append( $savePerpective );
	$menu->AppendSubMenu( $submenu, 'Perpektive laden' );	
	$menu->AppendSeparator;	
	$menu->Append( $about );
	
	Wx::Event::EVT_MENU( $this, wxID_ABOUT, sub { ... } );
	Wx::Event::EVT_MENU( $this, $defaultPerspective, sub { $this->manager->LoadPerspective( $this->defaultPerspective ) } );
	
	$MenuBar->Append( $menu, '?' );
	
	# Und noch die Menübar dem Frame zuweisen
	$this->SetMenuBar( $MenuBar );	
	
	#######################
	### Die (Edit) Toolbar
	#######################
	$this->{Toolbar} = Wx::ToolBar->new( $this, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxTB_FLAT | wxTB_DOCKABLE  );
	# TODO feature Request to implement this
	#  $this->{Toolbar}->AddStretchableSpace;
	my $toolBack = $this->{Toolbar}->AddTool( wxID_ANY, 'Abbrechen', Wx::ArtProvider::GetBitmap( wxART_GO_BACK ) );
	$this->{Toolbar}->AddSeparator;
	my $toolSave = $this->{Toolbar}->AddTool( wxID_ANY, 'Speichern', Wx::ArtProvider::GetBitmap( wxART_FILE_SAVE ) );
	$this->{Toolbar}->Realize;
	
	Wx::Event::EVT_TOOL( $this, $toolBack->GetId, \&OnToolBack );
	Wx::Event::EVT_TOOL( $this, $toolSave->GetId, \&OnToolSave );
	
	$manager->AddPane( $this->Toolbar,
		Wx::AuiPaneInfo->new
			->Top
			->Name( 'Toolbar' )->CaptionVisible( 0 )
			->Resizable( 0 )->Movable( 0 )->Gripper( 0 )
			->Show( 0 )			
	);
			
	
	# Dies ist notwendig, um
	# den AUIManager zu initialisieren
	$manager->Update;

	# Events
	Wx::Event::EVT_AUI_PANE_BUTTON( $this->manager, \&OnAuiButton );
	Wx::Event::EVT_CLOSE( $this, \&OnClose  );

	# Default Perpektive speichern
	$this->{defaultPerspective} = $manager->SavePerspective;

	1;
}



=head2 Load( Titel )

=cut

sub Load {
	my ( $this, $Titel ) = @_;
	
	$logger->trace( '---' );

	# setzte auf Basispane zurück
	$this->centralPane( $this->Base );

	# Lade das ausgewählte Video
	# prefatche das Genre (über VideoGenre)
	# und das Titelbild
	# Info-Daten werden nicht geprefetch, sondern
	# je nach angezeigten Notebook-Page in der 
	# Info-Pane nachgeladen
	my $rs = $schema->resultset( 'Video' )->find( 
		{ Titel => $Titel }, 
		{ 
			prefetch => [
				{ 'VideoGenre' => 'Genre' },
				'TitleImage',
			] 
		} 
	);
	
	$this->{resultset} = $rs;
	
	return if not $rs;
	
	$this->Base->loadFrom( $rs );
	$this->Image->loadFrom( $rs );
	$this->Info->loadFrom( $rs );
	
	1;
}

=head2 SwitchPane( Pane1 Pane2 )

Returns true, if the first pane is hidden and false otherwise

=cut

sub SwitchPane {
	my ( $this, $Pane1, $Pane2 ) = @_;
	
	$logger->trace( '---' );
	
	my $show = $Pane1->IsShown;
	
	$this->manager->GetPane( $Pane1 )->Show( ! $show );
	$this->manager->GetPane( $Pane2 )->Show( $show );
	
	$this->manager->Update;

	return 0;
}

=head2 ShowReview( ReviewID )

=cut

sub ShowReview {
	my ( $this, $ReviewID ) = @_;
	
	$logger->trace( $ReviewID );

	$this->centralPane( $this->Review );

	# Nur das benötigte Review nachladen
	$this->Review->SetPage( 
		$schema->resultset( 'Review' )
			->find( $ReviewID, { select => 'Review' } )
			->Review 
	);
	
	1;
}

=head2 centralPane( pane )

Setzt die zentrale Pane, welche angezeigt werden soll

=cut

sub centralPane {
	my ( $this, $pane ) = @_;
	
	$logger->trace( '---' );
	
	return $this->{centralPane} if not $pane;

	if ( $this->{centralPane} eq $pane ) {
		$logger->debug( 'Pane wird schon angezeigt' );
		return $this->{centralPane};
	}
	
	# wenn die vorherige Pane, Speicherorte war,
	# sicherstellen, dass das Menu korrekt umgestellt wird
	if ( $this->{centralPane} eq $this->Speicherorte ) {
		$logger->trace( 'central Pane war Speicherort-Pane - setze Menu zurück' );
		$this->menuShowSpeicherorte->Check( 0 )
	} 

	$this->SwitchPane( $this->{centralPane} => $pane );
	
	$logger->debug( 'Pane geswitcht' );
		
	return $this->{centralPane} = $pane;
}

=head2 OnAuiButton

=cut

sub OnAuiButton {
	my ( $manager, $event ) = @_;
	
	$logger->trace( '---' );
	
	# Im Moment, erzeugt ein schließen einfach ein Wechsel
	# auf die Basispane
	$manager->GetManagedWindow->centralPane( $manager->GetManagedWindow->Base );
	
	$event->Skip;
	return;
	
	#############################
	
	# Ich muss irgendwie herausbekommen, ob die geschlossene
	# Pane die Review Pane ist
	# Dieser buckelige Umweg scheint die einzige Möglichkeit zu sein
	if( $manager->SavePaneInfo( $event->GetPane ) =~ /name=Review/ ) {
		
		# Das Basisfenster wieder anzeigen, wenn das
		# Review-Fenster geschlossen wird
		$manager->GetPane( $manager->GetManagedWindow->Base )->Show;
	}
	
	# Verarbeite den Event weiter wie
	# gewöhnt, daher Schließe oder Zerstöre Fenster
	# $manager->Update wird im EventHandler durchgeführt
	$event->Skip;
}

=head2 editMode

=cut

sub editMode2 {
	my ( $this, $set ) = @_;
	
	$logger->trace( !! $set ); # !! - suppress undef warning
	
	return $this->{editMode} if not defined $set;
	
	# wenn der editMode nicht über die Menu-Funktionalität
	# aufgerufen wird
	if ( $this->menuEnableEdit->IsChecked != $set ) {
		$this->menuEnableEdit->Check( $set );
	}
	
	# zurückschalten auf central-Pane immer
	$this->centralPane( $this->Base );
	
	# Toolbar anzeigen
	$this->manager->GetPane( $this->Toolbar )->Show( $set );
	$this->manager->Update;
	
	$this->{editMode} = $set;
	
	$this->Base          ->editMode( $set );
	$this->Search        ->editMode( $set );
	$this->ExtendedSearch->editMode( $set );
	$this->Info          ->editMode( $set );
	$this->Speicherorte  ->editMode( $set );
	
	# Menupunkte ausgrauen im editMode
#	$this->menuShowSpeicherorte  ->Enable( ! $set );
	$this->menuShowExtendedSearch->Enable( ! $set );
	
}

=head2 OnMenuShowSpeicherorte

=cut

sub OnMenuShowSpeicherorte {
	my ( $this, $event ) = @_;
	
	$this->menuShowSpeicherorte->IsChecked
		? $this->ShowSpeicherorte
		: $this->centralPane( $this->Base )
	;
}

=head2 ShowSpeicherorte( speicherortID?, inhalt? )

=cut

sub ShowSpeicherorte {
	my ( $this, $speicherortID, $inhalt ) = @_;
	
	$logger->trace( '---' );
	
	$this->Speicherorte->lazyLoad;
	
	$this->centralPane( $this->Speicherorte );
	
	$this->menuShowSpeicherorte->Check( 1 );
	
	if ( defined $speicherortID ) {
		$logger->trace( "Speicherort ID: $speicherortID" );
		$this->Speicherorte->SelectItemByData( $speicherortID );
		
		if ( defined $inhalt ) {
			$logger->trace( "Inhalt: $inhalt" );
			$this->Speicherorte->SetInhalt( $inhalt );
		}
	}
		
	1;
}

=head2 Clear

=cut

sub Clear {
	my $this = shift;
	
	$logger->trace( '---' );
	
	$this->Search->ClearSelection;
}

=head2 GetVideo

=cut

sub GetVideo {
	my $this = shift;

	# warum?	
#	$logger->logdie( 'Diese Funktion darf nur im editMode aufgerufen werden!' )
#		if not $this->editMode;
		
	return $this->resultset;
}

=head2 OnToolBack

=cut

sub OnToolBack {
	my ( $this, $event ) = @_;
	
	$logger->trace( '---' );
	
	$this->editMode( 0 );
	
	$this->Load( $this->GetVideo->Titel );
	
	1;
}

=head2 OnToolSave

=cut

sub OnToolSave {
	my ( $this, $event ) = @_;
	
	$logger->trace( '---' );
}

1;