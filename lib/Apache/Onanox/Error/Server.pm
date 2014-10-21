package Apache::Onanox::Error::Server;

use strict;
use warnings;

our $VERSION = 0.01;
our $DEBUG = 1;

use Apache::Constants qw(:common);

sub handler ($$) {
    my $class = shift;
    my $self = bless {}, $class;
    my $r = shift;

    $r->content_type("text/html");
    $r->send_http_header;
    $r->no_cache(1);

    $r->print(<<EOF);
<html>
<head>
   <title>Apache::Onanox Server Error</title>
</head>
<body>
<h1>Apache::Onanox Server Error</h1>
Apache::Onanox has encountered a fatal error.<br>
If you are the server administrator, check the Apache error log 
and fix any problems stated there.<br> 
Otherwise, please contact the server administrator informing them
of the error.<br>
<br>
Thanks,<br>
Apache::Onanox on behalf of the server administrator
</body>
</html>
EOF
    return OK;
}

1;

=head1 NAME

Apache::Onanox::Error::Server

=head1 ABSTRACT

Server Error handler for Apache::Onanox. 

=head1 DESCRIPTION

Gets called when Things Go Badly Wrong.


=head1 SEE ALSO

L<Apache::Onanox>

=cut
