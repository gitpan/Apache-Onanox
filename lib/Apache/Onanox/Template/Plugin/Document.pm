package Apache::Onanox::Template::Plugin::Document;

use strict;
use warnings;

use base qw( Apache::Onanox::Template::Plugin::Base );
use Apache::Onanox::Document;

=head2 create

Creates a document.

=cut

sub create {
    my $self = shift;
    my $p = $self->req_parameters;
    my ($d, $e) = $p->get('createdoc');
    return if $e;
    my @params = qw(path title version type worldread worldwrite contents);
    my %document = ();
    my $error = '';

    foreach (@params) {
        ($document{$_}, $error) = $p->get($_);
        my $not_error = 1 if $_ =~ /^version$|^world/;
        $document{$_} ||= 0 if $_ =~ /^version$/;
        $document{$_} ||= 1 if $_ =~ /^worldread$/;
        $document{$_} ||= 0 if $_ =~ /^worldwrite$/;
        $self->error("$_ not ok") if $error and not $not_error;
        return unless defined $document{$_};
        $self->info("$_ ok");
    }
    my $user = $self->stash->get('user');
    $document{author_id} = $user->user_id;

    my $aod = Apache::Onanox::Document->new;
    my ($doc, $ee) = $aod->create(\%document);
    $self->error("Error creating document ($ee)") if $ee;
    return if $ee;
    $self->success("Document created");
    $self->log("document " . $document{path} . " created")
        if $doc;
    return;
}

=head2 update

Updates a document.

=cut

sub update {
    my $self = shift;
    my $p = $self->req_parameters;
    my ($d, $e) = $p->get('getupdatedoc');
    my ($dd, $ee) = $p->get('updatedoc');
    my $aod = Apache::Onanox::Document->new;

    if ($d) {
        my ($ddd, $err) = $p->get('getpath');
	$self->error("Error: ".$err) if $err;
        my ($doc, $er2) = $aod->get($ddd);
	$self->error("Error: ".$er2) if $er2;
        $self->stash->set(['update' => 0, 'path' => 0], $doc->{path});
        $self->stash->set(['update' => 0, 'title' => 0], $doc->{title});
        $self->stash->set(['update' => 0, 'contents' => 0], $doc->{contents});

        return 'update';
    } elsif ($dd) {

        my @params = qw(path title version type worldread worldwrite contents);
        my %document = ();
        my $error = '';

        foreach (@params) {
            ($document{$_}, $error) = $p->get($_);
            my $not_error = 1 if $_ =~ /^version$|^world/;
            $document{$_} ||= 0 if $_ =~ /^version$/;
            $document{$_} ||= 1 if $_ =~ /^worldread$/;
            $document{$_} ||= 0 if $_ =~ /^worldwrite$/;
            $self->error("$_ not ok") if $error and not $not_error;
            return unless defined $document{$_};
            $self->info("$_ ok");
        }

        $self->info("Got here");
        my $user = $self->stash->get('user');
        $self->info("Got here");
        my ($doc, $eee) = $aod->update(\%document, $user);
        $self->info("Got here");
        $self->error("Error updating document ($eee)") if $eee;
        return if $eee;
        $self->success("Document updated");
        $self->log("document " . $document{path} . " updated")
            if $doc;
        return 'success';
    } else {
        return 'get';
    }
}

=head2 delete

Deletes a document.

=cut

sub delete {
    my $self = shift;
    my $p = $self->req_parameters;
    my ($d, $e) = $p->get('deletedoc');
    return if $e;
    my @params = qw(path repeatpath version);
    my %document = ();
    my $error = '';

    foreach (@params) {
        ($document{$_}, $error) = $p->get($_);
        my $not_error = 1 if $_ =~ /^version$/;
        $document{$_} ||= 0 if $_ =~ /^version$/;
        $self->error("$_ not ok") if $error and not $not_error;
        return unless defined $document{$_};
        $self->info("$_ ok");
    }
    my $eq = ($document{path} eq $document{repeatpath});
    $self->error("Paths do not match") unless $eq;
    return unless $eq;
    $self->info("Parameters OK");

    my $aod = Apache::Onanox::Document->new;
    my $user = $self->stash->get('user')->user_id;
    my ($doc, $ee) = $aod->delete($document{path}, $document{version}, $user);
    $self->info("Deletion OK") if $doc;
    $self->error("Error deleting document ($ee)") if $ee;
    return if $ee;
    $self->success("Document deleted");
    $self->log("document " . $document{path} . " deleted");
    return;
}

=head2 list

Lists all documents.

=cut

sub list {
    my $aod = Apache::Onanox::Document->new;
    return $aod->list;
}

1;

=head1 SEE ALSO

L<Apache::Onanox>

L<Template>

L<Template::Plugin>
