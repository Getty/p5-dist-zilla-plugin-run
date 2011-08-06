package Dist::Zilla::Plugin::Run::BeforeRelease;
# ABSTRACT: execute a command of the distribution before release
use Moose;
with qw(
	Dist::Zilla::Role::BeforeRelease
	Dist::Zilla::Plugin::Run::Role::Runner
);

use namespace::autoclean;

sub before_release {
  my ( $self, $archive ) = @_;
  $self->call_script({
    archive =>  $archive,
    pos     => [$archive]
  });
}

=head1 SYNOPSIS

  [Run::BeforeRelease]
  run = script/myapp_before.pl %s

or
  
  [Run::BeforeRelease / MyAppBefore]
  run = script/myapp_before.pl %s

=head1 DESCRIPTION

This plugin executes before release a command, if its given on config. The %s get replaced by the archive of the release.

=cut

1;
