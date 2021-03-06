package Mafia::Command::cheater;

use Crypt::Eksblowfish::Bcrypt qw/bcrypt/;
use Mojo::Base 'Mafia::Command';
use Mafia::Names;
use Mafia::Role qw/:all/;
use Mafia::Timestamp;
use List::Util 'shuffle';
use Text::Lorem::More 'lorem';

sub run {
	my $self = shift;
	my $schema = $self->db;

	say 'Creating dummy users...';
	my $cipher = bcrypt('password', '$2$10$fPFp/lzQBClHVBz/U2QQau');
	my @users = map {
		my $name = Mafia::Names->random_name;

		my $user = $schema->resultset('User')->create({ login => lc $name });

		$user->name_set($name);

		# Not using password_set() here to avoid doing the cipher for each user
		$user->create_related(passwords => { cipher => $cipher });

		$user;
	} 0 .. 10;

	my $f11 = $schema->resultset('Setup')->search({ name => 'F11' })->first;
	GAME: for (0, 1) {
		say "Creating dummy game...";
		my $game = $f11->create_related('games', {});

		# my $day = 60 * 60 * 24;
		# my $time = time - 20 * $day;

		$game->log('Game created.');

		for my $user (shuffle @users) {
			my $player = $game->create_related('players', {
				user_id => $user->id,
				alias   => $user->name,
			});

			$game->log("%s joined the game", $player->alias);

			last if $game->full;

			last GAME if $_ == 1 && $game->players->count == 4;
		}

		$game->begin;

		say "+ dummy posts";
		for (0 .. 3) {
			my (@players, $n_of_posts);

			if ($game->day) {
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
				});

				if (!$game->day) {
					$post->update({
						private => 1,
						audience_type => 'r',
						audience_id   => GOON()->id,
					});
				}

				# $time += 60 + int rand 3600;
			}

			# Lynch or night kill
			$game->players->living->first->update({ alive => 0 });

			$game->cycle;
		}
	}
}

1;
