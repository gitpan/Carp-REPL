package Devel::REPL::Plugin::LexEnvCarp;

use Moose::Role;
use namespace::clean -except => [ 'meta' ];
use Devel::LexAlias;

has 'environments' => (
    isa => 'ArrayRef',
    is => 'rw',
    required => 1,
    default => sub { [{}] },
);

has 'packages' => (
    isa => 'ArrayRef',
    is => 'rw',
    required => 1,
    default => sub { ['main'] },
);

has 'frame' => (
    isa => 'Int',
    is => 'rw',
    required => 1,
    default => 0,
);

has 'backtrace' => (
    isa => 'Str',
    is => 'rw',
    required => 1,
    default => '',
);

around 'frame' => sub
{
    my $orig = shift;

    my ($self, $frame) = @_;

    return $orig->(@_) if !defined($frame);

    if ($frame < 0)
    {
        warn "You're already at the bottom frame.\n";
    }
    elsif ($frame >= @{ $self->packages })
    {
        warn "You're already at the top frame.\n";
    }
    else
    {
        my ($package, $file, $line) = @{$self->packages->[$frame]};
        print "Now at $file:$line (frame $frame).\n";
        $orig->(@_);
    }
};

# this is totally the wrong spot for this. oh well.
around 'read' => sub
{
  my $orig = shift;
  my ($self, @rest) = @_;
  my $line = $self->$orig(@rest);

  return if !defined($line) || $line =~ /^\s*:q\s*$/;

  if ($line =~ /^\s*:b?t\s*$/)
  {
    print $self->backtrace;
    return '';
  }

  if ($line =~ /^\s*:up?\s*$/)
  {
    $self->frame($self->frame + 1);
    return '';
  }

  if ($line =~ /^\s*:d(?:own)?\s*$/)
  {
    $self->frame($self->frame - 1);
    return '';
  }

  return $line;
};

around 'mangle_line' => sub
{
  my $orig = shift;
  my ($self, @rest) = @_;
  my $line = $self->$orig(@rest);

  my $frame = $self->frame;
  my $package = $self->packages->[$frame][0];

  my $declarations = join "\n",
                     map {"my $_;"}
                     keys %{ $self->environments->[$frame] };

  my $aliases = << 'ALIASES';
while (my ($k, $v) = each %{ $_REPL->environments->[$_REPL->frame] })
{
    Devel::LexAlias::lexalias 0, $k, $v;
}
ALIASES

  return << "CODE";
package $package;
no warnings 'misc'; # declaration in same scope masks earlier instance
no strict 'vars';   # so we get all the global variables in our package
$declarations
$aliases
$line
CODE
};

=head1 NAME

Devel::REPL::Plugin::LexEnvCarp - Devel::REPL plugin for Carp::REPL

=head1 VERSION

Version 0.06

=cut

our $VERSION = '0.06';

=head1 SYNOPSIS

This sets up the environment captured by L<Carp::REPL|Carp::REPL>. This plugin
isn't intended for use by anything else. There are plans to move some features
from this into a generic L<Devel::REPL|Devel::REPL> plugin.

This plugin also adds a few extra commands like :up and :down to move up and
down the stack.

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
