#!/usr/bin/perl

# This perl program sets everything up for us to build our Docker image.
# Call this first, then call 'docker build...' after this program runs.
#
# It fetches a WAR artifact from a Nexus repository, and also extracts some
# info from the final URL to be used as further environment variables.
#
# usage: ./build.pl <servername> <repository> <version>
# 
# example: ./build.pl "https://ka-tools.mosaic.arizona.edu/nexus" \ 
#                     "snapshots" \
#                     "ua-release11-SNAPSHOT"
#

use strict;
use File::Basename;

#####################################################################
# Setup
#####################################################################

my $dirname = dirname(__FILE__);
my $fileDir = "$dirname/files";

# First, clean up after any prior runs.
# Remove everything from the files dir
`rm -rf $fileDir`;

# Make the files dir
`mkdir $fileDir`;


#####################################################################
# Download Application WAR file
#####################################################################

#my $APP_VERSION = "ua-release11-SNAPSHOT";
#my $APP_REPO = "snapshots";
#my $MAVEN_SERVER = "https://ka-tools.mosaic.arizona.edu/nexus";

# Retrieve the Repository and Version info from Environment Variables
my $MAVEN_SERVER = $ARGV[0];
my $APP_REPO = $ARGV[1];
my $APP_VERSION = $ARGV[2];

# Assemble the initial URL
my $MAVEN_ENDPOINT = "$MAVEN_SERVER/service/local/artifact/maven/redirect";
my $WAR_SOURCE_URL = "$MAVEN_ENDPOINT?r=$APP_REPO&g=org.kuali.kfs&a=kfs-web&v=$APP_VERSION&c=ua-ksd&p=war";

# Request the initial URL from Nexus. It will respond with the latest build for that 
# release as a 302 redirect, but the text of the return will contain the final URL.
my $resp = `curl --silent '$WAR_SOURCE_URL'`;

# Strip off the descriptive text from the response, leaving just the final artifact URL.
my $fullURL = $resp;
$fullURL =~ s/If you are not automatically redirected use this url: //;

# $fullURL will look something like:
# https://ka-tools.mosaic.arizona.edu/nexus/service/local/repositories/snapshots/content/org/kuali/kfs/kfs-web/ua-release11-SNAPSHOT/kfs-web-ua-release11-20160429.062827-12-ua-ksd.war

# Actually download the real artifact to our files folder
`curl '$fullURL' -o ./files/kfs.war`;

# Extract the date and timestamp info from the URL for use in tagging.
my ($timestamp) = $fullURL =~ m/-([0-9]{8}\.[0-9]{6}-[0-9]+)-ua/;


#####################################################################
# Print out resulting ENV vars
#####################################################################

# We need to send this data back to the caller so that it can be stored as environment vars in 
# the parent context.

print "export APP_VERSION_TIMESTAMP='$timestamp'\n";

