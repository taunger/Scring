package Scring::Util;

=head1 NAME

Scring::Util

=head1 DESCRIPTION



=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Wx qw( wxBITMAP_TYPE_ICO );
use Wx::DND;
use FindBin;
use File::Spec;
use Log::Log4perl;
use Config::Source;

our $config;
our $schema;
our $logger;

sub import {
	my $caller = caller;

	# typeglob, zuweisung einer Scalar-Referenz
	# nur der Referenzierte Teil(Scalar) wird dem
	# namespace zugewiesen und nicht der gesamte glob
	no strict 'refs';
	*{ $caller . '::config' } = \$config;
	*{ $caller . '::schema' } = \$schema;
	*{ $caller . '::logger' } = \Log::Log4perl->get_logger( $caller );
	# Die letzte Zeile ist die Funktionalität von 
	# Log::Log4perl Kategorieweise zu loggen, umgesetzt
	# für jede spezifische Klasse - genial! :)
}

=head2 initialize

=cut

sub initialize {

	# als erstes die Default Config initialisieren
	$config = Config::Source->new;
	$config->add_source( defaultConfig() );

	# Scring ist eine portable Anwendung
	# Nutzerdatenverzeichnis immer in Abhängikeit vom Script
	# daher sollte auch ein einfaches mkdir reichen
	if ( not -d $config->get( 'app.dir.userdata' ) ) {
		mkdir $config->get( 'app.dir.userdata' ) or die $!; 
	}
	
	# jetzt können wir schauen, ob eine Nutzerkonfiguration 
	# da ist und diese laden
	# sollte die Umgebungsvariable DEVEL gesetzt sein, wird keine
	# Nutzerkonfiguration geladen
	# TODO dokumentiere Umgebungsvariable in Scring.pl
	if ( not $ENV{DEVEL} and -f $config->get( 'app.file.config' ) ) {
		$config->add_source( $config->get( 'app.file.config' ) );
	}
	
	# die $logfile-variable wird durch einen Pfad ersetzt, 
	# der ins Nutzerverzeichnis zeigt
	my $logger_config = $config->get( 'logger.config' );
	$logger_config =~ s!\$logfile!$config->get( 'app.file.defaultlog' )!eg;

	# jetzt sollten wir alles haben um 
	# den logger zu initialisieren	
	Log::Log4perl::init( \$logger_config );
	$logger = Log::Log4perl->get_logger( __PACKAGE__ );
	
	# work around Wx locale Bug
	# https://rt.cpan.org/Ticket/Display.html?id=83110
	if ( $config->get( 'bug.wxlocale' ) ) {
		require POSIX;
		POSIX::setlocale( POSIX::LC_NUMERIC(), 'C' );
		
		$logger->debug( 'Workaround for LC_NUMERIC locale bug in Wx used' );
	}
	
	1;
}

=head2 initializeSchema

=cut

sub initializeSchema {
	
	# FIX des bugs: https://rt.cpan.org/Public/Bug/Display.html?id=80073
	# Das Modul DBIx::Class:TimeStamp lädt DateTime dieses lädt Math::Round
	# Der Fehler tritt in Erscheinung, sobald ein Thread gestartet wird.
	# Fehler tritt erst ab perl 5.16 auf
	require AutoLoader;
	
	# Backend laden
	$logger->trace( 'begin load Schema' );
	require Scring::Schema;
	$logger->debug( 'Schema loaded - Version: ' . $Scring::Schema::VERSION );
	
	# Verbinde
	$schema = Scring::Schema->connect( 
		$config->get( 'app.db.dataSource' ), '', '', 
		{
			PrintError       => 0,
			RaiseError       => 1,
			sqlite_unicode   => 1,
			on_connect_call  => 'use_foreign_keys', # siehe DBIx::Class::Storage::DBI::SQLite 
		} 
	);
	
	# TODO check database vs schema version
	# evtl hat der deploymenthandler eine funktion für
	$logger->trace( 'connection initialized' );
	
	# Statement tracing einschalten	- nur bei debug
	# Achtung! könnte sich mit Log4perl beissen
	if ( $logger->is_debug ) {
		
		require Scring::Util::SchemaLogger;
		$schema->storage->debugobj( Scring::Util::SchemaLogger->new );
		
		$schema->storage->debug( 1 );
	}
	
	# aktualisiere Schema, wenn nötig
	$schema->handleDeploy;
		
	1;
}

=head2 cleanup

=cut

sub cleanup {

	$logger->trace( '---' );

	# Speichere Nutzerfile, 
	# ignoriere Dabei alle ^app Strings
	$config->save_file( $config->get( 'app.file.config' ), exclude => [ qr/^app/ ] );	
	
	1;
}

