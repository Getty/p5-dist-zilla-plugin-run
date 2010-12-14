package Dist::Zilla::Plugin::Run::BeforeRelease;
# ABSTRACT: execute a command of the distribution on (so far) release
use Moose;
with qw(
	Dist::Zilla::Role::BeforeRelease
	Dist::Zilla::Plugin::Run::Role::Runner
);

use namespace::autoclean;

sub before_release {
	shift->call_script(@_);
}

=head1 SYNOPSIS

  [Run::BeforeRelease]
  run = script/myapp_before.pl %s

or
  
  [Run::BeforeRelease / MyAppBefore]
  run = script/myapp_before.pl %s

=head1 DESCRIPTION

This plugin executes before release a command, if its given on config. The %s get replaced by the archive of the release.

=head2 notexist_fatal

If this value is set to false, the plugin will ignore a not existing script. Default is true.

=cut

1;
