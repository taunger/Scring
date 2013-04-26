package Scring::Wx::Dialog::Preferences;

=head1 NAME

Scring::Wx::Dialog::Preferences

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx qw( wxID_ANY wxVERTICAL wxDEFAULT_DIALOG_STYLE wxRESIZE_BORDER wxMAXIMIZE_BOX wxDefaultPosition 
		   wxALL wxEXPAND wxBOTTOM wxOK wxCANCEL wxID_OK );
use Wx::Event;

use Scring::Util;
use Scring::Wx::Dialog::Preferences::Logger;
use Scring::Wx::Dialog::Preferences::Expert;

use parent -norequire => qw( Wx::Dialog );

use Object::Tiny qw( 
	notebook
	
	logger
	expert
);

=head2 new

=cut

sub new {
	my ( $class, $parent ) = @_;
	
	$logger->trace( '---' );
	
	my $this = $class->SUPER::new( 
		$parent, wxID_ANY, 'Einstellungen',
		wxDefaultPosition,
		$config->get( 'wx.dialog.preferences.size' ),
		wxDEFAULT_DIALOG_STYLE | wxRESIZE_BORDER | wxMAXIMIZE_BOX    
	);
	
	$this->SetIcon( Scring::Util->getIcon );
	$this->Centre;
	
	$this->initialize;
	
	$this->logger->load;
	
	return $this;
}

=head2 initialize

=cut

sub initialize {
	my $this = shift;
	
	$this->{notebook} = Wx::Treebook->new( $this, wxID_ANY );
	
	$this->{logger} = Scring::Wx::Dialog::Preferences::Logger->new( $this->notebook );
	$this->{expert} = Scring::Wx::Dialog::Preferences::Expert->new( $this->notebook );
	
	$this->notebook->AddPage( $this->logger, 'Logger' );
	$this->notebook->AddPage( $this->expert, 'Experte' );
	
	my $main = Wx::BoxSizer->new( wxVERTICAL );
	my $rand = Wx::BoxSizer->new( wxVERTICAL );
	
	$rand->Add( $this->notebook, 1, wxEXPAND | wxBOTTOM, 5 );
	$rand->Add( $this->CreateSeparatedButtonSizer( wxOK | wxCANCEL ), 0, wxEXPAND );
	$main->Add( $rand, 1, wxALL | wxEXPAND, 5 );
	
	$this->SetSizer( $main );
	$this->SetAutoLayout( 1 );
	
	Wx::Event::EVT_BUTTON( $this, wxID_OK, \&OnOk );
	
	1;
}

=head2 OnOk

=cut

sub OnOk {
	my ( $this, $event ) = @_;
	
	$this->logger->save;
	
	$logger->info( 'Damit alle Änderungen wirksam werden müssen sie die Anwendung evtl. neu starten.' );
	
	return $this->EndModal( wxID_OK );
}

1;