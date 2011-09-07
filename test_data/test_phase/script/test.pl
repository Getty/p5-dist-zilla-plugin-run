#!/usr/bin/env perl

use strict;
use warnings;

use Path::Class;

my $fh = dir($ARGV[ 0 ])->file('test.txt')->openw();

printf $fh "test";

close($fh);

