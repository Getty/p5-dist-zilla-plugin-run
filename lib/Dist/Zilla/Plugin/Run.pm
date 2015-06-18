use strict;
use warnings;

package Dist::Zilla::Plugin::Run;
# ABSTRACT: Run external commands and code at specific phases of Dist::Zilla
# KEYWORDS: plugin tool distribution build release run command shell execute

our $VERSION = '0.040';

1;
__END__

=pod

=head1 SYNOPSIS

  [Run::AfterBuild]
  run = script/do_this.pl --dir %s --version %s
  run = script/do_that.pl
  eval = unlink scratch.dat

  [Run::BeforeBuild]
  fatal_errors = 0
  run = script/do_this.pl --version %s
  run = script/do_that_crashy_thing.pl
  eval = if ($ENV{SOMETHING}) {
  eval =   $_[0]->log('some message')
  eval = }

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
  run_if_release = ./Build install
  run_if_release = make install

  [Run::AfterMint]
  run = some command %d
  eval = unlink scratch.dat
  eval = print "I just minted %n for you. Have a nice day!\n";

=head1 DESCRIPTION

Run arbitrary commands and code at various L<Dist::Zilla> phases.

=head1 PARAMETERS

=head2 run

Run the specific command at the specific L<Dist::Zilla> phase given by the
plugin. For example, C<[Run::Release]> runs during the release phase.

=head2 run_if_trial

Only run the given command if this is a I<trial> build or release.

=head2 run_no_trial

Only run the given command if this isn't a I<trial> build or release.

=head2 run_if_release

Only run the given command if this is a release.

=head2 run_no_release

Only run a given command if this isn't a release.

=head2 eval (EXPERIMENTAL)

Treats the input as a list of lines of Perl code; the code is evaluated at the
specific L<Dist::Zilla> phase given by the plugin. The code is executed in its
own C<eval> scope, within a subroutine body; C<@_> contains the instance of the
plugin executing the code. (Remember that C<shift> in an C<eval> actually
operates on C<@ARGV>, not C<@_>, so to access the plugin instance, use
C<$_[0]>.)

=head2 censor_commands

Normally, C<run*> commands are included in distribution metadata when used
with the L<[MetaConfig]|Dist::Zilla::Plugin::MetaConfig> plugin. To bypass
this, set C<censor_commands = 1>.  Additionally, this command is set to true
automatically when a URL with embedded password is present.

Defaults to false.

=head2 fatal_errors

When true, if the C<run> command returns a non-zero exit status or the C<eval>
command dies, the build will fail. Defaults to true.

=head2 quiet

When true, diagnostic messages are not printed (except in C<--verbose> mode).

Defaults to false.

=head1 EXECUTION ORDER

All commands for a given option name are executed together, in the order in
which they are documented above.  Within commands of the same option name,
order is preserved (from the order provided in F<dist.ini>).

=head1 CONVERSIONS

The following conversions/format specifiers are defined
for passing as arguments to the specified commands and eval strings
(though not all values are available at all phases).

=for :list
* C<%a> the archive of the release (available to all C<*Release> phases)
* C<%d> the directory in which the dist was built (or minted) (not in C<BeforeBuild>)
* C<%n> the dist name
* C<%p> path separator ('/' on Unix, '\\' on Win32... useful for cross-platform dist.ini files)
* C<%v> the dist version
* C<%t> C<-TRIAL> if the release is a trial release, otherwise the empty string
* C<%x> full path to the current perl interpreter (like $^X but from L<Config>)

Additionally C<%s> is retained for backward compatibility.
Each occurrence is replaced by a different value
(like the regular C<sprintf> function).
Individual plugins define their own values for the positional replacement of C<%s>.

B<NOTE>: when using filenames (e.g. C<%d>, C<%n> and C<%x>), be mindful that
these paths could contain special characters or whitespace, so if they are to
be used in a shell command, take care to use quotes or escapes!

=head1 DANGER! SECURITY RISK!

The very nature of these plugins is to execute code. Be mindful that your code
may run on someone else's machine and don't be a jerk!

=cut
