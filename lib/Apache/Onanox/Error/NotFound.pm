package Apache::Onanox::Error::NotFound;

use strict;
use warnings;

use base qw(Apache::Onanox);
use Apache::Constants qw(:common :response :http);

our $VERSION = 0.01;
our $DEBUG = 1;

sub uri {
    return '/errors/404.html';
}

sub status {
    return DOCUMENT_FOLLOWS;
}

1;
