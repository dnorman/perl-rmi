package RMI::Proto::JSON_RMI;
use Moose;
use base 'RMI::Proto';
use JSON;


sub dispatch{
      my $self = shift;
      my $body = shift;

      my $ref = from_json( ref($body) eq 'SCALAR' ? $$body : $body );

      my $result =  $self->dispatch_ref( $ref );

      return to_json({
		      status => 200,
		      result => $result,
		     });
}

sub dispatch_ref{
      my ($self, $ref) = @_;
      #use Data::Dumper;
      #print STDERR Dumper($ref);

      ref($ref) eq 'HASH' || RMI::Exception->throw('Must be a JSON object');
      my $service = $self->{service};

      #HERE - Recursion goes here
      if($ref->{object}){
	    my $params = $self->_checkparam( $ref->{params} );
	    return $service->dispatch_object( $ref->{object}, $ref->{method}, $params );

      }elsif($ref->{class}){
	    my $params = $self->_checkparam( $ref->{params} );
	    return $service->dispatch_class($ref->{class}, $ref->{method}, $params );

      }elsif($ref->{struct}){
	    return $self->_checkparam( $ref->{struct} );

      }else{
	    RMI::Exception->throw('Invalid instruction');
      }
}

sub _checkparam{
      my $self = shift;
      my $in = shift;

      my %out;
      foreach ( keys %{$in} ){
	    if( ref $in->{$_} ){
		  $out{$_} = $self->dispatch_ref( $in->{$_} );
	    }else{
		  $out{$_} = $in->{$_};
	    }
      }

      return \%out;
}


sub error{
      my $self = shift;
      my $error = shift;

      return to_json({
		      status => 500,
		      result => undef,
		      error  => $error,
		     });

}

1;
