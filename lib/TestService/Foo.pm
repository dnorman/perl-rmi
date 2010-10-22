package TestService::Foo;
use base 'TestService';

return 1;

sub echo{
      my $self = shift;
      return shift;
}
sub dumper{
      my $self = shift;
      my $in = shift;
      use Data::Dumper;
      print STDERR Dumper( $in );
      return 1;
}
sub nested{
      my $self = shift;
      my $in = shift;

      return {
	      in  => $in,
	      A => { B => { C => 123, D => [4,5,6], E => [{F => 7},{ G => 8 }] } },
	      H => [ 9,10 ]
	     }
}
