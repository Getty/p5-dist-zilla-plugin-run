use strict;
use warnings;
use Test::More 0.88;
use Test::DZil;
use Path::Class;

use Test::File::ShareDir -share => {
  -module => { 'Dist::Zilla::MintingProfile::Default' => 'test_data/profiles' },
};

{
  my $tzil = Minter->_new_from_profile(
    [ Default => 'default' ],
    { name    => 'DZT-Minty' ,},
    { global_config_root => dir('test_data/global')->absolute },    # sadly, this must quack like a Path::Class for now
  );

  $tzil->mint_dist();

  my $dir = $tzil->tempdir->subdir(qw(mint empty_dir));

  ok -d $dir, 'created directory in mint dir';

  is_deeply [$dir->children], [], 'dir is empty but exists';

  like $tzil->slurp_file('mint/lib/DZT/Minty.pm'),
    qr/package DZT::Minty;/,
    'minted regular file';

  like $tzil->slurp_file('mint/minted_at.txt'),
    qr/DZT-Minty minted at \d+/,
    'created file the hard way';
}

done_testing;
