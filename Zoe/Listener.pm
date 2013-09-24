#!/usr/bin/perl

package Zoe::Listener;

$VERSION = v0.0.1;

use v5.10.0;
use strict;
use IO::Socket;
use Thread;

# This is the entry point
# parameters:
#
#   $bindhost -> the host to bind to
#   $port     -> the port to bind to 
#   $delegate -> the message dispatch function
#
# When a message arrives, the delegate function will be invoked 
# with a reference to a hash that contais the incoming message
# parameters
sub listen {
	my ($bindhost, $port, $delegate) = @_;
	my $server_socket = IO::Socket::INET->new(LocalAddr => $bindhost, 
                                                  LocalPort => $port, 
	                                          Listen => 5,
        	                                  Proto => 'tcp',
                	                          Reuse => 1);
	die $@ unless $server_socket;

	while (my $connection = $server_socket->accept) {
		Thread->new(\&incoming, $connection, $delegate);
	}
}

# Manages an incoming connection
sub incoming {
	my ($connection, $delegate) = @_;;
	Thread->self->detach;
	my $buf;
	while (my $line = <$connection>) {
		$buf = $buf . $line;
	}
	$connection->close();
	my %map = parse($buf);
	&{$delegate}(\%map);
}

# Given a message:
#
#  a=b & c=d & c=e & f=g
#
# generates a hash like:
#
# { a => [b], c => [d, e], f => [g] }
sub parse {
	my $buf = shift;
	my @pairs = split /&/, $buf;
	my %dict = ();
	foreach my $pair (@pairs) {
		my ($key, $value) = split(/=/, $pair, 2);
		if ($dict{ $key }) {
			push @{ $dict{ $key } }, $value;
		} else {
			$dict{ $key } = [ $value ];
		}
	}
	return %dict;
}

