use strict;
use warnings;

package Dist::Zilla::Plugin::Run;
# ABSTRACT: Run external commands at specific phases of Dist::Zilla

=head1 SYNOPSIS

  [Run::AfterBuild]
  run = script/do_this.pl --dir %s --version %s
  run = script/do_that.pl

  [Run::BeforeBuild]
  run = script/do_this.pl --version %s
  run = script/do_that.pl

  [Run::BeforeRelease]
  run = script/myapp_before1.pl %s
  run = script/myapp_before2.pl %n %v
  run_no_trial = script/no_execution_on_trial.pl %n %v

  [Run::Release]
  run = script/myapp_deploy1.pl %s
  run = deployer.pl --dir %d --tgz %a --name %n --version %v
  run_no_trial = script/no_execution_on_trial.pl --dir %d --tgz %a --name %n --version %v

  [Run::AfterRelease]
  run = script/myapp_after.pl --archive %s --version %s
  ; %p can be used as the path separator if you have contributors on a different OS
  run = script%pmyapp_after.pl --archive %s --version %s

  [Run::AfterRelease / MyAppAfter]
  run = script/myapp_after.pl --archive %s --version %s

  [Run::Test]
  run = script/tester.pl --name %n --version %v some_file.ext

  [Run::AfterMint]
  run = some command %d

=head1 DESCRIPTION

Run arbitrary commands at various L<Dist::Zilla> phases.

Use 'run_no_trial' instead of 'run' to only run a given command
if this isn't a I<trial> build/release.

=head1 CONVERSIONS

The following conversions/format specifiers are defined
for passing as arguments to the specified commands
(though not all values are available at all phases).

=for :list
* C<%a> the archive of the release (available to all C<*Release> phases)
* C<%d> the directory in which the dist was built (or minted) (not in C<BeforeBuild>)
* C<%n> the dist name
* C<%p> path separator ('/' on Unix, '\\' on Win32... useful for cross-platform dist.ini files)
* C<%v> the dist version
* C<%x> full path to the current perl interpreter (like $^X but from L<Config>)

Additionally C<%s> is retained for backward compatibility.
Each occurrence is replaced by a different value
(like the regular C<sprintf> function).
Individual plugins define their own values for the positional replacement of C<%s>.

=cut

1;
