package Scring::Wx::Widget::TextCtrlGenre;

=head1 NAME

Scring::Wx::Widget::TextCtrlGenre

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use List::MoreUtils qw( any none );

use Wx qw( wxID_OK );
use Wx::Event;

use Scring::Util;

use parent -norequire => qw( Wx::TextCtrl );

=head2 new

=cut

sub new {
	my $class = shift;
	
	$logger->trace( '---' );
	
	my $this = $class->SUPER::new( @_ );
	
	Wx::Event::EVT_LEFT_DCLICK( $this, \&OnDClick );
	
	$this->generateGenreMap;
	
	return $this;	
}

=head2 generateGenreMap

=cut

sub generateGenreMap {
	my $this = shift;
	
	$logger->trace( '---' );

	for ( $schema->resultset( 'Genre' )->all ) {
		$this->{genreMap}{ $_->Bezeichnung } = $_->id;
	}
	
	1;
}

=head2 storeTo( resultset  )

=cut

sub storeTo {
	my ( $this, $rs ) = @_;
	
	my @newGenre = $this->genreFromString( $this->GetValue );
	my @genre = map { $_->Bezeichnung } $rs->Genre;

	# l�sche �berfl�ssige
	for my $g ( @genre ) {
		$rs->delete_related( 'VideoGenre', { Genre => $this->{genreMap}{ $g } } )
			if none { $g eq $_ } @newGenre;
	}
	
	# f�ge neue hinzu
	for my $g ( @newGenre ) {
		$rs->create_related( 'VideoGenre', { Genre => $this->{genreMap}{ $g } } )
			if none { $g eq $_} @genre;
	}
	
	1;
}

=head2 loadFrom( resultset )

=cut

sub loadFrom {
	my ( $this, $rs ) = @_;
	
	$this->ChangeValue( $this->genreToString( $rs->Genre ) );
}

=head2 genreToString

=cut

sub genreToString {
	my $this = shift;
	
	return join ';', map { $_->Bezeichnung } @_;
}

=head2 genreFromString

=cut

sub genreFromString {
	my ( $this, $string ) = @_;
	
	return split /;/, $string;
}


=head2 OnDClick

=cut

sub OnDClick {
	my ( $this, $event ) = @_;
	
	$logger->trace( '---' );
	
	return if not $this->GetParent->editMode;
	
	# Wir gehen alle Genre duch, und vergleichen
	# sie mit aktuellen
	# Wird einer gefunden, so wird der index gespeichert
	# und unten bei SetSelection verwendet
	my @currentGenre = $this->genreFromString( $this->GetValue );
	my ( @allGenre, @seen );
	my $i = 0;
	
	for my $genre ( sort keys $this->{genreMap} ) {
		push @seen, $i if any { $genre eq $_ } @currentGenre;
		$i++;
		push @allGenre, $genre;
	}
	
	my $dlg = Wx::MultiChoiceDialog->new( $this, '', 'Genre ausw�hlen', \@allGenre );
	$dlg->SetSelections( @seen );
	$dlg->SetSize( $config->get( 'wx.dialog.TextCtrlGenre.MultiChoiceDialog.size' ) );
	
	if ( $dlg->ShowModal == wxID_OK ) {
		my @sel = $dlg->GetSelections;
		my @newGenre;
		for ( @sel ) {
			push @newGenre, $allGenre[ $_ ];
		}
		$this->ChangeValue( join ';', @newGenre );
	}
	
	# TODO size zur�ckspeichern?
	$dlg->Destroy;
	
}

1;