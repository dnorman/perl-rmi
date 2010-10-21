package RMI::Proto;
use Moose;

has service => ( is => 'ro', required => 1 );

sub error{
      my $self = shift;
      my $message = shift;
      push @{ $self->{errors} }, $message;

      return 1;
}
1;
