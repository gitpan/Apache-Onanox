package Apache::Onanox::Mail;

=head1 NAME

Apache::Onanox::Mail

=head1 ABSTRACT

Uses Mail::Send to send an email

=head1 METHODS

=cut

use strict;
use warnings;
use Mail::Send;
use base qw(Apache::Onanox::Base);

our $VERSION = 0.01;

=head2 send

my $mail        = Apache::Onanox::Mail-E<gt>new;

my $msg         = {};

$msg-E<gt>{to}      = 'foo@bar.com'; # required

$msg-E<gt>{subject} = 'hello world'; # required

$msg-E<gt>{body}    = 'hello world'; # required

$msg-E<gt>{from}    = 'baz@bar.com'; # optional, E<lt>Apache userE<gt>@E<lt>machineE<gt> is default

$msg-E<gt>{cc}      = 'zoo@bar.com'; # optional

$msg-E<gt>{bcc}     = 'zen@bar.com'; # optional

$mail-E<gt>send($msg);

=cut

sub send {
    my $self = shift;
    my $mail = shift;
    return unless $mail->{to} and $mail->{body} and $mail->{subject};
    $self->log("sending mail " . $mail->{subject} . " to " . $mail->{to});

    my $msg = Mail::Send->new;
    $msg->to($mail->{to});
    $msg->subject($mail->{subject});
    $msg->cc($mail->{cc}) if $mail->{cc};
    $msg->bcc($mail->{bcc}) if $mail->{bcc};
    $msg->set('From', $mail->{from}) if $mail->{from};
    $msg->add('X-Mailer', 'Apache Onanox mailer [Version ' . $VERSION . ']');
    $msg->add('Content-type', 'text/plain; charset="iso-8859-1"');

    my $mh = $msg->open;
    print $mh $mail->{body};
    $mh->close;
    $self->log("mail " . $mail->{subject} . " sent to " . $mail->{to});
    return 1;
}

1;

=head1 SEE ALSO

L<Mail::Send>

L<Apache::Onanox>

=cut
