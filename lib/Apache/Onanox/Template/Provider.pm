package Apache::Onanox::Template::Provider;

=head1 NAME

Apache::Onanox::Template::Provider

=head1 ABSTRACT

Used to get templates from the database. Subclass of L<Template::Provider>.

=head2 METHODS

=cut

use strict;
use warnings;
use base qw( Template::Provider );
use Apache::Onanox::Document;

our $VERSION = 0.01;


=head2 fetch

Gets documents from the database.

=cut

sub fetch {
    my ($self, $name) = @_;
    my ($data, $document, $error, $aoerror);

    #### get the document ####
    my $aod = Apache::Onanox::Document->new;
    ($document, $aoerror) = $aod->contents($name);
    if ($aoerror and not $document){
        ($document, $aoerror) = $aod->contents
            ($Apache::Onanox::Document::ErrorNotFound);
    }

    #### let TT do its thing ####
    ($data, $error) = $self->_load(\$document);
    ($data, $error) = $self->_compile($data) unless $error;
    $data = $data->{data} unless $error;

    #### return ####
    return ($data, $error);
}

1;

=head1 SEE ALSO

L<Apache::Onanox>

L<Template>

L<Template::Provider>

=cut
