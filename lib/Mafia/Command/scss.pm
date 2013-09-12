package Mafia::Command::scss;

use Mojo::Base 'Mojolicious::Command';
use Mojo::IOLoop;
use Getopt::Long qw/GetOptionsFromArray/;
use File::stat;
use Text::Sass::XS qw/sass_compile_file/;

has watch => 0;

sub run {
	my ($self, @args) = @_;

	GetOptionsFromArray(\@args, 'w|watch' => sub {
		$self->watch(1);
		say ">>> Sass is watching for changes. Press Ctrl-C to stop.";
	});

	my $in  = $self->rel_file('public/style/mafia.scss');
	my $out = $self->rel_file('public/style/mafia.css');

	my $mtime = 0;
	my $cb = sub {
		my $stat = stat $in;
		if ($mtime != $stat->mtime) {
			if ($mtime != 0) {
				say ">>> Change detected to $in";
			}
			$mtime = $stat->mtime;

			my ($css, $err) = sass_compile_file($in);

			if ($err) {
				print "!!! $err";
			} else {
				if (-e $out) {
					say ">>> Overwrite $out";
				} else {
					say ">>> Write $out";
				}
				open my $fh, '>', $out;
				print $fh $css;
				close $fh;
			}
		}
	};

	if ($self->watch) {
		Mojo::IOLoop->recurring(0.3 => $cb);
		Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
	} else {
		$cb->();
	}
}

1;
