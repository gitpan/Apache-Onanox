package Apache::Onanox::Error::Unauthorized;

use strict;
use warnings;

use base qw(Apache::Onanox);
our $VERSION = 0.01;
our $DEBUG = 1;

sub uri {
    return '/errors/401.html';
}

1;
