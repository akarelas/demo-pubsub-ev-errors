#!/usr/bin/env perl

use v5.32;
use warnings;
use FindBin '$RealBin';
use lib "$RealBin/local/lib/perl5";

use Mojolicious::Lite -signatures;

use Mojo::IOLoop;
use Mojo::Pg;

our ($pg, $pubsub);

Mojo::IOLoop->next_tick(sub {
  $pg = Mojo::Pg->new('postgresql://dbuser:dbuser@localhost/my_db');
  $pubsub = $pg->pubsub;
  $pubsub->listen(events => sub {});
  $pubsub->on(disconnect => sub {
    app->log->warn('Dis-connected!!!');
    warn 'Dis-connected';
  });
  $pubsub->on(reconnect => sub {
    app->log->warn('Re-connected!!!');
    warn 'Re-connected';
  });
  Mojo::IOLoop->recurring(5 => sub {
    $pubsub->notify(events => 'foo');
  });
});

get '/' => sub ($c) {
  $c->render(template => 'index');
};

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Welcome';
<h1>Welcome to the Mojolicious real-time web framework!</h1>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
