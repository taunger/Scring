package Scring::Wx::Toolbar;

=head1 NAME

Scring::Wx::EditToolbar

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx qw( wxID_ANY wxDefaultPosition wxDefaultSize wxTB_FLAT wxTB_DOCKABLE );
use Wx::Event;
use Wx::ArtProvider qw( :artid );

use Scring::Util;
use Scring::Wx::Role::Pane;

use parent -norequire => qw( Wx::ToolBar Scring::Wx::Role::Pane );

use Object::Tiny qw( 
	aui
	
	frame
);

=head2 new

=cut

sub new {
	my ( $class, $parent, $auiManager ) = @_;
	
	my $this = $class->SUPER::new( $parent, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxTB_FLAT | wxTB_DOCKABLE  );
	
	$this->{frame} = $parent;
	$this->{aui}   = $auiManager;
	
	# TODO feature Request to implement this
	# $this->AddStretchableSpace;
	my $back = $this->AddTool( wxID_ANY, 'Abbrechen', Wx::ArtProvider::GetBitmap( wxART_GO_BACK ) );
	$this->AddSeparator;
	my $save = $this->AddTool( wxID_ANY, 'Speichern', Wx::ArtProvider::GetBitmap( wxART_FILE_SAVE ) );
	
	Wx::Event::EVT_TOOL( $parent, $back->GetId, \&OnBack );
	Wx::Event::EVT_TOOL( $parent, $save->GetId, \&OnSave );
	
	$this->Realize;
	
	return $this;
}

=head2 editMode( set )

=cut

sub editMode {
	my $this = shift;
	
	my $ret = $this->SUPER::editMode( @_ );
	
	$this->show( $ret );
}

=head1 Scring::Wx::Frame Methoden

=head2 OnBack

=cut

sub OnBack {
	my $this = shift;
	
	# TODO Video auf Änderungen überprüfen
	
	$this->editMode( 0 );
}

=head2 OnSave

=cut

sub OnSave {
	my $this = shift;
	
	
}


1;