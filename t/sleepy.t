use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::Timer;

use WWW::Mechanize::Pluggable;

note "Pluggable should have loaded Plugin::Sleepy...";

ok my $mech = WWW::Mechanize::Pluggable->new(),
    "created new pluggable object";

ok $mech->can('sleep'), "sleep method created";
is $mech->sleep, 0, "sleep 0 by default";

foreach ( 'x', '10x', '1..', '1 .. 10' ) {
    dies_ok { WWW::Mechanize::Pluggable->new( sleep => $_ ) }
    "dies with invalid sleep value ($_)";
}

ok $mech= WWW::Mechanize::Pluggable->new( sleep => 5 ),
    "created new pluggable object with sleep";

is $mech->sleep, 5, "sleep set to 5 seconds";

my @tests = (
    {   name => 'get',
        code => sub { $mech->get("http://www.google.com/webhp?hl=en") },
    },
    {   name => 'follow_link',
        code => sub { $mech->follow_link( text => "Images" ) },
    },
    {   name => 'back',
        code => sub { $mech->back() },
    },
    {   name => 'reload',
        code => sub { $mech->reload() },
    },
    {   name => 'submit',
        code => sub { $mech->submit() },
    },
);

ok $mech->sleep(3), "setting sleep";
is $mech->sleep, 3, "now set to 3 seconds";

foreach my $test (@tests) {
    note $test->{name};
    time_atleast( $test->{code}, 2, "get took over 2 seconds" );
}

ok $mech->sleep('2..4'), "setting sleep to range";
is $mech->sleep, '2..4', "now set to between 2 and 4 seconds";

foreach my $test (@tests) {
    note $test->{name};
    time_between( $test->{code}, 2, 5, "slept for between 2 and 4 seconds" );
}

#
# $a = WWW::Mechanize::Sleepy->new( sleep => '5..10' );
# timed( '$a->get( "http://www.google.com/webhp?hl=en" )', '5..10' );
# timed( '$a->follow_link( text => "Images" )',            '5..10' );
# timed( '$a->back()',                                     '5..10' );
# timed( '$a->reload()',                                   '5..10' );
# timed( '$a->submit()',                                   '5..10' );
#
# $a->sleep(1);
# is( $a->sleep(), 1, 'sleep()' );
# timed( '$a->reload()', '1' );
#
# $a->sleep(0);
# is( $a->sleep(), '0', 'sleep(0)' );
#
# sub timed {
#     my ( $cmd, $expected ) = @_;
#
#     my $t1 = time();
#     eval($cmd);
#     my $elapsed = time() - $t1;
#     ok( $a->success(), "$cmd : success" );
#
#     if ( $expected =~ /\.\./ ) {
#         my ( $r1, $r2 ) = split( /\.\./, $expected );
#         ok( ( $elapsed >= $r1 ), "$cmd : took between $r1 and $r2 seconds" );
#     } else {
#         ok( ( $elapsed >= $expected ),
#             "$cmd : slept at least $expected seconds" );
#     }
# }

done_testing();

