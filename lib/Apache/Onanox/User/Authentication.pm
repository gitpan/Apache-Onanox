package Apache::Onanox::User::Authentication;

=head1 NAME

Apache::Onanox::User::Authentication

=head1 ABSTRACT

Authentication via cookies and login form.

=head1 METHODS

=cut

use base qw(Apache::Onanox::Base);
use Apache::Cookie;
use Apache::Onanox::User;

=head2 new

Simple constructor.

=cut

sub new {
    my $self = bless {}, $_[0];
    $self->parameters($_[1]);
    return $self;
}

=head2 parameters

Gets the parameters.

=cut

sub parameters {
    $_[0]->{_parameters} = $_[1] if $_[1];
    return $_[0]->{_parameters};
}

=head2 user

Returns authenticated username.

=cut

sub user {
    my $self = shift;
    my $set = shift;
    my $unset = shift;
    $self->{_username} = $set if $set;
    $self->{_username} = undef if $unset;
    return $self->{_username};
}

=head2 authorised

Authorised user or guest user.

=cut

sub authorised {
    my $self = shift;
    my $set = shift;
    my $unset = shift;
    $self->{_authorised} = $set if $set;
    $self->{_authorised} = undef if $unset;
    return $self->{_authorised};
}

=head2 authenticate

Do authentication.

=cut

sub authenticate {
    my $self = shift;

    $self->{DEBUG} = 1;

    $self->cookie_login;
    $self->do_login;
    $self->do_logout;
    $self->auth_user->lasttime($self->sql_date);

    return $self->auth_user;
}

=head2 auth_user

Return a user object, either of the authenticated user, or of the guest user.

=cut

sub auth_user {
    my $self = shift;
    return $self->{_auth_user} if $self->{_auth_user};

    if ($self->authorised){
        $self->{_auth_user} = 
            Apache::Onanox::User->new({username => $self->user});
    } else {
        $self->{_auth_user} = 
            Apache::Onanox::User->new({username => 'guest'});
    }
    return $self->{_auth_user};
}

=head2 cookie_login

Checks for a login cookie, and validates user details from that.

=cut

sub cookie_login {
    my $self = shift;

    # Get cookie and parse it
    my $cookies = Apache::Cookie->fetch;
    return unless $cookies->{login};

    my ($username, $salt) = $cookies->{login}->value;
    return unless $username and $salt;

    my $user = Apache::Onanox::User->new({username => $username});
    $self->user_debug("Bad cookie: no such user $username. Log in again.")
        unless $user;
    return unless $user;

    if ($salt ne $self->create_md5($user->password)) { 
        $self->user_debug("Bad cookie: salts don't match. Log in again."); 
        $self->create_cookie; # invalidate the cookie
        return;
    }

    if ($user->status =~ /^unactivated$|^locked$/) { 
        $self->user_debug("Account is " . $user->status);
        $self->create_cookie; # invalidate the cookie
	return;
    }

    $self->authorised("true");
    $self->user($username);
    return;
}

=head2 do_login

Checks username and password, sets cookie.

=cut

sub do_login {
    my $self = shift;
    my ($l, $e) = $self->parameters->get('login');
    return unless $l;
    my ($username, $password);
    ($username, $e) = $self->parameters->get('username');
    $self->user_debug("Login error ($e)") if $e;
    ($password, $e) = $self->parameters->get('password');
    $self->user_debug("Login error ($e)") if $e;
    return unless($username and $password);

    my $user = Apache::Onanox::User->new({username => $username});
    unless($user->exists) {
        $self->user_debug("Login error: no such user $username");
        return;
    }
    if ($user->status =~ /^unactivated$|^locked$/) { 
        $self->user_debug("Account is " . $user->status);
        $self->create_cookie; # invalidate the cookie
        return;
    }
    unless($password eq $user->password) {
        $self->user_debug("passwords don't match");
        return;
    }
    $self->create_cookie($username, $password);
    $self->authorised("true");
    $self->user($username);
    $self->user_debug("Good login from $username");
    return;
}

=head2 do_logout

Logs out a user.

=cut

sub do_logout {
    my $self = shift;
    my ($l, $e) = $self->parameters->get('logout');
    return unless $l;

    $self->create_cookie; # invalidate the cookie
    $self->authorised('', 'true');
    $self->user('', 'true');
    $self->user_debug("logged out");
    return;
}

=head2 create_cookie

Creates a login cookie.

=cut

sub create_cookie {
    my $self = shift;
    my $username = shift;
    my $passwd = shift;

    # We want to use this to unset cookies too...
    my @value;
    if (!$username or !$passwd) {
        $username = 'guest';
        $passwd   = '';
    }
    $value[0] = $username if $username;
    $value[1] = $self->create_md5($passwd) if $passwd;

    my $logincookie =  Apache::Cookie->new($self->{request},
                           -name    => 'login',
                           -value   => \@value,
                           -expires => '+3M',
                           -path    => '/',
                           );
    $logincookie->bake;
    return;
}

1;

=head1 SEE ALSO

L<Apache::Onanox>

=cut
