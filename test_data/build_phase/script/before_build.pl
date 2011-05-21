#!/usr/bin/env perl

use strict;
use warnings;

use Path::Class;

my $fh = file("BEFORE_BUILD.txt")->openw();

close($fh);
