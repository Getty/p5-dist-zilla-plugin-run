use strict;
use warnings FATAL => 'all';

use Test::More;
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';
use Test::DZil;
use Test::Fatal;
use Test::Deep;
use Path::Tiny;

my @config = map {
    my $phase = $_;
    map {
        $_ || $phase eq 'release'
            ? [ 'Run::' . ucfirst($_) . ucfirst($phase) => { eval => [
                "Path::Tiny::path('eval_out.txt')->append_raw('" . ($_ ? "${_}_" : "") . "$phase for [' . \$_[0]->plugin_name . ']' . qq{\\n});" ] } ]
            : ()
        } ('before', '', 'after')
    } qw(build release);

my $tzil = Builder->from_config(
    { dist_root => 't/does-not-exist' },
    {
        add_files => {
            path(qw(source dist.ini)) => simple_ini(
                [ GatherDir => ],
                [ FakeRelease => ],
                @config,
            ),
            path(qw(source lib Foo.pm)) => "package Foo;\n1;\n",
        },
    },
);

$tzil->chrome->logger->set_debug(1);
is(
    exception { $tzil->release },
    undef,
    'build proceeds normally',
);

my $build_dir = path($tzil->tempdir)->child('build');
my $source_dir = path($tzil->tempdir)->child('source');

is(
    $source_dir->child('eval_out.txt')->slurp_raw,
    <<'CONTENT',
before_build for [Run::BeforeBuild]
after_build for [Run::AfterBuild]
before_release for [Run::BeforeRelease]
release for [Run::Release]
after_release for [Run::AfterRelease]
CONTENT
    'all phases evaluate their code directly',
);

cmp_deeply(
    $tzil->log_messages,
    superbagof(
        re(qr/^\Q[Run::BeforeBuild] evaluating: Path::Tiny::path('eval_out.txt')->append_raw('before_build \E/),
        re(qr/^\Q[Run::AfterBuild] evaluating: Path::Tiny::path('eval_out.txt')->append_raw('after_build \E/),
        re(qr/^\Q[Run::BeforeRelease] evaluating: Path::Tiny::path('eval_out.txt')->append_raw('before_release \E/),
        re(qr/^\Q[Run::Release] evaluating: Path::Tiny::path('eval_out.txt')->append_raw('release \E/),
        re(qr/^\Q[Run::AfterRelease] evaluating: Path::Tiny::path('eval_out.txt')->append_raw('after_release \E/),
    ),
    'got diagnostics when code is evaluated',
);

diag 'got log messages: ', explain $tzil->log_messages
    if not Test::Builder->new->is_passing;

done_testing;
