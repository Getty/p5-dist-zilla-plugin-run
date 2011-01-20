package Dist::Zilla::Plugin::Run::Role::Runner;
# ABSTRACT: Role for the packages of Dist::Zilla::Plugin::Run
use Moose::Role;
use namespace::autoclean;

has run => (
	is => 'ro',
	isa  => 'ArrayRef',
	default => sub { [] },
);

has notexist_fatal => (
	is => 'ro',
	isa => 'Bool',
	default => sub { 1 },
);


sub call_script {
	my ( $self, @params ) = @_;

    foreach my $run_cmd (@{$self->run}) {

        if ($run_cmd) {
            my @cmdparts = split(' ',$run_cmd);
            
            # this is not good, i should also check if its a command in PATH
            if (-f $cmdparts[0]) {
                my $command = sprintf($run_cmd,@params);
                $self->log("Executing: ".$command);
                my $output = `$command`;
                $self->log($output);
                $self->log_fatal("Errorlevel ".$?." on command execute") if $?;     
                $self->log("command executed successful");
            } else {
                if ($self->notexist_fatal) {
                    $self->log_fatal($cmdparts[0]." command not exist - breaking up here");
                } else {
                    $self->log($cmdparts[0]." command not exist - ignoring this");
                }
            }
        }
    } 
}

around mvp_multivalue_args => sub {
    my ($original, $self) = @_;
    
    my @res = $self->$original();

    push @res, qw( run );
    
    @res; 
};


=head1 DESCRIPTION

This is the base role for all the plugins L<Dist::Zilla::Plugin::Run> delivers. You dont need this.

=cut

1;
