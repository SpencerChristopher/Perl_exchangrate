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

    my $currencies_url = "$API_BASE_URL/currencies";
    my $response;

    try {
        $response = $ua->get($currencies_url);
    } catch {
        die "FATAL: Network request to fetch currency list failed. Error: $_\n";
    };

    unless ($response->is_success) {
        die "FATAL: Could not fetch currency list. API responded with: " . $response->status_line;
    }

    my $currencies;
    try {
        $currencies = decode_json($response->decoded_content);
    } catch {
        die "FATAL: Could not parse JSON response for currency list. Error: $_\n";
    };

    print "--------------------------------------------------\n";
    print "Supported Currencies:\n";
    print "--------------------------------------------------\n";
    foreach my $code (sort keys %{$currencies}) {
        printf "%-5s: %s\n", $code, $currencies->{$code};
    }
    print "--------------------------------------------------\n";
    
    exit 0;
}