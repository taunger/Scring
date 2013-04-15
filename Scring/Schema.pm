package Scring::Schema;

=head1 NAME

Scring::Schema

=head1 DESCRIPTION


=head1 USAGE

=cut

use 5.16.0;
use warnings;

use Scring::Util;

use parent qw( DBIx::Class::Schema );

our $VERSION = '1'; # nur Ganzzahlen!

__PACKAGE__->load_namespaces();

=head2 dbVersion

=cut

sub dbVersion {
	my $this = shift;
	
	$logger->trace( '---' );
	
	return $this->{dbVersion} if exists $this->{dbVersion};
	
	eval {
		# check Schema Version
		$this->{dbVersion} = $this->storage->dbh_do( 
			sub {
				my ( $storage, $dbh, @cols ) = @_;
				
				return $dbh->selectrow_arrayref( 
					'select max( version ) from dbix_class_deploymenthandler_versions' 
				)->[0];
			}
		)
		
	} or do {

		# this means implicit: nothing is installed
		if ( $@ =~ /no such table: dbix_class_deploymenthandler_versions/ ) {
			$this->{dbVersion} = 0;
		} 
		
		# die, if its something unesxpected
		else {
		 	die $@;
		}
	};
	
	return $this->{dbVersion};
}

=head2 handleDeploy

=cut

sub handleDeploy {
	my $this = shift;
	
	my $dbVersion = $this->dbVersion;
	
	$logger->debug( "Datenbankversion: $dbVersion, Schemaversion: $VERSION" );
	
	return 'ok' if $dbVersion == $VERSION;
	
	return $this->install if $dbVersion == 0;
	return $this->upgrade if $dbVersion < $VERSION;
		
	# else
	$logger->logexit( "Datenbankversion( $dbVersion ) größer als Schemaversion( $VERSION ) - Programm nicht aktuell?" );
	
	1;	
}

=head2 install

=cut

sub install {
	my $this = shift;
	
	require DBIx::Class::DeploymentHandler;
	my $dh = DBIx::Class::DeploymentHandler->new(
		schema          => $this,
		databases       => [ 'SQLite', 'Oracle', 'PostgreSQL', 'POD' ],
		force_overwrite => 1,
	);
	
	$dh->prepare_install;
	
	$dh->install;
	
	$this->generateSchemaGraph;
	
	$logger->info( "Schemaversion $VERSION installiert" );
	
	1;
}

=head2 upgrade

=cut

sub upgrade {
	my $this = shift;
	
	# TODO codeduplette, extrahieren und in config
	require DBIx::Class::DeploymentHandler;
	my $dh = DBIx::Class::DeploymentHandler->new(
		schema          => $this,
		databases       => [ 'SQLite', 'Oracle', 'PostgreSQL', 'POD' ],
		force_overwrite => 1,
	);
	
	$dh->prepare_deploy;
	
	$dh->prepare_upgrade( { from_version => $this->dbVersion, to_version => $VERSION } );
	
	$dh->upgrade;
	
	$this->generateSchemaGraph;
	
	$logger->info( 'Schema von Version ' . $this->dbVersion . "auf $VERSION geupgradet" );
	
	1;
}

=head2 generateSchemaGraph

=cut

# TODO die anderen coolen Producer-Module ansehen
# eventuell eine GUI-Option einfügen

sub generateSchemaGraph {
	my $this = shift;
	
	$logger->trace( '---' );
	
	# http://babyl.dyndns.org/techblog/entry/dbix-class-deploymenthandler-rocks
	# und SQL::Translator::Producer::Diagram 
	my $trans = SQL::Translator->new(
		parser        => 'SQL::Translator::Parser::DBIx::Class',
		parser_args   => { dbic_schema => $this },
		producer      => 'Diagram',
		producer_args => {
			out_file         => 'sql/diagram-v' . $VERSION . '.png',
			font_size        => 'large',
			show_constraints => 1,
			show_datatypes   => 1,
			show_sizes       => 1,
			show_fk_only     => 0,
		} 
	);

	$trans->translate;
	
	1;
}

1;