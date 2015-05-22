use strict;
use warnings;

package Dist::Zilla::Plugin::Run::AfterRelease;
# ABSTRACT: execute a command of the distribution after release

our $VERSION = '0.039';

use Moose;
with qw(
  Dist::Zilla::Role::AfterRelease
  Dist::Zilla::Plugin::Run::Role::Runner
);

use namespace::autoclean;

sub after_release {
  my ( $self, $archive ) = @_;
  $self->_call_script({
    archive =>  $archive,
    pos     => [$archive, sub { $self->zilla->version }]
  });
}

=head1 SYNOPSIS

  [Run::AfterRelease]
  run = script/myapp_after.pl --archive %s --version %s

or

  [Run::AfterRelease / MyAppAfter]
  run = script/myapp_after.pl %s %s

=head1 DESCRIPTION

This plugin executes the specified command after releasing.

=head1 POSITIONAL PARAMETERS

See L<Dist::Zilla::Plugin::Run/CONVERSIONS>
for the list of common formatting variables available to all plugins.

For backward compatibility:

=for :list
* The 1st C<%s> will be replaced by the archive of the release.
* The 2nd C<%s> will be replaced by the dist version.

=cut

1;
