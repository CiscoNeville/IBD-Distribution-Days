#!/usr/bin/perl
##############
#
# 
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
#use feature qw/ say /;
my %stuff2;

my $ticker = 'IXIC';

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

my $data = decode_json $json;
my $dumpedData = Dumper $data;

#print Dumper $data;
open (JSON1, ">json1.txt") or die "$! error trying to overwrite";
print JSON1 "$dumpedData";





my %stuff =  %{ $data -> {'Time Series (Daily)'} }   ;

open (JSON2, ">json2.txt") or die "$! error trying to overwrite";
print JSON2 Dumper(\%stuff);


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
%stuff2 =  %{ %stuff -> {"$year-$month-$day"} }   ;
#print Dumper(\%stuff2);


$price[$i] = $stuff2{'4. close'}; 
$volume[$i] = $stuff2{'6. volume'};
$date[$i] = "$year-$month-$day";

print "$year-$month-$day  closing price = $price[$i]  volume = $volume[$i] \n";


#if (  ($price[$i] lt $price[$i-1]  )  &&  ( $volume[$i] gt $volume[$i-1])  )  {
#print "redemption day (yeah, whatever)\n";
#}

$i++;
}

}
}
}


#re-iterate from beginning, looking for redemption days >5, see 90 day forward performance


#count last 15 trading days, see how many redemption days occurred

for ($i=15; $i<$#price; $i++)   {
my $redemptionDayCount = 0;
for (my $j = 15; $j>1; $j--)  {
if (  ($price[$i-$j] lt $price[$i-$j-1]  )  &&  ( $volume[$i-$j] gt $volume[$i-$j-1])  )  {
$redemptionDayCount++ ;
}
}

print "$date[$i] - Redemption days in last 15 = $redemptionDayCount \n";

#if Redemption days >= 5, check the return 90 days forward
if ($redemptionDayCount ge 5) {
$ninetyDayReturn = substr ((100 * (($price[$i+90] - $price[$i]) / $price[$i])) , 0, 6);
my $rounded = sprintf("%.1f%", "$ninetyDayReturn");
print "90 day return = $rounded%\n";
$anotherRedemptionDay++;
if ($rounded lt 0) { $correct++; }


}

}

#total number of times redemption days >=5 vs total number of trading days analyzed (%)
print "Total number of redemption days = $anotherRedemptionDay\n";
print "Total number of days 90 days future was negative = $correct\n";
print "percentage correct = $correct / $anotherRedemptionDay \n";
print "Total number of days analyized = $#price\n";



#number of times theory was right vs # wrong


#average return over that period












