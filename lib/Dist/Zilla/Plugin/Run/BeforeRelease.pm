use strict;
use warnings;

package Dist::Zilla::Plugin::Run::BeforeRelease;
# ABSTRACT: execute a command of the distribution before release

our $VERSION = '0.051';

use Moose;
with qw(
  Dist::Zilla::Role::BeforeRelease
  Dist::Zilla::Plugin::Run::Role::Runner
);

use namespace::autoclean;

sub before_release {
  my ( $self, $archive ) = @_;
  $self->_call_script({
    archive =>  $archive,
    pos     => [$archive]
  });
}

=head1 SYNOPSIS

  [Run::BeforeRelease]
  run = script/myapp_before.pl %v %d

or

  [Run::BeforeRelease / MyAppBefore]
  run = script/myapp_before.pl %v %d

=head1 DESCRIPTION

This plugin executes the specified command before releasing.

=head1 POSITIONAL PARAMETERS

See L<Dist::Zilla::Plugin::Run/CONVERSIONS>
for the list of common formatting variables available to all plugins.

For backward compatibility:

=for :list
* The 1st C<%s> will be replaced by the archive of the release.

=cut

1;
