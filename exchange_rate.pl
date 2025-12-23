#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

# Core dependencies
use Getopt::Long qw(GetOptions);
use LWP::UserAgent;
use JSON::MaybeXS qw(decode_json);
use Try::Tiny;

# Turn on autoflush for stdout
$| = 1;

# --- Constants ---
use constant API_BASE_URL => 'https://api.frankfurter.app';

# --- Subroutines ---

#
# get_exchange_rate_and_convert
#
# Fetches the latest exchange rate and prints the converted amount.
#
sub get_exchange_rate_and_convert {
    my ($amount, $from, $to) = @_;

    # Input validation
    die "ERROR: Amount must be a positive number.\n" unless ($amount > 0);
    die "ERROR: 'from' currency code must be a 3-letter code (e.g., USD).\n" unless ($from =~ /^[A-Z]{3}$/);
    die "ERROR: 'to' currency code must be a 3-letter code (e.g., EUR).\n" unless ($to =~ /^[A-Z]{3}$/);

    printf "Converting %.2f %s to %s...\n", $amount, $from, $to;

    my $ua = LWP::UserAgent->new;
    $ua->agent("PerlCurrencyConverter/0.1");
    $ua->timeout(10);
    
    my $latest_url = sprintf("%s/latest?amount=%.2f&from=%s&to=%s", API_BASE_URL, $amount, $from, $to);
    
    my $response;
    try {
        $response = $ua->get($latest_url);
    } catch {
        die "FATAL: Network request to fetch exchange rate failed. Error: $_
";
    };

    unless ($response->is_success) {
        # Provide a more helpful error for common currency mistakes
        if ($response->decoded_content =~ /Invalid `from` currency/i) {
             die "FATAL: The 'from' currency '$from' is not supported by the API. Run with --list to see available currencies.\n";
        }
        if ($response->decoded_content =~ /Invalid `to` currency/i) {
             die "FATAL: The 'to' currency '$to' is not supported by the API. Run with --list to see available currencies.\n";
        }
        die "FATAL: Could not fetch exchange rate. API responded with: " . $response->status_line;
    }

    my $data;
    try {
        $data = decode_json($response->decoded_content);
    } catch {
        die "FATAL: Could not parse JSON response for exchange rate. Error: $_
";
    };

    my $converted_amount = $data->{rates}->{$to};

    unless (defined $converted_amount) {
        die "FATAL: The API response did not contain the rate for '$to'.\n";
    }

    printf "%.2f %s is equal to %.2f %s\n", $amount, $from, $converted_amount, $to;
    
    exit 0;
}


#- 
#- list_available_currencies
#- 
#- Fetches and displays the list of all supported currencies from the API.
#- 
sub list_available_currencies {
    print "Fetching list of available currencies...\n";
    
    my $ua = LWP::UserAgent->new;
    $ua->agent("PerlCurrencyConverter/0.1");
    $ua->timeout(10);

    my $currencies_url = API_BASE_URL . "/currencies";
    my $response;

    try {
        $response = $ua->get($currencies_url);
    } catch {
        die "FATAL: Network request to fetch currency list failed. Error: $_
";
    };

    unless ($response->is_success) {
        die "FATAL: Could not fetch currency list. API responded with: " . $response->status_line;
    }

    my $currencies;
    try {
        $currencies = decode_json($response->decoded_content);
    } catch {
        die "FATAL: Could not parse JSON response for currency list. Error: $_
";
    };

    print "--------------------------------------------------\n";
    print "Supported Currencies:\n";
    print "--------------------------------------------------\n";
    foreach my $code (sort keys %{$currencies}) {
        printf "% -5s: %s\n", $code, $currencies->{$code};
    }
    print "--------------------------------------------------\n";
    
    exit 0;
}

#
# print_usage
#
# Prints the script's usage instructions.
#
sub print_usage {
    print <<'USAGE';
A simple command-line currency converter.

Usage:
  perl exchange_rate.pl --amount <number> --from <CURRENCY> --to <CURRENCY>
  perl exchange_rate.pl --list
  perl exchange_rate.pl --help

Options:
  --amount <number>     The amount of money to convert.
  --from   <CURRENCY>   The 3-letter currency code to convert from (e.g., USD).
  --to     <CURRENCY>   The 3-letter currency code to convert to (e.g., EUR).
  --list                List all available currencies supported by the API.
  --help                Show this help message.
USAGE
}


# --- Main Execution ---

sub main {
    my ($amount, $from, $to, $list, $help);
    
    # Gracefully handle lack of arguments.
    if (!@ARGV) {
        print_usage();
        exit 1;
    }

    GetOptions(
        'amount=f' => \$amount,
        'from=s'   => \$from,
        'to=s'     => \$to,
        'list'     => \$list,
        'help'     => \$help,
    ) or die "Error in command line arguments. Use --help for details.\n";

    if ($help) {
        print_usage();
        exit 0;
    }

    if ($list) {
        list_available_currencies();
        # list_available_currencies exits on its own
    }
    
    # If the main conversion arguments are present, run the conversion.
    if (defined $amount && defined $from && defined $to) {
        # Be forgiving with case
        get_exchange_rate_and_convert($amount, uc($from), uc($to));
        # get_exchange_rate_and_convert exits on its own
    }

    # If we get here, the combination of arguments was invalid.
    print "ERROR: Invalid combination of arguments.\n\n";
    print_usage();
    exit 1;
}

# Run the main subroutine
main();
