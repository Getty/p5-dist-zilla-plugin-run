use strict;
use warnings;
use Test::More 0.88;

use lib 't/lib';

use Path::Class;

use Test::DZil;

{
    my $tzil = Dist::Zilla::Tester->from_config(
        { dist_root => 'test_data/all_phases' },
    );

    $tzil->release;
    my $dir = $tzil->tempdir->subdir('build');
    my @txt = split /\n/, $tzil->slurp_file(file(qw(source script phases.txt)));

    my %f = (
        a => 'TestDzilPhases-1.01.tar.gz',
        n => 'TestDzilPhases',
        d => $dir,
        v => '1.01',
    );

    # test constant conversions as well as positional %s for backward compatibility
    my @exp = split /\n/, <<OUTPUT;
before_build $f{v} $f{n} $f{v}
after_build $f{n} $f{v} $f{d} $f{d} $f{v} $f{v}
before_release $f{n} -d $f{d} $f{a} -v $f{v}
release $f{a} $f{n} $f{v} $f{d}/a $f{d}/b
after_release $f{d} $f{v} $f{a} $f{v} $f{n}
OUTPUT

    # provide better test titles
    my @phases = map { /^(\w+) / && $1 } @exp;

    foreach my $i ( 0 .. $#exp ) {
      is($txt[$i], $exp[$i], "expected output from $phases[$i] phase");
    }
}

done_testing;
