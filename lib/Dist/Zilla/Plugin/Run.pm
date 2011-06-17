package Dist::Zilla::Plugin::Run;
# ABSTRACT: Running external commands on specific hooks of Dist::Zilla
use strict;
use warnings;

=head1 SYNOPSIS

  [Run::BeforeRelease]
  run = script/myapp_before1.pl %s
  run = script/myapp_before2.pl %s

  [Run::Release]
  run = script/myapp_deploy1.pl %s
  run = script/myapp_deploy2.pl %s

  [Run::AfterRelease]
  run = script/myapp_after.pl %s

=head1 DESCRIPTION

Run arbitrary commands at various L<Dist::Zilla> phases.

=cut

1;
