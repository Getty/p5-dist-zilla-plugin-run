#!/usr/bin/perl

use strict;
use warnings;

use Path::Class;

my $fh = dir($ARGV[ 0 ], 'lib')->file('AFTER_BUILD.txt')->openw();

printf $fh "after_build";

close($fh);