package Apache::Onanox::User::Preferences;

=head1 NAME

Apache::Onanox::User::Preferences

=head1 ABSTRACT

User preferences manipulation class.

=head1 METHODS

=cut

use strict;
use warnings;
use Apache::Onanox::Database::User::Preferences;
use base qw(Apache::Onanox::Base);

our $VERSION = '0.01';

=head2 new

Simple constructor

=cut

sub new {
    my $self = bless {}, $_[0];
    $self->user($_[1]);
    return $self;
}

=head2 user

Get/set user

=cut

sub user {
    $_[0]->{_user} = $_[1] if $_[1];
    return $_[0]->{_user};
}

=head2 get_by_id

Retrieves a preference by pref_id.

=cut

sub get_by_id {
    my $self = shift;
    my $pref_id = shift;
    return unless $pref_id;

    my $pref = Apache::Onanox::Database::User::Preferences->retrieve($pref_id);

    return $pref;
}

=head2 get

Retrieves preferences for a user.

=cut

sub get {
    my $self = shift;
    return unless $self->user;

    my @prefs = Apache::Onanox::Database::User::Preferences->search(
                        user_id => $self->user->user_id);

    return \@prefs;
}

=head2 get_by_type

Retrieves preferences for a user by type (and selector, optionally).

=cut

sub get_by_type {
    my $self = shift;
    return unless $self->user;
    my $type = shift;
    return unless $type;
    my $selector = shift;

    my $prefs = $self->get;
    my @by_type = grep { $_->{type} =~ /^$type$/ } @$prefs;
    if (defined $selector) {
        @by_type = grep { $_->{selector} =~ /^$selector$/ } @by_type;
    }
    return \@by_type;
}

=head2 list_types

Lists all types

=cut

sub list_types {
    my $self = shift;
    return unless $self->user;

    my $prefs = $self->get;
    my %types;
    foreach my $type (@$prefs) {
        $types{$type->{type}}++;
    }
    return %types;
}

=head2 list_selectors

Lists all selectors

=cut

sub list_selectors {
    my $self = shift;
    return unless $self->user;

    my $prefs = $self->get;
    my %types;
    foreach my $type (@$prefs) {
        $types{$type->{selector}}++;
    }
    return \%types;
}

=head2 get_values_by_type

Retrieves values of preferences for a user by type (and selector, optionally).

=cut

sub get_values_by_type {
    my $self = shift;
    return unless $self->user;
    my $type = shift;
    return unless $type;
    my $selector = shift;

    my $by_type = $self->get_by_type($type, $selector);
    my @values;
    foreach(@$by_type) {
        $values[$#values+1] = $_->{value};
    }
    return \@values;
}

=head2 theme

Retrieves theme for a user.

=cut

sub theme {
    my $self = shift;
    return unless $self->user;

    my $prefs = $self->get;

    foreach my $pref (@$prefs) {
        next unless $pref->type eq "theme";
        return $pref->value;
    }
    return;
}

=head2 make_css

Makes CSS from a user's preferences.

=cut

sub make_css {
    my $self = shift;
    return unless $self->user;

    my $prefs = $self->get;
    my @css;
    my %sels;
    my $CSS = '<style type="text/css">';

    foreach my $pref (@$prefs) {
        next unless $pref->type eq "CSS";
        $css[$#css+1] = $pref;
        $sels{$pref->selector}++;
    }

    foreach my $selector (sort keys %sels) {
        $CSS .= "\n" . $selector . " {\n";
        foreach my $cs (@css) {
            next unless $cs->selector eq $selector;
            $CSS .= "    " . $cs->property . ": " . $cs->value . ";\n";
	}
        $CSS .= "}\n";

    }
    
    $CSS .= '</style>';
    return $CSS;
}

=head2 preference

Gets a preference for a user.

=cut

sub preference {
    my $self = shift;
    my $selector = shift;
    my $property = shift;

    my $ret = undef;

    my $u = $self->get;

    foreach (@$u) {
        $ret = $u->[$_]->{value} 
            if (($u->[$_]->{selector} eq $selector) and
               ($u->[$_]->{property} eq $property));
    }

    return $ret;
}

=head2 create

Creates a new user preference.

=cut

sub create {
    my $self = shift;
    my $h = shift;

    my ($exists, $error) = $self->preference
        ($h->{selector}, $h->{property});
    return (undef, 1) if $exists;
    #### bleh, fixme ####

    my $new_pref = Apache::Onanox::Database::Preference->create($h);
    $new_pref->commit;
    return $new_pref;
}

=head2 reset

Resets all user preferences to those of guest user.

=cut

sub reset {
    my $self = shift;
    return if $self->user->username eq 'guest';

    my $new_pref = 
        Apache::Onanox::User::Preferences->new(
        Apache::Onanox::User->new({username => 'guest'}));
    my $prefs = $new_pref->get;

    foreach my $p (@$prefs) {
       my $temp = $p->copy({ user_id => $self->user->user_id });
       $temp->commit;
    }

    return;
}

=head2 update

Updates a preference

=cut

sub update {
    my $self = shift;
    return if $self->user->username eq 'guest';
    my $pref_id = shift;
    my $value = shift;

    my $pref = $self->get_by_id($pref_id);
    return unless $pref->user_id == $self->user->user_id;
    $pref->value($value);
    $pref->commit;

    return 1;
}

1;

=head1 SEE ALSO

L<Apache::Onanox>

=cut
