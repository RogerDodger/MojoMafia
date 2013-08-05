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

	for (1) {
		say "+ Creating dummy game";
		my $f11  = $schema->resultset('Setup')->search({ title => 'F11' })->first;
		my $game = $f11->create_related('games', {});

		my $thread = $schema->resultset('Thread')->create({
			title => 'Game '. $game->id,
		});

		$game->update({ thread_id => $thread->id });

		$game->log('Game created.');

		my $slots_left = $f11->size;
		for my $user (shuffle @users) {
			my %player = ( user_id => $user->id );
			if (rand > 0.7) {
				$player{alias} = ucfirst _rs(3,10);
			}

			$game->create_related('players', \%player);

			last if --$slots_left == 0;
		}

		$game->begin;

		my $day = 60 * 60 * 24;
		my $time = time - 20 * $day;

		say "+ Creating dummy posts";
		for (0 .. 3) {
			if ($game->is_day) {
				my @players = $game->players->living->all;

				for (0 .. 10 + int rand(60)) {
					my $player = $players[rand @players];

					my $post = $thread->create_related('posts', {
						player_id => $player->id,
						user_id   => $player->user->id,
						gamedate  => $game->date,
						class     => join(' ', 'game', $game->timeofday),
						plain     => lorem->paragraphs(1 + int rand 6),
					});

					$post->apply_markup;

					$post->update({
						created => Mafia::Timestamp->from_epoch($time),
						updated => Mafia::Timestamp->from_epoch($time),
					});

					$time += 60 + int rand(3600);
				}

				$game->players->living->first->update({ is_alive => 1 });
			}
			else {
				my @players = $game->players->living->scum->all;

				for (0 .. 3 + int rand(10)) {
					my $player = $players[rand @players];

					my $post = $thread->create_related('posts', {
						player_id => $player->id,
						user_id   => $player->user->id,
						gamedate  => $game->date,
						class     => join(' ', 'game', $game->timeofday, $player->team->name),
						plain     => lorem->paragraphs(1 + int rand 3),
					});

					$post->apply_markup;

					$post->update({
						created => Mafia::Timestamp->from_epoch($time),
						updated => Mafia::Timestamp->from_epoch($time),
					});

					$time += 60 + int rand(3600);
				}

				$game->players->living->inno->first->update({ is_alive => 0 });
			}

			$game->cycle;
		}
	}
}

1;
