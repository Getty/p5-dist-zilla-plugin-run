use strict;
use warnings;

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
    pos => [$param->{ build_root }, sub { $self->zilla->version }]
  });
}

=head1 SYNOPSIS

  [Run::AfterBuild]
  run = script/do_this.pl --dir %s --version %s
  run = script/do_that.pl


=head1 DESCRIPTION

This plugin executes the specified command after building the dist.

=head1 POSITIONAL PARAMETERS

See L<Dist::Zilla::Plugin::Run/CONVERSIONS>
for the list of common formatting variables available to all plugins.

For backward compatibility:

=for :list
* The 1st C<%s> will be replaced by the directory in which the dist was built.
* The 2nd C<%s> will be replaced by the dist version.

=cut

1;
