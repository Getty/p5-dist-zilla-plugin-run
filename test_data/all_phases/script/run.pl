use strict;
use warnings;

use Path::Tiny;

#my $fh = path($ARGV[ 0 ], 'lib', 'AFTER_BUILD.txt')->openw();
path(__FILE__)->parent->child('phases.txt')->append_raw(join(' ', @ARGV) . "\n");
