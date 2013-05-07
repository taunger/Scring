package Scring::Wx::Pane::Info;

=head1 NAME

Scring::Wx::Pane::Info

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx;
use Wx::Event;

use Scring::Util;

use parent -norequire => qw( Wx::TextCtrl );

=head2 new

=cut

sub new {
	my $class = shift;
	
	$logger->trace( '---' );
	
	my $this = $class->SUPER::new( @_ );
	
	return $this;	
}

=head2 loadFrom( resultset )

=cut

sub loadFrom {
	my ( $this, $rs ) = @_;
	
	$logger->trace( '---' );
	
	$this->ChangeValue( $rs->Info );
	
	1;
}

=head2 storeTo( resultset )

=cut

sub storeTo {
	my ( $this, $rs ) = @_;
	
	# Dadurch wird ein zweites Mal die video-Tabelle beschreiben,
	# eventuell nicht optimal
	$rs->Info( $this->GetValue );
	$rs->update; 
	
	1;
}

=head2 clear

=cut

sub clear {
	my $this = shift;
	
	$this->Clear;
}

=head2 editMode

=cut

sub editMode {
	my ( $this, $set ) = @_;
	
	return $this->{editMode} if not $set;
	
	$this->SetEditable( $set );
	
	$this->{editMode} = $set;
	
	1;
}

1;