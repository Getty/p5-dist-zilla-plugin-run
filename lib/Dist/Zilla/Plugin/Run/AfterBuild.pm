package Dist::Zilla::Plugin::Run::AfterBuild;
# ABSTRACT: execute a command of the distribution after build
use Moose;
with qw(
	Dist::Zilla::Role::AfterBuild
	Dist::Zilla::Plugin::Run::Role::Runner
);

use namespace::autoclean;

sub after_build {
    my ($self, $param) = @_;
  $self->call_script({
    dir =>  $param->{ build_root },
    pos => [$param->{ build_root }, $self->zilla->version]
  });
}

=head1 SYNOPSIS

  [Run::AfterBuild]
  run = script/do_this.pl --dir %s --version %s
  run = script/do_that.pl


=head1 DESCRIPTION

This plugin executes after build a command, if its given on config. The 1st %s get replaced by the directory, containing the distribution just built.
The 2nd - by the version of the distribution.

=cut

1;
