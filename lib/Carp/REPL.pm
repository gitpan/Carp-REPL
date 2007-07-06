package Carp::REPL;
use strict;
use warnings;
use PadWalker qw(peek_my peek_our);
use Devel::REPL;

# so the LexEnvCarp plugin can see what the current environment looks like
# it's a dirty hack but it will suffice for 0.01 :)
our %environment;

# in which package did the explosion occur?
our $package;

sub import
{
    $SIG{__DIE__} = \&repl;
}

=head1 NAME

Carp::REPL - read-eval-print-loop on die

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

The intended way to use this module is through the command line.

    perl tps-report.pl
        Can't call method "cover_sheet" without a package or object reference at tps-report.pl line 6019.

    perl -MCarp::REPL tps-report.pl
        Can't call method "cover_sheet" without a package or object reference at tps-report.pl line 6019.

        $ ($form, $subform)
        "27B/6" Report::TPS::Subreport=HASH(0x86da61c)

=head1 FUNCTIONS

=head2 repl

This module's interface consists of exactly one function: repl. This is
provided so you may install your own $SIG{__DIE__} handler if you have no
alternatives.

It takes the same arguments as die, and returns no useful value.

=cut

sub repl
{
    print @_, "\n"; # tell the user what blew up
    # TODO stacktrace

    # capture globals then lexicals
    %environment = ( %{peek_our(1)}, %{peek_my(1)} );
    $package = caller(1);
    $package = 'main' if !defined($package);

    _canonicalize_environment();

    my $repl = Devel::REPL->new;
    $repl->load_plugin('LexEnvCarp');
    $repl->run;
}

# PadWalker aggressively returns references to everything
# so we try to produce the correct values for each variable

sub _canonicalize_environment
{
    for my $v (values %environment)
    {
        if (ref($v) eq 'SCALAR' || ref($v) eq 'REF')
        {
            $v = $$v;
        }
    }
}

=head1 AUTHOR

Shawn M Moore, C<< <sartak at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-carp-repl at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Carp-REPL>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Carp::REPL

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Carp-REPL>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Carp-REPL>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Carp-REPL>

=item * Search CPAN

L<http://search.cpan.org/dist/Carp-REPL>

=back

=head1 ACKNOWLEDGEMENTS

Thanks to Nelson Elhage and Jesse Vincent for the idea.

=head1 COPYRIGHT & LICENSE

Copyright 2007 Shawn M Moore, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Carp::REPL
