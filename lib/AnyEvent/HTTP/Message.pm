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

package AnyEvent::HTTP::Message;
{
  $AnyEvent::HTTP::Message::VERSION = '0.100';
}
BEGIN {
  $AnyEvent::HTTP::Message::AUTHORITY = 'cpan:RWSTAUNER';
}
# ABSTRACT: Lightweight objects for AnyEvent::HTTP Request/Response

use Carp ();


sub new {
  my $class = shift;

  my $self = @_ == 1 && ref($_[0]) eq 'HASH'
      # if passed a single hashref take a shallow copy
    ? { %{ $_[0] } }
      # otherwise it's the argument list for http_request()
    : $class->parse_args(@_);

  # accept 'content' as an alias for 'body', but store as 'body'
  $self->{body} = delete $self->{content}
    if exists $self->{content};

  bless $self, $class;
}



sub parse_args {
  my $self = shift;
  Carp::croak( join ' ',
    (ref($self) || $self),
    'has not defined a parse_args() method'
  );
}


# stubs for read-only accessors
sub body    { $_[0]->{body}           }
sub headers { $_[0]->{headers} ||= {} }

# alias
sub content { $_[0]->body }


sub header {
  my ($self, $h) = @_;
  $h =~ tr/_/-/;
  return $self->headers->{ lc $h };
}

sub _normalize_headers {
  my ($self, $headers) = @_;
  my $norm = {};
  while( my ($k, $v) = each %$headers ){
    my $n = $k;
    $n =~ tr/_/-/;
    $norm->{ lc $n } = $v;
  }
  return $norm;
}

1;


__END__
=pod

=for :stopwords Randy Stauner ACKNOWLEDGEMENTS TODO featureful http cpan testmatrix url
annocpan anno bugtracker rt cpants kwalitee diff irc mailto metadata
placeholders metacpan

=encoding utf-8

=head1 NAME

AnyEvent::HTTP::Message - Lightweight objects for AnyEvent::HTTP Request/Response

=head1 VERSION

version 0.100

=head1 SYNOPSIS

  # don't use this directly

=head1 DESCRIPTION

This is a base class for:

=over 4

=item *

L<AnyEvent::HTTP::Request>

=item *

L<AnyEvent::HTTP::Response>

=back

=head1 CLASS METHODS

=head2 new

The constructor accepts either a single hashref of named arguments,
or a specialized list of arguments that will be passed to
a the L</parse_args> method (which must be defined by the subclass).

=head2 parse_args

Called by the constructor
when L</new> is not called with a single hashref.

Must be customized by subclasses.

=head1 ATTRIBUTES

=head2 body

Message content body

=head2 content

Alias for L</body>

=head2 headers

Message headers (hashref)

=head1 METHODS

=head2 header

  my $ua  = $message->header('User-Agent');
  # same as $message->header->{'user-agent'};

Takes the specified key,
converts C<_> to C<-> and lower-cases it,
then returns the value of that message header.

=head1 SUPPORT

=head2 Perldoc

You can find documentation for this module with the perldoc command.

  perldoc AnyEvent::HTTP::Message

=head2 Websites

The following websites have more information about this module, and may be of help to you. As always,
in addition to those websites please use your favorite search engine to discover more resources.

=over 4

=item *

Search CPAN

The default CPAN search engine, useful to view POD in HTML format.

L<http://search.cpan.org/dist/AnyEvent-HTTP-Message>

=item *

RT: CPAN's Bug Tracker

The RT ( Request Tracker ) website is the default bug/issue tracking system for CPAN.

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=AnyEvent-HTTP-Message>

=item *

CPAN Ratings

The CPAN Ratings is a website that allows community ratings and reviews of Perl modules.

L<http://cpanratings.perl.org/d/AnyEvent-HTTP-Message>

=item *

CPAN Testers

The CPAN Testers is a network of smokers who run automated tests on uploaded CPAN distributions.

L<http://www.cpantesters.org/distro/A/AnyEvent-HTTP-Message>

=item *

CPAN Testers Matrix

The CPAN Testers Matrix is a website that provides a visual overview of the test results for a distribution on various Perls/platforms.

L<http://matrix.cpantesters.org/?dist=AnyEvent-HTTP-Message>

=item *

CPAN Testers Dependencies

The CPAN Testers Dependencies is a website that shows a chart of the test results of all dependencies for a distribution.

L<http://deps.cpantesters.org/?module=AnyEvent::HTTP::Message>

=back

=head2 Bugs / Feature Requests

Please report any bugs or feature requests by email to C<bug-anyevent-http-message at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=AnyEvent-HTTP-Message>. You will be automatically notified of any
progress on the request by the system.

=head2 Source Code


L<https://github.com/rwstauner/AnyEvent-HTTP-Message>

  git clone https://github.com/rwstauner/AnyEvent-HTTP-Message.git

=head1 AUTHOR

Randy Stauner <rwstauner@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Randy Stauner.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

