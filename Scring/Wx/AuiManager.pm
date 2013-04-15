package Scring::Wx::AuiManager;

=head1 NAME

Scring::Wx::AuiManager

=head1 DESCRIPTION

Der AuiManager ist sowohl der Standard AUI Manager
von Wx, als auch ein Perspektiven Manager, der sich um
das speichern und laden von Standard- und Benutzerdefinierten
Perspektiven kümmert

=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx qw( wxID_ANY wxDefaultPosition wxDefaultSize );
use Wx::Aui;
use Wx::Event;
use Wx::Html;

use Scring::Util;
use Scring::Wx::Perspective;
use Scring::Wx::Pane::Base;
use Scring::Wx::Pane::VideoList;
use Scring::Wx::Pane::Cover;
use Scring::Wx::Pane::Misc;
use Scring::Wx::Pane::Speicherorte;
use Scring::Wx::Pane::Search;


use parent -norequire =>  'Wx::AuiManager';

use Object::Tiny qw( 
	wx
	
	defaultPerspective
	perspectiveById
	perspectiveByName
	
	base
	videoList
	cover
	misc
	reviewViewer
	speicherorte
	search
);

=head2 new

=cut

sub new {
	my ( $class, $managedWindow ) = @_; 
	
	$logger->trace( '---' );
	
	my $this = bless {}, $class;
	$this->{wx} = Wx::AuiManager->new( $managedWindow );
	$this->{perspectiveById} = {};
	$this->{perspectiveByName} = {};
	
	$this->initialize;
	
	# Alle weiteren Perspektiven aus der Konfiguration laden
	my $configArray = $config->get( 'wx.perspective.user' );
	
	for my $serialized ( @$configArray ) {
		my $entry = Scring::Wx::Perspective->deserialize( $serialized );
		
		$this->perspectiveByName->{ $entry->name } = $entry;
		$this->perspectiveById->{ $entry->id } = $entry;
	}
	
	# Default Perspektive hinzufügen,
	# dadurch wird eine eventuell gespeicherte Default Perspektive
	# gelöscht
	$this->savePerspectiveAs( 'Default' );
	$logger->trace( 'default Perspective saved' );
	
	return $this;
}

=head2 initialize

=cut

sub initialize {
	my $this = shift;
	
	$logger->trace( '---' );
	
	my $managedWindow = $this->GetManagedWindow;
	
	# Panels
	$this->{base}         = Scring::Wx::Pane::Base     ->new( $managedWindow );
	$this->{videoList}    = Scring::Wx::Pane::VideoList->new( $managedWindow );
	$this->{cover}        = Scring::Wx::Pane::Cover    ->new( $managedWindow );
		
	# speicherorte braucht den AuiManager
	$this->{search}       = Scring::Wx::Pane::Search   ->new( $managedWindow, $this );
	$this->{speicherorte} = Scring::Wx::Pane::Speicherorte->new( $managedWindow, $this, $this->search );
		
	# AUINotebook
	$this->{misc} = Scring::Wx::Pane::Misc->new( $managedWindow, wxID_ANY, wxDefaultPosition, wxDefaultSize, 0 );
	
	# Other Widgets
	$this->{reviewViewer} = Wx::HtmlWindow->new( $managedWindow, wxID_ANY );
		
	$this->AddPane( $this->base        , Scring::Wx::Perspective->defaultPaneInfoFor( 'base' ) );
	$this->AddPane( $this->videoList   , Scring::Wx::Perspective->defaultPaneInfoFor( 'videoList' ) );
	$this->AddPane( $this->cover       , Scring::Wx::Perspective->defaultPaneInfoFor( 'cover' ) );
	$this->AddPane( $this->misc        , Scring::Wx::Perspective->defaultPaneInfoFor( 'misc' ) );
	$this->AddPane( $this->reviewViewer, Scring::Wx::Perspective->defaultPaneInfoFor( 'reviewViewer' ) );
	$this->AddPane( $this->speicherorte, Scring::Wx::Perspective->defaultPaneInfoFor( 'speicherorte' ) );
	$this->AddPane( $this->search      , Scring::Wx::Perspective->defaultPaneInfoFor( 'search' ) );
	
	$this->Update;
	
	1;
}

=head2 loadPerspectiveById( perspectiveId )

=cut

