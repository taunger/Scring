package Scring::Wx::Pane::Info::Reviews;

=head1 NAME

Scring::Wx::Pane::Info::Reviews

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx qw(  wxID_ANY wxEXPAND wxALL wxVERTICAL wxDefaultPosition wxDefaultSize wxTE_READONLY wxTE_MULTILINE wxLIST_FORMAT_LEFT wxLC_SINGLE_SEL wxLC_REPORT );
use Wx::Event;

use Scring::Util;
use Scring::Wx::Widget::LCBase;

use parent -norequire => qw( Scring::Wx::Widget::LCBase );

use Object::Tiny qw( ContextMenu );
use Object::Tiny::RW qw( editMode );

=head2 new

=cut

sub new {
	my ( $class, $parent ) = @_;
	
	my $this = $class->SUPER::new( $parent, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxLC_REPORT | wxLC_SINGLE_SEL );

	$this->InsertColumn( 1, 'Autor', wxLIST_FORMAT_LEFT, 120 );
	$this->InsertColumn( 2, 'Bewertung', wxLIST_FORMAT_LEFT );
	
	my $menu = $this->{ContextMenu} = Wx::Menu->new;
		
	my $addEntry    = Wx::MenuItem->new( $menu, wxID_ANY, 'Neu' );
	my $removeEntry = Wx::MenuItem->new( $menu, wxID_ANY, 'Löschen' );
	
	$menu->Append( $addEntry );
	$menu->AppendSeparator;
	$menu->Append( $removeEntry );
	
	Wx::Event::EVT_LIST_ITEM_ACTIVATED( $this, $this, \&OnActivated );
	Wx::Event::EVT_RIGHT_DOWN( $this, \&OnRightClick );
		
	Wx::Event::EVT_MENU( $this, $addEntry   , \&OnMenu_Add );
	Wx::Event::EVT_MENU( $this, $removeEntry, sub { $this->RemoveSelected } );	
	
	return $this;
}

=head2 loadFrom

=cut

sub loadFrom {
	my ( $this, $resultset ) = @_;
	
	$logger->trace( '---' );
	
	$this->DeleteAllItems;
	
	my $i = 0;
	for my $_ ( $resultset->Reviews ) {
		$this->InsertStringItem( $i, $_->Author );
		$this->SetItem( $i, 1, $_->Bewertung );
		$this->SetItemData( $i, $_->id );
		$i++;
	}
	
	1;
}

=head2 OnActivated

=cut

sub OnActivated {
	my ( $this, $event ) = @_;
	
	$logger->trace( '---' );
	
	Wx::wxTheApp->Frame->ShowReview( $event->GetData ); # GetData = ReviewID
	
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
	$this->ContextMenu->Enable( $this->ContextMenu->FindItemByPosition( 2 )->GetId, $foundItem );
	$this->PopupMenu( $this->ContextMenu, wxDefaultPosition );
	
	1;
}

=head2 OnMenu_Add

=cut

sub OnMenu_Add {
	my ( $this, $event ) = @_;
	
	$logger->trace( '---' );
	
	# TODO mehrere Quellen?
	# Anisearch, OFDB?
	
}

1;
