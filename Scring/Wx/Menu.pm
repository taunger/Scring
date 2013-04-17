package Scring::Wx::Menu;

=head1 NAME

Scring::Wx::Menu

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx qw( wxID_ANY wxID_EXIT wxID_ABOUT wxITEM_CHECK wxID_OK );
use Wx::Event;

use Scring::Util;
use Scring::Wx::Perspective;

use Object::Tiny qw( 
	menuBar 
	frame
	
	preferences
	exit
	newEntry
	enableEdit
	about
	perspectiveSubmenu
	speicherorte
	search
);

=head2 new( frame )

Setzt sich automatisch mittels $frame->SetMenuBar als Menu

=cut

sub new {
	my ( $class, $frame ) = @_;
	
	$logger->trace( '---' );
	
	my $this = bless {}, $class;
	
	$this->{menuBar}            = Wx::MenuBar->new;
	$this->{frame}              = $frame; # circular reference? - egal, wird eh nur beim ende zerstört
	
	$this->initialize;
	
	$frame->SetMenuBar( $this->menuBar );
	
	return $this;
}

=head2 initialize

=cut

sub initialize {
	my $this = shift;
	
	$logger->trace( '---' );
	
	my $frame   = $this->frame;
	my $menuBar = $this->menuBar;
	
	###
	# Menu: Programm	
	my $menu = Wx::Menu->new;
	
	$this->{preferences} = Wx::MenuItem->new( $menu, wxID_ANY  , 'Einstellungen' );
	$this->{exit}        = Wx::MenuItem->new( $menu, wxID_EXIT , "&Beenden\tALT-F4" );
	
	$menu->Append( $this->preferences );
	$menu->AppendSeparator;
	$menu->Append( $this->exit );

	# sendet close event, wird im frame nochmal abgefangen
	Wx::Event::EVT_MENU( $frame, wxID_EXIT, sub{ $frame->Close } ); 
	
	$menuBar->Append( $menu, '&Scring' );
	
	###
	# Menü Bearbeiten
	$menu = Wx::Menu->new;
	
	$this->{newEntry}   = Wx::MenuItem->new( $menu, wxID_ANY, "Neuer Eintrag\tCTRL-N"    , '', wxITEM_CHECK );
	$this->{enableEdit} = Wx::MenuItem->new( $menu, wxID_ANY, "Eintrag editieren\tCTRL-E", '', wxITEM_CHECK );
	
	$menu->Append( $this->newEntry );
	$menu->Append( $this->enableEdit );
	
	Wx::Event::EVT_MENU( $frame, $this->newEntry  , sub { shift->newEntry } );
	Wx::Event::EVT_MENU( $frame, $this->enableEdit, sub { shift->toggleEditMode } );
	
	$menuBar->Append( $menu, '&Bearbeiten' );
	
	###
	# Menu Fenster
	$menu = Wx::Menu->new;
	
	$this->{speicherorte} =  Wx::MenuItem->new( $menu, wxID_ANY, "Speicherorte\tCTRL-S", '' );
	$this->{search} =  Wx::MenuItem->new( $menu, wxID_ANY, "Suche\tCTRL-F", '' );
	$this->{savePerspective} = Wx::MenuItem->new( $menu, wxID_ANY, 'Perspektive speichern' );

	# Untermenü mit den gespeicherten Perpektiven automatisch generieren
	$this->{perspectiveSubmenu} = Wx::Menu->new;
	my $defaultPerspective = Wx::MenuItem->new( $this->perspectiveSubmenu, wxID_ANY, 'Default' );
	$this->perspectiveSubmenu->Append( $defaultPerspective );
	
	$this->perspectiveSubmenu->AppendSeparator;	
	$this->addPerspectiveSubmenuEntry( $_ ) for $this->frame->aui->allPerspectives;
	
	$menu->Append( $this->search );
	$menu->Append( $this->speicherorte );
	$menu->AppendSeparator;	
	$menu->Append( $this->{savePerspective} );
	$menu->AppendSubMenu( $this->perspectiveSubmenu, 'Perpektive laden' );	
		
	Wx::Event::EVT_MENU( $frame, $this->search, sub{ $frame->search->toggleShow } );
	Wx::Event::EVT_MENU( $frame, $this->speicherorte, sub{ $frame->speicherorte->toggleShow } );
	Wx::Event::EVT_MENU( $frame, $this->{savePerspective}, \&savePerspective );
	Wx::Event::EVT_MENU( $frame, $defaultPerspective, \&loadDefaultPerspective );
	
	$menuBar->Append( $menu, 'Ansicht' );
	
	###
	# Menü Hilfe
	$menu = Wx::Menu->new;
	
	$this->{about}          = Wx::MenuItem->new( $menu, wxID_ABOUT, 'Über' );

	$menu->Append( $this->about );
		
	Wx::Event::EVT_MENU( $frame, wxID_ABOUT, sub { ... } );
		
	$menuBar->Append( $menu, '?' );
	
	1;
}

=head2 addPerspectiveSubmenuEntry( Scring::Wx::Perspective )

=cut

sub addPerspectiveSubmenuEntry {
	my ( $this, $entry ) = @_;
	
	if ( $this->perspectiveSubmenu->FindItem( $entry->id ) ) {
		$logger->trace( $entry->id . ' : Item bereits im Menu - tue nichts' );
		return 0;  
	}
	
	$logger->trace( 'Item ' . $entry->id . ' wird hinzugefügt, name: ' . $entry->name );

	my $newItem = Wx::MenuItem->new( $this->perspectiveSubmenu, $entry->id, $entry->name );
	
	$this->perspectiveSubmenu->Append( $newItem );
	
	Wx::Event::EVT_MENU( $this->frame, $newItem, \&loadPerspective );
	
	1;
}




=head1 Scring::Wx::Frame Methoden

=head2 savePerspective

=cut

sub savePerspective {
	my ( $this, $event ) = @_; # $this == $frame!
	
	$logger->trace( '---' );
		
	my $dlg = Wx::TextEntryDialog->new( $this, 'Speichern als', 'Bezeichnung' );
	
	if ( $dlg->ShowModal == wxID_OK ) {
		
		my $entry = $this->aui->savePerspectiveAs( $dlg->GetValue );
		
		$this->menu->addPerspectiveSubmenuEntry( $entry );

	}	
	
	$dlg->Destroy;
}

=head2 loadPerspective

event

=cut

sub loadPerspective {
	my ( $this, $event ) = @_; # $this == $frame!
	
	$logger->trace( '---' );
	
	$this->aui->loadPerspectiveById( $event->GetId );
	
	1;
}

=head2 loadDefaultPerspective

event

=cut

sub loadDefaultPerspective {
	my ( $this, $event ) = @_; # $this == $frame!
	
	$logger->trace( '---' );
	
	$this->aui->loadPerspectiveByName( 'Default' );
	
	1;
}



1;