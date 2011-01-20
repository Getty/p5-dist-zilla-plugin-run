package Dist::Zilla::Plugin::Run::AfterRelease;
# ABSTRACT: execute a command of the distribution after release
use Moose;
with qw(
	Dist::Zilla::Role::AfterRelease
	Dist::Zilla::Plugin::Run::Role::Runner
);

use namespace::autoclean;

sub after_release {
    my $self = shift;
    
	$self->call_script(@_, $self->zilla->version);
}

=head1 SYNOPSIS

  [Run::AfterRelease]
  run = script/myapp_after.pl --archive %s --version %s

or

  [Run::AfterRelease / MyAppAfter]
  run = script/myapp_after.pl %s %s

=head1 DESCRIPTION

This plugin executes after release a command, if its given on config. The 1st %s get replaced by the archive of the release.
The 2nd - by the version of the distribution.

=head2 notexist_fatal

If this value is set to false, the plugin will ignore a not existing script. Default is true.

=cut

1;
