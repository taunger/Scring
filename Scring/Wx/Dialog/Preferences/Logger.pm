package Scring::Wx::Dialog::Preferences::Logger;

=head1 NAME

Scring::Wx::Dialog::Preferences::Logger

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx qw( wxID_ANY wxDefaultPosition wxDefaultSize wxTE_MULTILINE wxHSCROLL wxFONTFAMILY_MODERN wxFONTSTYLE_NORMAL wxFONTWEIGHT_NORMAL
		   wxNO_BORDER wxHL_CONTEXTMENU wxHORIZONTAL wxVERTICAL wxEXPAND wxBOTTOM wxALL wxRIGHT );

use Scring::Util;

use parent -norequire => qw( Wx::Panel );

use Object::Tiny qw( config );

=head2 new

=cut

sub new {
	my ( $class, $parent ) = @_;
	
	my $this = $class->SUPER::new( $parent );
	
	$this->initialize;
	
	return $this;
}

=head2 initialize

=cut

sub initialize {
	my $this = shift;
	
	$this->{config} = Wx::TextCtrl->new( 
		$this, wxID_ANY, '',
		wxDefaultPosition, wxDefaultSize, wxTE_MULTILINE | wxHSCROLL
	);
	
	$this->config->SetFont( 
		Wx::Font->new( 
			$this->config->GetFont->GetPointSize, 
			wxFONTFAMILY_MODERN, 
			wxFONTSTYLE_NORMAL, 
			wxFONTWEIGHT_NORMAL 
		) 
	);

	my $infoText = Wx::StaticText->new( $this, wxID_ANY, 'Infos zur Konfiguration unter:' );
	my $infoLink = Wx::HyperlinkCtrl->new( 
		$this, wxID_ANY, 'cpan Log::Log4perl', 
		'https://metacpan.org/module/Log::Log4perl', 
		wxDefaultPosition, wxDefaultSize, wxNO_BORDER | wxHL_CONTEXTMENU 
	);
	
	my $Sizer;
	$Sizer->{Info} = Wx::BoxSizer->new( wxHORIZONTAL );
	$Sizer->{Main} = Wx::BoxSizer->new( wxVERTICAL );
	$Sizer->{Rand} = Wx::BoxSizer->new( wxVERTICAL );
	
	$Sizer->{Info}->Add( $infoText, 0, wxRIGHT, 10 );
	$Sizer->{Info}->Add( $infoLink, 1 );
	$Sizer->{Rand}->Add( $Sizer->{Info}, 0, wxEXPAND | wxBOTTOM, 10 );
	$Sizer->{Rand}->Add( $this->config, 1, wxEXPAND );	
	$Sizer->{Main}->Add( $Sizer->{Rand}, 1, wxEXPAND | wxALL, 10 );
	
	$this->SetSizer( $Sizer->{Main} );	
	$this->SetAutoLayout( 1 );
	
	1;
}

=head2 load

=cut

sub load {
	my $this = shift;
	
	$this->config->ChangeValue( $config->get( 'logger.config' ) );
	
	;
}

=head2 save

=cut

sub save {
	my $this = shift;
	
	$config->set( 'logger.config' => $this->config->GetValue );
	
	1;
	
}

1;