package Mafia::Sass;
use Mojo::Base qw/Mojo::EventEmitter/;
push our @ISA, 'Mojolicious::Plugin';
use Mojo::IOLoop;
use File::stat;
use Text::Sass::XS qw/sass_compile_file/;

sub register {
	my ($self, $app) = @_;

	$app->style($self);

	my $in  = $app->home->rel_file('public/style/mafia.scss');
	my $out = $app->home->rel_file('public/style/mafia.css');

	my $mtime = 0;
	Mojo::IOLoop->recurring(0.1 => sub {
		my $stat = stat $in;
		if ($mtime != $stat->mtime) {
			if ($mtime != 0) {
				$app->log->debug("Sass: Change detected to $in");
				$self->emit(change => time);
			}
			$mtime = $stat->mtime;

			my ($css, $err) = sass_compile_file($in);

			if ($err) {
				$app->log->error($err);
			} else {
				if (-e $out) {
					$app->log->debug("Sass: Overwrite $out");
				} else {
					$app->log->debug("Sass: Write $out");
				}
				open my $fh, '>', $out;
				print $fh $css;
				close $fh;
			}
		}
	});

	$app->routes->get('/watchcss')->to(cb => sub {
		my $c = shift;

		# We're long-polling, so set timeout to longer than usual
		Mojo::IOLoop->stream($c->tx->connection)->timeout(300);

		# Return a response if a change to the style is emitted
		my $cb = $c->app->style->on(change => sub {
			my ($style, $time) = @_;
			$c->render(text => $time);
		});

		$c->on(finish => sub {
			my $self = shift;
			$self->app->style->unsubscribe(change => $cb);
		});
	});
}

1;
