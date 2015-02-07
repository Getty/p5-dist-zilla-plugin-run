use strict;
use warnings;
package Dist::Zilla::Plugin::Run::Clean;
# ABSTRACT: execute a command of the distribution on 'dzil clean'
# vim: set ts=8 sw=4 tw=78 et :
our $VERSION = '0.034';
use Moose;
with
    'Dist::Zilla::Role::Plugin',
    'Dist::Zilla::Plugin::Run::Role::Runner';

use Moose::Util ();
use Scalar::Util 'weaken';
use namespace::autoclean;

sub BUILD {
    my $plugin = shift;

    # when the zilla is demolished, allow the ourselves to be destroyed too
    weaken $plugin;

    # Dist::Zilla really ought to have a -CleanerProvider hook...
    Moose::Util::add_method_modifier($plugin->zilla->meta, 'after',
        [
            clean => sub {
                my ($zilla, $dry_run) = @_;
                return if not $plugin;
                $plugin->clean($dry_run);
            },
        ],
    );
};

sub clean
{
    my ($self, $dry_run) = @_;

    # may need some subrefs for positional parameters?
    my $params = {};

    foreach my $run_cmd (@{$self->run}) {
        $self->_run_cmd($run_cmd, $params, $dry_run);
    }

    if (my @code = @{ $self->eval }) {
        my $code = join "\n", @code;
        $self->_eval_cmd($code, $params, $dry_run);
    }
}

__PACKAGE__->meta->make_immutable;
__END__

=pod

=head1 SYNOPSIS

In your F<dist.ini>:

    [Run::Clean]
    run = script/do_that.pl
    eval = unlink scratch.dat

=head1 DESCRIPTION

This plugin executes the specified command(s) when cleaning the dist.

=head1 POSITIONAL PARAMETERS

See L<Dist::Zilla::Plugin::Run/CONVERSIONS>
for the list of common formatting variables available to all plugins.
(Some of them may not work properly, because the dist is not built
when running the clean command. These are not tested yet - patches welcome!)

=cut
