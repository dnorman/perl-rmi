package RMI;
use RMI::Service;

use strict;
# sub import {
#       my $pkg = shift;
#       print STDERR "IMPORT $pkg\n";
#       $pkg->setup(@_);
# }

sub setup {
    my ( $class, %param ) = @_;
    my $service = RMI::Service->new(baseclass => $class, %param);

    $class->setup_engine ( $param{engine} );
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

1;
