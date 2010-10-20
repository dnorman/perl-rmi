package RMI::Service;

use Moose;

use Module::Pluggable::Object;
#use RMI::Exception;
#use Class::MOP;
#use Class::Inspector;

has 'baseclass' => (is => 'ro', required => 1);

sub BUILD {
      my $self = shift;
      my $params = shift;

      $self->setup_service;
}

sub dispatch{
      my $ref = shift;
      if($ref->{object}){
	    #
      }elsif($ref->{class}){
	    print STDERR "GOT CLASS $ref->{class}\n";
      }else{
	    die "Invalid instruction"
      }
}

sub getclass{
      my $self = shift;
      my $class = shift;
      # HERE HERE HERE - this is crap

      ###my $fullclass = $self->{base} . '::'
#	eval "require $class";
}

sub setup_service {
    my $self = shift;

    my $locator = Module::Pluggable::Object->new( search_path => $self->baseclass );
    my @mods = $locator->plugins;

    for my $module (@mods) {
	  my $class = $module;
	  $class =~ s/\:\:/\./;
	  print STDERR "Registered: $component\n";
         $self->classes->{ $class } = 1;#$class->setup_component($component);
    #     for my $component ($class->expand_component_module( $component, $config )) {
    #         next if $comps{$component};
    #         $class->_controller_init_base_classes($component); # Also cover inner packages
    #         $class->components->{ $component } = $class->setup_component($component);
    #     }
    }
    
}

1;
