use strict;
use warnings;
use Test::More 0.88;

use Test::DZil;
use Path::Tiny;
use Test::Deep;
use Test::Fatal;

{
    my $tzil = Builder->from_config(
        { dist_root => 't/does-not-exist' },
        {
            add_files => {
                path(qw(source dist.ini)) => simple_ini(
                    [ GatherDir => ],
                    [ MetaConfig => ],
                    [ 'Run::BeforeBuild' => { run => [ 'sh -c "exit 2"' ] } ],
                ),
                path(qw(source lib Foo.pm)) => "package Foo;\n1;\n",
            },
        },
    );

    $tzil->chrome->logger->set_debug(1);
    like(
        exception { $tzil->build },
        qr/command exited with status 2 \(512\)/,
        'build failed, reporting the error from the run command',
    );

    cmp_deeply(
        $tzil->log_messages,
        superbagof(
            '[Run::BeforeBuild] executing: sh -c "exit 2"',
            '[Run::BeforeBuild] command exited with status 2 (512)',
        ),
        'log messages list what happened',
    );

    diag 'got log messages: ', explain $tzil->log_messages
        if not Test::Builder->new->is_passing;
}

{
    my $tzil = Builder->from_config(
        { dist_root => 't/does-not-exist' },
        {
            add_files => {
                path(qw(source dist.ini)) => simple_ini(
                    [ GatherDir => ],
                    [ MetaConfig => ],
                    [ FakeRelease => ],
                    [ 'Run::BeforeBuild' => { eval => [ 'die "oh noes"' ] } ],
                ),
                path(qw(source lib Foo.pm)) => "package Foo;\n1;\n",
            },
        },
    );

    $tzil->chrome->logger->set_debug(1);
    like(
        exception { $tzil->build },
        qr/evaluation died: oh noes/,
        'build failed, reporting the error from the eval command',
    );

    cmp_deeply(
        $tzil->log_messages,
        superbagof(
            '[Run::BeforeBuild] evaluating: die "oh noes"',
            re(qr/^\[Run::BeforeBuild\] evaluation died: oh noes/),
        ),
        'log messages list what happened',
    );

    diag 'got log messages: ', explain $tzil->log_messages
        if not Test::Builder->new->is_passing;
}

{
    my $tzil = Builder->from_config(
        { dist_root => 't/does-not-exist' },
        {
            add_files => {
                path(qw(source dist.ini)) => simple_ini(
                    [ GatherDir => ],
                    [ MetaConfig => ],
                    [ 'Run::BeforeBuild' => { run => [ 'sh -c "exit 2"' ], fatal_errors => 0, } ],
                ),
                path(qw(source lib Foo.pm)) => "package Foo;\n1;\n",
            },
        },
    );

    $tzil->chrome->logger->set_debug(1);
    is(
        exception { $tzil->build },
        undef,
        'build succeeded, despite the run command failing',
    );

    cmp_deeply(
        $tzil->log_messages,
        superbagof(
            '[Run::BeforeBuild] executing: sh -c "exit 2"',
            '[Run::BeforeBuild] command exited with status 2 (512)',
        ),
        'log messages list what happened',
    );

    diag 'got log messages: ', explain $tzil->log_messages
        if not Test::Builder->new->is_passing;
}

{
    my $tzil = Builder->from_config(
        { dist_root => 't/does-not-exist' },
        {
            add_files => {
                path(qw(source dist.ini)) => simple_ini(
                    [ GatherDir => ],
                    [ MetaConfig => ],
                    [ FakeRelease => ],
                    [ 'Run::BeforeBuild' => { eval => [ 'die "oh noes"' ], fatal_errors => 0, } ],
                ),
                path(qw(source lib Foo.pm)) => "package Foo;\n1;\n",
            },
        },
    );

    $tzil->chrome->logger->set_debug(1);
    is(
        exception { $tzil->build },
        undef,
        'build succeeded, despite the eval command failing',
    );

    cmp_deeply(
        $tzil->log_messages,
        superbagof(
            '[Run::BeforeBuild] evaluating: die "oh noes"',
            re(qr/^\[Run::BeforeBuild\] evaluation died: oh noes/),
        ),
        'log messages list what happened',
    );

    diag 'got log messages: ', explain $tzil->log_messages
        if not Test::Builder->new->is_passing;
}

done_testing;
