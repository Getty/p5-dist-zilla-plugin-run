use strict;
use warnings;

package Dist::Zilla::Plugin::Run::Release;
# ABSTRACT: execute a command of the distribution on release

our $VERSION = '0.038';

use Moose;
with qw(
  Dist::Zilla::Role::Releaser
  Dist::Zilla::Plugin::Run::Role::Runner
);

use namespace::autoclean;

sub release {
  my ( $self, $archive ) = @_;
  $self->_call_script({
    archive =>  $archive,
    pos     => [$archive]
  });
}

=head1 SYNOPSIS

  [Run::Release]
  run = script/myapp_deploy.pl %s

or

  [Run::Release / MyAppDeploy]
  run = script/myapp_deploy.pl %s

=head1 DESCRIPTION

This plugin executes the specified command for the release process.

This way you can specify a custom release command without needing any other C<Releaser> plugin.

=head1 POSITIONAL PARAMETERS

See L<Dist::Zilla::Plugin::Run/CONVERSIONS>
for the list of common formatting variables available to all plugins.

For backward compatibility:

=for :list
* The 1st C<%s> will be replaced by the archive of the release.

=cut

1;
