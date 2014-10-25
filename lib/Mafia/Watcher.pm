package Mafia::Watcher;
use Mojo::Base 'Mojolicious::Plugin';

use Mojo::IOLoop;
use File::stat;
use File::Find;
use Text::Sass::XS ':all';
use JavaScript::Minifier 'minify';

sub register {
	my ($self, $app) = @_;

	$app->attr(style => sub { Mojo::EventEmitter->new });
	$app->attr(js => sub { Mojo::EventEmitter->new });

	my $copyright = do { local $/; <DATA> };

	SASS: {
		my $in  = $app->home->rel_file('public/style/mafia.scss');
		my $out = $app->home->rel_file('public/style/mafia.css');
		my $dir = $app->home->rel_dir('public/style/src');

		my $compile = sub {
			my ($css, $err) = sass_compile_file($in, {
				output_style => SASS_STYLE_NESTED,
			});

			if ($err) {
				$app->log->error($err);
			} else {
				if (-e $out) {
					$app->log->debug("Overwrite $out");
				} else {
					$app->log->debug("Write $out");
				}
				open my $fh, '>', $out;
				print $fh $css;
				close $fh;
			}
		};

		Mojo::IOLoop->recurring(0.1 => watcher(style => $app, $dir, $compile));
	}

	JS: {
		my $out = $app->home->rel_file('public/js/mafia.js');
		my $dir = $app->home->rel_dir('public/js/src');

		my $compile = sub {
			my $code = '';
			find sub {
				open my $fh, '<', $_;
				$code .= do { local $/; <$fh> };
				close $fh;
			}, $dir;

			if (-e $out) {
				$app->log->debug("Overwrite $out");
			} else {
				$app->log->debug("Write $out");
			}

			open my $fh, '>', $out;
			print $fh $copyright;
			print $fh minify(input => $code);
			close $fh;
		};

		Mojo::IOLoop->recurring(0.1 => watcher(js => $app, $dir, $compile));
	}

	$app->routes->get('/watch/css')->to(cb => sub {
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

		$c->render_later;
	});
}

sub watcher {
	my ($event, $app, $dir, $compile) = @_;
	my %mtime;
	return sub {
		find sub {
			my $fn = $File::Find::name;
			my $stat = stat $fn;

			if (exists $mtime{$fn} && $mtime{$fn} != $stat->mtime) {
				$app->log->debug("Change detected to $fn");
				$compile->();
				$app->$event->emit(change => time);
			}

			$mtime{$fn} = $stat->mtime;
		}, $dir;
	};
}

1;

__DATA__
/*
 * Copyright (c) 2013 Cameron Thornton.
 *
 * This library is free software; you can redistribute and/or modify it
 * under the same terms as Perl version 5.14.2.
 */
