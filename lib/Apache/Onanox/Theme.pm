package Apache::Onanox::Theme;

=head1 NAME

Apache::Onanox::Theme

=head1 ABSTRACT

Theme manipulation class.

=head1 METHODS

=cut

use strict;
use warnings;
use Apache::Onanox::Database::Theme;
use base qw(Apache::Onanox::Base);

our $VERSION = '0.01';
our %Errors        = (
        exists     => 'Theme already exists',
        bad_path   => 'Invalid path',
        create_dir => 'Cannot create a directory',
        not_found  => 'Theme does not exist',
        not_owner  => 'You do not own this theme',
        no_param   => 'Parameter not supplied',
);

=head2 get

Retrieves theme.

=cut

sub get {
    my $self = shift;
    my $theme = shift;
    return unless $theme;

    my @themes = Apache::Onanox::Database::Theme->search(name => $theme);
    return $themes[0];
}

=head2 get_all

Retrieves all themes.

=cut

sub get_all {
    my @themes = Apache::Onanox::Database::Theme->retrieve_all;
    return \@themes;
}

=head2 list

Retrieves names of all themes.

=cut

sub list {
    my $self = shift;
    my $themes = $self->get_all;
    my @names;

    foreach (@$themes) {
        $names[$#names+1] = $_->name;
    }

    return \@names;
}

=head2 create

Creates a new theme.

=cut

sub create {
    my $self = shift;
    my $theme = shift;

    my ($exists, $error) = $self->get($theme->{name});
    return (undef, $Errors{exists}) if $exists;

    my $new_theme = Apache::Onanox::Database::Theme->create($theme);
    $new_theme->commit;
    return $new_theme;
}

=head2 update

Update a theme.

=cut

sub update {
    my $self  = shift;
    my $theme = shift;
    my $user  = shift;
    return (undef, $Errors{no_param}) unless $theme;
    return (undef, $Errors{no_param}) unless $user;

    my ($exists, $error) = $self->get($theme->{name});
    return (undef, $error) if $error;
    return (undef, $Errors{not_found}) unless $exists;
    return (undef, $Errors{not_owner}) 
        unless $exists->{owner_id} == $user->user_id;

    foreach (keys %$theme) {
        $exists->$_($theme->{$_});
    }
    $exists->commit;
    return $exists;
}

=head2 delete

Deletes a theme.

=cut

sub delete {
    my $self   = shift;
    my $theme  = shift;
    my $owner  = shift;

    my ($the, $error) = $self->get($theme);
    return (undef, $Errors{not_found}) unless $the;
    return (undef, $Errors{not_owner}) unless $owner;
    return (undef, $Errors{not_owner}) unless $the->{owner_id} == $owner;
    $self->log("Deleting " . $theme);
    $the->delete;
    return (1, undef);
}

1;

=head1 SEE ALSO

L<Apache::Onanox>

=cut
