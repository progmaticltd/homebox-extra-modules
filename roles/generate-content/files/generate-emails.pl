#!/usr/bin/perl

# Other uses
use strict;
use warnings;
use utf8;
use autodie;

use Getopt::Long;
use Text::Greeking;
use File::Slurp;
use MIME::QuotedPrint;
use MIME::Base64;
use MIME::Lite;
use Data::Random qw(:all);
use DateTime::Format::Mail;
use Getopt::Long;
use File::Temp qw(tempfile);
use DateTime::Format::Strptime;


# Load the parameters
my $lang;
my $recipient;
my $from;
my $month;
my $year;

GetOptions (
    "lang=s"      => \$lang,
    "month=s"     => \$month,
    "year=s"      => \$year,
    "recipient=s" => \$recipient,
    "from=s"      => \$from)
    or die("Error in command line arguments\n");

# Load the dictionary
my $file = "/usr/share/dict/$lang";
my $words = read_file($file) ;

# Load the words
my $generator = Text::Greeking->new;
$generator->add_source($words);

# Create the subject
$generator->paragraphs(1,1);
$generator->sentences(1,1);
$generator->words(6,12);

my $subject = $generator->generate;

# Create the message body
$generator->paragraphs(3,9);
$generator->sentences(3,9);
$generator->words(10,22);

my $body = $generator->generate;

# Create a text attachment
$generator->paragraphs(10, 30);
$generator->sentences(6,18);
$generator->words(7,17);

my $attach_file = new File::Temp(UNLINK => 1);
$attach_file->print($generator->generate);
$attach_file->flush;

# Generate an attachment name
my $attach_name = rand_chars(set => 'alphanumeric', min => 6, max => 14);

# Datetime of the message
my $datetime = rand_datetime(min => '2000-01-01', max => 'now' );
print $datetime;

my $strp = DateTime::Format::Strptime->new(
    pattern   => '%Y-%m-%d %H:%M:%S',
    locale    => 'en_GB',
    time_zone => 'Europe/London',
    );
my $dt = $strp->parse_datetime($datetime);

# Prepare the message, and send the message
my $msg = MIME::Lite->new(
    From     => $from,
    To       => $recipient,
    Subject  => $subject,
    Date     => DateTime::Format::Mail->format_datetime($dt),
    Type     => 'multipart/mixed'
    );

$msg->attach (
    Type => 'text/plain; charset=UTF-8',
    Data => $body,
    ) or die "Error adding the body message part: $!";

$msg->attach(
    Type => 'text/plain; charset=UTF-8',
    Path => $attach_file,
    Filename => "${attach_name}.txt",
    Disposition => 'attachment'
    ) or die "Error adding the text message part: $!";

$msg->send;

# Release the attachment file
close $attach_file;
