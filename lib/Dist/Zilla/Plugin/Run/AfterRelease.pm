package Dist::Zilla::Plugin::Run::AfterRelease;
# ABSTRACT: execute a command of the distribution on (so far) release
use Moose;
with qw(
	Dist::Zilla::Role::AfterRelease
	Dist::Zilla::Plugin::Run::Role::Runner
);

use namespace::autoclean;

sub after_release {
	shift->call_script(@_);
}

=head1 SYNOPSIS

  [Run::AfterRelease]
  run = script/myapp_after.pl %s

or

  [Run::AfterRelease / MyAppAfter]
  run = script/myapp_after.pl %s

=head1 DESCRIPTION

This plugin executes after release a command, if its given on config. The %s get replaced by the archive of the release.

=head2 notexist_fatal

If this value is set to false, the plugin will ignore a not existing script. Default is true.

=cut

1;
