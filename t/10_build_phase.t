use strict;
use warnings;
use Test::More 0.88;

use Path::Class;
use Dist::Zilla::Tester;

{
    my $tzil = Dist::Zilla::Tester->from_config(
        { dist_root => 'test_data/build_phase' },
    );

    $tzil->build;
    
    my $before_build_result = $tzil->tempdir->file(qw(source BEFORE_BUILD.txt));
    
    ok(-f $before_build_result, 'Before build script has been ran');
    
    
    my $after_build_result  = $tzil->slurp_file(file(qw(build lib AFTER_BUILD.txt)));
    
    ok($after_build_result eq 'after_build', 'Correct `after_build` result');
}

done_testing;
