package Apache::Onanox::User;

=head1 NAME

Apache::Onanox::User

=head1 ABSTRACT

User manipulation class.

=head1 METHODS

=cut

use strict;
use warnings;
use Apache::Onanox::Database::User;
use Apache::Onanox::User::Preferences;
use base qw(Apache::Onanox::Base);

our $VERSION = '0.01';
our %Errors        = (
        not_found  => 'User does not exist',
        no_param   => 'Parameter not supplied',
);

=head2 new

Simple constructor

=cut

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    my $h = shift;

    if ($h->{username}){
        $self->get($h->{username});
    } elsif ($h->{user_id}) {
        $self->get_by_id($h->{user_id});
    } else {
        return undef;
    }

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

Retrieves a user by user_id.

=cut

sub get_by_id {
    my $self = shift;
    my $user_id = shift;
    return unless $user_id;

    my @users = Apache::Onanox::Database::User->search(
                        user_id => $user_id);

    return if @users > 1;
    $self->user($users[0]);
    return $self->user;
}

=head2 get

Retrieves a user.

=cut

sub get {
    my $self = shift;
    my $username = shift;
    return unless $username;

    my @users = Apache::Onanox::Database::User->search(
                        username => $username);

    return if @users > 1;
    $self->user($users[0]);
    return $self->user;
}

=head2 get_all

Retrieves all users.

=cut

sub get_all {
    my @users = Apache::Onanox::Database::User->retrieve_all;
    return \@users;
}

=head2 list

Retrieves usernames of all users.

=cut

sub list {
    my $self = shift;
    my $users = $self->get_all;
    my @names;

    foreach (@$users) {
        $names[$#names+1] = $_->username;
    }

    return \@names;
}

=head2 create

Creates a new user.

=cut

sub create {
    my $self = shift;
    my $user = shift;
    $user->{created} = $self->sql_date unless $user->{created};
    $user->{status} = 'unactivated';

    $self->get($user->{username});
    my $exists = $self->user;
    return (undef, 1) if $exists;

    my $new_user = Apache::Onanox::Database::User->create($user);
    $new_user->commit;
    #my $p = $new_user->preferences($new_user->{user_id});
    my $u = Apache::Onanox::User->new({user_id => $new_user->{user_id}});
    $u->preferences->reset;
    return $new_user;
}

=head2 update

Updates a user.

=cut

sub update {
    my $self        = shift;
    my $user        = shift;
    return (undef, $Errors{no_param})   unless $user;
    my ($exists, $error) = $self->get($user->{username});
    return (undef, $Errors{not_found})  unless $exists;

    delete $user->{user_id}; # changing the primary key is baad, mkay?
    foreach (keys %$user) {
        next unless defined $user->{$_};
        $exists->$_($user->{$_});
    }
    $exists->commit;
    return $exists;
}

=head2 exists

Checks for the existance of a user;

=cut

sub exists {
    return $_[0]->{_user};
}

=head2 activate

Activates a new user account.

=cut

sub activate {
    return unless $_[0]->exists;
    return unless $_[0]->user->{status} eq 'unactivated';

    $_[0]->user->status('active');
    $_[0]->user->commit;
    return $_[0]->user;
}

=head2 user_id 

Returns user_id.

=cut

sub user_id {
    return unless $_[0]->exists;
    return $_[0]->user->user_id;
}

=head2 username

Returns / sets username.

=cut

sub username {
    return unless $_[0]->exists;
    return $_[0]->user->username if $#_ == 0;
    $_[0]->user->username($_[1]);
    $_[0]->user->commit;
    return $_[0]->user;
}

=head2 email

Returns email address.

=cut

sub email {
    return unless $_[0]->exists;
    return $_[0]->user->email if $#_ == 0;
    $_[0]->user->email($_[1]);
    $_[0]->user->commit;
    return $_[0]->user;
}

=head2 realname

Returns user's real name.

=cut

sub realname {
    return unless $_[0]->exists;
    return $_[0]->user->realname if $#_ == 0;
    $_[0]->user->realname($_[1]);
    $_[0]->user->commit;
    return $_[0]->user;
}

=head2 password

Returns password.

=cut

sub password {
    return unless $_[0]->exists;
    return $_[0]->user->password if $#_ == 0;
    $_[0]->user->password($_[1]);
    $_[0]->user->commit;
    return $_[0]->user;
}

=head2 status

Returns status.

=cut

sub status {
    return unless $_[0]->exists;
    return $_[0]->user->status if $#_ == 0;
    $_[0]->user->status($_[1]);
    $_[0]->user->commit;
    return $_[0]->user;
}

=head2 created

Returns creation datetime.

=cut

sub created {
    return unless $_[0]->exists;
    return $_[0]->user->created;
}

=head2 lasttime

Returns user's last access datetime.

=cut

sub lasttime {
    return unless $_[0]->exists;
    return $_[0]->user->lasttime if $#_ == 0;
    $_[0]->user->lasttime($_[1]);
    $_[0]->user->commit;
    return $_[0]->user;
}

=head2 logged_in

Gets list of users logged in.

(TBC. Currently just displays all users.)

=cut

sub logged_in {
    my $self = shift;
    my $time = shift;
    return $self->list;
}

=head2 ip_addr

Returns user's last access IP address.

=cut

sub ip_addr {
    return unless $_[0]->exists;
    return $_[0]->user->ip_addr if $#_ == 0;
    $_[0]->user->ip_addr($_[1]);
    $_[0]->user->commit;
    return $_[0]->user;
}

=head2 preferences

Return Apache::Onanox::User::Preferences object for the user.

=cut

sub preferences {
    return unless $_[0]->exists;
    return Apache::Onanox::User::Preferences->new($_[0]);
}

1;

=head1 SEE ALSO

L<Apache::Onanox>

=cut
