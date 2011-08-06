use strict;
use warnings;
use Test::More 0.88;

use lib 't/lib';

use Test::DZil;

{
    my $tzil = Dist::Zilla::Tester->from_config(
        { dist_root => 'test_data/all_phases' },
    );

    my $dir = 'fake';

    my %f = (
        a => 'TestDzilPhases-1.01.tar.gz',
        n => 'TestDzilPhases',
        d => $dir,
        v => '1.01',
    );

    my $formatter = $tzil->plugin_named('Run::AfterRelease')->build_formatter({
        archive   => $f{a},
        dir       => $dir,
        pos       => [qw(run run reindeer)]
    });

    is $formatter->format('snowflakes/%v|%n\\%s,%s,%s,%s in %d(%a)'),
        "snowflakes/$f{v}|$f{n}\\run,run,reindeer, in $f{d}($f{a})",
        'correct formatting';

    is $formatter->format('%v%s%n'), "$f{v}$f{n}", 'ran out of %s (but not the constants)';
}

done_testing;
