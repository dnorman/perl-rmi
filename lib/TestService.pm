package TestService;

use strict;
use base 'RMI';
__PACKAGE__->setup();

sub new { return bless({},__PACKAGE__) }
sub foo{ 123 }


1;
