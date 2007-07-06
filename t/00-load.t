#!perl -T

use Test::More tests => 2;

BEGIN {
	use_ok( 'Carp::REPL' );
	use_ok( 'Devel::REPL::Plugin::LexEnvCarp' );
}

diag( "Testing Carp::REPL $Carp::REPL::VERSION, Perl $], $^X" );
