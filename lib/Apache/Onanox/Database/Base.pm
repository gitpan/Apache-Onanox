package Apache::Onanox::Database::Base;

=head1 NAME

Apache::Onanox::Database::Base

=head1 ABSTRACT

Base class for Apache::Onanox::Database objects

=head1 METHODS

=cut

use strict;
use warnings;
use Class::DBI::FromCGI;
use Class::DBI::mysql::FullTextSearch;
use base qw(Class::DBI);

our $VERSION = '0.01';
my $setup; 

=head2 setup_onanox

Database connection

=cut

sub setup_onanox {
    my $class = shift;
    return if $setup;
    __PACKAGE__->set_db('Main', shift, shift, shift);
    $setup = 1;
}

1;

=head1 SEE ALSO

L<Apache::Onanox>

=cut
