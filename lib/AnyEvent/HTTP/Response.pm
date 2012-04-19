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

package AnyEvent::HTTP::Response;
{
  $AnyEvent::HTTP::Response::VERSION = '0.100';
}
BEGIN {
  $AnyEvent::HTTP::Response::AUTHORITY = 'cpan:RWSTAUNER';
}
# ABSTRACT: HTTP Response object for AnyEvent::HTTP

use parent 'AnyEvent::HTTP::Message';
use Carp ();


sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);

  if( my $h = $self->{headers} ){
    $self->{headers} = $self->_normalize_headers($h);
  }

  return $self;
}


sub args {
  my ($self) = @_;
  return (
    $self->body,
    {
      %{ $self->headers },
      %{ $self->pseudo_headers },
    },
  );
}


sub parse_args {
  my $self = shift;
  Crap::croak(
    (ref($self) || $self) .
    q[ expects two arguments: ($content_body, \%headers)]
  )
    unless @_ == 2;

  my $args  = {
    body    =>      $_[0],
  };

  my %headers = %{ $_[1] };
  my %pseudo;
  {
    my @pseudo = grep { /^[A-Z]/ } keys %headers;
    # remove the ae-http pseudo-headers (init-capped)
    @pseudo{ @pseudo } = delete @headers{ @pseudo };
  }
  @$args{qw(headers pseudo_headers)} = (\%headers, \%pseudo);

  return $args;
}


sub pseudo_headers { $_[0]->{pseudo_headers} ||= {} }

1;


__END__
=pod

=for :stopwords Randy Stauner ACKNOWLEDGEMENTS TODO featureful http

=encoding utf-8

=head1 NAME

AnyEvent::HTTP::Response - HTTP Response object for AnyEvent::HTTP

=head1 VERSION

version 0.100

=head1 SYNOPSIS

  # named arguments (via hashref):
  AnyEvent::HTTP::Request->new({
    body    => $body,
    headers => \%headers,
    pseudo_headers => \%pseudo,
  });

  # argument list like the callback for AnyEvent::HTTP::http_request
  AnyEvent::HTTP::Request->new($body, \%headers);

=head1 DESCRIPTION

This object represents an HTTP response from L<AnyEvent::HTTP>.

This is a companion class to L<AnyEvent::HTTP::Request>.

=head1 CLASS METHODS

=head2 new

See L</SYNOPSIS> for usage example.

Accepts a list of arguments
(like those that would be passed
to the callback in
L<AnyEvent::HTTP/http_request>)
which will be passed through L</parse_args>.

Alternatively a single hashref can be passed
with anything listed in L</ATTRIBUTES> as the keys.

=head2 parse_args

Called by the constructor
to parse the argument list
passed to the callback in
L<AnyEvent::HTTP/http_request>
and return a hashref which will be the basis for the object.

The list should look like
C<< ($body, \%headers) >>.

This will separate the "pseudo" headers
from the regular http headers
as described by
L<AnyEvent::HTTP/http_request>
(http headers are lower-cased
and pseudo headers start with an upper case letter).

=head1 ATTRIBUTES

=head2 body

Response content body

=head2 content

Alias for L</body>

=head2 headers

HTTP Response headers

=head2 pseudo_headers

A hashref of extra fields
that L<AnyEvent::HTTP/http_request> returns with the http headers
(the ones that start with an upper-case letter... Status, Reason, etc).

=head1 METHODS

=head2 args

Returns a list of arguments like those passed to the callback in
L<AnyEvent::HTTP/http_request>.

=for test_synopsis my ($body, %headers, %pseudo);

=head1 TODO

=over 4

=item *

Provide conversion to/from more featureful L<HTTP::Response>

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

