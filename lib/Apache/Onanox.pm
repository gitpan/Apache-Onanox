package Apache::Onanox;

=head1 NAME

Apache::Onanox

=head1 ABSTRACT

Apache handler for Apache::Onanox. 

=head1 SYNOPSIS

Copy onanox.conf and startup.pl to your Apache configuration 
directory ($APACHE_ROOT/conf/).

Put the following into your L<httpd.conf>

C<include onanox.conf>

Edit onanox.conf to suit your needs, specifically the database connection
variables.

=head1 DESCRIPTION

Apache::Onanox is an application framework for customisable multi-user
websites.

=head1 METHODS

=cut

###############################################################################
# General setup
###############################################################################

use strict;
use warnings;

use base qw(Apache::Onanox::Base);

use Apache::Constants qw(:common :response :http);
use Apache::Log;
use Apache::Onanox::Document;
use Apache::Onanox::Parameters;
use Apache::Onanox::User::Authentication;

our $VERSION = 0.01;
our $DEBUG = 1;

###############################################################################
# Handler
###############################################################################

=head2 handler

Apache handler.

=cut

sub handler ($$) {
    my $class = shift;
    my $self = bless {}, $class;
    $self->request(shift);

    $self->init;
    # Save time and quit now if the document doesn't exist
    return $self->status unless $self->check_exists eq DOCUMENT_FOLLOWS;
    $self->authenticate;
    $self->send_response;
    return $self->status;
}

###############################################################################
# Accessor methods
###############################################################################

=head2 request

Get/set request object

=cut

sub request {
    $_[0]->{_request} = $_[1] if $_[1];
    return $_[0]->{_request};
}

=head2 status

Get/set the HTTP return status.

=cut

sub status {
    $_[0]->{_status} = $_[1] if $_[1];
    return $_[0]->{_status};
}

=head2 user

Get/set the current user

=cut

sub user {
    $_[0]->{_user} = $_[1] if $_[1];
    return $_[0]->{_user};
}

=head2 uri

Gets Apache request URI

=cut

sub uri {
    return $_[0]->request->uri;
}

=head2 tt_vars

Get or set Template Toolkit variables.

=cut

sub tt_vars {
    my $self = shift;
    my $get  = shift;
    my $set  = shift;
    $self->{_tt_vars} = {} unless $self->{_tt_vars};

    if    ( $set and $get) { $self->{_tt_vars}->{$get} = $set; }
    elsif (!$set and $get) { return $self->{_tt_vars}->{$get}; }
    else                   { return $self->{_tt_vars};         }
}

=head2 parameters

Get/set parameter object

=cut

sub parameters {
    $_[0]->{_parameters} = $_[1] if $_[1];
    return $_[0]->{_parameters};
}

=head2 document

Get/set document object

=cut

sub document {
    $_[0]->{_document} = $_[1] if $_[1];
    return $_[0]->{_document};
}

###############################################################################
# Initialisation
###############################################################################

=head2 init

Initialisation sequence.

=cut

sub init {
    my $self = shift;
    $Apache::Onanox::Base::USER_DEBUG = undef;
    $self->status(DOCUMENT_FOLLOWS); # Everything is OK at this point
    $self->setup_log('DEBUG');
    $self->setup_database;
    $self->setup_parameters;
}

=head2 setup_log

Sets up Apache logging.

Loglevels: EMERG ALERT CRIT ERR WARNING NOTICE INFO DEBUG

=cut

sub setup_log {
    my $level = $_[1];
    $level ||= 'ALERT';
    my $loglevel = 'Apache::Log::' . $level;
    $_[0]->request->server->loglevel(eval($loglevel));
}

=head2 setup_database

Global database setup. Instantiates L<Apache::Onanox::Database::Base> object.

Uses Apache config file parameters 'dbconn', 'dbuser' and 'dbpass'.

=cut

sub setup_database {
    my $self = shift;
    Apache::Onanox::Database::Base->setup_onanox(
        $self->request->dir_config('dbconn'),
        $self->request->dir_config('dbuser'),
        $self->request->dir_config('dbpass')
    );
}

