package Apache::Onanox::Template::Plugin::Theme;

use strict;
use warnings;

use base qw( Apache::Onanox::Template::Plugin::Base );
use Apache::Onanox::Theme;

=head2 create

Creates a theme.

=cut

sub create {
    my $self = shift;
    my $p = $self->req_parameters;
    my ($t, $e) = $p->get('createtheme');
    return if $e;
    my @params = qw(name header config footer description);
    my %theme = ();
    my $error = '';

    foreach (@params) {
        ($theme{$_}, $error) = $p->get($_);
        return unless defined $theme{$_};
        $self->info("$_ ok");
    }

    my $aot = Apache::Onanox::Theme->new;
    my ($the, $ee) = $aot->create(\%theme);
    $self->error("Error creating theme ($ee)") if $ee;
    return if $ee;
    $self->success("Theme created");
    $self->log("Theme " . $theme{name} . " created")
        if $the;
    return;
}

=head2 update

Updates a theme.

=cut

sub update {
    my $self = shift;
    my $p = $self->req_parameters;
    my ($t, $e) = $p->get('getupdatetheme');
    my ($tt, $ee) = $p->get('updatetheme');
    my $aot = Apache::Onanox::Theme->new;

    if ($t) {
        my ($ttt, $err) = $p->get('getname');
	$self->error("Error: ".$err) if $err;
        my ($the, $er2) = $aot->get($ttt);
	$self->error("Error: ".$er2) if $er2;
        $self->stash->set(['update' => 0, 'name' => 0], $the->{name});
        $self->stash->set(['update' => 0, 'description' => 0], 
	    $the->{description});
        $self->stash->set(['update' => 0, 'header' => 0], $the->{header});
        $self->stash->set(['update' => 0, 'footer' => 0], $the->{footer});
        $self->stash->set(['update' => 0, 'config' => 0], $the->{config});

        return 'update';
    } elsif ($tt) {

        my @params = qw(name header footer config description);
        my %theme= ();
        my $error = '';

        foreach (@params) {
            ($theme{$_}, $error) = $p->get($_);
            return unless defined $theme{$_};
            $self->info("$_ ok");
        }

        $self->info("Got here");
        my $user = $self->stash->get('user');
        $self->info("Got here");
        my ($the, $eee) = $aot->update(\%theme, $user);
        $self->info("Got here");
        $self->error("Error updating theme ($eee)") if $eee;
        return if $eee;
        $self->success("Theme updated");
        $self->log("theme " . $theme{name} . " updated")
            if $the;
        return 'success';
    } else {
        return 'get';
    }
}

=head2 delete

Deletes a theme.

=cut

sub delete {
    my $self = shift;
    my $p = $self->req_parameters;
    my ($t, $e) = $p->get('deletetheme');
    return if $e;
    my @params = qw(name repeatname);
    my %theme = ();
    my $error = '';

    foreach (@params) {
        ($theme{$_}, $error) = $p->get($_);
        return unless defined $theme{$_};
        $self->info("$_ ok");
    }
    my $eq = ($theme{name} eq $theme{repeatname});
    $self->error("Names do not match") unless $eq;
    return unless $eq;
    $self->info("Parameters OK");

    my $aot = Apache::Onanox::Theme->new;
    my $user = $self->stash->get('user')->user_id;
    my ($the, $ee) = $aot->delete($theme{name}, $user);
    $self->info("Deletion OK") if $the;
    $self->error("Error deleting theme($ee)") if $ee;
    return if $ee;
    $self->success("Theme deleted");
    $self->log("Theme " . $theme{name} . " deleted");
    return;
}

=head2 list

Lists all themes.

=cut

sub list {
    my $aot = Apache::Onanox::Theme->new;
    return $aot->list;
}

1;

=head1 SEE ALSO

L<Apache::Onanox>

L<Template>

L<Template::Plugin>
