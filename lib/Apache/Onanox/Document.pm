package Apache::Onanox::Document;

=head1 NAME

Apache::Onanox::Document

=head1 ABSTRACT

Document manipulation class

=cut

use strict;
use warnings;

use Apache::Onanox::Database::Document;
use Apache::Onanox::Template::Provider;
use Apache::Onanox::Theme;
use Template;
use Template::Service;
use Template::Plugins;
use Template::Context;

use base qw(Apache::Onanox::Base);

our $VERSION       = '0.01';
our $DefaultIndex  = 'index.html';
our $DefaultTitle  = 'Untitled Document';
our $UserDetails   = '/tasks/user/details.html';
our $ErrorNotFound = '/errors/404.html';
our $Config        = '/config';
our %Errors        = (
        exists     => 'Document already exists',
        bad_path   => 'Invalid path',
        create_dir => 'Cannot create a directory',
        not_found  => 'Document does not exist',
        locked     => 'Document is locked',
        not_locker => 'You have not locked this document',
        not_locked => 'Document is not locked',
        not_owner  => 'You do not own this document',
        no_param   => 'Parameter not supplied',
);

=head2 contents

Get the contents of a specified document

=cut

sub contents {
    my $self     = shift;
    my $document = shift;
    my $version  = shift;
    return unless $document;

    my ($doc, $error) = $self->get($document, $version);
    return $doc->contents unless $error;
    return (undef, $error);
}    

=head2 get

Gets a document object from the database and escapes tags.

=cut

sub get {
    my $self     = shift;
    my $document = shift;
    my $version  = shift;
    $version     ||= 0;
    return unless $document;

#    $document =~ s((.*)/$)($1/$DefaultIndex);

#    my @documents = Apache::Onanox::Database::Document->search(
#                        path => $document);

#    foreach my $doc (@documents) {
#        next unless $doc->version == $version;
        my ($doc, $err) = $self->get_unescaped($document, $version);
	return (undef, $err) if $err;
        $doc->{contents} = $self->escape_tags($doc->contents)
            unless($doc->type eq 'parsed');
        return ($doc, undef);
#    }

    return (undef, $ErrorNotFound);
}

=head2 get_all

Retrieves all documents.

=cut

sub get_all {
    my @docs = Apache::Onanox::Database::Document->retrieve_all;
    return \@docs;
}

=head2 list

Retrieves paths of all documents.
(TBC. Currently returns all documents.)

=cut

sub list {
    my $self = shift;
    return $self->get_all;
#    my $docs = $self->get_all;
#    my @names;
#
#    foreach (@$docs) {
#        $names[$#names+1] = $_->path;
#    }
#
#    return \@names;
}

=head2 get_unescaped

Gets a document object from the database.

=cut

sub get_unescaped {
    my $self     = shift;
    my $document = shift;
    my $version  = shift;
    $version     ||= 0;
    return unless $document;

    $document =~ s((.*)/$)($1/$DefaultIndex);
    $document =~ s(^/~)($UserDetails);

    my @documents = Apache::Onanox::Database::Document->search(
                        path => $document);

    foreach my $doc (@documents) {
        next unless $doc->version == $version;
        $doc->{title} = $DefaultTitle if ($doc->{title} eq '');
        return ($doc, undef);
    }

    return (undef, $ErrorNotFound);
}

=head2 exists

Tests for the existance of a document.

=cut

sub exists {
    my $self     = shift;
    my $document = shift;
    my $version  = shift;

    my ($doc, $err) = $self->get($document, $version);
    return 1 if $doc;
    return undef;
}

=head2 title

Gets a document's title

=cut

sub title {
    my $self     = shift;
    my $document = shift;
    my $version  = shift;

    my ($doc, $err) = $self->get($document, $version);
    $doc->{title} ne '' ? return $doc->title:
                  return $DefaultTitle;
}

=head2 context

Get/set the Template context.

=cut

sub context {
    $_[0]->{_context} = $_[1] if $_[1];
    return $_[0]->{_context};
}

=head2 escape_tags

Escapes TT tags.

=cut

sub escape_tags {
   my $self = shift;
   $_ = shift;

   s/\[%/&#91;&#37;/g; # open TT tag
   s/%\]/&#37;&#93;/g; # close TT tag
   s/\$/&#36;/g;       # interpolated variable
   return $_;
}

=head2 delete

Deletes a document.

=cut

sub delete {
    my $self     = shift;
    my $document = shift;
    my $version  = shift;
    my $owner    = shift;

    my ($doc, $error) = $self->get($document, $version);
    return (undef, $Errors{not_found}) unless $doc;
    return (undef, $Errors{not_owner}) unless $owner;
    return (undef, $Errors{not_owner}) unless $doc->{author_id} == $owner;
    $self->log("Deleting " . $document);
    $doc->delete;
    return (1, undef);
}