=head2 setup_parameters

Sets up parameters for untainting.

=cut

sub setup_parameters {
    my $self = shift;
    my %parameters = $self->request->method eq 'POST' 
        ? $self->request->content 
        : $self->request->args;
    $self->parameters(Apache::Onanox::Parameters->new(\%parameters));
}

###############################################################################
# Stuff to do afterwards
###############################################################################

=head2 send_response

Sends response and debugging info.

=cut

sub send_response {
    my $self = shift;
    # get the document before sending headers so that 
    # the SERVER_ERROR handler doesn't break when things go wrong.
    my $doc = $self->get_document; 
    $self->send_headers;
    $self->request->print($doc);
    $self->user_debug("Completed at: " . scalar gmtime);
    $DEBUG ?
        $self->request->print($self->user_debug) :
        $self->request->print("<!-- ".$self->user_debug."-->");
} 

=head2 send_headers

Sends HTTP content type and headers.

=cut

sub send_headers {
    my $self = shift;
    $self->request->content_type("text/html");
    $self->request->send_http_header;
    $self->request->no_cache(1);
}

###############################################################################
# Other methods
###############################################################################

=head2 check_exists

Checks to see if the document requested exists.

=cut

sub check_exists {
    my $self = shift;

    $self->document(Apache::Onanox::Document->new);
    my $exists = $self->document->exists($self->uri);
    $self->status(NOT_FOUND) unless $exists;
    return $self->status;
}

=head2 get_document

Does the document stuff.

=cut

sub get_document {
    my $self = shift;

    $self->setup_tt_vars;
    return $self->document->render(
        $self->uri, 
        $self->tt_vars, 
        $self->tt_vars('theme')
        );
}

=head2 authenticate

Runs authentication phase.

=cut

sub authenticate {
    my $self = shift;

    my $auth = Apache::Onanox::User::Authentication->new($self->parameters);
    $self->user($auth->authenticate);
    return;
}

=head2 setup_tt_vars

Set some useful Template Toolkit variables.

=cut

sub setup_tt_vars {
    my $self = shift;

    my ($test_theme, $error) = $self->parameters->get('theme');
    #user is trying it
    my @side  = qw(left right top bottom);
    foreach (@side) {
        $self->tt_vars($_ . '_panels' =>
            $self->user->preferences->get_values_by_type('panel', $_))
    }

    $self->tt_vars(user        => $self->user);
    $self->tt_vars(location    => $self->uri);
    $self->tt_vars(hostname    => $self->request->hostname);
    $self->tt_vars(remote_host => $self->request->get_remote_host);
    $self->tt_vars(title       => $self->document->title($self->uri));
    $self->tt_vars(theme       => $self->user->preferences->theme);
    $self->tt_vars(theme       => $test_theme) unless $error;
    $self->tt_vars(CSS         => $self->user->preferences->make_css);
    $self->tt_vars(parameters  => \$self->parameters);

    return $self->tt_vars;
}

1;

=head1 TODO

Below is a list of things that need done.

=over 4

=item *
Automated tests!

=item *
Code refactoring.

=item *
Movable side panels.

=item *
Make it more usable.

=item *
Add some themes.

=item *
Colour schemes.

=item *
Documentation.

=item *
Installation client.

=back

=head1 BUGS / KNOWN PROBLEMS

Security / authorisation / ACLs. 
Currently anyone can read or create any doc or theme.

~user translation.

=head1 AVAILABILITY

Available for download from CPAN F<http://www.cpan.org/> or from
F<http://russell.matbouli.org/code/apache-onanox/>

=head1 AUTHOR

Russell Matbouli E<lt>apache-onanox-spam@russell.matbouli.orgE<gt>

F<http://russell.matbouli.org>

=head1 LICENSE

Distributed under GPL v2. See COPYING included with this distibution.

=head1 SEE ALSO

L<Apache>

L<mod_perl>

L<Template>

L<Class::DBI>

L<MySQL>

=cut
