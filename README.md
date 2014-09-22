This is a comprehensive Puppet module for configuring the [Riemann
distributed systems monitor](http://riemann.io) on an infrastructure.

Full documentation for all types and classes can be found in the definition
file for that element; this README only gives brief highlights of what's
available.


# Configuring the server

A very basic configuration of the server process itself would look like
this:

    riemann::server { "system": }

This will install the latest release of Riemann for your OS and configure it
to start on boot, with a very simplistic configuration -- TCP/UDP/websockets
listeners on localhost, access to the REPL by running `riemann-repl`, and no
streams -- that is, every event will be dropped unceremoniously on the
floor.

There are a number of things you can do to adjust the way that Riemann is
configured.  While the full set of configuration options is documented in
the `riemann::server` type docs, there are a few common configuration
"patterns" that are indicated below.

To make the TCP/UDP/websockets services listen on a specific address:

    riemann::server { "system":
        listen => "0.0.0.0"
    }

If you have a graphite server you'd like to send some (or all) metrics to,
you can tell us all about it (this will then also define a `graph` var
for you to reference where needed in your streams configuration):

    riemann::server { "system":
        graphite_server => "192.0.2.42:2003"
    }

You can also configure your mail server:

    riemann::server { "system":
        mailer => {
            from => "riemann@example.com",
            host => "mail.example.com",
            user => "riemann",
            pass => "s3kr1t"
        }
    }

All the arguments you pass to the `mailer` hash will be forwarded straight
on to the `riemann.email/mailer` var.  You will also then have an `email`
var available to use in your `def`s and streams.


## Configuring Streams

To make Riemann do anything useful, you'll need to define *streams*.  This
is simple enough to do, with the `riemann::stream` type:

    riemann::stream { "log_ALL_THE_THINGS":
        content => "#(info %)"
    }

This will add a new stream to the top-level "streams" list, which logs
every event that comes through.  Alternately, you might want to index
everything:

    riemann::stream { "index_every_event":
        content => "index"
    }

This demonstrates the availability of one of a number of pre-defined vars
in the streams for you to use in your own stream definitions.  The full set
of available vars is documented in the `riemann::stream` type.

Since stream definitions can be largish, you can read the content of a file
into the manifest, too:

    riemann::stream { "notify_on_many_conditions":
        content => file("local/etc/riemann/stream/complex_notify")
    }


## Defining vars

Typically, streams reference any number of pre-defined vars.  These are used
to keep your configurations neat, and avoid having to repeat yourself
interminably.  You can define them yourself, using the `riemann::def` type:

    riemann::def {
        "tell-ops":
            content => "(rollup 5 3600 (email \"ops@example.com\"))";
        "tell-ops-now":
            content => "(email \"ops@example.com\")";
    }

Like `riemann::stream`, you can also read a file to get a definition from:

    riemann::def { "somebigdef":
        content => file("local/etc/riemann/defs/somebigdef")
    }

There's one "catch" with `def`s -- if the contents of a `def` refer to the
name of another `def`, they need to be defined in a certain order.  The
order in which `def`s are listed in the configuration file (and thus are
evaluated) is controlled by the namevar of each resource -- they are sorted
alphanumerically.  Thus, if you want to make sure a `def` happens before
another, just make sure it's namevar sorts first:

    riemann::def {
        "00-zany-condition":
            name    => "zany-condition",
            content => "(fn [e] (and (< 2.71828 (:metric e) 3.14159)
                                     (fn-find #\"irrational\" (:service e))))";
        "01-zanier-condition":
            name    => "zanier-condition",
            content => "(fn [e] (or (< (:metric e) 0) (zany-condition e)))";
    }

In this case, the name `zanier-condition` normally sorts before
`zany-condition` (because `"i" < "y"`), so in order to get the order of
definitions correct, I prefixed the namevar of each resource with some
digits.  Then, because the name of the `def` I wanted to create didn't match
the namevar, I used the `name` attribute to define what the `def`'s name
was.

It's ugly, but it works.  If someone wants to fix this by writing a parser
to work out the "correct" ordering for a collection of `def`s automatically,
I'm all ears.


# Installing the health-check client

Since a Riemann server is pretty pointless without events flowing into it,
there's `riemann::health` to setup the core "health checks" on every machine:

    riemann::health { "system"
        server => "riemann.example.com"
    }

This will also install an init script and `riemann-health` service, and
ensure that the service is running every time Puppet runs.


# Licence and copyright

The following applies to all files in this module, unless otherwise stated.

    Copyright (C) 2014 Digivizer Pty Ltd
    Copyright (C) 2014 Matt Palmer <matt@hezmatt.org>

    This program is free software; you can redistribute it and/or modify it
    under the terms of the GNU General Public License version 3, as
    published by the Free Software Foundation.

    This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, see <http://www.gnu.org/licences/>
