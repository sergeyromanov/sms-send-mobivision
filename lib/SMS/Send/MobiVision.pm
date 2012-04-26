package SMS::Send::MobiVision;

use strict;

use HTTP::Tiny;
use XML::TreePP;

my $SEND_URL = 'http://connect.mbvn.ru/xml/';
my $BALANCE_URL = 'http://connect.mbvn.ru/xml/balance.php';

sub new {
    my($class, $login, $password, $origin) = @_;

    my $self = {
        login    => $login,
        password => $password,
        origin   => $origin,
    };
    bless $self, $class;

    return $self;
}

sub send {
    my($self, $phone, $string) = @_;

    my $tpp = XML::TreePP->new;
    my $tree = {
        request => {
            message => {
                -type => 'sms',
                sender => $self->{origin},
                abonent => {
                    -phone => $phone,
                    -number_sms => 1,
                },
                text => $string,
            },
            security => {
                login    => {-value => $self->{login}},
                password => {-value => $self->{password}},
            }
        }
    };
    my $xml = $tpp->write($tree);

    my $ua  = HTTP::Tiny->new;
    my $res = $ua->post($SEND_URL, {
        content => $xml
    });

    return $res->{content};
}

sub balance {
    my $self = shift;

    my $tpp = XML::TreePP->new;
    my $tree = {
        request => {
            security => {
                login    => {-value => $self->{login}},
                password => {-value => $self->{password}},
            }
        }
    };
    my $xml = $tpp->write($tree);

    my $ua  = HTTP::Tiny->new;
    my $res = $ua->post($BALANCE_URL, {
        content => $xml
    });

    return $res->{content};
}


1;

