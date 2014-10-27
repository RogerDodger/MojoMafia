package Mafia::Command::cheater;

use Crypt::Eksblowfish::Bcrypt qw/bcrypt/;
use Mojo::Base 'Mafia::Command';
use Mafia::Names;
use Mafia::Role qw/:all/;
use Mafia::Timestamp;
use List::Util 'shuffle';
use Text::Lorem::More 'lorem';

sub _rs {
	# Return a random string of length between $min and $max
	my $min = shift;
	my $max = shift // $min;
	state $chars = ['a'..'z'];
	my $length = int rand($max - $min + 1) + $min;
	return join '', map { $chars->[rand 26] } 1 .. $length;
}

sub run {
	my $self = shift;
	my $schema = $self->db;

	say 'Creating dummy users...';
	my $cipher = bcrypt('password', '$2$10$fPFp/lzQBClHVBz/U2QQau');
	my @users = map {
		my $name = Mafia::Names->random_name;

		my $user = $schema->resultset('User')->create({
			name => $name,
			dname => $name,
			nname => lc $name,
		});

		$user->create_related(passwords => { cipher => $cipher });

		$user;
	} 0 .. 10;

	GAME: for (0, 1) {
		say "Creating dummy game...";
		my $f11  = $schema->resultset('Setup')->search({ name => 'F11' })->first;
		my $game = $f11->create_related('games', {});

		my $thread = $schema->resultset('Thread')->create({
			title => 'Game '. $game->id,
		});

		$game->update({ thread_id => $thread->id });

		$game->log('Game created.');

		for my $user (shuffle @users) {
			$game->create_related('players', {
				user_id => $user->id,
				alias   => $user->dname,
			});

			last if $game->full;

			last GAME if $_ == 1 && $game->players->count == 4;
		}

		$game->begin;

		my $day = 60 * 60 * 24;
		my $time = time - 20 * $day;

		say "+ dummy posts";
		for (0 .. 3) {
			my (@players, $n_of_posts);

			if ($game->is_day) {
				@players = $game->players->living->all;
				$n_of_posts = 10 + int rand 15;
			} else {
				@players = $game->players->living->with_role(GOON)->all;
				$n_of_posts = 4 + int rand 10;
			}

			for (1 .. $n_of_posts) {
				my $player = $players[rand @players];

				my $post = $game->create_post(
					lorem->paragraphs(1 + int rand 6),
				);

				$post->update({
					user_id     => $player->user_id,
					user_alias  => $player->alias,
					created     => Mafia::Timestamp->from_epoch($time),
					updated     => Mafia::Timestamp->from_epoch($time),
				});

				if (!$game->is_day) {
					$post->update({ private => 1 });
					$post->create_related(audiences => {
						role_id => GOON,
					});
				}

				$time += 60 + int rand(3600);
			}

			# Lynch or night kill
			$game->players->living->first->update({ is_alive => 0 });

			$game->cycle;
		}
	}
}

1;
