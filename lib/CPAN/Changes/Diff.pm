## Copyright (C) Graham Barr
## vim: ts=8:sw=2:expandtab:shiftround
## ABSTRACT: Detect CPAN distribution changelog differences

package CPAN::Changes::Diff;

use Moose;
use Algorithm::Diff qw(diff);
use Path::Class;
use List::Util qw(sum);
use Carp qw(croak);
use Pod::Simple::Text;

use Moose::Util::TypeConstraints;

class_type('Path::Class::Entity');

coerce 'Path::Class::Entity'    ##
  => from 'Str'                 ##
  => via {
      -f $_ ? Path::Class::file($_)
    : -d _  ? Path::Class::dir($_)
    :         croak "$_: not found\n";
  };

has [qw(left right)] => (
  is       => 'ro',
  isa      => 'Path::Class::Entity',
  coerce   => 1,
  required => 1,
);

sub _find_files {
  my ($left, $right) = @_;

  if ($left->is_dir and $right->is_dir) {
    foreach my $lfile ($left->children) {
      next if $lfile->is_dir;
      my $base = $lfile->basename;
      next
        unless -f $lfile and $base =~ /^ (?: changes | changelog )(?: \.txt | \.pod )? $/ix;
      my $rfile = $right->file($base);
      return ($lfile, $rfile) if -f $rfile;
    }
  }
  elsif ($left->is_dir) {
    $left = $left->file($right->basename);
    croak "$left: not found\n" unless -f $left;
    return ($left, $right);
  }
  elsif ($right->is_dir) {
    $right = $right->file($left->basename);
    croak "$right: not found\n" unless -f $right;
    return ($left, $right);
  }
  else {
    return ($left, $right);
  }

  croak "Cannot locate changes files\n";
}

sub _content {
  my $file = shift;
  my $pod  = Pod::Simple::Text->new;
  $pod->output_string(\my $buffer);
  $pod->parse_file($file->stringify);
  return $pod->content_seen ? split(/^/, $buffer) : $file->slurp;
}

sub changes {
  my $self = shift;
  my ($left, $right) = _find_files($self->left, $self->right);

  my @f1 = _content($left);
  my @f2 = _content($right);

  my $diffs = diff(\@f1, \@f2);
  return unless @$diffs;

  my @chunks = sort { $b->{score} <=> $a->{score} or $a->{line} <=> $b->{line} }
    map {
      my $n = sum(0, map { $_->[0] eq '+' ? 1 : -1 } @$_);
      +{score   => abs($n),
        changes => $n,
        line    => $_->[0][1],
        diff    => $_,
      };
    } @$diffs;

  my $sign = $chunks[0]{changes} > 0 ? '+' : '-';
  my $text = join "", map { $_->[2] } grep { $_->[0] eq $sign } @{$chunks[0]{diff}};

  $text =~ s/\A\s*\n//;
  $text =~ s/^\s*\z//m;

  return $text;
}

1;

__END__

=head1 NAME

CPAN::Changes::Diff - Detect CPAN distribution changelog differences

=head1 SYNOPSYS

  use CPAN::Changes::Diff;

  my $ccd = CPAN::Changes::Diff->new(
    left  => $path_to_dist1,
    right => $path_to_dist2,
  );

  print $ccd->changes;

=head1 DESCRIPTION

C<CPAN::Changes::Diff> takes two distributions and returns a string determined by doing a diff
of the change log files in each.

C<left> and C<right> may be either direcories or files. If both are files then the diff is performed
on them. If one is a file and one a directory then a file having the same basename is checked in the
other. If they are both directories then both are searches for change log files. The same file must
appear in both directories.

The diff returned is the text of the largest diff chunk found between the two files. If the files
contain POD then they are first converted to text with L<Pod::Simple::Text>

=head1 SEE ALSO

L<Algorithm::Diff> L<Pod::Simple::Text>

=head1 AUTHOR

Graham Barr C<< <gbarr@cpan.org> >>


=cut

