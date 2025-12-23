# Perl Currency Exchange Rate Calculator

**Author:** christopher.spencer.g@yahooo.com

## Overview

This is a command-line Perl script that fetches real-time currency exchange rates from the free `frankfurter.dev` API and calculates the converted value for a given amount.

## Prerequisites

- Perl 5.x
- `cpanm` (or another CPAN client) for installing dependencies.

## Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/SpencerChristopher/Perl_exchangrate_yahoo.git
    cd Perl_exchangrate_yahoo
    ```

2.  **Install Dependencies:**
    This project uses a `cpanfile` to declare its dependencies. You can use a tool like `cpanm` (App::cpanminus) to easily install them.

    ```bash
    cpanm --installdeps .
    ```

## Usage

Run the script from your command line, providing the amount, the base currency, and the target currency as named options.

```bash
perl exchange_rate.pl --amount <number> --from <CURRENCY> --to <CURRENCY>
```

**Example:**

To convert 100 US Dollars to Euros:

```bash
perl exchange_rate.pl --amount 100 --from USD --to EUR
```

**Example Output:**

```
Converting 100.00 USD to EUR...
100.00 USD is equal to 92.50 EUR
```
