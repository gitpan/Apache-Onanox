package Apache::Onanox::Template::Plugin::User;

use strict;
use warnings;

use base qw( Apache::Onanox::Template::Plugin::Base );
use Apache::Onanox::User;
use Apache::Onanox::Mail;

=head2 password

Lost password function.

=cut

sub password {
    my $self = shift;
    my $p = $self->req_parameters;
    my ($d, $e) = $p->get('user_password');
    return if $e;

    my @params = qw(username email);
    my $user = {};
    my $error = '';

    foreach (@params) {
        ($user->{$_}, $error) = $p->get($_);
        $self->error("$_ not ok") if $error;
        return if $error;
        return unless defined $user->{$_};
        $self->info("$_ ok");
    }

    my $aou = Apache::Onanox::User->new({username => $user->{username}});
    $self->error("no such user " . $user->{username})
        unless $aou->exists;
    $self->info("okay user " . $user->{username}) if $aou->exists;
    return unless $aou->exists;
    $self->info("Email addresses match") 
        if ($user->{email} eq $aou->email);
    $self->info("Email addresses do not match") 
        unless ($user->{email} eq $aou->email);
    $self->error("Email addresses do not match") 
        unless ($user->{email} eq $aou->email);
    return unless ($user->{email} eq $aou->email);
    $self->info("Sending mail...");

    my $aod = Apache::Onanox::Document->new;
    my $mail = Apache::Onanox::Mail->new;
    my $msg = {
        to => $aou->realname.' <'.$aou->email.'>',
        from => 'Apache Onanox password mailer <noreply@localhost>',
        subject => $aod->title('/email/lostpassword.email'),
        body => $aod->render
            ('/email/lostpassword.email', $aou->user, 'email'),
    };
    my $success = $mail->send($msg);
    $self->error("Error sending mail") unless $success;
    return unless $success;

    $self->success("Email has been sent");
    $self->log("password sent to " . $aou->username . 
                         " at ". $aou->email);
    return;
}

=head2 create

Creates a new user account.

=cut

