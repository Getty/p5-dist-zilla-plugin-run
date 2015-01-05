use strict;
use warnings;
use Test::More 0.88;
use Test::DZil;
use Path::Tiny;

{
    my $tzil = Builder->from_config(
        { dist_root => 't/does-not-exist' },
        {
            add_files => {
                path(qw(source dist.ini)) => simple_ini(
                    [ GatherDir => ],
                    [ MetaConfig => ],

                    [ 'Run::BeforeBuild' => { run => [ '%x script%prun.pl before_build %s %n %v .%d.%a. %x' ] } ],
                    [ 'Run::AfterBuild' => { run => [ '%x script%prun.pl after_build %n %v %d %s %s %v .%a. %x' ] } ],
                    [ 'Run::BeforeRelease' => { run => [ '%x script%prun.pl before_release %n -d %d %s -v %v .%a. %x' ] } ],
                    [ 'Run::Release' => { run => [ '%x script%prun.pl release %s %n %v %d/a %d/b %a %x' ] } ],
                    [ 'Run::AfterRelease' => { run => [ '%x script%prun.pl after_release %d %v %s %s %n %a %x' ] } ],
                ),
                path(qw(source lib Foo.pm)) => "package Foo;\n1;\n",
                path(qw(source script run.pl)) => <<'SCRIPT',
use strict;
use warnings;

use Path::Tiny;

path('.')->child('phases.txt')->append_raw(join(' ', @ARGV) . "\n");
SCRIPT
            },
        },
    );

    $tzil->chrome->logger->set_debug(1);
    $tzil->release;

    my %f = (
        a => 'DZT-Sample-0.001.tar.gz',
        n => 'DZT-Sample',
        d => path($tzil->tempdir)->child('build')->canonpath, # use OS-specific path separators
        v => '0.001',
        x => Dist::Zilla::Plugin::Run::Role::Runner->current_perl_path,
    );

    # test constant conversions as well as positional %s for backward compatibility
    my $expected = <<OUTPUT;
before_build $f{v} $f{n} $f{v} ... $f{x}
after_build $f{n} $f{v} $f{d} $f{d} $f{v} $f{v} .. $f{x}
before_release $f{n} -d $f{d} $f{a} -v $f{v} .$f{a}. $f{x}
release $f{a} $f{n} $f{v} $f{d}/a $f{d}/b $f{a} $f{x}
after_release $f{d} $f{v} $f{a} $f{v} $f{n} $f{a} $f{x}
OUTPUT

    is(
        path($tzil->tempdir)->child(qw(source phases.txt))->slurp_raw,
        $expected,
        'got expected output for all five phases',
    );

    diag 'got log messages: ', explain $tzil->log_messages
        if not Test::Builder->new->is_passing;
}

done_testing;
