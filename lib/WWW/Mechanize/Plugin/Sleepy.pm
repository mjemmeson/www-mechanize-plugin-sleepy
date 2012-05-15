package WWW::Mechanize::Plugin::Sleepy;

# ABSTRACT: A WWW::Mechanize plugin to provide the behaviour of WWW::Mechanize::Sleepy while using WWW::Mechanize::Pluggable

use strict;
use warnings;
use Carp qw/ croak /;

=head1 SYNOPSIS

Set all Mechanize objects to sleep for 5 seconds between requests:

    use WWW::Mechanize::Pluggable Sleepy => [ sleep => 5 ];

or, set single Mechanize instance to sleep for 5 seconds between requests:

    use WWW::Mechanize::Pluggable;
    
    my $mech = WWW::Mechanize::Pluggable->new( sleep => 5 );

# TODO also can use range (1..10) for random sleep length


=cut

sub import {
    my ( $class, %args ) = @_;
    $WWW::Mechanize::Pluggable::Sleepy = $args{sleep}
        if defined $args{sleep};
}

sub init {
    my ( $class, $pluggable, %args ) = @_;

    no strict 'refs';
    *{ caller() . '::sleep' }  = \&sleep;
    *{ caller() . '::_sleep' } = \&_sleep;

    foreach my $method (
        qw/ get put reload back request follow_link submit submit_form/)
    {

        # 0; - carries on to rest of parent method
        $pluggable->pre_hook( $method, sub { $_[0]->_sleep(); 0; } );
    }

    my $sleep
        = defined $args{sleep}
        ? $args{sleep}
        : $WWW::Mechanize::Pluggable::Sleepy || 0;

    _set_sleep( $pluggable, $sleep );
}

=method sleep

    $mech->sleep(1);
    $mech->sleep('5..10');
    
    my $sleep = $mech->sleep;

Get/set sleep time

=cut

sub sleep {
    my ( $self, $arg ) = @_;
    _set_sleep( $self, $arg ) if defined $arg;
    return $self->{Sleepy_Time};
}

sub _set_sleep {
    my ( $self, $arg ) = @_;

    my $method;
    if ( !defined $arg ) {
        $method = sub { };
    } elsif ( my ( $from, $to ) = $arg =~ m/^(\d+)\.\.(\d+)$/ ) {
        croak "sleep range (i1..i2) must have i1 < i2"
            if $1 >= $2;
        $method = sub { CORE::sleep( int( rand( $to - $from ) ) + $from ); };
    } elsif ( $arg !~ m/\D/ ) {
        $method = sub { CORE::sleep($arg); };
    } else {
        croak "sleep parameter must be an integer or a range i1..i2";
    }

    $self->{Sleepy_Time}   = $arg;
    $self->{Sleepy_Method} = $method;
}

sub _sleep {
    my ($self) = @_;
    $self->{Sleepy_Method}->();
}

=head1 SEE ALSO

=for :list
* L<WWW::Mechanize::Sleepy>
* L<WWW::Mechanize::Pluggable>

=cut

1;

