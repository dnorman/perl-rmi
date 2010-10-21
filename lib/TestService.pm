package TestService;

use strict;
use base 'RMI';
__PACKAGE__->setup();

sub new {
      my $package = shift;
      return bless({}, $package);
}
sub foo{ 123 }
use Data::Dumper;
sub dumper{ my $self = shift; Dumper( [@_] ) };

1;
