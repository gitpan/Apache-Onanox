package Apache::Onanox::Base;

=head1 NAME

Apache::Onanox::Base

=head1 ABSTRACT

Base class for Apache::Onanox classes

=cut

use strict;
use warnings;
use Digest::MD5;

our $USER_DEBUG;

=head2 new

Simple constructor

=cut

sub new {
    return bless {}, $_[0];
}

=head2 log

Prints to STDERR

=cut

sub log {
    print STDERR '[' . gmtime() . '] ' . $_[1]. "\n";
}

=head2 create_md5

Returns double MD5 of a string.

=cut

sub create_md5 {
    return unless $_[1];

    # do it twice to avoid theoretical vulnerability in MD5
    my $md5 = Digest::MD5->new;
    $md5->add($_[1]);
    my $digest = $md5->hexdigest;
    $md5->add($digest);
    return $md5->hexdigest;
}

=head2 sql_date

Current date time in ISO format

=cut

sub sql_date {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime();
    $year += 1900;
    return "$year-$mon-$mday $hour:$min:$sec"; 
}

=head2 user_debug 

Debugging to the browser

=cut

sub user_debug {
    $USER_DEBUG = '' unless $USER_DEBUG;
    my $debug = $_[1];
    $debug =~ s/^(.*)$/$1\n/g if $debug;
    $debug =~ s/\n/\n<br>/g if $debug;
    $USER_DEBUG .= $debug if $debug;
    return $USER_DEBUG;
}

1;

=head1 SEE ALSO

L<Apache::Onanox>

=cut
