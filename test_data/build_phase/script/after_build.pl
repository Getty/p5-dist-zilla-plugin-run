use strict;
use warnings;

use Path::Tiny;

path($ARGV[ 0 ], 'lib', 'AFTER_BUILD.txt')->spew("after_build");
