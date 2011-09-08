use strict;
use warnings;
use Test::More 0.88;

use Path::Class;

use Dist::Zilla::Tester;

{
    my $tzil = Dist::Zilla::Tester->from_config(
        { dist_root => 'test_data/test_phase' },
    );

    $tzil->build();

    $tzil->run_tests_in($tzil->tempdir->subdir('build'));
    
    my $test_file   = $tzil->tempdir->file(qw(build test.txt));
    
    ok(-f $test_file, 'Test script has been ran');
    
    
    my $content     = $tzil->slurp_file(file(qw(build test.txt)));
    
    ok($content eq 'test', 'Correct `test` result');
}

done_testing;
