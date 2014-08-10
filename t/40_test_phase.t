use strict;
use warnings;
use Test::More 0.88;
use Path::Tiny;
use Test::DZil;

{
    my $tzil = Builder->from_config(
        { dist_root => 't/does-not-exist' },
        {
            add_files => {
                path(qw(source dist.ini)) => simple_ini(
                    [ GatherDir => ],
                    [ 'Run::Test' => { run => [ '%x script%ptest.pl "%d" %n-%v' ] } ],
                    [ FakeRelease => ],
                ),
                path(qw(source lib Foo.pm)) => "package Foo;\n1;\n",
                path(qw(source script test.pl)) => <<'SCRIPT',
use strict;
use warnings;
use Path::Tiny;
path($ARGV[ 0 ], 'test.txt')->spew(join(' ', test => @ARGV));
SCRIPT
            },
        },
    );

    $tzil->build();

    my $build_dir = path($tzil->tempdir)->child('build');
    $tzil->run_tests_in($build_dir);

    my $test_file   = $build_dir->child('test.txt');

    ok(-f $test_file, 'Test script has been ran');

    my $content     = $tzil->slurp_file(path(qw(build test.txt)));

    is($content, "test $build_dir DZT-Sample-0.001", 'Correct `test` result');
}

done_testing;
