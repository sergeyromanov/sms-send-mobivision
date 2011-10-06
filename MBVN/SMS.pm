package SMS;

use strict;

use HTTP::Request::Common;
use LWP::UserAgent ();
use XML::LibXML;

my $SEND_URL = 'http://connect.mbvn.ru/xml/';
my $BALANCE_URL = 'http://connect.mbvn.ru/xml/balance.php';

sub new {
    my ($class, $login, $password, $origin) = @_;
    
    my $self = {
        'login'    => $login,
        'password' => $password, 
        'origin'   => $origin,
    };
    bless $self, $class;
    
    return $self;
}

sub send {
    my ($self, $phone, $string) = @_;

    my $dom = XML::LibXML::Document->new('1.0', 'UTF-8');
    my $root = $dom->createElement('request');
    $dom->setDocumentElement($root);

    my $message = $dom->createElement('message');
    $message->setAttribute('type', 'sms');
      
    my $sender = $dom->createElement('sender');
    $sender->appendText($self->{'origin'});
    $message->appendChild($sender);
      
    my $text = $dom->createElement('text');
    $text->appendText($string);
    $message->appendChild($text);

    my $recipient = $dom->createElement('abonent');
    $recipient->setAttribute('phone', '7' . $phone);
    $recipient->setAttribute('number_sms', '1');
    $message->appendChild($recipient);
      
    $root->appendChild($message);

    my $security = $dom->createElement('security');

    my $login = $dom->createElement('login');
    $login->setAttribute('value', $self->{'login'});
    $security->appendChild($login);

    my $password = $dom->createElement('password');
    $password->setAttribute('value',  $self->{'password'});
    $security->appendChild($password);

    $root->appendChild($security);

    my $xml = $dom->toString;
    $xml =~ s/\n//g;
    
    my $ua  = LWP::UserAgent->new;
    my $res = $ua->request(
        POST $SEND_URL,
        Content_Type => 'text/xml',
        Content => $xml
    );
    my $answer = XML::LibXML->load_xml('string' => $res->content);
    my $xc  = XML::LibXML::XPathContext->new($answer);
    return $xc->findvalue('/response/information') eq 'send' ? 1 : 0;
}

sub balance {
    my $self = shift;
    my $xml = <<XML;
<?xml  version="1.0" encoding="utf-8" ?>
<request>
  <security>
    <login value="$self->{'login'}" />
    <password value="$self->{'password'}" />
  </security>
</request>
XML

    my $ua  = LWP::UserAgent->new;
    my $res = $ua->request(
        POST $BALANCE_URL,
        Content_Type => 'text/xml',
        Content => $xml
    );
    use Data::Dumper; print Dumper $res;
}


1;
