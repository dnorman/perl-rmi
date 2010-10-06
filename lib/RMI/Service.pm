package RMI::Service;

use Class::Inspector;

sub new {
      my $self = {};
      my %params = @_;
      $self->{base} = %params{base};

      return bless ($self, _PACKAGE_);
}

sub dispatch{
      my $ref = shift;
      if($ref->{object}){
	    #
      }elsif($ref->{class}){
	    print STDERR "GOT CLASS $ref->{class}\n";
	    use Testobj;
	    return Testobj->new;
      }else{
	    die "Invalid instruction"
      }
}

sub getclass{
      my $self = shift;
      my $class = shift;
      # HERE HERE HERE - this is crap

      use Testobj;
      return Testobj->new;

      ###my $fullclass = $self->{base} . '::'
#	eval "require $class";
}
