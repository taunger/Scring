package Scring::Wx::Pane::VideoList;

=head1 NAME

Scring::Wx::Pane::VideoList

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

# key codes sind in der defs.h von wxWidgets
use Wx qw(  wxEXPAND wxALL wxID_ANY wxVERTICAL wxLB_SORT wxDefaultPosition wxDefaultSize wxBOTTOM 
			WXK_UP WXK_DOWN WXK_ESCAPE wxNOT_FOUND wxTheApp );

use Scring::Util;
use Scring::Wx::Role::Pane;

use parent -norequire => qw( Wx::Panel Scring::Wx::Role::Pane );

use Object::Tiny qw( 
	frame
	
	filter
	list
	counter
	titles
);

=head2 new

=cut

sub new {
	my ( $class, $parent ) = @_;
	
	$logger->trace( '---' );
	
	my $this = $class->SUPER::new( $parent );
	$this->{frame} = $parent;	
	
	$this->initialize;
	
	$this->loadList;
	
	return $this;
}

=head2 initialize

=cut

sub initialize {
	my $this = shift;
	
	$logger->trace( '---' );
	
	my $W = {};
	my $S = {};
	
	$S->{Main} = Wx::BoxSizer->new( wxVERTICAL );
	$S->{Rand} = Wx::BoxSizer->new( wxVERTICAL );
	
	$this->{filter} = Wx::SearchCtrl->new( $this, wxID_ANY, '' );
	$this->{filter}->ShowSearchButton( 0 );
	$this->{filter}->ShowCancelButton( 0 );
	
	$this->{list} = Wx::ListBox->new( $this, wxID_ANY, wxDefaultPosition, wxDefaultSize, [], wxLB_SORT );
	
	$this->{counter} = Wx::StaticText->new( $this, wxID_ANY, '' );
		
	$S->{Rand}->Add( $this->filter , 0, wxEXPAND | wxBOTTOM, 10 );
	$S->{Rand}->Add( $this->list   , 1, wxEXPAND | wxBOTTOM, 5);
	$S->{Rand}->Add( $this->counter, 0, wxEXPAND );

	$S->{Main}->Add( $S->{Rand}, 1, wxEXPAND | wxALL, 10 );
	
	$this->SetSizer( $S->{Main} );
	$this->SetAutoLayout( 1 );
	
	Wx::Event::EVT_LISTBOX       ( $this, $this->list   , \&OnSelChange_list );
	Wx::Event::EVT_LISTBOX_DCLICK( $this, $this->list   , \&OnDClick_list ); 
	Wx::Event::EVT_CHAR          ( $this->counter       , \&OnChar_filter );
	Wx::Event::EVT_TEXT          ( $this, $this->counter, \&OnText_filter );	
	
	1;
}

=head2 loadList

=cut

sub loadList {
	my $this = shift;
	
	$logger->trace( '---' );
	
	$this->{titles} = $schema->resultset( 'Video' )->allTitles;
	
	$this->list->Clear; 
	$this->list->Append( $this->titles );
	
	$this->refreshCounter;
	
	1;	
}

=head2 refreshCounter

=cut

sub refreshCounter {
	my $this = shift;
	
	$logger->trace( '---' );
	
	$this->counter->SetLabel( $this->list->GetCount . ' Einträge' );
	
	1;
}

=head2 currentSelection

=cut

sub currentSelection {
	my $this = shift;
	
	$logger->trace( '---' );
	
	return $this->list->GetStringSelection;
}

=head2 setSelectedTitle( title )

=cut

sub setSelectedTitle {
	my ( $this, $setSelectedTitle ) = @_;
	
	$logger->trace( '---' );
	
	return $this->list->SetStringSelection( $setSelectedTitle );
}

=head2 focusFilter

=cut

sub focusFilter {
	my $this = shift;
	
	$logger->trace( '---' );
	
	return $this->filter->SetFocus;
}

=head2 focusList

=cut

sub focusList {
	my $this = shift;
	
	$logger->trace( '---' );
	
	return $this->list->SetFocus;
}

=head2 OnSelChange_list

=cut

sub OnSelChange_list {
	my $this = shift;
	
	wxTheApp->frame->loadVideo( Titel => $this->list->GetStringSelection );
	
	1;
}

=head2 OnDClick_list

event

=cut

sub OnDClick_list {
	my ( $this, $event ) = @_;
	
	$this->frame->editMode( 1 );
	
	1;
}

=head2 editMode

=cut

sub editMode {
	my ( $this, $set ) = @_;
	
	$this->SUPER::editMode( $set );
	
	$this->list->Enable( ! $set );
	
	1;
}

1;
__END__
=head2 prepareGUI

=cut

