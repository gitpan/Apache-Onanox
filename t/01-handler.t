#!/usr/local/bin/perl -wT
use strict;
use lib qw(../lib);

use Test::More tests => 1;

use_ok('Apache::Onanox');
use Apache::Onanox;

#use_ok('Apache::Onanox::Test::FakeRequest');
#use Apache::Onanox::Test::FakeRequest;

#$Apache::Onanox::Test::FakeRequest::CONFIG = { 
#    dbconn => 'dbi:mysql:Onanox', 
#    dbuser => 'root', 
#    dbpass => 'passwd' }; 

#$Apache::Onanox::Test::FakeRequest::PARAMETERS = { 
#    'User-Agent' => 'lwp-request/2.01',
#    content => ('foo', 'bar'), 
#    args => ('baz', 'zoo') };

#my $r = Apache::Onanox::Test::FakeRequest->new();

#print STDERR $r->dir_config('dbconn');
#isa_ok($r, 'Apache::Onanox::Test::FakeRequest', 'Apache::FakeRequest instance');

#my $ret = Apache::Onanox->handler($r);
#ok(defined $ret, 'defined value($ret)');
#ok($ret == 200, 'handler returned 200, OK');
