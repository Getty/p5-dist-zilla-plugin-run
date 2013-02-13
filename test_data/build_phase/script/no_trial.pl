#!/usr/bin/env perl

use strict;
use warnings;
use Path::Class;

dir($ARGV[0], 'lib')->file('NO_TRIAL.txt')->openw()->print(":-P");
