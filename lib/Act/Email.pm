#  send emails

use strict;
package Act::Email;

use MIME::Lite ();
use Net::SMTP;
use Act::Config;

# send an email
# Act::Email::send(
#     from    => 'foo@example.com',
# or  from    => { name => 'Foo Bar', email => 'foo@example.com' },
#     to      => 'foo@example.com',
# or  to      => { name => 'Foo Bar', email => 'foo@example.com' },
# or  to      => [ \$address1, \%address2 ],
#     subject => 'blah',
#     body    => 'more blah',
# optional args (default values are shown):
#     encoding     => 'ISO-8859-1',
#     content_type => 'text/plain',
#     precedence   => 'bulk',
# );

my %defaults = (
     encoding     => 'ISO-8859-1',
     content_type => 'text/plain',
     precedence   => 'bulk',
);
sub send
{
    my %args = @_;

    my %opts;
    $opts{Port} = $Config->email_smtp_port
        if $Config->email_smtp_port;
    my $smtp = Net::SMTP->new($Config->email_smtp_server, %opts)
      or die "can't create new Net::SMTP object";

    # apply defaults
    for my $key (keys %defaults) {
        $args{$key} = $defaults{$key}
            unless $args{$key};
    }

    # sender
    my $from = ref($args{from}) ? $args{from} : { email => $args{from} };

    # create message
    my $msg = MIME::Lite->new (
        From            => $from->{name}
                         ? "$from->{name} <$from->{email}>"
                         : $from->{email},
        Subject         => $args{subject},
        'Precedence:'   => $args{precedence},
        Type            => qq($args{content_type}; charset="$args{encoding}"),
        Datestamp       => 0,
        Data            => $args{body},
    );

    # envelope sender
    $smtp->mail($from->{email});

    # recipients
    $args{to} = [ $args{to} ] if ref($args{to}) ne 'ARRAY';
    for my $to (@{$args{to}}) {
        $to = { email => $to } unless ref($to);
        $msg->add(To => $to->{name} ? "$to->{name} <$to->{email}>"
                                    : $to->{email});
        $smtp->to($to->{email}) or die $smtp->message;
    }
    $smtp->data()                      or die $smtp->message;
    $smtp->datasend($msg->as_string()) or die $smtp->message;
    $smtp->dataend()                   or die $smtp->message;
    $smtp->quit()                      or die $smtp->message;
}
1;