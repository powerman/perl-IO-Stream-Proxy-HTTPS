package IO::Stream::Proxy::HTTPS;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('1.0.3');    # update POD & Changes & README

# update DEPENDENCIES in POD & Makefile.PL & README
use IO::Stream::const;
use MIME::Base64;
use Scalar::Util qw( weaken );

use constant HTTP_OK => 200;

sub new {
    my ($class, $opt) = @_;
    croak '{host}+{port} required'
        if !defined $opt->{host}
        || !defined $opt->{port}
        ;
    croak '{user}+{pass} required'
        if $opt->{user} xor $opt->{pass};
    my $self = bless {
        host        => undef,
        port        => undef,
        user        => undef,
        pass        => undef,
        %{$opt},
        out_buf     => q{},                 # modified on: OUT
        out_pos     => undef,               # modified on: OUT
        out_bytes   => 0,                   # modified on: OUT
        in_buf      => q{},                 # modified on: IN
        in_bytes    => 0,                   # modified on: IN
        ip          => undef,               # modified on: RESOLVED
        is_eof      => undef,               # modified on: EOF
        _want_write => undef,
        }, $class;
    return $self;
}

sub PREPARE {
    my ($self, $fh, $host, $port) = @_;
    croak '{fh} already connected'
        if !defined $host;
    $self->{out_buf} = "CONNECT ${host}:${port} HTTP/1.0\r\n";
    if (defined $self->{user}) {
        $self->{out_buf} .= 'Proxy-Authorization: Basic '
            . encode_base64($self->{user}.q{:}.$self->{pass}, q{})
            . "\r\n"
            ;
    }
    $self->{out_buf} .= "\r\n";
    $self->{_slave}->PREPARE($fh, $self->{host}, $self->{port});
    $self->{_slave}->WRITE();
    return;
}

sub WRITE {
    my ($self) = @_;
    $self->{_want_write} = 1;
    return;
}

sub EVENT {
    my ($self, $e, $err) = @_;
    my $m = $self->{_master};
    if ($err) {
        $m->EVENT(0, $err);
    }
    if ($e & IN) {
        if ($self->{in_buf} =~ s{\A(HTTP/\d\.\d\s(\d+)\s.*?)\r?\n\r?\n}{}xms) {
            my ($reply, $status) = ($1, $2);
            if ($status == HTTP_OK) {
                $e = CONNECTED;
                if (my $l = length $self->{in_buf}) {
                    $e |= IN;
                    $m->{in_buf}    .= $self->{in_buf};
                    $m->{in_bytes}  += $l;
                }
                $m->EVENT($e);
                $self->{_slave}->{_master} = $m;
                weaken($self->{_slave}->{_master});
                $m->{_slave} = $self->{_slave};
                if ($self->{_want_write}) {
                    $self->{_slave}->WRITE();
                }
            }
            else {
                $m->EVENT(0, 'https proxy: '.$reply);
            }
        }
    }
    if ($e & EOF) {
        $m->{is_eof} = $self->{is_eof};
        $m->EVENT(0, 'https proxy: unexpected EOF');
    }
    return;
}


1; # Magic true value required at end of module
__END__

=head1 NAME

IO::Stream::Proxy::HTTPS - HTTPS proxy plugin for IO::Stream


=head1 VERSION

This document describes IO::Stream::Proxy::HTTPS version 1.0.3


=head1 SYNOPSIS

    use IO::Stream;
    use IO::Stream::Proxy::HTTPS;

    IO::Stream->new({
        ...
        plugin => [
            ...
            proxy   => IO::Stream::Proxy::HTTPS->new({
                host    => 'my.proxy.com',
                port    => 3128,
                user    => 'me',
                pass    => 'mypass',
            }),
            ...
        ],
    });


=head1 DESCRIPTION

This module is plugin for L<IO::Stream> which allow you to route stream
through HTTPS (also called CONNECT) proxy.

You may use several IO::Stream::Proxy::HTTPS plugins for single IO::Stream
object, effectively creating proxy chain (first proxy plugin will define
last proxy in a chain).

=head2 EVENTS

When using this plugin event RESOLVED will never be delivered to user because
target {host} which user provide to IO::Stream will never be resolved on
user side (it will be resolved by HTTPS proxy).

Event CONNECTED will be generated after HTTPS proxy successfully connects to
target {host} (and not when socket will connect to HTTPS proxy itself).

=head1 INTERFACE 

=over

=item new({ host=>$host, port=>$port })

=item new({ host=>$host, port=>$port, user=>$user, pass=>$pass })

Connect to proxy $host:$port, optionally using basic authorization.

=back


=head1 DIAGNOSTICS

=over

=item C<< {host}+{port} required >>

You must provide both {host} and {port} to IO::Stream::Proxy::HTTPS->new().

=item C<< {user}+{pass} required >>

You have provided either {user} or {pass} to IO::Stream::Proxy::HTTPS->new()
while you have to provide either both or none of them.

=item C<< {fh} already connected >>

You have provided {fh} to IO::Stream->new(), but this is not supported by
this plugin. Either don't use this plugin or provide {host}+{port} to
IO::Stream->new() instead.

=back


=head1 CONFIGURATION AND ENVIRONMENT

IO::Stream::Proxy::HTTPS requires no configuration files or environment variables.


=head1 DEPENDENCIES

L<IO::Stream>.


=head1 INCOMPATIBILITIES

None reported.


=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to author, or
C<bug-ev-stream-proxy-https@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Alex Efros  C<< <powerman-asdf@ya.ru> >>


=head1 LICENSE AND COPYRIGHT

Copyright (c) 2008, Alex Efros C<< <powerman-asdf@ya.ru> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
