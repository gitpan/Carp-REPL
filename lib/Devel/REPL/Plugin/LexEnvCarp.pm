package Devel::REPL::Plugin::LexEnvCarp;

use Moose::Role;
use namespace::clean -except => [ 'meta' ];
use Lexical::Persistence;

has 'lexical_environment' => (
  isa => 'Lexical::Persistence',
  is => 'rw',
  required => 1,
  lazy => 1,
  default => sub { Lexical::Persistence->new }
);

around 'mangle_line' => sub {
  my $orig = shift;
  my ($self, @rest) = @_;
  my $line = $self->$orig(@rest);
  my $lp = $self->lexical_environment;

  # exactly the same as LexEnv except for this call
  $lp->set_context(
    _ => {
        %Carp::REPL::environment, # XXX gross!
        %{$lp->get_context('_')},
    });

  # Collate my declarations for all LP context vars then add '';
  # so an empty statement doesn't return anything (with a no warnings
  # to prevent "Useless use ..." warning)
  return "package $Carp::REPL::package;\n"
         .join('', map { "my $_;\n" } keys %{$lp->get_context('_')})
         .qq{{ no warnings 'void'; ''; }\n}.$line;
};

around 'execute' => sub {
  my $orig = shift;
  my ($self, $to_exec, @rest) = @_;
  my $wrapped = $self->lexical_environment->wrap($to_exec);
  return $self->$orig($wrapped, @rest);
};

=head1 NAME

Devel::REPL::Plugin::LexEnvCarp - Devel::REPL plugin for Carp::REPL

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

This implements exactly the same thing as the Devel::REPL::Plugin::LexEnv
module except the lexical environment exposed by Carp::REPL is mixed in.

=head1 AUTHOR

Shawn M Moore, C<< <sartak at gmail.com> >>

=head1 BUGS

Please report any bugs to a medium given by Carp::REPL.

=head1 COPYRIGHT & LICENSE

Copyright 2007 Shawn M Moore, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Devel::REPL::Plugin::LexEnvCarp
