use strict;
use warnings;

package Dist::Zilla::Plugin::Run::BeforeBuild;
# ABSTRACT: execute a command of the distribution before build

our $VERSION = '0.036';

use Moose;
with qw(
  Dist::Zilla::Role::BeforeBuild
  Dist::Zilla::Plugin::Run::Role::Runner
);

use namespace::autoclean;

sub before_build {
  my ($self) = @_;
  $self->_call_script({
    pos => [sub { $self->zilla->version }]
  });
}

=head1 SYNOPSIS

  [Run::BeforeBuild]
  run = script/do_this.pl --version %s
  run = script/do_that.pl

=head1 DESCRIPTION

This plugin executes the specified command before building the dist.

=head1 POSITIONAL PARAMETERS

See L<Dist::Zilla::Plugin::Run/CONVERSIONS>
for the list of common formatting variables available to all plugins.

For backward compatibility:

=for :list
* The 1st C<%s> will be replaced by the dist version.

=cut

1;
