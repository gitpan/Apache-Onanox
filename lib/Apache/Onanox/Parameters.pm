package Apache::Onanox::Parameters;

use strict;
use warnings;
use CGI::Untaint;
use base qw(Apache::Onanox::Base);

=head2 new

Simple constructor

=cut

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    my $param = shift;
    $self->parameters($param);
    $self->untaint($self->parameters);
    return $self;
}

=head2 parameters

Sets parameters.

=cut

sub parameters {
    my $self = shift;
    my $set  = shift;
    $self->{_parameters} = $set if $set 
        and not defined $self->{_parameters};
    return $self->{_parameters};
}

=head2 get_parameter

Gets parameters.

=cut

sub get_parameter {
    return $_[0]->parameters->{$_[1]};
}

=head2 untaint

Get/set the CGI::Untaint object

=cut

sub untaint {
    $_[0]->{_untaint} = CGI::Untaint->new($_[1]) 
        if $_[1] and not defined $_[0]->{_untaint};
    return $_[0]->{_untaint};
}

=head2 get

Gets an untainted parameter.

=cut

sub get {
    my $self = shift;
    my $param = shift;
    return unless defined $param;
    my $as = shift;
    $as ||= '-as_printable';

    return $self->untaint->extract($as => $param)
        if $self->get_parameter($param);
    return (undef, "Parameter $param does not exist");
}

=head2 param

Gets an untainted parameter but fails silently or returns whatever 
default value you provide (for TT).

=cut

sub param {
    my ($x, $y) = &get(shift, shift);
    return $x if $x;
    return shift;
}

1;
