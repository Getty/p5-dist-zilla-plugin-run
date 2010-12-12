package Dist::Zilla::Plugin::Run;
# ABSTRACT: execute a command of the distribution on (so far) release
use Moose;
with 'Dist::Zilla::Role::Releaser';

use Cwd;

use namespace::autoclean;

has on_release => (
	is => 'ro',
	isa => 'Str',
	required => 1,
);

sub release {
	my ( $self, $archive ) = @_;

	if ($self->on_release) {
		my $command = sprintf($self->on_release,$archive);
		$self->log("Executing: ".$command);
		my $output = `$command`;
		$self->log($output);
		$self->log_fatal("Errorlevel ".$?." on command execute") if $?;		
		$self->log("on_release command executed successful");		
	}

}

=head1 SYNOPSIS

  [Run]
  on_release = script/myapp_deploy.pl %s

=head1 DESCRIPTION

This plugin executes (so far) on release a command, if its given on config. %s gets replaced by the release archive file name.

=cut

1;
