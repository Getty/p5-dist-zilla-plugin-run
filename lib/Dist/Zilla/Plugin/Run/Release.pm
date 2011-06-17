package Dist::Zilla::Plugin::Run::Release;
# ABSTRACT: execute a command of the distribution on release
use Moose;
with qw(
	Dist::Zilla::Role::Releaser
	Dist::Zilla::Plugin::Run::Role::Runner
);

use namespace::autoclean;

sub release {
	shift->call_script(@_);
}

=head1 SYNOPSIS

  [Run::Release]
  run = script/myapp_deploy.pl %s

or
  
  [Run::Release / MyAppDeploy]
  run = script/myapp_deploy.pl %s

=head1 DESCRIPTION

This plugin executes on release a command, if its given on config. The %s get replaced by the archive of the release.

=cut

1;
