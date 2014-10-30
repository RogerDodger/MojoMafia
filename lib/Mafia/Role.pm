package Mafia::Role;

use v5.14;
use base qw/Exporter/;
use warnings;
use Carp;
use Data::Dump;

my %cache;

BEGIN {
	my @roles = qw/INNO GOON RB GF COP DOC/;

	my $i = 0;
	for my $role (@roles) {
		$i++;
		eval qq{
			use constant _$role => $i;
			sub $role () {
				return __PACKAGE__->find($i);
			}
		};
	}

	our @EXPORT_OK = ( @roles );
	our %EXPORT_TAGS = ( all => \@EXPORT_OK );
}

{
	my %names = (
		_INNO() => 'Townie',
		_GOON() => 'Mafioso',
		_RB()   => 'Roleblocker',
		_GF()   => 'Godfather',
		_COP()  => 'Cop',
		_DOC()  => 'Doctor',
	);

	my %group = (
		_INNO() => 'Town',
		_GOON() => 'Mafia',
	);

	my @order = (
		_INNO,
		_GOON,
		_RB,
		_GF,
		_COP,
		_DOC,
	);

	my $j = 0;
	for my $id (@order) {
		$cache{$id} = {
			id    => $id,
			name  => $names{$id},
			group => $group{$id},
			order => ++$j,
		};
		bless $cache{$id}, __PACKAGE__;
	}
}

sub find {
	my $q = pop;

	# Find by ID, quickest
	if (defined(my $role = $cache{$q})) {
		return $role;
	}

	# Find by name
	for my $role (values %cache) {
		if ($role->name eq $q) {
			return $role;
		}
	}

	return undef;
}

sub group {
	return shift->{group};
}

sub id {
	return shift->{id};
}

sub is {
	return shift->id == shift->id;
}

sub name {
	return shift->{name};
}

sub order {
	return shift->{order};
}

1;
