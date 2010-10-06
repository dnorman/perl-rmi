package RMI;

use Module::Pluggable::Object;
use RMI::Exception;
use Class::MOP;

# sub import {
#       my $pkg = shift;
#       print STDERR "IMPORT $pkg\n";
#       $pkg->setup(@_);
# }

sub setup {
    my ( $class, %param ) = @_;

    $class->setup_engine(  delete $param{engine} );
    #$class->setup_service(   delete $param{class} );
}

sub setup_engine {
      my ( $class, $engine ) = @_;
      print STDERR "SETUP_ENGINE ($class)\n";
      $engine = 'RMI::Engine::' . $engine if $engine;
      my $eobj;
      if ( $ENV{MOD_PERL} ) {

	    #my $meta = Class::MOP::get_metaclass_by_name($class);
	    # create the apache method
	    #$meta->add_method('apache' => sub { shift->engine->apache });

	    my ( $software, $version ) = $ENV{MOD_PERL} =~ /^(\S+)\/(\d+(?:[\.\_]\d+)+)/;

	    $version =~ s/_//g;
	    $version =~ s/(\.[^.]+)\./$1/g;

	    if ( $software eq 'mod_perl' ) {
		  if ( !$engine ) {
			if     ( $version >= 1.99922 ) {
			      $engine = 'RMI::Engine::Apache2'
			}elsif ( $version >= 1.9901  ) {
			      $engine = 'RMI::Engine::Apache2'
			}elsif ( $version >= 1.24    ) {
			      $engine = 'RMI::Engine::Apache'
			}else {
			      RMI::Exception->throw( "Unsupported mod_perl version: $ENV{MOD_PERL}" );
			}
		  }

		  # install the correct mod_perl handler
		  if ( $version >= 1.9901 ) {
			*handler = sub : method { $eobj->handler( @_ ) };
		  }else {
			*handler = sub ($$)     { $eobj->handler( @_ ) };
		  }

	    }else {
		  RMI::Exception->throw( "Unsupported mod_perl: $ENV{MOD_PERL}" );
	    }
      }

      unless ($engine) {
	    $engine = 'RMI::Engine'
      }

      print STDERR "ENGINE: $engine\n";
      Class::MOP::load_class($engine);
      $eobj = $engine->new;

      # # engine instance
      # $class->engine( $engine->new );
}

sub handle_request{
      
}

sub locate_components {
    my $class  = shift;
    my $config = shift;

    my @paths   = qw( ::Controller ::C ::Model ::M ::View ::V );
    my $extra   = delete $config->{ search_extra } || [];

    push @paths, @$extra;

    my $locator = Module::Pluggable::Object->new(
        search_path => [ map { s/^(?=::)/$class/; $_; } @paths ],
        %$config
    );

    my @comps = $locator->plugins;

    return @comps;
}

sub setup_service {
    my $class = shift;

    my $config  = $class->config->{ setup_components };

    my @comps = sort { length $a <=> length $b }
                $class->locate_components($config);
    my %comps = map { $_ => 1 } @comps;


    for my $component ( @comps ) {
        # We pass ignore_loaded here so that overlay files for (e.g.)
        # Model::DBI::Schema sub-classes are loaded - if it's in @comps
        # we know M::P::O found a file on disk so this is safe

        Catalyst::Utils::ensure_class_loaded( $component, { ignore_loaded => 1 } );

        # Needs to be done as soon as the component is loaded, as loading a sub-component
        # (next time round the loop) can cause us to get the wrong metaclass..
        $class->_controller_init_base_classes($component);
    }

    for my $component (@comps) {
        $class->components->{ $component } = $class->setup_component($component);
        for my $component ($class->expand_component_module( $component, $config )) {
            next if $comps{$component};
            $class->_controller_init_base_classes($component); # Also cover inner packages
            $class->components->{ $component } = $class->setup_component($component);
        }
    }


    RMI::Service->new( base => $config->{BaseModule} );
    
}

1;
