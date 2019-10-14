#!/usr/bin/env perl
use strict;
use warnings;

use Test2::V0;
use Scalar::Util qw(weaken);
use Devel::Peek;
use Scope::Guard qw(guard);

use ok 'Rax';

my $rax = Rax->new;
$rax->insert($_) for counties();

{
  my $iter = $rax->iter->first;
  my @counties;
  while (my $county = $iter->next) {
    push @counties, $county;
  }

  is(0 + @counties, 62, "got 62 counties");
  my @expect = counties();
  @expect = sort @expect;
  is(\@counties, \@expect);

  $iter->first;
  ok( $iter->compare("==", $counties[0]), "compare == works");
  ok($iter->compare('<', $counties[2]), "compare < works");
}

{
  my $iter = $rax->iter->last;
  my @counties;
  while (my $county = $iter->prev) {
    push @counties, $county;
  }

  is(0 + @counties, 62, "got 62 counties");
  my @expect = counties();
  @expect = reverse sort @expect;
  is(\@counties, \@expect);
}


done_testing;

sub counties {
  return (
  "Albany County",
  "Allegany County",
  "Bronx County",
  "Broome County",
  "Cattaraugus County",
  "Cayuga County",
  "Chautauqua County",
  "Chemung County",
  "Chenango County",
  "Clinton County",
  "Columbia County",
  "Cortland County",
  "Delaware County",
  "Dutchess County",
  "Erie County",
  "Essex County",
  "Franklin County",
  "Fulton County",
  "Genesee County",
  "Greene County",
  "Hamilton County",
  "Herkimer County",
  "Jefferson County",
  "Kings County",
  "Lewis County",
  "Livingston County",
  "Madison County",
  "Monroe County",
  "Montgomery County",
  "Nassau County",
  "New York County",
  "Niagara County",
  "Oneida County",
  "Onondaga County",
  "Ontario County",
  "Orange County",
  "Orleans County",
  "Oswego County",
  "Otsego County",
  "Putnam County",
  "Queens County",
  "Rensselaer County",
  "Richmond County",
  "Rockland County",
  "St. Lawrence County",
  "Saratoga County",
  "Schenectady County",
  "Schoharie County",
  "Schuyler County",
  "Seneca County",
  "Steuben County",
  "Suffolk County",
  "Sullivan County",
  "Tioga County",
  "Tompkins County",
  "Ulster County",
  "Warren County",
  "Washington County",
  "Wayne County",
  "Westchester County",
  "Wyoming County",
  "Yates County",
);
}
