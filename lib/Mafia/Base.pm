# Base class for all Mafia packages
package Mafia::Base;
use Mojo::Base -base;

# Almost identical to Mojo::Base::import, except importing more features.
# Because of caller() shenanigans, we can't just inherit it like normal.
sub import {
   my $class = shift;
   return unless my $flag = shift;

   # Base
   if ($flag eq '-base') { $flag = $class }

   # Strict
   elsif ($flag eq '-strict') { $flag = undef }

   # Module
   elsif ((my $file = $flag) && !$flag->can('new')) {
      $file =~ s!::|'!/!g;
      require "$file.pm";
   }

   # ISA
   if ($flag) {
      my $caller = caller;
      no strict 'refs';
      push @{"${caller}::ISA"}, $flag;
      Mojo::Base::_monkey_patch $caller, 'has', sub { Mojo::Base::attr($caller, @_) };
   }

   # Mojo modules are strict!
   $_->import for qw(strict warnings utf8);
   feature->import(qw/:5.10 signatures postderef/);
   warnings->unimport(qw/experimental::signatures experimental::postderef/);
}

BEGIN {
   # Because we want Mojo::Template templates to also have postderef, we'll give
   # Mojo::Base this new import() as well
   no warnings 'redefine';
   *Mojo::Base::import = \&import;
}

1;
