#!/usr/bin/perl -w

use strict;

my @changes = `svn log --limit 15 -v`;
my $state   = "initial";
my $rev;
my $date;
my @files;

foreach ( @changes )
{
    if( $state eq "initial" && /^\-+$/ )
    {
        $state = "revision";
    }
    elsif( $state eq "revision" )
    {
        chomp();
        my @words = split /\s+/;
        $rev  = $words[0];
        $date = $words[4];
        $rev =~ s/r(\d+)\s*/$1/;
        $state = "paths";
    }
    elsif( $state eq "paths" )
    {
        $state = "files";
    }
    elsif( $state eq "files" )
    {
        chomp();
        if( /^$/ )
        {
            $state = "excerpt";
        }
        elsif( / +([A-Z]) +.*website(\/.*html|png|jpg|pdf)$/ )
        {
            my $op   = $1;
            my $file = $2;
            
            if( !($file =~ /include/) && $op ne "D" )
            {
                $file =~ s/\.shtml/.html/;
                push( @files, $file );
            }
        }
    }
    elsif( $state eq "excerpt" )
    {
        chomp();
        s/Website://;
        s/^\s*//;
        s/[\<\>]//g;
        my $excerpt = $_;
        print "    <li>$date: <a href=\"http://equalizer.svn.sourceforge.net/viewvc/equalizer?view=rev&revision=$rev\">$excerpt</a></li>\n";
        if( @files )
        {
            print "    <ul><font size=\"-1\">\n";
            foreach my $file ( @files )
            {
                print "        <li><a href=\"$file\">$file</a></li>\n";
            }
            print "    </font></ul>\n";
        }

        $rev  = "";
        $date = "";
        $state = "initial";
        @files = ();
    }
}