=head2 lock

Locks a document for a user

=cut

sub lock {
    my $self      = shift;
    my $document  = shift;
    my $locker_id = shift;
    my $version   = shift;
    return (undef, $Errors{no_param} . "document")   unless $document;
    return (undef, $Errors{no_param} . "locker_id")   unless $locker_id;

    # Test and test and set
    my ($doc, $error) = $self->get($document, $version);
    return (undef, $Errors{locked}) if $doc->{locker_id};
    select(undef, undef, undef, 0.5); #sleep 1/2 second
    ($doc, $error) = $self->get($document, $version);
    return (undef, $Errors{locked}) if $doc->{locker_id};
    $doc->locker_id($locker_id);
    $doc->commit;
    return 1;
}

=head2 unlock

Unlocks a document.

=cut

sub unlock {
    my $self      = shift;
    my $document  = shift;
    my $locker_id = shift;
    my $version   = shift;
    return (undef, $Errors{no_param})   unless $document;
    return (undef, $Errors{no_param})   unless $locker_id;

    my ($doc, $error) = $self->get($document, $version);
    return (undef, $Errors{not_locked}) unless $doc->{locker_id};
    return (undef, $Errors{not_locker}) unless $doc->{locker_id} == $locker_id;
    $doc->locker_id(0);
    $doc->commit;
    return 1;
}

=head2 create

Creates a document.

=cut

sub create {
    my $self        = shift;
    my $doc         = shift;
    $doc->{created} = $self->sql_date;
    $doc->{locker_id} = 0;
    return (undef, $Errors{create_dir}) if $doc->{path} =~ m#/$#;
    return (undef, $Errors{bad_path}) if $doc->{path} =~ m#^!/#;

    my ($exists, $error) = $self->get($doc->{path}, $doc->{version});
    return (undef, $Errors{exists}) if $exists;

    my $newdoc = Apache::Onanox::Database::Document->create($doc);
    $newdoc->commit;
    return $newdoc;
}

=head2 update

Updates a document.

=cut

sub update {
    my $self        = shift;
    my $doc         = shift;
    my $user        = shift;
    $doc->{created} = $self->sql_date;
    return (undef, $Errors{no_param})   unless $doc;
    return (undef, $Errors{no_param})   unless $user;
    return (undef, $Errors{create_dir}) if $doc->{path} =~ m#/$#;
    return (undef, $Errors{bad_path})   if $doc->{path} =~ m#^!/#;
    my ($exists, $error) = 
        $self->get_unescaped($doc->{path}, $doc->{version});
    return (undef, $Errors{not_found})  unless $exists;
    return (undef, $Errors{not_owner}) 
        unless $exists->{author_id} == $user->user_id;
    my ($ok, $err) = 
        $self->lock($doc->{path}, $user->user_id, $doc->{version});
    return (undef, $err) if $err;

    foreach (keys %$doc) {
        $exists->$_($doc->{$_});
    }

#    $exists->locker_id('');
    $exists->commit;
    ($ok, $err) = 
        $self->unlock($doc->{path}, $user->user_id, $doc->{version});
    return (undef, $err) if $err;
    return $exists;
}

=head2 render

Renders a document with Template Toolkit.

=cut

sub render {
    my $self  = shift;
    my $doc   = shift;
    my $vars  = shift;
    my $theme = shift;

    my ($pre, $post) = $self->get_theme($theme);
    my $service = Template::Service->new({
        LOAD_PLUGINS   => Template::Plugins->new({ PLUGIN_BASE    => 
                'Apache::Onanox::Template::Plugin'}),
        LOAD_TEMPLATES => Apache::Onanox::Template::Provider->new,
        PRE_PROCESS    => $pre,
        POST_PROCESS   => $post,
    });

    my $template = Template->new({
        SERVICE        => $service,
        INTERPOLATE    => 0,
    }) || die Template->error;

    $self->context($service->context);
    my $temp = undef;
    $template->process($doc, $vars, \$temp) || die $template->error;
    return $temp;
}

=head2 get_theme

Gets the headers and footers for a theme

=cut

sub get_theme {
    my $self = shift;
    my $theme = shift;

    my $aot = Apache::Onanox::Theme->new;
    my $t   = $aot->get($theme);
            # it failed, try for default theme
    $t      = $aot->get('default') unless $t; 
    
    my (@pre, @post);
    push @pre, ($Config) if $self->exists($Config);
    if (defined $t) {
	push @pre,  ($t->header) if $self->exists($t->header);
	push @pre,  ($t->config) if $self->exists($t->config);
	push @post, ($t->footer) if $self->exists($t->footer);
    }
    return (\@pre, \@post);
}

1;

=head1 SEE ALSO

F<Apache::Onanox>

=cut
