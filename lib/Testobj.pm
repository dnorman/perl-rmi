package Testobj;

use parent 'RMI';
_PACKAGE_->setup( name => 'Testobj' );

sub new { return bless({},_PACKAGE_) }
sub foo{ 123 } 


