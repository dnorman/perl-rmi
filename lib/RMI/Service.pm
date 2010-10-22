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

sub dispatch_class {
      my $self   = shift;
      my $class  = shift;
      my $method = shift;
      my $params = shift;
      use Data::Dumper;
      print STDERR Dumper($class,$method,$params);

      my $pkg = $self->class( $class );
      if( $pkg ){
	    my $coderef = $self->_getmethod($pkg, $method);
	    return $pkg->$coderef(  $params  );
      }else{
	    RMI::Exception->throw('Invalid class');
      }
}

sub _getmethod{
      my $self = shift;
      my $pkg = shift;
      my $method = shift;

      my $coderef = $self->{ $pkg }{ $method };
      return $coderef if $coderef;

      $coderef = $pkg->can($method) or RMI::Exception->throw("Method '$method' is invalid for class '$pkg'");

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