sub loadPerspectiveById {
	my ( $this, $id ) = @_;
	
	my $perspective = $this->perspectiveById->{ $id };
	
	$this->loadPerspective( $perspective );

	1;
}

=head2 loadPerspectiveByName( name )

=cut

sub loadPerspectiveByName {
	my ( $this, $name ) = @_;
	
	$logger->trace( $name );
	
	my $perspective = $this->perspectiveByName->{ $name };
		
	$this->loadPerspective( $perspective );

	1;
}

=head2 loadPerspective( Scring::Wx::Perspective )

=cut

sub loadPerspective {
	my ( $this, $perspective ) = @_;
	
	$logger->trace( '---' );
	
	my $frame = $this->GetManagedWindow;

	$frame->Move( $perspective->framePosition );
	$frame->SetSize( $perspective->frameSize );
	$frame->Maximize( $perspective->maximized );
	
	$this->wx->LoadPerspective( $perspective->auiPaneInfo );
	
	$logger->debug( 'Perspektive geladen, id: ' . $perspective->id . ', name: ' . $perspective->name );
	
	1;	
}

=head2 savePerspectiveAs( name )

=cut

sub savePerspectiveAs {
	my ( $this, $name ) = @_;
	
	$logger->debug( "Setze $name " );
	
	my $frame = $this->GetManagedWindow;
	
	my $newEntry = Scring::Wx::Perspective->new( 
		name          => $name,
		auiPaneInfo   => $this->wx->SavePerspective,
		
		maximized     => $frame->IsMaximized ? 1 : 0,
		
		frameSize     => [ $frame->GetSizeWH ],
		framePosition => [ $frame->GetScreenPositionXY ],	 
	);
	
	# suche Eintrag, wenn schon vorhanden, überschreiben
	if ( $this->perspectiveByName->{ $name } ) {
		
		$logger->trace( 'Eintrag überschreiben' );
		
		$this->perspectiveByName->{ $name }->auiPaneInfo  ( $newEntry->auiPaneInfo );
		$this->perspectiveByName->{ $name }->frameSize    ( $newEntry->frameSize );
		$this->perspectiveByName->{ $name }->maximized    ( $newEntry->maximized );
		$this->perspectiveByName->{ $name }->framePosition( $newEntry->framePosition );
		
		# perspectiveById wird durch den Alias automatisch überschrieben
	} 
	
	# neuen einfügen
	else {
		
		$logger->trace( 'neuen Eintrag hinzufügen' );
		
		# id noch generieren
		$newEntry->generateId;
		
		$this->perspectiveByName->{ $name }       = $newEntry;
		$this->perspectiveById->{ $newEntry->id } = $newEntry;
	
	}
		
	return $newEntry;
}

=head2 allPerspectives

# gibt alle, außer der Default Perspektive zurück

=cut

sub allPerspectives {
	my $this = shift;
	
	return grep { not $_->name eq 'Default' } values $this->perspectiveById;
}

=head2 showPane( pane, show=1 )

=cut

sub showPane {
	my ( $this, $pane, $show ) = @_;
	
	$logger->trace( '---' );
	
	$this->wx->GetPane( $pane )->Show( $show // 1 );
	$this->wx->Update;
}

=head2 isPaneShown( pane )

=cut

sub isPaneShown {
	my ( $this, $pane ) = @_;
	
	return $this->wx->GetPane( $pane )->IsShown;
}

=head1 Method Override

=head2 UnInit

Bevor es an das UnInit des wxAuiManagers weitergeleitet wird,
noch alle (außer der Default) Perspektiven sichern.

=cut

sub UnInit { 
	my $this = shift;
	
	my @configArray = map { $_->serialize } $this->allPerspectives;
	$config->set( 'wx.perspective.user' => \@configArray );

	$logger->debug( 'Perspektiven gespeichert' );
	
	return $this->wx->UnInit( @_ );
}

=head2 Method Forwarding

=cut

sub GetManagedWindow { return shift->wx->GetManagedWindow( @_ ) }
sub AddPane          { return shift->wx->AddPane( @_ ) }
sub Update           { return shift->wx->Update( @_ ) }


# Schnittstellen nicht öffentlich
#sub SavePerspective  { return shift->wx->SavePerspective( @_ ) }
#sub LoadPerspective  { return shift->wx->LoadPerspective( @_ ) }

1;