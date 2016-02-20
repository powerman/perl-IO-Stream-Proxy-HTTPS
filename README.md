[![Build Status](https://travis-ci.org/powerman/perl-IO-Stream-Proxy-HTTPS.svg?branch=master)](https://travis-ci.org/powerman/perl-IO-Stream-Proxy-HTTPS)
[![Coverage Status](https://coveralls.io/repos/powerman/perl-IO-Stream-Proxy-HTTPS/badge.svg?branch=master)](https://coveralls.io/r/powerman/perl-IO-Stream-Proxy-HTTPS?branch=master)

# NAME

IO::Stream::Proxy::HTTPS - HTTPS proxy plugin for IO::Stream

# VERSION

This document describes IO::Stream::Proxy::HTTPS version v2.0.0

# SYNOPSIS

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

# DESCRIPTION

This module is plugin for [IO::Stream](https://metacpan.org/pod/IO::Stream) which allow you to route stream
through HTTPS (also called CONNECT) proxy.

You may use several IO::Stream::Proxy::HTTPS plugins for single IO::Stream
object, effectively creating proxy chain (first proxy plugin will define
last proxy in a chain).

## EVENTS

When using this plugin event RESOLVED will never be delivered to user because
target {host} which user provide to IO::Stream will never be resolved on
user side (it will be resolved by HTTPS proxy).

Event CONNECTED will be generated after HTTPS proxy successfully connects to
target {host} (and not when socket will connect to HTTPS proxy itself).

# INTERFACE 

- new({ host=>$host, port=>$port })
- new({ host=>$host, port=>$port, user=>$user, pass=>$pass })

    Connect to proxy $host:$port, optionally using basic authorization.

# DIAGNOSTICS

- `{host}+{port} required`

    You must provide both {host} and {port} to IO::Stream::Proxy::HTTPS->new().

- `{user}+{pass} required`

    You have provided either {user} or {pass} to IO::Stream::Proxy::HTTPS->new()
    while you have to provide either both or none of them.

- `{fh} already connected`

    You have provided {fh} to IO::Stream->new(), but this is not supported by
    this plugin. Either don't use this plugin or provide {host}+{port} to
    IO::Stream->new() instead.

# SUPPORT

## Bugs / Feature Requests

Please report any bugs or feature requests through the issue tracker
at [https://github.com/powerman/perl-IO-Stream-Proxy-HTTPS/issues](https://github.com/powerman/perl-IO-Stream-Proxy-HTTPS/issues).
You will be notified automatically of any progress on your issue.

## Source Code

This is open source software. The code repository is available for
public review and contribution under the terms of the license.
Feel free to fork the repository and submit pull requests.

[https://github.com/powerman/perl-IO-Stream-Proxy-HTTPS](https://github.com/powerman/perl-IO-Stream-Proxy-HTTPS)

    git clone https://github.com/powerman/perl-IO-Stream-Proxy-HTTPS.git

## Resources

- MetaCPAN Search

    [https://metacpan.org/search?q=IO-Stream-Proxy-HTTPS](https://metacpan.org/search?q=IO-Stream-Proxy-HTTPS)

- CPAN Ratings

    [http://cpanratings.perl.org/dist/IO-Stream-Proxy-HTTPS](http://cpanratings.perl.org/dist/IO-Stream-Proxy-HTTPS)

- AnnoCPAN: Annotated CPAN documentation

    [http://annocpan.org/dist/IO-Stream-Proxy-HTTPS](http://annocpan.org/dist/IO-Stream-Proxy-HTTPS)

- CPAN Testers Matrix

    [http://matrix.cpantesters.org/?dist=IO-Stream-Proxy-HTTPS](http://matrix.cpantesters.org/?dist=IO-Stream-Proxy-HTTPS)

- CPANTS: A CPAN Testing Service (Kwalitee)

    [http://cpants.cpanauthors.org/dist/IO-Stream-Proxy-HTTPS](http://cpants.cpanauthors.org/dist/IO-Stream-Proxy-HTTPS)

# AUTHOR

Alex Efros &lt;powerman@cpan.org>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2008 by Alex Efros &lt;powerman@cpan.org>.

This is free software, licensed under:

    The MIT (X11) License
