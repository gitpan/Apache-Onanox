package Apache::Onanox::Database::User;

=head1 NAME

Apache::Onanox::Database::User

=head1 ABSTRACT

User table manipulation

=cut

use strict;
use warnings;
use Class::DBI::FromCGI;
use base qw(Apache::Onanox::Database::Base);
our $VERSION = '0.01';

__PACKAGE__->table('Users');
__PACKAGE__->columns(
               All => qw( user_id 
                          username 
                          email
                          realname
                          password
                          status
                          created
                          lasttime
                          ip_addr
                        )
                    );
__PACKAGE__->untaint_columns(
    printable => [qw/username password status realname/],
    integer => [qw/user_id/],
    date => [qw/created lasttime/],
    email => [qw/email/],
    );

1;
