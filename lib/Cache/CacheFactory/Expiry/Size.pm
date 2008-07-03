###############################################################################
# Purpose : Cache Size Expiry Policy Class.
# Author  : Sam Graham
# Created : 25 Jun 2008
# CVS     : $Id: Size.pm,v 1.3 2008-06-27 11:58:10 illusori Exp $
###############################################################################

package Cache::CacheFactory::Expiry::Size;

use warnings;
use strict;

use Cache::Cache;
use Cache::BaseCache;

use Cache::CacheFactory::Expiry::Base;

use base qw/Cache::CacheFactory::Expiry::Base/;

$Cache::CacheFactory::Expiry::Size::VERSION =
    sprintf"%d.%03d", q$Revision: 1.3 $ =~ /: (\d+)\.(\d+)/;

sub read_startup_options
{
    my ( $self, $param ) = @_;

    $self->{ max_size } = $param->{ max_size }
        if exists $param->{ max_size };
}

sub set_object_validity
{
    my ( $self, $key, $object, $param ) = @_;

}

sub set_object_pruning
{
    my ( $self, $key, $object, $param ) = @_;

}

sub should_keep
{
    my ( $self, $cache, $storage, $policytype, $object ) = @_;
    my ( $cachesize );

    $cachesize = $self->{ _cache_size } || $storage->size();

    return( 1 ) if $cachesize <= $self->{ max_size };
    return( 0 );
}

1;

=pod

=head1 NAME

Cache::CacheFactory::Expiry::Size - size-based expiry policy for Cache::CacheFactory.

=head1 DESCRIPTION

L<Cache::CacheFactory::Expiry::Size>
is a size-based expiry (pruning and validity) policy for
L<Cache::CacheFactory>.

It provides similar functionality and backwards-compatibility with
the C<max_size> option of L<Cache::SizeAwareFileCache> and variants.

It's highly recommended that you B<DO NOT> use this policy as a
validity policy, as calculating the size of the contents of the
cache on each read can be quite expensive, and it's semantically
ambiguous as to just what behaviour is intended by it anyway.

Note that in its current implementation L<Cache::CacheFactory::Expiry::Size>
is "working but highly inefficient" when it comes to purging.
It is provided mostly for completeness while a revised version
is being worked on.

=head1 SIZE SPECIFICATIONS

Currently all size values must be specified as numbers and will be
interpreted as bytes. Future versions reserve the right to supply
the size as a string '10 M' for ease of use, but this is not currently
implemented.

=head1 STARTUP OPTIONS

The following startup options may be supplied to 
L<Cache::CacheFactory::Expiry::Size>,
see the L<Cache::CacheFactory> documentation for
how to pass options to a policy.

=over

=item max_size => $size

This sets the maximum size that the cache strives to keep under,
any items that take the cache over this size will be pruned (for
a pruning policy) at the next C<< $cache->purge() >>.

See the L</"SIZE SPECIFICATIONS"> section above for details on
what values you can pass in as C<$size>.

Note that by default pruning policies are not immediately enforced,
they are only applied when a C<< $cache->purge() >> occurs. This
means that it is possible (likely even) for the size of the cache
to exceed C<max_size> at least on a temporary basis. When the next
C<< $cache->purge() >> occurs, the cache will be reduced back down
below C<max_size>.

If you make use of the C<auto_purge_on_set> option to
L<Cache::CacheFactory>, you'll cause a C<< $cache->purge() >>
on a regular basis depending on the value of C<auto_purge_interval>.

However, even with the most aggressive values of C<auto_purge_interval>
there will still be a best-case scenario of the cache entry being
written to the cache, taking it over C<max_size>, and the purge
then reducing the cache below C<max_size>. This is essentially
unavoidable since it's impossible to know the size an entry will
take in the cache until it has been written.

=back

=head1 STORE OPTIONS

There are no per-key options for this policy.

=head1 SEE ALSO

L<Cache::CacheFactory>, L<Cache::Cache>, L<Cache::SizeAwareFileCache>,
L<Cache::SizeAwareCache>, L<Cache::CacheFactory::Object>,
L<Cache::CacheFactory::Expiry::Base>

=head1 AUTHORS

Original author: Sam Graham <libcache-cachefactory-perl BLAHBLAH illusori.co.uk>

Last author:     $Author: illusori $

=head1 COPYRIGHT

Copyright 2008 Sam Graham.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
