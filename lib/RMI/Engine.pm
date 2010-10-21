
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

sub proto{
      my $self = shift;
      my $proto = shift;
      my $service = shift;

      use RMI::Proto::JSON_RMI;
      if($proto eq 'JSON_RMI'){
	    return RMI::Proto::JSON_RMI->new( service => $service );
      }else{
	    RMI::Exception->throw("Unknown protocol $proto");
      }
}



1;
