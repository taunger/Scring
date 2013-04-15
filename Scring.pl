package main;

use 5.16.0;
use warnings;

use Scring;

eval {
	Scring->main( );
};
if ( $@ ) {
	my $error = $@;
	require Wx;
	print STDERR $error;
	Wx::MessageBox( $error, 'Uncatched exception', Wx::wxOK() | Wx::wxICON_ERROR() );	
}

1;
