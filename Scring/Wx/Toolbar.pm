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

use parent -norequire => qw( Wx::ToolBar );

use Object::Tiny qw( 
	frame
);

=head2 new

=cut

sub new {
	my ( $class, $parent ) = @_;
	
	my $this = $class->SUPER::new( $parent, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxTB_FLAT | wxTB_DOCKABLE  );
	
	# TODO feature Request to implement this
	#  $this->AddStretchableSpace;
	my $back = $this->AddTool( wxID_ANY, 'Abbrechen', Wx::ArtProvider::GetBitmap( wxART_GO_BACK ) );
	$this->AddSeparator;
	my $save = $this->AddTool( wxID_ANY, 'Speichern', Wx::ArtProvider::GetBitmap( wxART_FILE_SAVE ) );
	
#	Wx::Event::EVT_TOOL( $this, $toolBack->GetId, \&OnToolBack );
#	Wx::Event::EVT_TOOL( $this, $toolSave->GetId, \&OnToolSave );
	
	$this->Realize;
		
	return $this;
}


1;