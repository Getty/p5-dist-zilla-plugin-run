use strict;
use warnings;

package Dist::Zilla::Plugin::Run::Test;
# ABSTRACT: execute a command of the distribution after build

our $VERSION = '0.038';

use Moose;
with qw(
    Dist::Zilla::Role::TestRunner
    Dist::Zilla::Plugin::Run::Role::Runner
);

use namespace::autoclean;

sub test {
    my ($self, $dir) = @_;

    $self->_call_script({
        dir =>  $dir
    });
}

=head1 SYNOPSIS

  [Run::Test]
  run = script/tester.pl --name %n --version %v some_file.ext

=head1 DESCRIPTION

This plugin executes the specified command during the test phase.

=head1 CAVEAT

Unlike the other [Run::*] plugins, when running the scripts, the
current working directory will be the directory with
newly built distribution. This is the way Dist::Zilla works.

=head1 POSITIONAL PARAMETERS

See L<Dist::Zilla::Plugin::Run/CONVERSIONS>
for the list of common formatting variables available to all plugins.

There are no positional parameters for this plugin.

=cut

1;
