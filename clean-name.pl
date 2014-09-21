#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';

=pod
Script Name: clean-name.pl
Author:      Pablo Virgo
Last edit:   2014-09-20
Synopsis:    Takes a list of files and ensures that they are named in
a "unix-sane" fashion.  Lowercase letters, no spaces or special
characters.

Copyright (C) 2010, Pablo Virgo
Copying:
  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.  This program is distributed in
  the hope that it will be useful, but WITHOUT ANY WARRANTY; without
  even the implied warranty of MERCHANTABILITY or FITNESS FOR A
  PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.  You should have received a copy of the GNU General Public
  License along with this program.  If not, see
  <http://www.gnu.org/licenses/>.
=cut

use File::Copy;
use File::Basename;
use Getopt::Long;

my ($help, $verbose);
my $clobber = 1;

GetOptions ("help!"    => \$help,
            "verbose!" => \$verbose,
            "clobber!" => \$clobber);

if ($help || (@ARGV == 0)) {
   help();
   exit 0;
}

for my $file_name (@ARGV)
{
  if ( ! -e $file_name )
  {
    warn "$file_name is not a valid file.\n";
    next;
  }

  my ($file, $dir) = fileparse($file_name);
  my $new_file = $dir . new_name($file_name);

  if (($dir . $file) eq $new_file)
  {
    next;
  }

  if (!$clobber && -e $new_file)
  {
    warn "$new_file exists, skipping.\n";
  } else
  {

    if ($verbose)
    {
      print "Moving $file_name to $new_file.\n";
    }

    move($file_name, $new_file);
  }
}

sub new_name {
   my $name = $_[0];
   $name = "\L$name";
   $name =~ s/ /_/g;
   $name =~ s/\&/and/g;
   $name =~ s/__*/_/g;
   $name =~ s/--*/-/g;
   $name =~ s/(_-_|-_|_-)/-/g;
   $name =~ s/(_\.|\._|-\.|\.-)/\./g;
   $name =~ s/[^a-z0-9-_,.@#~]//g;
   return $name;
}

sub help {
   print "Takes a list of files and cleans up their names.\n";
   print "Usage: clean_name.pl [OPTIONS]... FILE LIST\n";
   print "Options:\n";
   printf "    %-15s Do not overwrite an existing file.\n",
          "--no-clobber";
   printf "    %-15s Verbose mode.\n", "-v or --verbose";
   printf "    %-15s Print this help message.\n", "-h or --help";
}
