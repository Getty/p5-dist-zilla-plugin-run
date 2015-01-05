use strict;
use warnings;

package Dist::Zilla::Plugin::Run::Role::Runner;
# ABSTRACT: Role for the packages of Dist::Zilla::Plugin::Run

use Moose::Role;
use namespace::autoclean;
use File::Spec (); # core
use Config     (); # core
use List::Util 1.33 'any';

has perlpath => (
    is      => 'ro',
    isa     => 'Str',
    builder => 'current_perl_path',
);

has censor_commands => (
    is => 'ro',
    isa => 'Bool',
    lazy => 1,
    default => sub {
        my $self = shift;

        # look for user:password URIs
        my ($command) = grep {
            any { /\b\w+:[^@]+@\b/ } @{ $self->$_ }
        } qw(run run_if_trial run_no_trial run_if_release run_no_release);

        $self->log("found a $command command that looks like it contains a password: redacting this from dumped configs!") if $command;
        $command ? 1 : 0;
    },
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

has eval => (
    is => 'ro',
    isa  => 'ArrayRef[Str]',
    default => sub { [] },
);

around dump_config => sub
{
    my ($orig, $self) = @_;
    my $config = $self->$orig;

    $config->{+__PACKAGE__} = {
        map {
            @{$self->$_}
            ? ( $_ => ( $self->censor_commands ? 'REDACTED' : $self->$_ ) )
            : ()
        }
        qw(run run_if_trial run_no_trial run_if_release run_no_release eval),
    };

    return $config;
};

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
            $self->log_debug([ 'not executing, because no trial: %s', $run_cmd ]);
        }
    }

    foreach my $run_cmd (@{$self->run_no_trial}) {
        if ($is_trial) {
            $self->log_debug([ 'not executing, because trial: %s', $run_cmd ]);
        } else {
            $self->run_cmd($run_cmd, $params);
        }
    }

    my $is_release = defined $ENV{'DZIL_RELEASING'} && $ENV{'DZIL_RELEASING'} == 1 ? 1 : 0;

    foreach my $run_cmd (@{$self->run_if_release}) {
        if ($is_release) {
            $self->run_cmd($run_cmd, $params);
        } else {
            $self->log_debug([ 'not executing, because no release: %s', $run_cmd ]);
        }
    }

    foreach my $run_cmd (@{$self->run_no_release}) {
        if ($is_release) {
            $self->log_debug([ 'not executing, because release: %s', $run_cmd ]);
        } else {
            $self->run_cmd($run_cmd, $params);
        }
    }

    if (my @code = @{ $self->eval }) {
        my $code = join "\n", @code;

        $self->eval_cmd($code, $params);
    }
}

sub run_cmd {
    my ( $self, $run_cmd, $params ) = @_;
    if ($run_cmd) {
        require IPC::Open3;  # core

        my $command = $self->build_formatter($params)->format($run_cmd);
        $self->log("executing: $command");

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

        $self->log_fatal("command exited with status $status ($?)") if $status;
        $self->log_debug('command executed successfully');
    }
}

sub eval_cmd {
    my ( $self, $code, $params ) = @_;

    $code = $self->build_formatter($params)->format($code);
    $self->log("evaluating: $code");

    my $sub = sub { eval $code };
    $sub->($self);
    $self->log_fatal('evaluation died: ' . $@) if $@;
}

around mvp_multivalue_args => sub {
    my ($original, $self) = @_;

    my @res = $self->$original();

    push @res, qw( run run_no_trial run_if_trial run_if_release run_no_release eval );

    @res;
};

my $path_separator = (File::Spec->catfile(qw(a b)) =~ m/^a(.+?)b$/)[0];

sub build_formatter {
    my ( $self, $params ) = @_;

    require String::Formatter;
    String::Formatter->VERSION(0.102082);

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
        n => sub { $self->zilla->name },

        # backward compatibility (don't error)
        s => '',

        # portability
        p => $path_separator,
        x => sub { $self->perlpath },
    };

    # available during build, not mint
    unless( $params->{minting} ){
        $codes->{v} = sub { $self->zilla->version };
        $codes->{t} = sub { $self->zilla->is_trial ? '-TRIAL' : '' };
    }

    # positional replace (backward compatible)
    if( my @pos = @{ $params->{pos} || [] } ){
        # where are you defined-or // operator?
        $codes->{s} = sub {
            my $s = shift(@pos);
            $s = $s->() if ref $s eq 'CODE';
            defined($s) ? $s : '';
        };
    }

    return String::Formatter->new({ codes => $codes });
}

sub current_perl_path {
    # see perlvar $^X for why we don't just use that here
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
