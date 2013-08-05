package Mafia::Command::deploy;
use Mojo::Base 'Mafia::Command';
use Mafia::Schema;
use Data::Dump;

sub run {
	my $self = shift;

	# DBD::SQLite specific -- change to support more deployment options
	my $fn = (split /:/, $self->config->{dsn})[-1];
	if (-e $fn) {
		print "SQLite database '$fn' already exists and will be overwritten. "
		    . "Do you want to continue? [y/n] ";
		chomp(my $ans = <STDIN>);
		if ($ans =~ /^(?:y|yes)$/i) {
			unlink $fn;
		}
		else {
			say "Aborting deploy.";
			exit(1);
		}
	}

	say "Deploying database...";
	my $schema = Mafia::Schema->connect(
		$self->config->{dsn},'','',
		{ sqlite_unicode => 1, ignore_version => 1 }
	);
	$schema->deploy;

	say '+ Creating teams';
	$schema->resultset('Team')->populate([
		[  qw/name type/   ],
		[ 'town',   'inno' ],
		[ 'mafia',  'scum' ],
		[ 'bratva', 'scum' ],
		[ 'yakuza', 'scum' ],
		[ 'other',  'other' ],
	]);

	say '+ Creating roles';
	$schema->resultset('Role')->populate([
		[   qw/name   type/ ],
		[ 'townie',      'town' ],
		[ 'cop',         'town' ],
		[ 'doctor',      'town' ],
		[ 'goon',        'scum' ],
		[ 'godfather',   'scum' ],
		[ 'roleblocker', 'scum' ],
	]);

	say '+ Creating user `Nobody`';
	my $nobody = $schema->resultset('User')->create({
		id   => -1,
		name => 'Nobody',
	});

	say '+ Creating F11 setup...';
	my $setup = $schema->resultset('Setup')->create({
		user_id   => $nobody->id,
		title     => 'F11',
		descr     => 'Standard newbie setup',
		allow_nk  => 1,
		allow_nv  => 1,
		day_start => 1,
		final     => 1,
		private   => 0,
	});

	my %roles = map { $_->name, $_->id } $schema->resultset('Role')->all;
	my %teams = map { $_->name, $_->id } $schema->resultset('Team')->all;

	$setup->create_related('setup_roles', {
		role_id  => $roles{$_->[0]},
		team_id  => $teams{$_->[1]},
		pool     => $_->[2],
		count    => $_->[3],
	}) for (
		[ 'townie',      'town', 1, 5 ],
		[ 'cop',         'town', 1, 1 ],
		[ 'doctor',      'town', 1, 1 ],
		[ 'roleblocker', 'mafia', 1, 1 ],
		[ 'goon',        'mafia', 1, 1 ],

		[ 'townie', 'town', 2, 6 ],
		[ 'cop',    'town', 2, 1 ],
		[ 'goon',   'mafia', 2, 2 ],

		[ 'townie', 'town', 3, 6 ],
		[ 'doctor', 'town', 3, 1 ],
		[ 'goon',   'mafia', 3, 2 ],

		[ 'townie',      'town', 4, 7 ],
		[ 'roleblocker', 'mafia', 4, 1 ],
		[ 'goon' ,       'mafia', 4, 1 ],
	);
}

'Construction complete.';
