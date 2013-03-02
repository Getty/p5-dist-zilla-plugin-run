use strict;
use warnings;

package Dist::Zilla::Plugin::Run::Role::Runner;
# ABSTRACT: Role for the packages of Dist::Zilla::Plugin::Run
use Moose::Role;
use String::Formatter 0.102082 ();
use namespace::autoclean;
use File::Spec (); # core
use IPC::Open3 (); # core
use Config     (); # core

has perlpath => (
    is      => 'ro',
    isa     => 'Str',
    builder => 'current_perl_path',
);

has run => (
    is => 'ro',
    isa  => 'ArrayRef',
    default => sub { [] },
);

has run_if_trial => (
    is => 'ro',
    isa  => 'ArrayRef',
    default => sub { [] },
);

has run_no_trial => (
    is => 'ro',
    isa  => 'ArrayRef',
    default => sub { [] },
);

has run_if_release => (
    is => 'ro',
    isa  => 'ArrayRef',
    default => sub { [] },
);

has run_no_release => (
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
        $self->run_cmd($run_cmd, $params);
    }

    my $is_trial = $self->zilla->is_trial ? 1 : 0;

    foreach my $run_cmd (@{$self->run_if_trial}) {
        if ($is_trial) {
            $self->run_cmd($run_cmd, $params);
        } else {
            $self->log("Not executing, because no trial: $run_cmd");
        }
    }

    foreach my $run_cmd (@{$self->run_no_trial}) {
        if ($is_trial) {
            $self->log("Not executing, because trial: $run_cmd");
        } else {
            $self->run_cmd($run_cmd, $params);
        }
    }

    my $is_release = defined $ENV{'DZIL_RELEASING'} && $ENV{'DZIL_RELEASING'} == 1 ? 1 : 0;

    foreach my $run_cmd (@{$self->run_if_release}) {
        if ($is_release) {
            $self->run_cmd($run_cmd, $params);
        } else {
            $self->log("Not executing, because no release: $run_cmd");
        }
    }

    foreach my $run_cmd (@{$self->run_no_release}) {
        if ($is_release) {
            $self->log("Not executing, because release: $run_cmd");
        } else {
            $self->run_cmd($run_cmd, $params);
        }
    }

}

sub run_cmd {
    my ( $self, $run_cmd, $params ) = @_;
    if ($run_cmd) {
        my $command = $self->build_formatter($params)->format($run_cmd);
        $self->log("Executing: $command");

        # autoflush STDOUT so we can see command output right away
        local $| = 1;
        # combine stdout and stderr for ease of proxying through the logger
        my $pid = IPC::Open3::open3(my ($in, $out), undef, $command);
        while(defined(my $line = <$out>)){
            chomp($line); # logger appends its own newline
            $self->log($line);
        }
        # zombie repellent
        waitpid($pid, 0);
        my $status = ($? >> 8);

        $self->log_fatal("Command exited with status $status ($?)") if $status;
        $self->log("Command executed successfully");
    }
}

around mvp_multivalue_args => sub {
    my ($original, $self) = @_;
    
    my @res = $self->$original();

    push @res, qw( run run_no_trial run_if_trial run_if_release run_no_release );
    
    @res; 
};

my $path_separator = (File::Spec->catfile(qw(a b)) =~ m/^a(.+?)b$/)[0];

sub build_formatter {
    my ( $self, $params ) = @_;

    # stringify build directory
    my $dir = $params->{dir} || $self->zilla->built_in;
    $dir = $dir ? "$dir" : '';

    my $codes = {
        # not always available
        # explicitly pass a string (not an object) [rt-72008]
        a => defined $params->{archive} ? "$params->{archive}" : '',

        # build dir or mint dir
        d => $dir,

        # dist name
        n => $self->zilla->name,

        # backward compatibility (don't error)
        s => '',

        # portability
        p => $path_separator,
        x => $self->perlpath,
    };

    # available during build, not mint
    unless( $params->{minting} ){
        $codes->{v} = $self->zilla->version;
    }

    # positional replace (backward compatible)
    if( my @pos = @{ $params->{pos} || [] } ){
        # where are you defined-or // operator?
        $codes->{s} = sub { my $s = shift(@pos); defined($s) ? $s : '' };
    }

    return String::Formatter->new({ codes => $codes });
}

sub current_perl_path {
    # see perlvar $^X
    my $perl = $Config::Config{perlpath};
    if ($^O ne 'VMS') {
        $perl .= $Config::Config{_exe}
            unless $perl =~ m/$Config::Config{_exe}$/i;
    }
    return $perl;
}

=head1 DESCRIPTION

This is the base role for all the plugins L<Dist::Zilla::Plugin::Run> delivers. You don't need this.

=cut

1;
# vim: set ts=4 sts=4 sw=4 expandtab smarttab:
