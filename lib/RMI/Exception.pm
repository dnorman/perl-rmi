package RMI::Exception;

use Moose;
use Carp;

has message => (
    is      => 'ro',
    isa     => 'Str',
    default => sub { $! || '' },
);

use overload 
  '""'     => \&as_string_nl,
  fallback => 1;

sub as_string {
    my ($self) = @_;
    return $self->message;
}

sub as_string_nl {
    my ($self) = @_;
    return $self->message . "\n";
}

around BUILDARGS => sub {

    my ($next, $class, @args) = @_;
    if (@args == 1 && !ref $args[0]) {
        @args = (message => $args[0]);
    }

    my $args = $class->$next(@args);
    $args->{message} ||= $args->{error} if exists $args->{error};

    return $args;
};

sub throw {
    my $class = shift;
    my $error = $class->new(@_);
    local $Carp::CarpLevel = 1;
    croak $error;
}

sub rethrow {
    my ($self) = @_;
    croak $self;
}

__PACKAGE__->meta->make_immutable;

1;
