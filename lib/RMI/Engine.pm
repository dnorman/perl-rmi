
package RMI::Engine;

sub new { bless {}, shift }

sub register_service{
      my $self = shift;
      my $class = shift;
      my $service = shift;

      $self->{services}->{ $class } = $service;
}

sub service{
      my $self = shift;
      my $class = shift;
      return $self->{services}->{ $class };
}


1;
