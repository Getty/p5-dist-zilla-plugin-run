use strict;
use warnings;
use Test::More 0.88;
use Test::Deep;
use Dist::Zilla::Tester;

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

    cmp_deeply(
        $tzil->distmeta,
        superhashof({
            x_Dist_Zilla => superhashof({
                plugins => supersetof(
                    {
                        class => 'Dist::Zilla::Plugin::Run::BeforeBuild',
                        config => {
                            'Dist::Zilla::Plugin::Run::Role::Runner' => {
                                run => [ '%x script%prun.pl before_build %s %n %v .%d.%a. %x' ],
                            },
                        },
                        name => 'Run::BeforeBuild',
                        version => ignore,
                    },
                    {
                        class => 'Dist::Zilla::Plugin::Run::AfterBuild',
                        config => {
                            'Dist::Zilla::Plugin::Run::Role::Runner' => {
                                run => [ '%x script%prun.pl after_build %n %v %d %s %s %v .%a. %x' ],
                            },
                        },
                        name => 'Run::AfterBuild',
                        version => ignore,
                    },
                    {
                        class => 'Dist::Zilla::Plugin::Run::BeforeRelease',
                        config => {
                            'Dist::Zilla::Plugin::Run::Role::Runner' => {
                                run => [ '%x script%prun.pl before_release %n -d %d %s -v %v .%a. %x' ],
                            },
                        },
                        name => 'Run::BeforeRelease',
                        version => ignore,
                    },
                    {
                        class => 'Dist::Zilla::Plugin::Run::Release',
                        config => {
                            'Dist::Zilla::Plugin::Run::Role::Runner' => {
                                run => [ '%x script%prun.pl release %s %n %v %d/a %d/b %a %x' ],
                            },
                        },
                        name => 'Run::Release',
                        version => ignore,
                    },
                    {
                        class => 'Dist::Zilla::Plugin::Run::AfterRelease',
                        config => {
                            'Dist::Zilla::Plugin::Run::Role::Runner' => {
                                run => [ '%x script%prun.pl after_release %d %v %s %s %n %a %x' ],
                            },
                        },
                        name => 'Run::AfterRelease',
                        version => ignore,
                    },
                ),
            }),
        }),
        'dumped configs are good',
    );
}

done_testing;
