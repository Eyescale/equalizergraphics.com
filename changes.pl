#!/opt/local/bin/perl -w
# Creates an html page and RSS feed for latest changes on the website.

# needs perl modules: 'sudo port install p5-xml-rss p5-datetime'

use strict;
use XML::RSS;

my $svn = $ENV{'SVN'};
if( !$svn || $svn eq "" )
{
    $svn = "svn";
}

my @changes = `$svn log --limit 15 -v`;
my $state   = "initial";
my $rev;
my $date;
my $time;
my $image = "";
my @files;

# RSS setup
my $rss = new XML::RSS( version => '1.0' );
$rss->channel(
    title        => "Latest Changes on Equalizer: Parallel Rendering",
    link         => "http://www.equalizergraphics.com",
    description  => "Parallel Rendering Software for OpenGL",
    dc => {
        date       => `date +%Y-%m-%dT%H:%M+01:00`,
        subject    => "Parallel Rendering",
        creator    => 'eile@equalizergraphics.com',
        publisher  => 'webmaster@equalizergraphics',
        rights     => 'Copyright 2008, Stefan Eilemann',
        language   => 'en-us',
    },
    syn => {
        updatePeriod     => "daily",
        updateFrequency  => "1",
        updateBase       => "2000-01-01T10:00+00:00",
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
        $time = $words[5];
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
        elsif( / +([A-Z]) \/trunk\/website(\/[\w\/\._\-]+(html|shtml|png|jpg|pdf))([ \n])/ )
        {
            my $op   = $1;
            my $file = $2;
            my $type = $3;

            $file =~ s/\.shtml/.html/;

            if( !($file =~ /include/) && !($file =~ /DBCAAF49A0C0/) && $op ne "D" )
            {
                push( @files, $file );

                if( $image eq "" && $type =~ /(png|jpg)/ && -e "build/$file" )
                {
                    $image = $file;
                }
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
        print "    <li><a name=\"$rev\"></a>$date: <a href=\"http://equalizer.svn.sourceforge.net/viewvc/equalizer?view=rev&revision=$rev\">$excerpt</a></li>\n";
        my $description = "";

        if( @files )
        {
            if( $image ne "" )
            {
                $description .= "    <div class=\"float_right\">\n";
                $description .= "        <img src=\"http://www.equalizergraphics.com$image\" width=\"200\">\n";
                $description .= "    </div>\n";
            }

            $description .= "    <ul><font size=\"-1\">\n";
            foreach my $file ( @files )
            {
                if(  -e "build/$file" )
                {
                    $description .="        <li><a href=\"http://www.equalizergraphics.com$file\">$file</a></li>\n";
                }
                else
                {
                    $description .="        <li>$file</li>\n";
                }
            }
            $description .= "    </font></ul>\n";
        }
        print $description;
        if( $image ne "" )
        {
            print "<div class=\"flush_float\"></div>\n";
        }

        $rss->add_item(
            title       => "$excerpt",
            link        => "http://www.equalizergraphics.com/changes.html#$rev",
            description => $description,
            dc          => {
                date        => $date . "T" . $time . "+01:00",
            }
            );

        $rev  = "";
        $date = "";
        $time = "";
        $image = "";
        $state = "initial";
        @files = ();
    }

    # save RSS feed
    $rss->save( "equalizer.rdf" );
}
