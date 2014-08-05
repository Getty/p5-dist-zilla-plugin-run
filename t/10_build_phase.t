use strict;
use warnings;
use Test::More 0.88;

use Path::Tiny;
use Dist::Zilla::Tester;
use Test::Deep;

sub test_build {
    my %test = @_;

    my $tzil = Dist::Zilla::Tester->from_config(
        { dist_root => 'test_data/build_phase' },
    );

    $tzil->is_trial(1) if $test{trial};
    $tzil->build;

    my $before_build_result = path($tzil->tempdir, qw(source BEFORE_BUILD.txt));

    ok(-f $before_build_result, 'Before build script has been ran');


    my $after_build_result  = $tzil->slurp_file(path(qw(build lib AFTER_BUILD.txt)));

    ok($after_build_result eq 'after_build', 'Correct `after_build` result');

    my $no_trial_file = path($tzil->tempdir, qw(build lib NO_TRIAL.txt));
    if( $test{trial} ){
        ok( (! -e $no_trial_file), 'is trial - file not written' );

        like $tzil->log_messages->[-1],
            qr{\[Run::AfterBuild\] Not executing, because trial: %x script%pno_trial.pl "%s"},
            'logged skipping of non-trial command';
    }
    else {
        ok( (  -f $no_trial_file), 'non-trial - file present' );
        is $no_trial_file->slurp, ':-P', 'non-trial content';

        my $script = path(script => 'no_trial.pl');
        like $tzil->log_messages->[-2],
            qr{\[Run::AfterBuild\] Executing: .+ \Q$script\E .+},
            'logged execution';

        like $tzil->log_messages->[-1],
            qr{\[Run::AfterBuild\] Command executed successfully},
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
    );
}

test_build();
test_build(trial => 1);

done_testing;
