use strict;
use warnings;

package Dist::Zilla::Plugin::Run::AfterMint;
# ABSTRACT: Execute a command after a new distribution is minted

our $VERSION = '0.043';

use Moose;
with qw(
  Dist::Zilla::Role::AfterMint
  Dist::Zilla::Plugin::Run::Role::Runner
);

use namespace::autoclean;

sub after_mint {
  my ($self, $param) = @_;
  $self->_call_script({
    dir     => $param->{mint_root},
    minting => 1,
  });
}

=head1 SYNOPSIS

  [Run::AfterMint]
  run = some command %d

=head1 DESCRIPTION

This plugin executes the specified command after minting a new distribution.

=head1 CONVERSIONS

See L<Dist::Zilla::Plugin::Run/CONVERSIONS>
for the list of common formatting variables available to all plugins.

=cut

1;
