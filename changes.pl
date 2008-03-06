#!/opt/local/bin/perl -w
# Creates an html page and RSS feed for latest changes on the website.

# needs RSS perl module, 'sudo port install p5-xml-rss'

use strict;
use XML::RSS;

my @changes = `svn log --limit 15 -v`;
my $state   = "initial";
my $rev;
my $date;
my @files;

# RSS setup
my $rss = new XML::RSS( version => '1.0' );
$rss->channel(
    title        => "Equalizer: Parallel Rendering",
    link         => "http://www.equalizergraphics.com",
    description  => "Parallel Rendering Software for OpenGL",
    dc => {
        date       => `date +%Y-%m-%dT%H:%M`,
        subject    => "Parallel Rendering",
        creator    => 'eile@equalizergraphics.com',
        publisher  => 'webmaster@equalizergraphics',
        rights     => 'Copyright 2008, Stefan Eilemann',
        language   => 'en-us',
    },
    syn => {
        updatePeriod     => "daily",
        updateFrequency  => "1",
        updateBase       => "1901-01-01T00:00+00:00",
    }
);

# go through last changes
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
        if( /^$/ )
        {
            $state = "excerpt";
        }
        elsif( / +([A-Z]) \/trunk\/website(\/[\w\/\._\-]+html|shtml|png|jpg|pdf)([ \n])/ )
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
        my $description = "";

        if( @files )
        {
            $description = "    <ul><font size=\"-1\">\n";
            foreach my $file ( @files )
            {
                $description .="        <li><a href=\"$file\">$file</a></li>\n";
            }
            $description .= "    </font></ul>\n";
        }
        print $description;

        $rss->add_item(
            title       => "$excerpt",
            link        => "http://equalizer.svn.sourceforge.net/viewvc/equalizer?view=rev&revision=$rev",
            description => $description,
            );

        $rev  = "";
        $date = "";
        $state = "initial";
        @files = ();
    }

    # save RSS feed
    $rss->save( "equalizer.rdf" );
}
