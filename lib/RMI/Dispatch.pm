package RMI::Service;

use Class::Inspector;

sub dispatch{
      my $ref = shift;
      if($ref->{object}){
	    #
      }elsif($ref->{class}){
	    
      }else{
	    die "Invalid instruction"
      }
}
