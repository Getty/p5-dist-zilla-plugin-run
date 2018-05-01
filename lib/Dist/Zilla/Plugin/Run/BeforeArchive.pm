use strict;
use warnings;

package Dist::Zilla::Plugin::Run::BeforeArchive;
# ABSTRACT: execute a command of the distribution before creating the archive

our $VERSION = '0.048';

use Moose;
with qw(
  Dist::Zilla::Role::BeforeArchive
  Dist::Zilla::Plugin::Run::Role::Runner
);

use namespace::autoclean;

sub before_archive {
  my ($self) = @_;
  $self->_call_script({});
}

=head1 SYNOPSIS

  [Run::BeforeArchive]
  run = script/do_this.pl --dir %d --version %v
  run = script/do_that.pl

=head1 DESCRIPTION

This plugin executes the specified command before the archive file is built.

=head1 POSITIONAL PARAMETERS

See L<Dist::Zilla::Plugin::Run/CONVERSIONS>
for the list of common formatting variables available to all plugins.

=cut

1;
