package Scring::Wx::Pane::Misc;

=head1 NAME

Scring::Wx::Pane::Info

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx qw( wxID_ANY wxEXPAND wxALL wxVERTICAL wxDefaultPosition wxDefaultSize wxTE_READONLY wxTE_MULTILINE wxLIST_FORMAT_LEFT wxLC_SINGLE_SEL wxLC_REPORT );
use Wx::AUI;

use Scring::Util;
#use Scring::Wx::Pane::Info::Reviews;
use Scring::Wx::Pane::VideoSpeicherorte;
use Scring::Wx::Pane::Info;
use Scring::Wx::Pane::Links;
use Scring::Wx::Pane::Reviews;

use parent -norequire => qw( Wx::AuiNotebook );

use Object::Tiny qw( 
	videoSpeicherorte
	info
	links
	reviews
);

=head2 new

=cut

sub new {
	my $class = shift;
	
	$logger->trace( '---' );
	
	my $this = $class->SUPER::new( @_ );
	
	# TODO das hier kann irgendwann getan werden,
	# wenn Wx diese Methoden wrappt	
	# Im ArtProvider die Gestaltung anpassen
	#my $artProvider = $this->GetArtProvider;
	
	$this->{reviews}           = Scring::Wx::Pane::Reviews->new( $this, wxID_ANY );
	$this->{videoSpeicherorte} = Scring::Wx::Pane::VideoSpeicherorte->new( $this, wxID_ANY );
	$this->{links}             = Scring::Wx::Pane::Links->new( $this, wxID_ANY );
	$this->{info}              = Scring::Wx::Pane::Info->new( $this, wxID_ANY, '', wxDefaultPosition, wxDefaultSize, wxTE_READONLY | wxTE_MULTILINE );
	
	$this->AddPage( $this->reviews          , 'Reviews' );
	$this->AddPage( $this->videoSpeicherorte, 'Speicherorte' );
	$this->AddPage( $this->links            , 'Links' );
	$this->AddPage( $this->info             , 'Info' );
	
#	Wx::Event::EVT_AUINOTEBOOK_PAGE_CHANGED( $this, $this, \&loadCurrentPage );
		
	return $this;
}


1;

__END__

=head2 loadFrom( resultset )

=cut

sub loadFrom {
	my ( $this, $rs ) = @_;

	$logger->trace( '---' );
	
	$this->{resultset} = $rs;
	
	# Die Flags, das die einzelnen
	# Seiten geladen wurden erst mal auf "false"
	$this->{loaded} = [];
	
	$this->loadCurrentPage;
	
	1;	
}

=head2 loadCurrentPage

=cut

sub loadCurrentPage {
	my $this = shift;
	
	$logger->trace( '---' );
	
	# das interessiert uns alles nicht,
	# sollte kein resultset existieren
	return if not $this->resultset;
	
	# Die einzelnen Felder werden nur jeweils
	# einmal geladen, das ist besonders
	# im editMode wichtig, da sonst der Pagewechsel
	# alles zurücksetzen würde
	# --
	# Irgendwann könnte das mal in GetCurrentPage 
	# umgewandelt werden, wenn in wxPerl implementiert
	if ( not $this->{loaded}->[ $this->GetSelection ] ) {
		
		# Info braucht keine eigene Klass
		$this->GetSelection == 3
			? $this->{Info}->ChangeValue( $this->resultset->Info )
			: $this->GetPage( $this->GetSelection )->loadFrom( $this->resultset )
		;
		
		$this->{loaded}->[ $this->GetSelection ] = 1;
	}
	
	1;
}

=head2 loadAllPages

=cut

sub loadAllPages {
	my $this = shift;
	
	for my $i ( 0 .. 2 ) {
		if ( not $this->{loaded}->[ $i ] ) {
			$this->GetPage( $i )->loadFrom( $this->resultset );
			$this->{loaded}->[ $i ] = 1;
		}
	}
	
	if ( not $this->{loaded}->[ 3 ] ) {
		$this->{Info}->ChangeValue( $this->resultset->Info );
		$this->{loaded}->[ 3 ] = 1;
	}
	
	1;
}


=head2 editMode

=cut

sub editMode {
	my ( $this, $set ) = @_;
	
	return $this->{editMode} if not defined $set;
	
	# alle Seiten laden, damit beim 
	# editieren nicht was durcheinander kommt
	$this->loadAllPages;
	
	$this->{Reviews}     ->editMode( $set );
	$this->{Speicherorte}->editMode( $set );
	$this->{Links}       ->editMode( $set );
	
	$this->{Info}->SetEditable( $set );
	
	1;
}

=head2 addSpeicherort

=cut

sub addSpeicherort {
	my ( $this, $v ) = @_;
	
	$logger->trace( '---' );
	
	# gehe sicher, dass Tab visible
	$this->SetSelection( 1 ) if $this->GetSelection != 1;
	
	$this->{Speicherorte}->add( $v );
}

1;