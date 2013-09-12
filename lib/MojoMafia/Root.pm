package MojoMafia::Root;
use Mojo::Base 'Mojolicious::Controller';

use File::stat;

sub index {
	my $c = shift;

	$c->render;
}

sub watchcss {
	my $c = shift;

	# We're long-polling, so set timeout to longer than usual
    Mojo::IOLoop->stream($c->tx->connection)->timeout(300);

	# Block until we find
	my $fn = $c->app->home->rel_file('public/style/mafia.css');
	my $mtime = $c->req->param('mtime') || 0;

	my $id;
	$id = Mojo::IOLoop->recurring(0.3 => sub {
		my $stat = stat $fn;
		if ($stat->mtime != $mtime) {
			Mojo::IOLoop->remove($id);
			return $c->render(text => $stat->mtime);
		}
	});
}

sub events {
	my $c = shift;

	$c->render(text => 'Not yet implemented');
}

1;
