package SMS::Send::MobiVision;

# ABSTRACT: SMS::Send MobiVision driver

use strict;
use v5.10.1;

use parent qw(SMS::Send::Driver);

use Carp qw(croak);
use HTTP::Tiny;
use XML::TreePP;

my %URLS = (
    send    => 'http://connect.mbvn.ru/xml/',
    balance => 'http://connect.mbvn.ru/xml/balance.php'
);

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
                sender  => $args{sender} // $self->{_origin},
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

    my $res = $self->{_ua}->post($URLS{send}, {
        content => $xml
    });
    croak("Bad response: $res->{content}") unless $res->{status} eq '200';

    return $tpp->parse($res->{content})->{response};
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

    my $res = $self->{_ua}->post($URLS{balance}, {
        content => $xml
    });
    croak("Bad response: $res->{content}") unless $res->{status} eq '200';

    return $tpp->parse($res->{content})->{response};
}


1;

