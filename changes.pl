#!/usr/bin/perl -w

use strict;

my @changes = `svn log --limit 25`;
my $state   = "initial";
my $rev;
my $date;

foreach ( @changes )
{
    if( $state eq "initial" && /^\-+$/ )
    {
        $state = "revision"
    }
    elsif( $state eq "revision" )
    {
        chomp();
        my @words = split /\s+/;
        $rev  = $words[0];
        $date = $words[4];
        $rev =~ s/r(\d+)\s*/$1/;
        $state = "blank";
    }
    elsif( $state eq "blank" )
    {
        $state = "excerpt";
    }
    elsif( $state eq "excerpt" )
    {
        chomp();
        s/Website://;
        s/^\s*//;
        s/[\<\>]//g;
        my $excerpt = $_;
        print "    <li>$date: $excerpt... (<a href=\"http://equalizer.svn.sourceforge.net/viewvc/equalizer?view=rev&revision=$rev\">more</a>)</li>\n";
        
        $rev  = "";
        $date = "";
        $state = "initial";
    }
}
