use 5.16.0;
use warnings;

# TODO kommandozeilenversoin oder gar gui zum depployen

use DBIx::Class::DeploymentHandler;
use Scring::Schema;
use Scring::Util;

Scring::Util->initialize;


my $schema = Scring::Schema->connect(
	$config->get( 'db.data_source' ), '', '', 	
	{
		PrintError       => 0,
		RaiseError       => 1,
		sqlite_unicode   => 1,
		on_connect_call  => 'use_foreign_keys', 
	}  
);

my $dh = DBIx::Class::DeploymentHandler->new( 
	schema 		=> $schema,
	databases	=> [ 'SQLite', 'Oracle', 'PostgreSQL', 'POD' ],
);

$dh->prepare_install;
$dh->install;

# $dh->prepare_upgrade( {
	# from_version => 0.1,
	# to_version   => 0.2,
# } );
# $dh->upgrade;