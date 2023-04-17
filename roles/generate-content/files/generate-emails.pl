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
use Pod::Usage;
use DateTime::Format::Strptime;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Tiny;
use Data::Dumper;
use URI::Encode qw(uri_encode uri_decode);
use Time::Local;

# Load the parameters
my $lang;
my $recipient;
my $from = 'postmaster';
my $month;
my $year;
my $attach = 'text';
my $wikipedia_domain = "en.wikipedia.org";
my $body = 'text';

GetOptions (
    "body=s"      => \$body,
    "lang=s"      => \$lang,
    "month=s"     => \$month,
    "year=s"      => \$year,
    "recipient=s" => \$recipient,
    "attach=s"    => \$attach,
    "from=s"      => \$from,
    "wiki=s"      => \$wikipedia_domain
    ) or die("Error in command line arguments\n");

# TODO: Check the parameters

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

# Create the date time range of the message
my $last_day;
if ( $month < 11 ) {
    my $last_day_epoch = timelocal(0, 0, 0, 1, $month + 1, $year) - 86400;
    $last_day = (localtime $last_day_epoch)[3];
} else {
    my $last_day_epoch = timelocal(0, 0, 0, 1, 0, $year + 1) - 86400;
    $last_day = (localtime $last_day_epoch)[3];
}

my $min_date = sprintf("%04d-%02d-01 00:00:00", $year, $month);
my $max_date = sprintf("%04d-%02d-%02d 23:59:59", $year, $month, $last_day);

my $datetime = rand_datetime(min => $min_date, max => $max_date);

my $strp = DateTime::Format::Strptime->new(
    pattern   => '%Y-%m-%d %H:%M:%S',
    locale    => 'en_GB',
    time_zone => 'Europe/London',
    );
my $dt = $strp->parse_datetime($datetime);

# Prepare the first part of the message
my $msg = MIME::Lite->new(
    From     => $from,
    To       => $recipient,
    Subject  => $subject,
    Date     => DateTime::Format::Mail->format_datetime($dt),
    Type     => 'multipart/mixed'
    );

if ( $body eq 'html' ) {

    # Create the message body
    my $nbp = 3 + int(rand(5));
    my $body = "" ;

    for ( my $p = 0 ; $p < $nbp ; $p++ ) {
        $generator->paragraphs(1,1);
        $generator->sentences(3,9);
        $generator->words(10,22);
        $body .= "<p>" . $generator->generate . "</p>";
    }

    # Add the root message
    $msg->attach (
        Type => 'text/html; charset=UTF-8',
        Data => "<html><h1>$subject</h1><body>$body</body></html>",
        ) or die "Error adding the body message part: $!";

} elsif ( $body eq 'text') {

    # Create the message body
    $generator->paragraphs(3,9);
    $generator->sentences(3,9);
    $generator->words(10,22);

    my $body = $generator->generate;

    # Add the root message
    $msg->attach (
        Type => 'text/plain; charset=UTF-8',
        Data => $body,
        ) or die "Error adding the body message part: $!";

}

if ( $attach eq 'pdf' ) {

    # Get the url of a random wikipedia page
    my $res = HTTP::Tiny->new->head("https://$wikipedia_domain/wiki/Special:Random");

    # Get the url and create the attachment name
    my $page_title = $res->{url};
    $page_title =~ s:.*/::g;
    my $attach_name = uri_decode($page_title);

    $res = HTTP::Tiny->new->get("https://$wikipedia_domain/api/rest_v1/page/pdf/$page_title");

    # Attach the pdf file
    $msg->attach (
        Type => 'application/pdf',
        Data => $res->{content},
        Filename => "$attach_name.pdf",
        Disposition => 'attachment'
        ) or die "Error adding the body message part: $!";

} elsif ( $attach eq 'text' ) {

    # Create a text attachment
    $generator->paragraphs(10, 30);
    $generator->sentences(6,18);
    $generator->words(7,17);

    # Generate an attachment name
    my $attach_name = rand_chars(set => 'alphanumeric', min => 6, max => 14);

    $msg->attach(
        Type => 'text/plain; charset=UTF-8',
        Data => $generator->generate,
        Filename => "${attach_name}.txt",
        Disposition => 'attachment'
        ) or die "Error adding the text message part: $!";

}

# Send the email
$msg->send;


__END__

=head1 NAME

generate-emails - Generate and send random emails

=head1 SYNOPSIS

generate-emails [options]

=head1 OPTIONS

 Options:
   --help            brief help message
   --man             full documentation
   --lang            name of the language file to use in /usr/share/dict
   --year            the year to use to generate the email date
   --month           the month to use to generate the email date
   --recipient       the locall recipient email address
   --attach          type of attachment to use: text (default), html, or pdf
   --from            the from email address to use
   --wiki            the url of wikipedia to use when generating pdf attachments

=cut
