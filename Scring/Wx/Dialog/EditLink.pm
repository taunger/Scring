package Scring::Wx::Dialog::EditLink;

=head1 NAME

Scring::Wx::Dialog::EditLink

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx qw( wxID_ANY wxDefaultPosition wxDEFAULT_DIALOG_STYLE wxRESIZE_BORDER wxDefaultSize wxCB_READONLY wxVERTICAL wxHORIZONTAL wxOK wxCANCEL wxRIGHT 
		   wxBOTTOM wxEXPAND wxALL wxID_OK );
use Wx::Event;

use Scring::Util;

use parent -norequire => qw( Wx::Dialog );

=head2 new

=cut

sub new {
	my ( $class, $parent ) = @_;
	
	my $this = $class->SUPER::new( 
		$parent, wxID_ANY, 'Link bearbeiten',
		wxDefaultPosition,
		$config->get( 'wx.dialog.EditLink.size' ),
		wxDEFAULT_DIALOG_STYLE | wxRESIZE_BORDER
	);
	
	$this->prepareGUI;
	
	# Combobox füllen
	$this->{W}{CB_Bezeichnung}->Append( [ 
		$schema->resultset( 'LinkBezeichnung' )
				->search( undef, { order_by => 'Bezeichnung' } )
				->get_column( 'Bezeichnung' )
				->all
	] );
	
	$this->{W}{ED_url}->SetFocus;
	
	return $this;	
}

=head2 prepareGUI

=cut

sub prepareGUI {
	my $this = shift;
	
	my $W = $this->{W} = {};
	my $S = $this->{S} = {};
	my $P = $this;
	
	$W->{ST_Bezeichnung}	= Wx::StaticText->new( $P, wxID_ANY, 'Bezeichnung:'		);	
	$W->{CB_Bezeichnung}	= Wx::ComboBox	->new( $P, wxID_ANY, '', wxDefaultPosition, wxDefaultSize, [], wxCB_READONLY );
	$W->{ST_url}			= Wx::StaticText->new( $P, wxID_ANY, 'URL:'				);
	$W->{ED_url}			= Wx::TextCtrl	->new( $P, wxID_ANY, ''					);
	$W->{BTN_Clipboard}	    = Wx::Button	->new( $P, wxID_ANY, 'Zwischenablage'	);
	
	$S->{Main} = Wx::BoxSizer->new( wxVERTICAL );
	$S->{Rand} = Wx::BoxSizer->new( wxVERTICAL );
	
	$S->{Bezeichnung}	= Wx::BoxSizer->new( wxHORIZONTAL );
	$S->{url}			= Wx::BoxSizer->new( wxHORIZONTAL );
	
	$S->{STDButton}		= $P->CreateButtonSizer( wxOK | wxCANCEL );
	$S->{Bottom}		= Wx::BoxSizer->new( wxHORIZONTAL );
	
	# Sizer-Layout
	$S->{Bezeichnung}->Add( $W->{ST_Bezeichnung}, 1, wxRIGHT, 5 );
	$S->{Bezeichnung}->Add( $W->{CB_Bezeichnung}, 3 );
	$S->{url}->Add( $W->{ST_url}, 1, wxRIGHT, 5 );
	$S->{url}->Add( $W->{ED_url}, 3 );
	$S->{Bottom}->Add( $W->{BTN_Clipboard}, 0 );
	$S->{Bottom}->Add( $S->{STDButton}, 1, );
	
	$S->{Rand}->Add( $S->{Bezeichnung}, 0, wxEXPAND | wxBOTTOM, 10 );
	$S->{Rand}->Add( $S->{url}, 0, wxEXPAND | wxBOTTOM, 10 );
	$S->{Rand}->Add( $S->{Bottom}, 0, wxEXPAND );
	
	
	$S->{Main}->Add( $S->{Rand}, 1, wxEXPAND | wxALL, 10 );
	
	$P->SetSizer( $S->{Main} );
	$P->SetAutoLayout( 1 );
	
	Wx::Event::EVT_BUTTON( $this, $W->{BTN_Clipboard}, \&OnClickBTN_Clipboard );
	Wx::Event::EVT_LEFT_DOWN( $W->{ST_url}, sub { $this->OnLeftClickST_url( @_ ) } );
}

=head2 Bezeichnung( Bezeichnung? )

=cut

sub Bezeichnung {
	my ( $this, $Bezeichnung ) = @_;
	
	return $this->{W}{CB_Bezeichnung}->GetValue if not defined $Bezeichnung;
	
	$this->{W}{CB_Bezeichnung}->SetStringSelection( $Bezeichnung );
	
	# Rückgabewert funktioniert irgendwie nicht
#	if ( not $this->{W}{CB_Bezeichnung}->SetStringSelection( $Bezeichnung ) ) {
#		$logger->error( "Bezeichnung $Bezeichnung nicht in der CB gefunden" );
#		$this->{W}{CB_Bezeichnung}->SetSelection( 0 ); 
#	}
	
	return $Bezeichnung;
}

=head2 url( url? )

=cut

sub url {
	my ( $this, $url ) = @_;
	
	return $this->{W}{ED_url}->GetValue if not defined $url;
	
	$this->{W}{ED_url}->ChangeValue( $url );
	
	return $url
}

=head2 OnClickBTN_Clipboard

=cut

sub OnClickBTN_Clipboard {
	my ( $this, $event ) = @_;
	
	$this->LoadFromClipboard;
	
	1;
}

=head2 LoadFromClipboard

=cut

sub LoadFromClipboard {
	my $this = shift;
	
	$logger->trace( '---' );
	
	my $text = Scring::Util::->getClipboardText;
	
	$logger->debug( "Clipboard Text: $text" );
	
	for my $bezeichnung ( $this->{W}{CB_Bezeichnung}->GetStrings ) {
		if ( $text =~ /$bezeichnung/i ) {
			$this->{W}{CB_Bezeichnung}->SetStringSelection( $bezeichnung );
			
			# TODO, nicht sauber, da hart gecoded
			if ( $bezeichnung eq 'Anisearch' ) {
				$text =~ s!http://!http://www.!g;
				$text =~ s!index\.php!!g;
			}
		
			last;	
		}		
	}
	
	
	# clipboard text setzten
	$this->{W}{ED_url}->SetValue( $text );
}

=head2 OnLeftClickST_url

=cut

sub OnLeftClickST_url {
	my $this = shift;
	
	Wx::LaunchDefaultBrowser( $this->{W}{ED_url}->GetValue )
			or $logger->error( 'Standardbrowser konnte nicht gestartet werden' );
}

1;