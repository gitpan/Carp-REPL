use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Carp::REPL',
    AUTHOR              => 'Shawn M Moore <sartak@gmail.com>',
    VERSION_FROM        => 'lib/Carp/REPL.pm',
    ABSTRACT_FROM       => 'lib/Carp/REPL.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'PadWalker' => 0,
        'Devel::REPL' => 0,
        'Moose' => 0,
        'Moose::Role' => 0,
        'namespace::clean' => 0,
        'Lexical::Persistence' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Carp-REPL-*' },
);
