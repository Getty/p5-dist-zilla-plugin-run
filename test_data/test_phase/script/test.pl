use strict;
use warnings;

use Path::Tiny;

path($ARGV[ 0 ], 'test.txt')->spew(join(' ', test => @ARGV));

