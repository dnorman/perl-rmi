package RMI::Engine::Apache2;

use strict;
use base 'RMI::Engine';
#use attributes;
use Apache2::Request;
use Apache2::RequestIO;
use Apache2::RequestUtil;
use Apache2::Const -compile => qw(OK);
use Data::Dumper;
use JSON;
use constant {
      MAX_BYTES => 5_000_000
};

my $service;
sub handler : method{
      my $self = shift;
      my $obj = shift;
      my $r = shift;
      my $req = Apache2::Request->new($r);


      print "LOOK $self,$obj\n";
      my $config = $r->dir_config();
      $r->no_cache(1);

      my $data = $req->param;
      my $buf;

      my $bytes = $r->headers_in->{'content-length'};
      if($bytes > 0 && $bytes < MAX_BYTES){
	    $r->read($buf, $bytes);
	    my $ref = from_json($buf ) or die "Invalid JSON";
	    print Dumper( $ref, $config );

	    # $service ||= RMI::Service->new( base => $config->{BaseModule} );
	    # $service->dispatch( $ref );
      }
      return Apache2::Const::OK; # or another status constant
}

sub get_mode{
      my $obj = shift;
      my $method = shift;

      my $ref = $obj->can($method);
      return undef unless $ref;

      my %attr = map {$_ => 1} attributes::get( $ref );

      if($attr{method}){
	    return '';
      }
      if($attr{attrib}){
	    return 'html';
      }

      return undef;
}

1;

=pod

my $item = $client->Ecom_Order_Item->new(
                                         product_id => 123,
                                         quantity => 1
                                        );
$item->allocate or die "Failed to allocate";

my $order = $client->Ecom_Order->new(
                                     items => [ $item, $item2 ]
                                    );
$order->commit;


Request:

{
 class:  'ECom.Order.Item',
 method: 'new',
 params: { product_id: 123, quantity: 1 }
}
Response:

{
status: 200,
result: {
         object: '1-123456789',
         expires: 'yyy-mm-dd 00:00:00',
         proto: {
                 methods: ['allocate','commit','release']
                 properties: ['product_id','quantity']
                }
         }
}
Request:

{
 class:  'ECom.Order',
 method: 'new',
 params: {
          items: [
                  {object: '1-1234567890'},
                  {object: '1-1234567891'}
                 ],
         }
}
Response:

{
status: 200,
result: {
         object: '2-123456789', // 2- indicates the server where the object exists
         expires: 'yyy-mm-dd 00:00:00',
         proto: {
                 methods: ['commit','cancel']
                 properties: ['order_id','items']
                }
         }
}
Alternately, chaining:

{
 class:  'ECom.Order',
 method: 'new',
 params: {
          items: [
                  {
                    class:  'ECom.Order.Item',
                    method: 'new',
                    params: { product_id: 123, quantity: 1 }
                  },
                  {object: '2-1234567891'},
                  {object: '1-0987654321', method: make_item, params: { whatever: 123 } }
                 ],
         }
}
Response:

{
status: 200,
result: {
         object: '2-123456789', // 2- indicates the server where the object exists
         expires: 'yyy-mm-dd 00:00:00',
         proto: {
                 methods: ['commit','cancel']
                 properties: ['order_id','items']
                }
         }
}

=cut
