package Mafia::Setup;
use Mojo::Base qw/Exporter/;

use Carp;
use Mafia::Role;

our @EXPORT_OK = qw/decode_setup encode_setup/;

sub decode {
	my $input = shift;

	my $lineNo = 1;
	my @pools;
	for my $section (split /\n\n/, $input) {

		my @pool;
		for my $line (split /\n/, $section) {

			my @player;
			my $count = 1;
			for my $word (split /\s+/, $line) {
				if (my $role = Mafia::Role->find($word)) {
					push @player, $role;
				}
				elsif ($word =~ /^x(\d+)$/) {
					$count = int $1;
				}
				else {
					Carp::croak qq{unrecognised token '$word' on line $lineNo};
				}
			}

			push @pool, (\@player) x $count;
			$lineNo++;
		}

		push @pools, \@pool;
	}

	return \@pools;
}

sub encode {
	my $pools = shift;
	my $output = '';

	for my $pool (@$pools) {
		my $count = 0;

		for (0..$#{$pool}) {
			$count++;

			my $player = $pool->[$_];
			if ($_ == $#{$pool} || !_cmp_players($player, $pool->[$_+1])) {
				$output .= join ' ', map $_->name, @$player;
				if ($count != 1) {
					$output .= " x$count";
				}
				$output .= "\n";

				$count = 0;
			}
		}

		$output .= "\n";
	}

	chomp $output;
	return $output;
}

BEGIN {
	*decode_setup = \&decode;
	*encode_setup = \&encode;
}

sub _cmp_players {
	my ($p1, $p2) = @_;

	if ($#{$p1} != $#{$p2}) {
		return 0;
	}

	for (0..$#{$p1}) {
		return 0 unless $p1->[$_]->is($p2->[$_]);
	}

	1;
}

__DATA__

@@ f11.setup

Townie x5
Townie Cop
Townie Doctor
Mafioso Roleblocker
Mafioso

Townie x6
Townie Cop
Mafioso x2

Townie x6
Townie Doctor
Mafioso x2

Townie x7
Mafioso Roleblocker
Mafioso
