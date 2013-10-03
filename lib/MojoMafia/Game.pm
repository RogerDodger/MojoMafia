package MojoMafia::Game;
use Mojo::Base 'Mojolicious::Controller';

sub fetch {
	my $c = shift;
	my $id = $c->param('id');
	my $game = $c->db('Game')->find($id);

	if (defined $game) {
		$c->stash->{game} = $game;

		if ($c->app->mode eq 'development' && defined $c->param('player')) {
			$c->stash->{player} = $c->stash->{game}->search_related(players => {
				alias => $c->param('player'),
			})->single;
		}
		elsif (defined $c->user) {
			$c->stash->{player} = $c->db('Player')->find({
				user_id => $c->user->id,
				game_id => $game->id,
			});
		}


		if ($game->is_active) {
			if ($game->is_day) {
				$c->stash->{votes} = $game->players->living;
			}
		}

		return 1;
	}
	else {
		return 0;
	}
}

sub thread {
	my $c = shift;

	my $roles = [];
	my $player_no = -1;
	if (my $player = $c->stash->{player}) {
		$roles = [ $player->player_roles->get_column("role_id")->all ];
		$player_no = $player->no;
	}

	my $page = $c->param('page');
	if ($page =~ /([1-9][0-9]*)/) {
		$page = $1 + 0;
	} else {
		$page = 1;
	}

	$c->stash->{posts} = $c->stash->{game}->thread->posts->search(
		{
			-or => [
				{ private => 0 },
				{ "audiences.role_id" => { -in => $roles } },
				{ "audiences.player_no" => $player_no },
			]
		},
		{
			page => $page,
			rows => 10,
			prefetch => [ qw/user/ ],
			join => [ qw/audiences/ ],
		}
	);

	$c->render;
}

"Geemu no jikan da.";
