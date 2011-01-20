package Dist::Zilla::Plugin::Run::AfterBuild;
# ABSTRACT: execute a command of the distribution after release
use Moose;
with qw(
	Dist::Zilla::Role::AfterBuild
	Dist::Zilla::Plugin::Run::Role::Runner
);

use namespace::autoclean;

sub after_build {
    my ($self, $param) = @_;
    
	$self->call_script($param->{ build_root });
}

=head1 SYNOPSIS

  [Run::AfterBuild]
  run = script/do_this.pl %s
  run = script/do_that.pl %s


=head1 DESCRIPTION

This plugin executes after build a command, if its given on config. The %s get replaced by the directory, containing the distribution just built.

=head2 notexist_fatal

If this value is set to false, the plugin will ignore a not existing script. Default is true.

=cut

1;
