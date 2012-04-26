package SMS::Send::MobiVision;

use strict;

use parent qw(SMS::Send::Driver);

use HTTP::Tiny;
use XML::TreePP;

my $SEND_URL = 'http://connect.mbvn.ru/xml/';
my $BALANCE_URL = 'http://connect.mbvn.ru/xml/balance.php';

sub new {
    my $class  = shift;

    my $self = {
        _ua => HTTP::Tiny->new,
        @_,
    };
    bless $self, $class;

    return $self;
}

sub send_sms {
    my($self, %args) = @_;

    $args{to} =~ s/^\+//;
    my $tpp = XML::TreePP->new;
    my $tree = {
        request => {
            message => {
                -type   => 'sms',
                sender  => $args{sender} || $self->{_origin},
                text    => $args{text},
                abonent => {
                    -phone      => $args{to},
                    -number_sms => 1,
                },
            },
            security => {
                login    => {-value => $self->{_login}},
                password => {-value => $self->{_password}},
            }
        }
    };
    my $xml = $tpp->write($tree);

    my $res = $self->{_ua}->post($SEND_URL, {
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
                login    => {-value => $self->{_login}},
                password => {-value => $self->{_password}},
            }
        }
    };
    my $xml = $tpp->write($tree);

    my $res = $self->{_ua}->post($BALANCE_URL, {
        content => $xml
    });

    return $res->{content};
}


1;

