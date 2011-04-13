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

done_testing();

