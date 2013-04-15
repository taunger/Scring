package Scring::Wx::Widget::LCBase;

=head1 NAME

Scring::Wx::Widget::LCBase

=head1 DESCRIPTION

Rein virtuelle Klassea als Basis f¸r die
Reviews, (Video)Speicherorte und Links ListViews

=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx qw(  wxID_ANY wxEXPAND wxALL wxVERTICAL wxDefaultPosition wxDefaultSize wxTE_READONLY wxTE_MULTILINE wxLIST_FORMAT_LEFT wxLC_SINGLE_SEL wxLC_REPORT );
use Wx::Event;

use Scring::Util;

use parent -norequire => qw( Wx::ListView );

=head2 new

=cut

sub new {
	my $class = shift;
	
	my $this = $class->SUPER::new( @_ );
	
	$this->{proportion} = [];
	$this->{proportionSum} = 0;
	$this->{currentColumn} = 0;
	
	Wx::Event::EVT_SIZE( $this, \&OnSize );
	
	return $this;	
}

=head2 AppendColumn( heading, format, proportion )

Die Methodensignatur ‰hnelt sich zum groﬂteil der von
Wx::ListView::InsertColumn, nur width wurde durch proportion
ersetzt und verh‰lt sich analog zur Proportion in einem Sizer.

Achtung! Entfernen von Columns momentan nicht sauber supported

=cut

sub AppendColumn {
	my ( $this, $heading, $format, $proportion ) = @_;
	
	$logger->trace( '---' );
	
	$this->{proportion}[ $this->{currentColumn} ] = $proportion // 1;
	$this->{proportionSum} += $proportion // 1;
	
	return $this->SUPER::InsertColumn( $this->{currentColumn}++, $heading, $format // wxLIST_FORMAT_LEFT );
}

=head2 ClearAll

=cut

sub ClearAll {
	my $this = shift;
	
	$this->{proportion} = [];
	$this->{proportionSum} = 0;
	$this->{currentColumn} = 0;
	
	$this->SUPER::ClearAll;
}

=head2 OnSize

=cut

sub OnSize {
	my ( $this, $event ) = @_;
	
	$logger->trace( '---' );
	
	# GetSize ist in diesem Fall falsch,
	# da auch eventuelle Scrollbars mit bedacht werden
	# Das ist mit GetClientSize nicht der Fall
	my $width = $this->GetClientSize->GetWidth;

	# Jede Spalte wird gem‰ﬂ ihrer proportion berechnet
	# Spaltenbreite[i] = LC-Breite / Summe der Proportionsangaben / Proporiton[i]
	for ( my $col = 0; $col < $this->{currentColumn}; $col++ ) {
		 
		$this->SetColumnWidth( $col, int( $width / $this->{proportionSum} * $this->{proportion}[ $col ] ) );
		
	}
	
	1;
}

=head2 SelectItemAtPos

=cut

sub SelectItemAtPos {
	my ( $this, $point ) = @_;
	
	my $yClient = $point->y;
	
	$logger->trace( "Click Client y: $yClient" );
	
	# Mausklick propagiert kein Focus!
	$this->SetFocus;
	
	# normalerweise kˆnnte das mit einen einfachen
	#     $this->FindItemAtPos( -1, $point, 1 );
	# abgedeckt werden. Das funktioniert aber nicht... (gibt immer -1 (not found))
	
	# Code abgeleitet von: /generic/listctrl.cpp - FindItem (pos)
	# https://github.com/wxWidgets/wxWidgets/blob/master/src/generic/listctrl.cpp

	# wenn Items existieren, brauchen wir eine Selectionslogik
	# wir schauen, ob es ein oberstes Item gibt
	# und holen uns seine Hˆhe
	if ( defined $this->GetItemRect( $this->GetTopItem ) ) {
		#my $itemHeight = $this->GetItemRect( $this->GetTopItem )->GetY;
		
		# SMELL: Achtung ItemRect gibt nicht die Itemhˆhe zur¸ck
		# hardcodiert 24 kˆnnte Probleme machen!!
		my $itemHeight = 24;
				
		# wir rechnen die Zeile des obersten Items plus die Berechnete
		# Zeilenanzahl - zb Click auf 50 => 50 / 26 = 1 Rest ...
		my $i = $this->GetTopItem + int( $yClient / $itemHeight )- 1; # -1 wg. array 0
		
		$logger->debug( "Ausgew‰hltes Item: $i" );
		
		# Wir ¸berpr¸fen ob an dieser Stelle ein Icon existiert
		# und wenn ja, selektieren wir
		if ( defined $this->GetItemRect( $i ) ) {
			$this->Select( $i, 1 );
			return 1;
		}
	}
	

	return 0;	 
}

=head2 RemoveSelected

=cut

sub RemoveSelected {
	my $this = shift;
	
	$logger->trace( '---' );
	
	$this->DeleteItem( $this->GetFirstSelected );
	
	1;
}

1;