sub prepareGUI {
	my $this = shift;
	
	$logger->trace( '---' );
	
	my $W = $this->{W} = {};
	my $S = {};
	my $this = $this;
	
	$S->{Main} = Wx::BoxSizer->new( wxVERTICAL );
	$S->{Rand} = Wx::BoxSizer->new( wxVERTICAL );
	
	$this->{SC} = $W->{SC} = Wx::SearchCtrl->new( $this, wxID_ANY, '' );
	$this->{SC}->ShowSearchButton( 0 );
	$this->{SC}->ShowCancelButton( 0 );
	
	$this->{LB} = $W->{LB} = Wx::ListBox->new( $this, wxID_ANY, wxDefaultPosition, wxDefaultSize, [], wxLB_SORT );
	
	$this->{ST} = $W->{ST} = Wx::StaticText->new( $this, wxID_ANY, '' );
	
	$S->{Rand}->Add( $W->{SC}, 0, wxEXPAND | wxBOTTOM, 10 );
	$S->{Rand}->Add( $W->{LB}, 1, wxEXPAND | wxBOTTOM, 5);
	$S->{Rand}->Add( $W->{ST}, 0, wxEXPAND );

	$S->{Main}->Add( $S->{Rand}, 1, wxEXPAND | wxALL, 10 );
	
	$this->SetSizer( $S->{Main} );
	$this->SetAutoLayout( 1 );
	
	# Events
	Wx::Event::EVT_LISTBOX( $this, $W->{LB}, \&OnSelChange_LB );
	Wx::Event::EVT_LISTBOX_DCLICK( $this, $W->{LB}, \&OnDClick_LB ); 
	Wx::Event::EVT_CHAR( $W->{SC}, \&OnChar_SC );
	Wx::Event::EVT_TEXT( $this, $W->{SC}, \&OnText_SC );	
	
	1;
}

=head2 loadLB

=cut

sub loadLB {
	my $this = shift;
	
	$logger->trace( '---' );
	
	$this->{items} = [
		$schema->resultset( 'Video' )
			->search( undef, { order_by => 'Titel' } )
			->get_column( 'Titel' )
			->all
	];
	
	$this->LB->Clear; 
	$this->LB->Append( $this->items );
	
	$this->ST->SetLabel( $this->LB->GetCount . ' Einträge' );
}

=head2 OnSelChange_LB

event

=cut

sub OnSelChange_LB {
	my ( $this, $event ) = @_;
	
	$logger->trace( '---' );
	
	$this->GetParent->Load( $this->LB->GetStringSelection );
}

=head2 OnDClick_LB

=cut

sub OnDClick_LB {
	my ( $this, $event ) = @_;
	
	$logger->trace( '---' );
	
	$this->GetParent->editMode( 1 );
}

=head2 OnChar_SC

=cut

sub OnChar_SC {
	my ( $this, $event ) = @_;
	
	my $keyCode = $event->GetKeyCode;
	
	$logger->trace( $keyCode );
	
	# komischerweise funktioniert hier kein given-when Code 
	# ... evtl. ist eh ein dispatcher sinnvoller
	
	# Bei Escape löschen wir einfach den 
	# gesamten Inhalt der Sc
	if ( $keyCode == WXK_ESCAPE ) {
		$this->Clear;
	} 
	# Up-key, markiert eine Selection höher
	elsif ( $keyCode == WXK_UP ) {
		$this->GetParent->LB->SetSelection(
			$this->GetParent->LB->GetSelection - 1
		);
		
		$this->GetGrandParent->Load( $this->GetParent->LB->GetStringSelection );
	}
	# Down keys eine darunter
	elsif ( $keyCode == WXK_DOWN ) {
		$this->GetParent->LB->SetSelection(
			$this->GetParent->LB->GetSelection + 1
		);
		
		$this->GetGrandParent->Load( $this->GetParent->LB->GetStringSelection );
	}
	# alles markieren (STRG-A == 1)
	elsif ( $keyCode == 1 ) {
		$this->SetSelection( -1, -1 );
	}	
	# Alle weiteren Keys werden einfach
	# an EVT_TEXT weitergeleitet
	else {
		$event->Skip;
	}
	
	1;
}

=head2 OnText_SC

=cut

sub OnText_SC {
	my ( $this, $event ) = @_;
	
	# Die Suchbox hat 2 Modi:
	# einmal den normalen, bei dem die aktuelle Auswahl
	# nur neu gegrept wird
	# und einmal den Attributsmodus, bei dem 
	# die gesamte LB neu geladen wird
	
	my $string = $this->SC->GetValue;
	
	$logger->trace( $string );
		
	# ein = markiert den erweiterten Suchmode
	if ( $string =~ /=/ ) {
		$this->test( $string );
	} else {
		$this->LB->Clear;
		$this->LB->Append( [ grep { /$string/i } @{ $this->items } ] );
	}
	
	$this->ST->SetLabel( $this->LB->GetCount . ' Einträge' );
	
	1;	
}

=head2 test

=cut

sub test {
	my ( $this, $string ) = @_;
	#nimm lieber extendend search dafür...
	my %search;
	for my $_ ( split /;/, $string ) {
		
		$_ =~ /(.*?)=(.*)/;
		
		say 'bäh' if not $schema->resultset( 'Video' )->result_source->has_column( $1 );
		
		$search{ $1 } = $2;
	}
	
#	my $rs = $schema->resultset( 'Video' )->search( 
#		\%search, 
#		{ 
#			prefetch => [
#				{ 'VideoGenre' => 'Genre' },
#				'TitleImage',
#			],
#			select => 'Titel',
#		} 
#	)
#	->get_column( 'Titel' );
#
#	$this->LB->Clear; 
#	$this->LB->Append( [ $rs->all ] );
#	
#	$this->ST->SetLabel( $this->LB->GetCount . ' Einträge' );
}

=head2 editMode

=cut

sub editMode {
	my ( $this, $set ) = @_;
	
	$this->Enable( ! $set );
	
	1;
}

=head2 SetSearchString

=cut

sub SetSearchString {
	my ( $this, $string ) = @_;
	
	# SetValue sendet events
	$this->SC->SetValue( $string );
	
	1;
	
}

=head2 ClearSelection

=cut

sub ClearSelection {
	my $this = shift;
	
	$this->LB->SetSelection( wxNOT_FOUND );
	
	1;
}

1;