=head2 getIcon

=cut

sub getIcon {
	my $this = shift;
	
	$logger->trace( '---' );
	
	state $icon;
	return $icon if defined $icon;
	
	my $icon_path = $config->get( 'app.file.icon' );
	
	$logger->debug( "Icon-Path: $icon_path" );
	
	if ( -f $icon_path ) {
		# if icon path is ok use this
		$icon = Wx::Icon->new( $icon_path, wxBITMAP_TYPE_ICO );
	} else {
		# else warn and use WxPerl Icon
		$logger->debug( "Can't load Icon: $icon_path, using wxPerl icon instead!" );
		$icon = Wx::GetWxPerlIcon( );
	}
	
	return $icon;
}

=head2 getClipboardText

=cut

sub getClipboardText {

	# Zwischenablage öffnen
	if ( not Wx::wxTheClipboard->Open ) {
		$logger->error( 'Zwischenablage konnte nicht geöffnet werden!' );
		return undef;
	}
	
	# Textdata Objekt erstellen
	my $txdata = Wx::TextDataObject->new;
	
	# Überprüfen, ob Text in der Zwischenablage
	if ( Wx::wxTheClipboard->IsSupported( Wx::wxDF_TEXT ) ) {
			
		# Daten in Object laden
		if ( not Wx::wxTheClipboard->GetData( $txdata ) ) {
			$logger->error( 'Konnte keine Daten aus der Zwischenablage holen!' );
			return undef;
		}
	}
	
	# Zwischenablage wieder schliesen
	Wx::wxTheClipboard->Close;
	
	return $txdata->GetText;
}

=head2 defaultConfig

=cut

sub defaultConfig { 

	return
{
	'app.name'     => 'Scring',
	'app.version'  => $Scring::VERSION,
	'app.dir.userdata'    => File::Spec->catdir( $FindBin::Bin, 'userdata' ),
	'app.file.config'     => File::Spec->catfile( $FindBin::Bin, 'userdata', $ENV{USERNAME} . '.config' ),
	'app.file.defaultlog' => File::Spec->catfile( $FindBin::Bin, 'userdata', $ENV{USERNAME} . '.log' ),
	'app.file.icon'       => File::Spec->catfile( $FindBin::Bin, 'ressource', 'Scring.ico' ),
	'app.db.dataSource'   => 'dbi:SQLite:dbname=' . File::Spec->catfile( $FindBin::Bin, 'userdata', 'Scring.db' ),
	
	'bug.wxlocale' => 0,
		
	'wx.perspective.user'    => [],
	'wx.perspective.current' => undef,
	
	'wx.frame.size'                   => [ 1400, 700 ],
	'wx.dialog.EditSpeicherort.size'  => [ 600, 250 ],
	'wx.dialog.EditLink.size'  => [ 500, 180 ],
	'wx.dialog.ExtendedSearchEditor.size' => [ 500, 500 ],
	
	'wx.defaultFontPointSize'    => undef,
	'wx.panel.base.textctrlSize' => [ -1, 22 ],
	
	'user.lastTitle'   => '',
	'user.lastMiscTab' => 0,
	'user.editSpeicherort.lastStandort' => '',
	
	'logger.config' => <<'LOGGER_CONFIG',
log4perl.logger = TRACE, screen, wx

log4perl.appender.screen                          = Log::Log4perl::Appender::Screen
log4perl.appender.screen.stderr                   = 0
log4perl.appender.screen.layout                   = Log::Log4perl::Layout::PatternLayout
log4perl.appender.screen.layout.ConversionPattern = [%p] %d{HH:mm:ss,SSS} <%-40M %3L> :  %m%n

log4perl.appender.file                          = Log::Log4perl::Appender::File
log4perl.appender.file.filename                 = $logfile
log4perl.appender.file.mode                     = write
log4perl.appender.file.layout                   = Log::Log4perl::Layout::PatternLayout
log4perl.appender.file.layout.ConversionPattern = [%p] %d{HH:mm:ss,SSS} <%-40M %3L> :  %m%n

log4perl.appender.wx                          = Log::Log4perl::Appender::Wx::MessageBox
log4perl.appender.wx.Filter                   = wx_level_range
log4perl.appender.wx.layout                   = Log::Log4perl::Layout::PatternLayout
log4perl.appender.wx.layout.ConversionPattern = %M %L:%n%n%m%n

log4perl.filter.wx_level_range               = Log::Log4perl::Filter::LevelRange
log4perl.filter.wx_level_range.LevelMin      = INFO
log4perl.filter.wx_level_range.AcceptOnMatch = true
LOGGER_CONFIG

	'extendedSearch.querys' => { },
} }

1;