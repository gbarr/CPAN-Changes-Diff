#!perl

use Test::More;

BEGIN { use_ok( 'CPAN::Changes::Diff' ); }

sub check {
  my ($left, $right, $expect) = @_;

  for my $l (1, 2) {
    my $diff = CPAN::Changes::Diff->new(
      left  => $left,
      right => $right,
    );

    ok($diff);
    is($diff->changes, $expect);
    ($left, $right) = ($right, $left);
  }
}

check('t/data/DBI-1.612','t/data/DBI-1.613',<<EOS);
 Changes in DBI 1.613 (svn r14271) 22nd July 2010

      Fixed Win32 prerequisite module from PathTools to File::Spec.
    
      Changed attribute headings and fixed references in DBI pod (Martin J. Evans)
      Corrected typos in DBI::FAQ and DBI::ProxyServer (Ansgar Burchardt)

 Changes in DBI 1.612 (svn r14254) 16th July 2010
EOS


check('t/data/Moose-0.98','t/data/Moose-0.99',<<EOS);
0.99 Mon, Mar 8, 2010

  [NEW FEATURES]

  * New method find_type_for in Moose::Meta::TypeConstraint::Union, for finding
    which member of the union a given value validates for. (Cory Watson)

  [BUG FIXES]

  * DEMOLISH methods in mutable subclasses of immutable classes are now called
    properly (Chia-liang Kao, Jesse Luehrs)

  [NEW DOCUMENTATION]

  * Added Moose::Manual::Support that defines the support, compatiblity, and
    release policies for Moose. (Chris Prather)
EOS


check('t/data/Gtk2-1.222','t/data/Gtk2-1.223',<<EOS);
Overview of changes in Gtk2 1.223
=================================

* Cope with the rename of the keysym defines in gtk+ 2.22
* Correct the memory management in Gtk2::Gdk::Window->new
* Fix a test failure in GtkBuilder.t
EOS


done_testing();

