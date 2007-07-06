package Devel::REPL::Plugin::LexEnvCarp;

use Moose::Role;
use namespace::clean -except => [ 'meta' ];
use Lexical::Persistence;

has 'lexical_environment' => (
  isa => 'Lexical::Persistence',
  is => 'rw',
  required => 1,
  lazy => 1,
  default => sub { undef }
);

has 'frame' => (
  isa => 'Int',
  is => 'rw',
  required => 1,
  lazy => 1,
  default => sub { 0 },
);

around 'mangle_line' => sub {
  my $orig = shift;
  my ($self, @rest) = @_;
  my $line = $self->$orig(@rest);
  my $lp = $self->lexical_environment;
  my $frame_delta;
  my $frame = $self->frame;

  if (!defined($lp))
  {
    $lp = $self->lexical_environment(Lexical::Persistence->new);
    $frame_delta = 0;
  }

  if ($line =~ /^:up?$/i)
  {
    if ($frame + 1 == @Carp::REPL::environments)
    {
      return q{"You're already at the top frame."};
    }
    $frame_delta = 1;
  }
  elsif ($line =~ /^:d(?:own)?$/i)
  {
    if ($frame == 0)
    {
      return q{"You're already at the bottom frame."};
    }
    $frame_delta = -1;
  }

  if (defined($frame_delta))
  {
    $frame += $frame_delta;
    $self->frame($frame);
    $lp->set_context(
        _ => {
            %{$Carp::REPL::environments[$frame]},
        });
    my ($package, $file, $line) = @{$Carp::REPL::packages[$frame]};
    return qq{"Now at $file:$line (frame $frame)."} if $frame_delta != 0;
  }

  my $declarations = join '', map { "my $_;\n" } keys %{$lp->get_context('_')};

  # Collate my declarations for all LP context vars then add '';
  # so an empty statement doesn't return anything (with a no warnings
  # to prevent "Useless use ..." warning)
  return << "CODE";
package $Carp::REPL::packages[$frame][0];
$declarations
{
    no warnings 'void';
    '';
}
no strict 'vars'; # so we can play with the globals
$line
CODE
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

Version 0.04

=cut

our $VERSION = '0.04';

=head1 SYNOPSIS

This implements exactly the same thing as the Devel::REPL::Plugin::LexEnv
module except the lexical environment exposed by Carp::REPL is mixed in.

It also adds a few extra commands like :up and :down to move up and down the
stack.

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
