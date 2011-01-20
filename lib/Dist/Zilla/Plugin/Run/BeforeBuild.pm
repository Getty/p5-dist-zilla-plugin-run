package Dist::Zilla::Plugin::Run::BeforeBuild;
# ABSTRACT: execute a command of the distribution after build
use Moose;
with qw(
	Dist::Zilla::Role::BeforeBuild
	Dist::Zilla::Plugin::Run::Role::Runner
);

use namespace::autoclean;

sub before_build {
    my ($self) = @_;
    
	$self->call_script($self->zilla->version);
}

=head1 SYNOPSIS

  [Run::BeforeBuild]
  run = script/do_this.pl --version %s
  run = script/do_that.pl


=head1 DESCRIPTION

This plugin executes before build a command, if its given on config. The %s get replaced by the version of the distribution.

=head2 notexist_fatal

If this value is set to false, the plugin will ignore a not existing script. Default is true.

=cut

1;
