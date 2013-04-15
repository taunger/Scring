package Scring::Util::PerspectiveManager;

=head1 NAME

Scring::Util::PerspectiveManager

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx;
use Wx::Aui;
use Scring::Util;

use Object::Tiny::RW qw( default );

=head2 new

=cut

sub new {
	my $class = shift;
	
	$logger->trace( '---' );
	
	my $this = bless {}, $class;
}

=head2 hasCurrentPerspective

=cut

sub hasCurrentPerspective {
	my $this = shift;
	
	$logger->trace( '---' );
	
	return 
		defined $config->get( 'wx.perspective.current' )
			? 1
			: 0
	;
}

=head2 currentPerspective

=cut

sub currentPerspective {
	my $this = shift;
	
	$logger->trace( '---' );
	
	return $config->get( 'wx.perspective.current' );
}

=head2 set

=cut

sub set {
	my $this = shift;
	
	
}

=head2 get

=cut

sub get {
	my $this = shift;
	
	
}

=head2 defaultPaneInfoFor( paneName )

=cut

sub defaultPaneInfoFor {
	my ( $this, $paneName ) = @_;
	
	$logger->trace( $paneName );
	
	given ( $paneName ) {
		
		when ( 'base' ) {
			return Wx::AuiPaneInfo->new
					->Name( 'base' )
					->Caption( 'Base' )
					->CaptionVisible( 0 )
					->CenterPane
					->PaneBorder( 0 )
		}
		
		when ( 'videoList' ) {
			return Wx::AuiPaneInfo->new
					->Name( 'videoList' )
					->Caption( 'Video Liste' )
					->CaptionVisible( 0 )
					->Left
					->CloseButton( 0 )
					->MinSize( Wx::wxSIZE( 360, -1 ) )
					->PaneBorder( 0 )
					->Layer( 1 )
		}
		
		when ( 'cover' ) {
			return Wx::AuiPaneInfo->new
				->Name( 'Image' )
				->Caption( 'Image' )
				->CaptionVisible( 0 )
				->Right
				->CloseButton( 0 )
				->MinSize( Wx::wxSIZE( 320, 420 ) )
				->PaneBorder( 0 )
				->Layer( 1 )
		}
		
		default {
			$logger->logexit( "Keine default Pane-Information für $paneName" )
		}
		
	}
	
	1;
}


1;