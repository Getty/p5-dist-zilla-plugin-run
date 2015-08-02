use strict;
use warnings;

use Test::More 0.88;
use Test::DZil;
use Path::Tiny;
use Test::Deep;
use Test::Fatal;

my @configs = (
    {
        run => [ qq{"$^X" -le"print q(# hello this is a run command)"} ],
        eval => [ qq{die "oh noes"} ],
    },
    {
        run => [ qq{"$^X" -le"exit 2"} ],
        eval => [ qq{print "# hello this is an eval command\\xa"} ],
    }
);

foreach my $quiet (0, 1)
{
    foreach my $verbose (0, 1)
    {
        note "quiet = $quiet, verbose logging = $verbose";

        my $plugin_count = 0;
        my $tzil = Builder->from_config(
            { dist_root => 'does-not-exist' },
            {
                add_files => {
                    path(qw(source dist.ini)) => simple_ini(
                        [ GatherDir => ],
                        [ MetaConfig => ],
                        map {
                            [ 'Run::BeforeBuild' => 'plugin ' . $plugin_count++ => {
                                    quiet => $quiet,
                                    fatal_errors => 0,
                                    %$_,
                                } ]
                        } @configs,
                    ),
                    path(qw(source lib Foo.pm)) => "package Foo;\n1;\n",
                },
            },
        );

        $tzil->chrome->logger->set_debug($verbose);

        is(
            exception { $tzil->build },
            undef,
            'build completed successfully',
        );

        my @run_messages = (
            map {
                my $num = $_;
                map {
                    my $key = $_;
                    map {
                        "[plugin $num] " . ( $key eq 'run' ? 'executing: ' : 'evaluating: ') . $_
                    } @{$configs[$num]->{$_}}
                } keys %{ $configs[$num] }
            } 0 .. $#configs
        );

        if ($quiet and not $verbose)
        {
            foreach my $message (@run_messages) {
                ok(!( grep { $_ eq $message } @{$tzil->log_messages} ), 'did not see log message when running command');
            }
        }
        else
        {
            cmp_deeply(
                $tzil->log_messages,
                superbagof(
                    @run_messages,
                    re(qr/^\[plugin 0\] evaluation died: oh noes/),
                    '[plugin 1] command exited with status 2 (512)',
                ),
                "saw expected log messages when quiet=$quiet, verbose=$verbose",
            );
        }

        cmp_deeply(
            $tzil->distmeta,
            superhashof({
                x_Dist_Zilla => superhashof({
                    plugins => supersetof(
                        map {
                            {
                                class => 'Dist::Zilla::Plugin::Run::BeforeBuild',
                                config => {
                                    'Dist::Zilla::Plugin::Run::Role::Runner' => {
                                        %{ $configs[$_] },
                                        fatal_errors => 0,
                                        quiet => $quiet,
                                    },
                                },
                                name => "plugin $_",
                                version => Dist::Zilla::Plugin::Run::BeforeBuild->VERSION,
                            }
                        } (0 .. $#configs)
                    ),
                }),
            }),
            'dumped configs are good',
        ) or diag 'got distmeta: ', explain $tzil->distmeta;

        diag 'got log messages: ', explain $tzil->log_messages
            if not Test::Builder->new->is_passing;
    }
}

{
    my $tzil = Builder->from_config(
        { dist_root => 'does-not-exist' },
        {
            add_files => {
                path(qw(source dist.ini)) => simple_ini(
                    [ GatherDir => ],
                    [ MetaConfig => ],
                    [ 'Run::BeforeBuild' => { quiet => 1, run => [ qq{"$^X" -le"print q/hi/; exit 2"} ] } ],
                ),
                path(qw(source lib Foo.pm)) => "package Foo;\n1;\n",
            },
        },
    );

    $tzil->chrome->logger->set_debug(0);    # explicitly *not* --verbose mode!
    like(
        exception { $tzil->build },
        qr/command exited with status 2 \(512\)/,
        'build failed, reporting the error from the run command',
    );

    cmp_deeply(
        $tzil->log_messages,
        superbagof(
            qq{[Run::BeforeBuild] executed: "$^X" -le"print q/hi/; exit 2"},
            '[Run::BeforeBuild] hi',
            '[Run::BeforeBuild] command exited with status 2 (512)',
        ),
        'log messages list what happened, after the fact',
    );

    cmp_deeply(
        $tzil->distmeta,
        superhashof({
            x_Dist_Zilla => superhashof({
                plugins => supersetof(
                    {
                        class => 'Dist::Zilla::Plugin::Run::BeforeBuild',
                        config => {
                            'Dist::Zilla::Plugin::Run::Role::Runner' => {
                                run => [ qq{"$^X" -le"print q/hi/; exit 2"} ],
                                fatal_errors => 1,
                                quiet => 1,
                            },
                        },
                        name => 'Run::BeforeBuild',
                        version => Dist::Zilla::Plugin::Run::BeforeBuild->VERSION,
                    },
                ),
            }),
        }),
        'dumped configs to metadata',
    ) or diag 'got distmeta: ', explain $tzil->distmeta;

    diag 'got log messages: ', explain $tzil->log_messages
        if not Test::Builder->new->is_passing;
}

done_testing;
