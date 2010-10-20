package RMI::Service;

use Moose;
use Module::Pluggable::Object;
use RMI::Exception;
use attributes;
#use Class::MOP;
#use Class::Inspector;

has 'baseclass' => (is => 'ro', required => 1);

sub BUILD {
      my $self = shift;
      my $params = shift;

      $self->setup_service;
}

sub dispatch{
      my $self = shift;
      my $ref = shift;
      use Data::Dumper;
      print STDERR Dumper('Dispatch', $ref);
      if($ref->{object}){
	    #
      }elsif($ref->{class}){
	    my $pkg = $self->class( $ref->{class} );
	    if( $pkg ){
		  my $coderef = $self->_getmethod($pkg,$ref->{method});

		  return $pkg->$coderef(  %{ $ref->{params} }  );
	    }else{
		  RMI::Exception->throw('Invalid class');
	    }
	    print STDERR "GOT CLASS $ref->{class}\n";
	    
      }else{
	    RMI::Exception->throw('Invalid instruction');
      }
}

sub _getmethod{
      my $self = shift;
      my $pkg = shift;
      my $method = shift;

      my $coderef = $self->{ $pkg }{ $method } && return $coderef;

      $coderef = $obj->can($method) or RMI::Exception->throw("Method '$method' is invalid for class '$pkg'");

      #my %attr = map {$_ => 1} attributes::get( $coderef );
      #HERE - DECIDE WHAT attribs to require
      #if($attr{method}){
      #	    return '';
      # }
      return $self->{ $pkg }{ $method } = $coderef;
}

sub setup_service {
    my $self = shift;

    my $locator = Module::Pluggable::Object->new( search_path => $self->baseclass );
    my @mods = $locator->plugins;

    for my $module (@mods) {
	  my $class = $module;
	  $class =~ s/\:\:/\./;
	  eval { Class::MOP::load_class($module) };
	  if ($@){
		print STDERR "FAILED to register $class\n";
	  }else{
		print STDERR "Registered: $class\n";
		$self->{classes}->{ $class } = $module;
	  }
    }
    
}

sub class{
      my $self = shift;
      my $class = shift;
      return $self->{classes}->{ $class }
}


1;
