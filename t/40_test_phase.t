use strict;
use warnings;
use Test::More 0.88;

use Path::Tiny;
use Dist::Zilla::Tester;

{
    my $tzil = Dist::Zilla::Tester->from_config(
        { dist_root => 'test_data/test_phase' },
    );

    $tzil->build();

    my $dir = $tzil->tempdir->subdir('build');
    $tzil->run_tests_in($dir);

    my $test_file   = path($tzil->tempdir, qw(build test.txt));

    ok(-f $test_file, 'Test script has been ran');

    my $content     = $tzil->slurp_file(path(qw(build test.txt)));

    is($content, "test $dir Digest-MD5-0.01", 'Correct `test` result');
}

done_testing;
