package Mafia::Command::cheater;
use Mojo::Base 'Mafia::Command';
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

	my $mafia = $schema->resultset('Role')->search({ name => "mafia" })->single;

	say '+ Creating dummy users';
	my @users = map {
		my $user = $schema->resultset('User')->create({
			name => ucfirst _rs(3,10),
		});

		$user->create_related('emails', {
			address  => sprintf("%s@%s.%s", _rs(5,16), _rs(3,16), _rs(2,3)),
			main     => 1,
			verified => 1,
		});

		$user;
	} 0 .. 10;

	for (0, 1) {
		say "+ Creating dummy game";
		my $f11  = $schema->resultset('Setup')->search({ name => 'F11' })->first;
		my $game = $f11->create_related('games', {});

		my $thread = $schema->resultset('Thread')->create({
			title => 'Game '. $game->id,
		});

		$game->update({ thread_id => $thread->id });

		$game->log('Game created.');

		my $player_nos = $game->setup->player_nos;
		for my $user (shuffle @users) {
			# Users list is longer than number of players
			my $no = $player_nos->next or last;

			$game->create_related('players', {
				no      => $no,
				alias   => ucfirst _rs(3,10),
				user_id => $user->id,
			});
		}

		$game->begin;

		my $day = 60 * 60 * 24;
		my $time = time - 20 * $day;

		say "+ Creating dummy posts";
		for (0 .. 3) {
			my (@players, $n_of_posts);

			if ($game->is_day) {
				@players = $game->players->living->all;
				$n_of_posts = 10 + int rand 60;
			} else {
				@players = $game->players->living->with_role("mafia")->all;
				$n_of_posts = 4 + int rand 10;
			}

			for (1 .. $n_of_posts) {
				my $player = $players[rand @players];

				my $post = $thread->create_related(posts => {
					user_id     => $player->user_id,
					user_alias  => $player->alias,
					user_hidden => 1,
					gamedate    => $game->date,
					gametime    => $game->time,
					body_plain  => lorem->paragraphs(1 + int rand 6),
				});

				$post->apply_markup;

				$post->update({
					created => Mafia::Timestamp->from_epoch($time),
					updated => Mafia::Timestamp->from_epoch($time),
				});

				if (!$game->is_day) {
					$post->update({ private => 1 });
					$post->create_related(audiences => {
						role_id => $mafia->id,
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
