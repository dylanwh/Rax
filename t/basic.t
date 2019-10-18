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
  $r->insert("guard", $g);
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
  $r->insert("guard", $g);
  is($called, 0);
  $g = undef;
  is($called, 0);
  my $og = $r->remove("guard");
  is($called, 0);
  $og = undef;
  is($called, 1);
}

{
  my $r = Rax->new;
  my $called = 0;
  my $g = guard { $called++ };
  $r->insert("guard", $g);
  is($called, 0);
  $g = undef;
  is($called, 0);
  $r->insert("guard");
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
  my %h;
  foreach my $k ('a' .. 'z') {
    $h{$k} = 1;
  }
  my $r = Rax->new(\%h);

  foreach my $k ('a' .. 'z') {
    is($r->find($k), 1);
  }

}


{
  my %h;
  foreach my $k ('a' .. 'z') {
    $h{$k} = undef;
  }
  my $r = Rax->new(\%h);

  foreach my $k ('a' .. 'z') {
    ok($r->exists($k));
  }
}

done_testing;
