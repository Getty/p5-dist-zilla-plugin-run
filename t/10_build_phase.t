use strict;
use warnings;
use Test::More 0.88;

use Path::Class;
use Dist::Zilla::Tester;

sub test_build {
    my %test = @_;

    my $tzil = Dist::Zilla::Tester->from_config(
        { dist_root => 'test_data/build_phase' },
    );

    $tzil->is_trial(1) if $test{trial};
    $tzil->build;

    my $before_build_result = $tzil->tempdir->file(qw(source BEFORE_BUILD.txt));

    ok(-f $before_build_result, 'Before build script has been ran');


    my $after_build_result  = $tzil->slurp_file(file(qw(build lib AFTER_BUILD.txt)));

    ok($after_build_result eq 'after_build', 'Correct `after_build` result');

    my $no_trial_file = $tzil->tempdir->file(qw(build lib NO_TRIAL.txt));
    if( $test{trial} ){
        ok( (! -e $no_trial_file), 'is trial - file not written' );

        like $tzil->log_messages->[-1],
            qr{\[Run::AfterBuild\] Not executing, because trial: %x script%pno_trial.pl "%s"},
            'logged skipping of non-trial command';
    }
    else {
        ok( (  -f $no_trial_file), 'non-trial - file present' );
        is $no_trial_file->slurp, ':-P', 'non-trial content';

        my $script = file(script => 'no_trial.pl');
        like $tzil->log_messages->[-2],
            qr{\[Run::AfterBuild\] Executing: .+ \Q$script\E .+},
            'logged execution';

        like $tzil->log_messages->[-1],
            qr{\[Run::AfterBuild\] Command executed successfully},
            'logged command status';
    }
}

test_build();
test_build(trial => 1);

done_testing;
