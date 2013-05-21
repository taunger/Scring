package Scring::Wx::Perspective;

=head1 NAME

Scring::Wx::Perspective

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx;

use Scring::Util;

use Object::Tiny qw( id name );
use Object::Tiny::RW qw( auiPaneInfo frameSize maximized framePosition );

=head2 new

=cut

sub new {
	my ( $class, %p ) = @_;
	
	my $this = bless {}, $class;
	
	$this->{id}            = $p{id};
	$this->{name}          = $p{name};
	$this->{auiPaneInfo}   = $p{auiPaneInfo};
	$this->{frameSize}     = $p{frameSize} // [ 1, 1 ];
	$this->{framePosition} = $p{framePosition} // [ 1, 1 ];
	$this->{maximized}     = $p{maximized} // 0;
	
	return $this; 
}

=head2 generateId

Generiert eine neue, einzigartige Wx-ID für die perspektive.
Aber nur, wenn noch keine ID vorhanden!

Die ID wird für die Dauer der Programmsession nicht nochmal vergeben.

=cut

sub generateId {
	my $this = shift;
	
	$this->{id} //= Wx::NewId();
	
	return $this;
}

=head2 deserialize

Factory method

=cut

sub deserialize {
	my ( $class, $hashRef ) = @_;
	
	$logger->trace( '---' );
	
	return __PACKAGE__->new( %$hashRef )->generateId;
}

=head2 serialize

=cut

sub serialize {
	my $this = shift;
	
	$logger->trace( '---' );
	
	my $retHash;
	
	for ( qw( name auiPaneInfo frameSize maximized framePosition ) ) {
		
		$retHash->{ $_ } = $this->{ $_ };
		
	}
	
	return $retHash;
}

=head2 defaultPaneInfoFor( paneName )

Utility Class Methdod

=cut

sub defaultPaneInfoFor {
	my ( $class, $paneName ) = @_;
	
	$logger->trace( $paneName );
	
	if ( $paneName eq 'base' ) {
		return Wx::AuiPaneInfo->new
				->Name( 'base' )
				->Caption( 'Base' )
				->CaptionVisible( 0 )
				->CenterPane
				->PaneBorder( 0 )
	}
	
	if ( $paneName eq 'videoList' ) {
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
	
	if ( $paneName eq 'cover' ) {
		return Wx::AuiPaneInfo->new
			->Name( 'cover' )
			->Caption( 'Cover' )
			->CaptionVisible( 0 )
			->Right
			->CloseButton( 0 )
			->MinSize( Wx::wxSIZE( 320, 420 ) )
			->PaneBorder( 0 )
			->Layer( 1 )
	}
	
	if ( $paneName eq 'misc' ) {
		return Wx::AuiPaneInfo->new
			->Name( 'misc' )
			->Caption( 'Misc' )
			->CaptionVisible( 0 )
			->Right
			->CloseButton( 0 )
			->MinSize( Wx::wxSIZE( 320, -1 ) )
			->PaneBorder( 0 )
			->Layer( 1 )
	}
	
	if ( $paneName eq 'reviewViewer' ) {
		
		# wir müssen das zentrieren nachbaue...
		# blöd
		my $displaySize = Wx::GetDisplaySize();
		
		return Wx::AuiPaneInfo->new
			->Name( 'reviewViewer' )
			->Caption( 'Review Betrachter' )
			->CaptionVisible( 1 )
			->CloseButton( 1 )
			->MinSize( Wx::wxSIZE( 550, 700 ) )
			->MinimizeButton( 1 )
			->MaximizeButton( 1 )
			->PinButton( 1 )
			->Float
			->FloatingPosition( ( $displaySize->GetWidth - 550 ) / 2, ( $displaySize->GetHeight - 700 ) / 2 )
			->Show( 0 )
	}
	
	if ( $paneName eq 'speicherorte' ) {
		return Wx::AuiPaneInfo->new
			->Name( 'speicherorte' )
			->Caption( 'Speicherorte' )
			->CaptionVisible( 1 )
			->CloseButton( 0 )
			->MinSize( Wx::wxSIZE( 400, 500 ) )
			->PaneBorder( 1 )
			->Top
			->Show( 0 )
			
	}
	
	if ( $paneName eq 'search' ) {
		return Wx::AuiPaneInfo->new
			->Name( 'search' )
			->Caption( 'Suche' )
			->CaptionVisible( 1 )
			->CloseButton( 1 )
			->MinSize( Wx::wxSIZE( 400, 150 ) )
			->PaneBorder( 1 )
			->MinimizeButton( 1 )
			->MaximizeButton( 1 )
			->PinButton( 1 )
			->Show( 0 )
			->Float
			#->FloatingPosition( ( $displaySize->GetWidth - 450 ) / 2, ( $displaySize->GetHeight - 600 ) / 2 )
	}
	
	if ( $paneName eq 'toolbar' ) {
		return Wx::AuiPaneInfo->new
			->Top
			->Name( 'toolbar' )
			->CaptionVisible( 0 )
			->Resizable( 0 )
			->Movable( 0 )
			->Gripper( 0 )
			->Show( 0 )	
	}
		

	$logger->logexit( "Keine default Pane-Information für $paneName" );
	
	1;
}


1;