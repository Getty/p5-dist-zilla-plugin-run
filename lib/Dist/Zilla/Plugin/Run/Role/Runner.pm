package Dist::Zilla::Plugin::Run::Role::Runner;
# ABSTRACT: Role for the packages of Dist::Zilla::Plugin::Run
use Moose::Role;
use String::Formatter 0.102082 ();
use namespace::autoclean;

has run => (
	is => 'ro',
	isa  => 'ArrayRef',
	default => sub { [] },
);

around BUILDARGS => sub {
    my ( $orig, $class, @args ) = @_;
    my $built = $class->$orig(@args);

    foreach my $dep (qw( notexist_fatal )) {
        if ( exists $built->{$dep} ) {
            warn(" !\n ! $class attribute '$dep' is deprecated and has no effect.\n !\n");
            delete $built->{$dep};
        }
    }
    return $built;
};

sub call_script {
	my ( $self, $params ) = @_;

    foreach my $run_cmd (@{$self->run}) {

        if ($run_cmd) {
            my $command = $self->build_formatter($params)->format($run_cmd);
		$self->log("Executing: ".$command);
		my $output = `$command`;
		my $status = $?;
		$self->log($output);
		$self->log_fatal("Errorlevel ".$status." on command execute") if $status;
		$self->log("command executed successful");

        }
    } 
}

around mvp_multivalue_args => sub {
    my ($original, $self) = @_;
    
    my @res = $self->$original();

    push @res, qw( run );
    
    @res; 
};

sub build_formatter {
    my ( $self, $params ) = @_;

    # stringify build directory
    my $dir = $params->{dir} || $self->zilla->built_in;
    $dir = $dir ? "$dir" : '';

    return String::Formatter->new({
        codes => {
            # not always available
            a => $params->{archive} || '',
            d => $dir,
            n => $self->zilla->name,
            v => $self->zilla->version,
            # positional replace (backward compatible)
            s => sub { shift(@{ $params->{pos} }) || '' },
        },
    });
}

=head1 DESCRIPTION

This is the base role for all the plugins L<Dist::Zilla::Plugin::Run> delivers. You dont need this.

=cut

1;
