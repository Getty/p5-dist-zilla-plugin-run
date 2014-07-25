use strict;
use warnings;
use Path::Tiny;

path($ARGV[0], 'lib', 'NO_TRIAL.txt')->spew(":-P");
