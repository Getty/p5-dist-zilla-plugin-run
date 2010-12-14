package Dist::Zilla::Plugin::Run;
# ABSTRACT: Overview Module - just documentation
use strict;
use warnings;

=head1 SYNOPSIS

  [Run::BeforeRelease]
  run = script/myapp_before.pl %s

  [Run::Release]
  run = script/myapp_deploy.pl %s

  [Run::AfterRelease]
  run = script/myapp_after.pl %s

=cut

1;