sub create {
    my $self = shift;
    my $p = $self->req_parameters;
    my ($d, $e) = $p->get('create_user');
    return if $e;

    my @params = qw(username password repeat_password email realname);
    my $user = {};
    my $error = '';

    foreach (@params) {
        ($user->{$_}, $error) = $p->get($_);
        $self->error("$_ not ok") if $error;
        return if $error;
        return unless defined $user->{$_};
        $self->info("$_ ok");
    }
    return unless ($user->{password} eq $user->{repeat_password});
    $self->info("passwords match");

    my $aou = Apache::Onanox::User->new({username => $user->{username}});
    return if $aou->exists;

    $self->info("user doesn't exist");

    #### Setup for creation ####
    delete $user->{repeat_password};
    $user->{lasttime} = $self->sql_date;
    $user->{created} = $user->{lasttime};
#    $user->{ip_addr} = $self->{request}->get_remote_host;
    ($user->{ip_addr}, my $err) = $self->stash->get('remote_host');

    #### User Creation ####
    my $useracc = $aou->create($user);
    return unless $useracc;

    $self->info("user created");

    #### Send the mail with activation URL ####    
#    $user->{hostname}   = $self->{request}->hostname;
    ($user->{hostname}, $err) = $self->stash->get('hostname');
    $user->{url}        = '/tasks/user/activation.html';
    $user->{activation} = $self->create_md5($user->{password});

    my $mail = Apache::Onanox::Mail->new;
    my $aod = Apache::Onanox::Document->new;
    my $msg = {
        to => $user->{realname}.' <'.$user->{email}.'>',
        from => 'Apache Onanox <noreply@localhost>',
        subject => 'Your account details', 
        body => $aod->render('/email/newuser.email', $user, 'email'),
    };
    $mail->send($msg);

    $self->success('Account created, email sent.<br>
Please activate your account <a href="/tasks/user/activation.html">here</a>');

    $self->log("New user email sent to ". $user->{realname} .", (".
                          $user->{username} .") at ". $user->{email});
    return;
}

=head2 activate

Activates a new user account.

=cut

sub activate {
    my $self = shift;
    my $p = $self->req_parameters;
    my ($d, $e) = $p->get('activation');
    return if $e;

    my @params = qw(username activation);
    my $user = {};
    my $error = '';

    foreach (@params) {
        ($user->{$_}, $error) = $p->get($_);
        $self->error("$_ not ok") if $error;
        return if $error;
        return unless defined $user->{$_};
        $self->info("$_ ok");
    }

    my $u = Apache::Onanox::User->new({username => $user->{username}});
    my $exists = $u->exists;
    $self->error($user->{username}. " does not exist, so cannot activate")
        unless $exists;
    return unless $exists;

    $self->info("user exists ok");

    my $a = $self->create_md5($u->password);
    return unless ($user->{activation} eq $a);
    $self->info("activating");

    my $ae = $u->activate;
    unless ($ae) {
        $self->error('Error activating account!');
        return;
    }

    $self->success('Account activated. 
    You may now <a href="/tasks/user/login.html">log in</a>');

    $self->log("account activation for " . $user->{username});
    return;
}

=head2 customise

Customise preferences.

=cut

sub customise {
    my $self = shift;
    my $p = $self->req_parameters;
    my ($c, $e) = $p->get('customiseuser');
    return if $e;
    my $d = $p->parameters;
    my $user = $self->stash->get('user');

    foreach my $x (sort keys %$d) {
        next unless $x =~ m/^pref_(.*)$/;
        my $s = $user->preferences->update($1, $p->get($x));
        $self->error("Error with $x ". $p->get($x)) unless $s;
    }
    $self->success("Updates successfully completed.<br>
    Changes will take effect on next page load.");
}

=head2 reset

Resets user customisations.

=cut

sub reset {
    my $self = shift;
    my $p = $self->req_parameters;
    my ($d, $e) = $p->get('reset_prefs');
    return if $e;

    my $r = $self->stash->get('user')->preferences->reset;
    $self->success("Preferences reset") unless $r;
    $self->error("Error reseting") if $r;
}

=head2 logged_in

Lists users currently logged in

=cut

sub logged_in {
    my $self = shift;
    my $aou = Apache::Onanox::User->new({ user_id => 1 });
    my @users = $aou->logged_in('600');
    return @users;
}

=head2 list

Lists all users.

=cut

sub list {
    my $self = shift;
    return $self->stash->get('user')->list;
}

=head2 update

Updates a user.

=cut

sub update {
    my $self = shift;
    my $p = $self->req_parameters;
    my ($u, $e) = $p->get('updateuser');
    return unless $u;

    my $user = $self->stash->get('user');
    $self->stash->set(['update' => 0, 'email' => 0], $user->{email});
    $self->stash->set(['update' => 0, 'realname' => 0], $user->{realname});

    my @params = qw(realname email);
    my %user   = ();
    my $error  = '';

    foreach (@params) {
        ($user{$_}, $error) = $p->get($_);
        $self->info("$_ ok");
    }
    $user{username} = $user->username;

    my ($us, $ee) = $user->update(\%user);
    $self->error("Error updating user ($ee)") if $ee;
    return if $ee;
    $self->success("User updated");
    return;
}

=head2 details

Views a user's details.

=cut

sub details {
    my $self = shift;
    my $p = $self->req_parameters;

    my $user = $self->stash->get('user');
    my ($userdetails, $e) = $p->get('userdetails');
    return unless $userdetails;
    my $aou = Apache::Onanox::User->new({username => $userdetails});
    $self->error("User $userdetails does not exist") unless $aou->exists;
    return unless $aou->exists;
    $aou->{password} = undef; # let's not be naughty...
    $self->stash->set('viewuserdetails', $aou);

    $self->success("Here are the details:");
    return;
}

1;

=head1 SEE ALSO

L<Apache::Onanox>

L<Template>

L<Template::Plugin>
