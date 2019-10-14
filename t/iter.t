use strict;
use warnings;

use Test2::V0;
use Scalar::Util qw(weaken);
use Devel::Peek;
use Scope::Guard qw(guard);

use ok 'Rax';

{
  my $r = Rax->new;
  my $iter = $r->iter;
  weaken $r;
  ok(defined($r), "iter keeps main object alive");
  $iter = undef;
  ok(!defined($r), "object is cleared when iter is free()'d");
}

{
  my $r = Rax->new;
  like( dies { $r->iter->seek("q") }, qr/\Q"q" is not a valid operation for Rax::Iterator->seek/)
}

{
  my $r = Rax->new;
  my $iter = $r->iter;
  ok($iter->eof, "iterator starts at eof");
  ok(defined($iter->key), "key is always defined");
  is($iter->key, "");
  is($iter->value, undef);
}

{
  my $r = Rax->new;
  $r->insert("batman");
  $r->insert("rax is cool", 1);
  $r->insert("rax stores null for free");
  $r->insert("rax", 2);
  my $iter = $r->iter->seek(">=", "rax");
  my @found;
  while (my $key = $iter->next) {
    push @found, $iter->key;
  }
  is(\@found, ["rax", "rax is cool", "rax stores null for free"]);

  $iter->seek(">=", "rax");
  my %found;
  while (my ($key, $val) = $iter->next) {
    $found{$key} = $val;
  }
  is(\%found, { rax => 2, "rax is cool" => 1, "rax stores null for free" => undef });
}

done_testing;
