package Apache::Onanox::Template::Plugin::Base;

use strict;
use warnings;

use base qw( Apache::Onanox::Base Template::Plugin );
use Apache::Onanox::Parameters;
use Template::Plugin;

=head2 new

Simple constructor.

=cut

sub new {
    my $self = bless {}, $_[0];
    $self->{_CONTEXT} = $_[1];
    $self->parameters(Apache::Onanox::Parameters->new($_[2]));
    $self->stash;
    return $self;
}

=head2 parameters

Gets the parameters.

=cut

sub parameters {
    $_[0]->{_parameters} = $_[1] if $_[1];
    return $_[0]->{_parameters};
}

=head2 req_parameters

Gets the request parameters.

=cut

sub req_parameters {
    my $self = shift;
    my ($p, $e) = $self->stash->get('parameters');
    return if $e;
    $self->{_req_parameters} = $$p;
    return $self->{_req_parameters};
}

=head2 load

Returns the class.

=cut

sub load {
    return $_[0];
}

=head2 stash

Gets the stash

=cut

sub stash {
    my $self = shift;
    return $self->{_CONTEXT}->stash;
}

=head2 error

Get/set error messages.

=cut

sub error {
    $_[0]->{_error} = '' unless $_[0]->{_error};
    $_[0]->{_error} .= $_[1]. "<br>\n" if $_[1];
    return $_[0]->{_error};
}

=head2 warning

Get/set warning messages.

=cut

sub warning {
    $_[0]->{_warning} = '' unless $_[0]->{_warning};
    $_[0]->{_warning} .= $_[1]. "<br>\n" if $_[1];
    return $_[0]->{_warning};
}

=head2 info

Get/set informational messages.

=cut

sub info {
    $_[0]->{_info} = '' unless $_[0]->{_info};
    $_[0]->{_info} .= $_[1]. "<br>\n" if $_[1];
    return $_[0]->{_info};
}

=head2 success

Get/set success messages.

=cut

sub success {
    $_[0]->{_success} = '' unless $_[0]->{_success};
    $_[0]->{_success} .= $_[1]. "<br>\n" if $_[1];
    return $_[0]->{_success};
}

1;

=head1 SEE ALSO

L<Apache::Onanox>

L<Template>

L<Template::Plugin>

