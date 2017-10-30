#!/usr/bin/perl
##############
#
# DistributionDays.pl
# 
# usage DistributionDays.pl <symbol> <how_many_days> <what_period>
##############

use strict;
#use warnings;
#use HTML::Parser;
use Data::Dumper;
use WWW::Mechanize;
#use HTML::TokeParser;
#use File::Copy;
use JSON;
use Data::Dumper;
use Mozilla::CA;
use Statistics::Basic qw(:all);
#use feature qw/ say /;
my %stuff2;


if ($#ARGV != 2) {     #should be 3 arguments on CLI
print "Usgae: distributionDays.pl symbol how_many_days testing_period\n";
print "example- distributionDays.pl AAPL 5 15\n";
die;
 }



my ($ticker, $test_count, $test_period) = @ARGV;

my $baseurl ="http://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=$ticker&outputsize=full&apikey=KH7I7MHC4O912G6C";

my $browser = WWW::Mechanize->new();
my $html;
$browser->get($baseurl);
die $browser->response->status_line unless $browser->success;
my $json = $browser->content;

my @price;
my @volume;
my @date;
my $ninetyDayReturn;
my $anotherRedemptionDay;
my $correct;
my @return;
my @vanillaReturn;

my $data = decode_json $json;
my $dumpedData = Dumper $data;


my %stuff =  %{ $data -> {'Time Series (Daily)'} }   ;


my $i=0;
for (my $year=1995; $year<=2017 ; $year++)  {                                         
for (my $month=1; $month<=12 ; $month++)  {                                         
for (my $day=1; $day<=31 ; $day++)  {                                         

if ($day eq 1) { $day = '01'; }          
if ($day eq 2) { $day = '02'; }          
if ($day eq 3) { $day = '03'; }          
if ($day eq 4) { $day = '04'; }          
if ($day eq 5) { $day = '05'; }          
if ($day eq 6) { $day = '06'; }          
if ($day eq 7) { $day = '07'; }          
if ($day eq 8) { $day = '08'; }          
if ($day eq 9) { $day = '09'; }          
if ($month eq 1) { $month = '01'; }          
if ($month eq 2) { $month = '02'; }          
if ($month eq 3) { $month = '03'; }          
if ($month eq 4) { $month = '04'; }          
if ($month eq 5) { $month = '05'; }          
if ($month eq 6) { $month = '06'; }          
if ($month eq 7) { $month = '07'; }          
if ($month eq 8) { $month = '08'; }          
if ($month eq 9) { $month = '09'; }          

if (exists $stuff{"$year-$month-$day"}) {           
#print "$year-$month-$day\n";
%stuff2 =  %{ $stuff{"$year-$month-$day"} }   ;


$price[$i] = $stuff2{'4. close'}; 
$volume[$i] = $stuff2{'6. volume'};
$date[$i] = "$year-$month-$day";

#print "$year-$month-$day  closing price = $price[$i]  volume = $volume[$i] \n";


#if (  ($price[$i] lt $price[$i-1]  )  &&  ( $volume[$i] gt $volume[$i-1])  )  {
#print "distribution day (yeah, whatever)\n";
#}

$i++;
}

} 
}
}


#re-iterate from beginning, looking for redemption days >$test_count, see 90 day forward performance


#count last $test_period trading days, see how many redemption days occurred

for ($i=$test_period; $i<($#price-65); $i++)   {
my $redemptionDayCount = 0;
for (my $j = $test_period; $j>1; $j--)  {
if (  ($price[$i-$j] lt $price[$i-$j-1]  )  &&  ( $volume[$i-$j] gt $volume[$i-$j-1])  )  {
$redemptionDayCount++ ;
}
}

#print "$date[$i] - Redemption days in last 15 = $redemptionDayCount \n";

#if Redemption days >= 5, check the return 90 days forward
if ($redemptionDayCount ge $test_count) {
$ninetyDayReturn = substr ((100 * (($price[$i+65] - $price[$i]) / $price[$i])) , 0, 6);
my $rounded = sprintf("%.1f%", "$ninetyDayReturn");
#print "90 day return = $rounded\n";
push @return, $ninetyDayReturn;
$anotherRedemptionDay++;
if ($rounded lt 0) { $correct++; }

}
}



#total number of times redemption days >=5 vs total number of trading days analyzed (%)
my $totalNumberDaysAnalyized = ($#price-$test_period-65);
print "Total number of days analyized = $totalNumberDaysAnalyized\n";
my $percentageOfRedemptionDays =  substr ((100 * $anotherRedemptionDay / ($totalNumberDaysAnalyized), 0, 4));
print "Total number of $test_count/$test_period redemption days = $anotherRedemptionDay  -   $percentageOfRedemptionDays%\n";



#number of times theory was right vs # wrong
my $percentageCorrect = substr ((100 * $correct / $anotherRedemptionDay),0 ,4);
print "Total number of $test_count/$test_period redemption days 90 days future was negative = $correct   -   $percentageCorrect%\n";


#average return over that period
my $mean = mean(@return);
print "Average return 90 days out after $test_count/$test_period redemption days = $mean%\n";


#decide if the difference is statistically significant. 
#to do.




#do it all again for every day for this security (testing against)
for ($i=$test_period; $i<($#price-65); $i++)   {


#check the return 90 days forward
$ninetyDayReturn = substr ((100 * (($price[$i+65] - $price[$i]) / $price[$i])) , 0, 6);
my $rounded = sprintf("%.1f%", "$ninetyDayReturn");
#print "90 day return = $rounded\n";
push @vanillaReturn, $ninetyDayReturn;
}
#average return over that period
$mean = mean(@vanillaReturn);
print "Average return 90 days out after each of $totalNumberDaysAnalyized days = $mean%\n";



