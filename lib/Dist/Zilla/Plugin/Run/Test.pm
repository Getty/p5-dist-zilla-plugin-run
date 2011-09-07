package Dist::Zilla::Plugin::Run::Test;
# ABSTRACT: execute a command of the distribution after build
use Moose;
with qw(
	Dist::Zilla::Role::TestRunner
	Dist::Zilla::Plugin::Run::Role::Runner
);

use namespace::autoclean;

sub test {
    my ($self, $dir) = @_;
    
    $self->call_script({
        dir =>  $dir
    });
}

=head1 SYNOPSIS

  [Run::Test]
  run = script/tester.pl --name %n --version %v %d/some_file.ext


=head1 DESCRIPTION

This plugin executes the specified command during the test phase.

=head1 POSITIONAL PARAMETERS

See L<Dist::Zilla::Plugin::Run/CONVERSIONS>
for the list of common formatting variables available to all plugins.

=cut

1;
