# vim: set ts=2 sts=2 sw=2 expandtab smarttab:
#
# This file is part of AnyEvent-HTTP-Message
#
# This software is copyright (c) 2012 by Randy Stauner.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
use strict;
use warnings;

package AnyEvent::HTTP::Request;
{
  $AnyEvent::HTTP::Request::VERSION = '0.100';
}
BEGIN {
  $AnyEvent::HTTP::Request::AUTHORITY = 'cpan:RWSTAUNER';
}
# ABSTRACT: HTTP Request object for AnyEvent::HTTP

use parent 'AnyEvent::HTTP::Message';
use Carp ();


sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);

  $self->{method} = uc $self->{method};

  # allow these to be constructor arguments
  # but store them in params to keep things simple
  foreach my $key ( qw( body headers ) ){
    $self->{params}->{$key} = delete $self->{$key}
      if exists $self->{$key};
  }

  if( my $h = $self->{params}->{headers} ){
    $self->{params}->{headers} = $self->_normalize_headers($h);
  }

  return $self;
}


sub parse_args {
  my $self = shift;

  Crap::croak( join ' ',
    (ref($self) || $self),
    q[expects an odd number of arguments:],
    q[($method, $uri, (key => value, ...)*, \&callback)]
  )
    unless @_ & 1; ## no critic BitwiseOperators

  my $args = {
    method => shift,
    uri    => shift,
    cb     => pop,
    params => { @_ },
  };
  return $args;
}


sub args {
  my ($self) = @_;
  return (
    $self->method => $self->uri,
    %{ $self->params },
    $self->cb,
  );
}


sub method  { $_[0]->{method} }
sub uri     { $_[0]->{uri}    }
sub cb      { $_[0]->{cb}     }
sub params  { $_[0]->{params} ||= {} }


sub headers { $_[0]->params->{headers} ||= {} }
sub body    { $_[0]->params->{body} }


sub send {
  my ($self) = @_;
  require AnyEvent::HTTP;
  # circumvent the sub's prototype
  &AnyEvent::HTTP::http_request( $self->args );
}

1;


__END__
=pod

=for :stopwords Randy Stauner ACKNOWLEDGEMENTS TODO featureful http uri cb params

=encoding utf-8

=head1 NAME

AnyEvent::HTTP::Request - HTTP Request object for AnyEvent::HTTP

=head1 VERSION

version 0.100

=head1 SYNOPSIS

  # parse argument list for AnyEvent::HTTP::http_request
  AnyEvent::HTTP::Request->new(GET => $uri, %params, sub { ... });

  # or use a hashref of named arguments
  AnyEvent::HTTP::Request->new({
    method  => 'POST',
    uri     => 'http://example.com',
    cb      => sub { ... },
    params  => \%params,
    headers => \%headers,
    body    => $body,
  });

=head1 DESCRIPTION

This class creates a lightweight object
to represent an HTTP request as used by L<AnyEvent::HTTP>.

It was created to provide simple, clear test code
for parsing the parameters passed to L<AnyEvent::HTTP/http_request>.

Instead of code that looks something like this:

  is $args[0],       'POST',              'request method';
  is $args[1],       'http://some/where', 'request uri';
  is ref($args[-1]), 'CODE',              'http_request callback';
  is_deeply { @args[ 2 .. $#args - 1 ] }->{headers},
    \%expected_headers, 'request headers';

You can write clearer, simpler code like this:

  my $req = AnyEvent::HTTP::Request->new(@args);

  is $req->method,  'POST',              'request method';
  is $req->uri,     'http://some/where', 'request uri';
  is ref($req->cb), 'CODE',              'http_request callback';
  is_deeply $req->headers, \%expected_headers, 'request headers';

It's a little less weird, and easier to maintain (and do again).

This class also allows you to build an object by passing a hashref
of named parameters in case you'd prefer that.
You can then call L</send> to actually make the request
(via L<AnyEvent::HTTP/http_request>),
or L</args> to get the list of arguments the object would pass.

=head1 CLASS METHODS

=head2 new

See L</SYNOPSIS> for usage example.

Accepts a list of arguments
(like those that would be passed
to
L<AnyEvent::HTTP/http_request>)
which will be passed through L</parse_args>.

Alternatively a single hashref can be passed
with anything listed in L</ATTRIBUTES> as the keys.

=head2 parse_args

Called by the constructor
to parse the argument list
for
L<AnyEvent::HTTP/http_request>
and return a hashref which will be the basis for the object.

The list should look like
C<< ($method, $uri, %params, \&callback) >>.

=head1 ATTRIBUTES

=head2 method

Request method (GET, POST, etc)
(first argument to L<AnyEvent::HTTP/http_request>)

=head2 uri

Request uri (string)
(second argument to L<AnyEvent::HTTP/http_request>)

=head2 cb

Callback subroutine reference
(last argument to L<AnyEvent::HTTP/http_request>)

=head2 params

A hashref of the function parameters
(optional middle (key => value) arguments to L<AnyEvent::HTTP/http_request>)

B<Note> that these are connection params like
C<persistent> and C<timeout>,
not query params like in C<CGI>.

=head2 headers

A hashref of the HTTP request headers
(the C<headers> key of L</params>)

=head2 body

Request content body (if any)
(the C<body> key of L</params>)

=head2 content

Alias for L</body>

=head1 METHODS

=head2 args

Returns a list of arguments that can be passed to
L<AnyEvent::HTTP/http_request>
(beware the sub's prototype, though).

=head2 send

Actually submit the request by passing L</args>
to L<AnyEvent::HTTP/http_request>

=for test_synopsis my ($body, %params, %headers, $uri);

=head1 TODO

=over 4

=item *

Provide conversion to/from more featureful L<HTTP::Request>

=back

=head1 SEE ALSO

=over 4

=item *

L<AnyEvent::HTTP::Message> (base class)

=back

=head1 AUTHOR

Randy Stauner <rwstauner@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Randy Stauner.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

