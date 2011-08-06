package Dist::Zilla::Plugin::Run;
# ABSTRACT: Running external commands on specific hooks of Dist::Zilla
use strict;
use warnings;

=head1 SYNOPSIS

  [Run::BeforeRelease]
  run = script/myapp_before1.pl %s
  run = script/myapp_before2.pl %n %v

  [Run::Release]
  run = script/myapp_deploy1.pl %s
  run = deployer.pl --dir %d --tgz %a --name %n --version %v

  [Run::AfterRelease]
  run = script/myapp_after.pl %s %v

=head1 DESCRIPTION

Run arbitrary commands at various L<Dist::Zilla> phases.

=head1 CONVERSIONS

The following conversions/format specifiers are defined
for passing as arguments to the specified commands
(though not all values are available at all phases).

=for :list
* C<%a> the archive of the release (available to all C<*Release> phases)
* C<%d> the directory in which the dist was built (not in C<BeforeBuild>)
* C<%n> the dist name
* C<%v> the dist version

Additionally C<%s> is retained for backward compatibility.
Each occurrence is replaced by a different value
(like the regular C<sprintf> function).
Individual plugins define their own values for the positional replacement of C<%s>.

=cut

1;
