package Scring;

=head1 NAME

Scring

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;


our $VERSION = '0.01 - 2013-01-';

use Scring::Util;
use Scring::Wx::App;

=head2 main

=cut

sub main {
	
	# initialisiere config, logger and userdata
	Scring::Util->initialize;
	
	$logger->debug( 'START LOGGING' );	
	
	# einige Daten loggen
	$logger->debug( "Process ID: $$" );
	$logger->debug( "Interpreterversion: $^V" );
	$logger->debug( "Archname: $Config::Config{archname}" );
	$logger->debug( 'Kommandozeilenargumente: ' . join ' ', @ARGV );
	$logger->debug( 'Nutzerverzeichnis: ' . $config->get( 'app.dir.userdata' ) );
	$logger->debug( 'Programmversion: ' . $config->get( 'app.version' ) );
	$logger->debug( 'Wx version: ' . Wx::wxVERSION( ) );
	$logger->debug( '$ENV{DEVEL} = ' . $ENV{DEVEL} );
	
	# Datenbank initialisieren
	Scring::Util->initializeSchema;
	
	# zeichne Gui und starte die Event Loop
	my $Scring = Scring::Wx::App->new;
	$logger->debug( 'BEGIN MAIN LOOP' );
	$Scring->MainLoop;
	$logger->debug( 'END MAIN LOOP' );
	
	# Speichere Konfiguration
	# Lösche eventuelle Temporäre Dateien
	Scring::Util->cleanup;
		
	$logger->debug( 'END LOGGING' );
	
	1;
}

1;