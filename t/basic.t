use strict;
use warnings;

use Test2::V0;
use Scalar::Util qw(weaken);
use Devel::Peek;
use Scope::Guard qw(guard);

use ok 'Rax';

{
  my $r = Rax->new;
  my $called = 0;
  my $g = guard { $called++ };
  $r->insert("foo", $g);
  is($called, 0);
  $g = undef;
  is($called, 0);
  $r = undef;
  is($called, 1);
}

{
  my $r = Rax->new;
  my $called = 0;
  my $g = guard { $called++ };
  $r->insert("foo", $g);
  is($called, 0);
  $g = undef;
  is($called, 0);
  $r->insert("foo");
  is($called, 1);
}

{
  my $r = Rax->new;
  my $called = 0;
  my $g = guard { $called++ };
  $r->insert("foo", $g);
  is($called, 0);
  $g = undef;
  is($called, 0);
  my $ng = $r->insert("foo");
  is($called, 0);
  $ng = undef;
  is($called, 1);
}

{
  my $r = Rax->new;
  $r->insert("foo");
  is($r->find("foo"), undef);
  ok($r->exists("foo"), "foo exists");
  is($r->find("bar"), undef);
  my $old = $r->remove("foo");
  ok(!$r->exists("foo"), "foo does not exist");
  $r->insert("name", "Dylan");
  is($r->find("name"), "Dylan");
}

{
  my $r = Rax->new;
  $r->insert("name", "Dylan");
  $r->insert("hobby", "bread");
  $r->insert("hometown", "St. Petersburg");
  $r->insert("nemesis", "tests");
  is( $r->size, 4 );
}

{
  my $r = Rax->new;
  my $iter = $r->iter;
  weaken $r;
  ok(defined($r), "iter keeps main object alive");
  $iter = undef;
  ok(!defined($r), "object is cleared when iter is free()'d");
}


done_testing;
