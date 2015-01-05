use strict;
use warnings;
use Test::More 0.88;

use Test::DZil;
use Path::Tiny;
use Test::Deep;

sub test_build {
    my %test = @_;

    my $tzil = Builder->from_config(
        { dist_root => 't/does-not-exist' },
        {
            add_files => {
                path(qw(source dist.ini)) => simple_ini(
                    [ GatherDir => ],
                    [ MetaConfig => ],
                    [ 'Run::BeforeBuild' => { run => [ '%x script%pbefore_build.pl' ] } ],
                    [ 'Run::AfterBuild' => {
                        run => [ '%x script%pafter_build.pl "%s"' ],
                        run_no_trial => [ '%x script%pno_trial.pl "%s"' ],
                      }
                    ],
                ),
                path(qw(source lib Foo.pm)) => "package Foo;\n1;\n",
                path(qw(source script before_build.pl)) => <<'SCRIPT',
use strict;
use warnings;
use Path::Tiny;
path("BEFORE_BUILD.txt")->touch();
SCRIPT
                path(qw(source script after_build.pl)) => <<'SCRIPT',
use strict;
use warnings;
use Path::Tiny;
path($ARGV[ 0 ], 'lib', 'AFTER_BUILD.txt')->spew_raw("after_build");
SCRIPT
                path(qw(source script no_trial.pl)) => <<'SCRIPT',
use strict;
use warnings;
use Path::Tiny;
path($ARGV[0], 'lib', 'NO_TRIAL.txt')->spew_raw(":-P");
SCRIPT
            },
        },
    );

    $tzil->chrome->logger->set_debug(1);
    $tzil->is_trial(1) if $test{trial};
    $tzil->build;

    my $before_build_result = path($tzil->tempdir, qw(source BEFORE_BUILD.txt));

    ok(-f $before_build_result, 'Before build script has been ran');

    my $after_build_result  = path($tzil->tempdir)->child(qw(build lib AFTER_BUILD.txt))->slurp_raw;

    ok($after_build_result eq 'after_build', 'Correct `after_build` result');

    my $no_trial_file = path($tzil->tempdir, qw(build lib NO_TRIAL.txt));
    if( $test{trial} ){
        ok( (! -e $no_trial_file), 'is trial - file not written' );

        like $tzil->log_messages->[-1],
            qr{\[Run::AfterBuild\] not executing, because trial: %x script%pno_trial.pl "%s"},
            'logged skipping of non-trial command';
    }
    else {
        ok( (  -f $no_trial_file), 'non-trial - file present' );
        is $no_trial_file->slurp_raw, ':-P', 'non-trial content';

        my $script = path('script','no_trial.pl')->canonpath;   # use OS-specific path separators
        like $tzil->log_messages->[-2],
            qr{\[Run::AfterBuild\] executing: .+ \Q$script\E .+},
            'logged execution';

        like $tzil->log_messages->[-1],
            qr{\[Run::AfterBuild\] command executed successfully},
            'logged command status';
    }

    cmp_deeply(
        $tzil->distmeta,
        superhashof({
            x_Dist_Zilla => superhashof({
                plugins => supersetof(
                    {
                        class => 'Dist::Zilla::Plugin::Run::BeforeBuild',
                        config => {
                            'Dist::Zilla::Plugin::Run::Role::Runner' => {
                                run => [ '%x script%pbefore_build.pl' ],
                            },
                        },
                        name => 'Run::BeforeBuild',
                        version => ignore,
                    },
                    {
                        class => 'Dist::Zilla::Plugin::Run::AfterBuild',
                        config => {
                            'Dist::Zilla::Plugin::Run::Role::Runner' => {
                                run => [ '%x script%pafter_build.pl "%s"' ],
                                run_no_trial => [ '%x script%pno_trial.pl "%s"' ],
                            },
                        },
                        name => 'Run::AfterBuild',
                        version => ignore,
                    },
                ),
            }),
        }),
        'dumped configs are good',
    ) or diag 'got distmeta: ', explain $tzil->distmeta;

    diag 'got log messages: ', explain $tzil->log_messages
        if not Test::Builder->new->is_passing;
}

test_build();
test_build(trial => 1);

done_testing;
