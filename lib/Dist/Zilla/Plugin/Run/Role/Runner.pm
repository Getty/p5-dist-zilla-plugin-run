use strict;
use warnings;

package Dist::Zilla::Plugin::Run::Role::Runner;

our $VERSION = '0.037';

use Moose::Role;
use namespace::autoclean;
use File::Spec (); # core
use Config     (); # core
use Moose::Util 'find_meta';

has perlpath => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => 'current_perl_path',
);

has censor_commands => (
    is => 'ro',
    isa => 'Bool',
    default => 0,
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

has fatal_errors => (
    is => 'ro',
    isa => 'Bool',
    default => 1,
);

around dump_config => sub
{
    my ($orig, $self) = @_;
    my $config = $self->$orig;

    $config->{+__PACKAGE__} = {
        (map { $_ => $self->$_ } qw(fatal_errors)),
        map {
            @{ $self->$_ }
                # look for user:password URIs
                ? ( $_ => [ map { $self->censor_commands || /\b\w+:[^@]+@\b/ ? 'REDACTED' : $_ } @{ $self->$_ } ] )
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

sub _is_trial {
    my $self = shift;

    # we want to avoid provoking other plugins prematurely, but also be as
    # accurate as we can with this status

    my $release_status_attr = find_meta($self->zilla)->find_attribute_by_name('release_status');

    return ( $self->zilla->is_trial ? 1 : 0 ) if
        not $release_status_attr     # legacy (before Dist::Zilla 5.035)
        or $release_status_attr->has_value($self->zilla);

    # otherwise, only use the logic that does not require zilla->version
    # before Dist::Zilla 5.035, this is what $zilla->is_trial returned
    return $self->zilla->_release_status_from_env =~ /\A(?:testing|unstable)\z/ ? 1 : 0;
}

sub _call_script {
    my ( $self, $params ) = @_;

    foreach my $run_cmd (@{$self->run}) {
        $self->_run_cmd($run_cmd, $params);
    }

    foreach my $run_cmd (@{$self->run_if_trial}) {
        if ($self->_is_trial) {
            $self->_run_cmd($run_cmd, $params);
        } else {
            $self->log_debug([ 'not executing, because no trial: %s', $run_cmd ]);
        }
    }

    foreach my $run_cmd (@{$self->run_no_trial}) {
        if ($self->_is_trial) {
            $self->log_debug([ 'not executing, because trial: %s', $run_cmd ]);
        } else {
            $self->_run_cmd($run_cmd, $params);
        }
    }

    my $is_release = defined $ENV{'DZIL_RELEASING'} && $ENV{'DZIL_RELEASING'} == 1 ? 1 : 0;

    foreach my $run_cmd (@{$self->run_if_release}) {
        if ($is_release) {
            $self->_run_cmd($run_cmd, $params);
        } else {
            $self->log_debug([ 'not executing, because no release: %s', $run_cmd ]);
        }
    }

    foreach my $run_cmd (@{$self->run_no_release}) {
        if ($is_release) {
            $self->log_debug([ 'not executing, because release: %s', $run_cmd ]);
        } else {
            $self->_run_cmd($run_cmd, $params);
        }
    }

    if (my @code = @{ $self->eval }) {
        my $code = join "\n", @code;

        $self->_eval_cmd($code, $params);
    }
}

sub _run_cmd {
    my ( $self, $run_cmd, $params, $dry_run ) = @_;

    if ($dry_run) {
        $self->log_debug([ 'dry run, would run: %s', $run_cmd ]);
        return;
    }

    return if not $run_cmd;

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

    if (my $status = ($? >> 8)) {
        my $method = $self->fatal_errors ? 'log_fatal' : 'log';
        $self->$method("command exited with status $status ($?)");
    }
    else {
        $self->log_debug('command executed successfully');
    }
}

sub _eval_cmd {
    my ( $self, $code, $params, $dry_run ) = @_;

    if ($dry_run) {
        $self->log_debug([ 'dry run, would evaluate: %s', $code ]);
        return;
    }

    $code = $self->build_formatter($params)->format($code);
    $self->log("evaluating: $code");

    my $sub = sub { eval $code };
    $sub->($self);

    if ($@) {
        my $method = $self->fatal_errors ? 'log_fatal' : 'log';
        $self->$method('evaluation died: ' . $@);
    }
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

    my $codes = {
        # not always available
        # explicitly pass a string (not an object) [rt-72008]
        a => defined $params->{archive} ? "$params->{archive}" : '',

        # build dir or mint dir
        d => sub {
            # stringify build directory
            my $dir = $params->{dir} || $self->zilla->built_in;
            $dir ? "$dir" : '';
        },

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
        $codes->{t} = sub { $self->_is_trial ? '-TRIAL' : '' };
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

sub current_perl_path { $^X }

1;
# vim: set ts=4 sts=4 sw=4 expandtab smarttab:
