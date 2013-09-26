# btckit

I use this program to keep an eye on my Bitcoin investments with regards to the value of the Czech koruna.
It uses the Bitstamp API to look at the status of your account. It can send alerts to market movements
and issue stop-loss orders if the price is lower than a specified amount.

DO NOT USE THIS PROGRAM IF YOU AREN'T READY TO LOSE ALL YOUR MONEY OVER A BUG IN MY CODE!

## Installation

Clone and `bundle install`.

## Usage - basic (btcreport)

First, you must create a config directory: `~/.btckit`.

Then put the amount of invested CZK into `~/.btckit/initial_czk` - like this:

    $ echo "1000000" > ~/.btckit/initial_czk

Then you need to give `btckit` your Bitstamp credentials (don't forget to enable API access in Bitstamp).

    $ cat ~/.btckit/credentials.yaml
    ---
    username: 12345
    password: <your password>

I should point out that this file is very dangerous in the wrong hands. Make sure you give it some sane
privileges like 0700. Also take great care if you aren't the sole user of the machine that has this file.
Consider storing it on an encrypted partition.

Now you can use the first function of `btckit`: the `btcreport` utility.

* If you give `btcreport` no parameters, it gets the current price of Bitcoin, a reasonably recent conversion
  rate of USD and CZK, and calculates your profits.
* If you give `btcreport` a numerical parameter (e.g. `btcreport 1024.5`), `btcreport` tells you what your
  profits would be should Bitcoin reach the value in USD that you provided.

## Usage - Czech koruna Bitcoin wallet value

`btc-wallet-price` reports the value of your Bitcoin wallet in Czech koruna and the difference between your
initial investment and its current value. It expects your Bitcoin wallet balance in `~/.btckit/wallet_btc`:

	$ echo "1024.5" > ~/.btckit/wallet_btc

It pulls the CZK/BTC ticker from the API of http://bitcash.cz/market/.

## Usage - alerts (btc-stoploss)

To use alerts, you need to tell `btckit` some things about the mails it should send out.

    $ cat ~/.btckit/config.yaml
    ---
    mail_from: noreply-btckit@rny.cz
    mail_to:
        - mail1@example.com
	- +123123123@your.cell.operator.com

Now you should at least create a minimal `~/.btckit/orders.yaml` file:

    $ echo "--- []" > ~/.btckit/orders.yaml

The `orders.yaml` file contains instructions for `btc-stoploss`. There are three types of instructions:
* `alert_up`, `alert_down`: takes a single parameter: `price`. If Bitcoin gets above (or below, respectively)
  this price, it sends you a crude alert.
* `stop_loss`: if Bitcoins go below `price`, sell `amount` bitcoins for `minimum_price` USD/BTC.
  When this happens, a mail is sent as well.

This is a more complete example of `orders.yaml`:

    ---
    - type: :alert_up
      price: 300
    - type: :alert_up
      price: 220
    - type: :alert_down
      price: 80
    - type: :alert_down
      price: 70
    - type: :stop_loss
      price: 60
      minimum_price: 55
      amount: 10
    - type: :stop_loss
      price: 50
      minimum_price: 45
      amount: 15

This means:
* Send me a mail when Bitcoin reaches 300 USD/BTC (or 220 USD/BTC) or more.
* Send me a mail when Bitcoin drops to 80 USD/BTC (or 70 USD/BTC) or lower.
* When Bitcoin drops below 60 USD/BTC, place a limit sell order of 10 BTC for 55 USD/BTC.
* When Bitcoin drops below 50 USD/BTC, place a limit sell order of 15 BTC for 45 USD/BTC.

If you want to use `btc-stoploss`, you must manually set your computer to run it periodically. One way to
ensure this is to put it in a crontab.

## btcreport-xosd

This tiny script (that currently works only on my machines :) gives the result of `btcreport`
to my utility `xosdutil`. Feel free to ignore it.

## A warning

Before you start to trust `btckit`, first test it with instantly executed orders of type `:alert_down` or `:alert_up`.
This is to make sure that e-mails are getting sent and that you can successfully obtain prices from Bitstamp.

If you want to start placing `:stop_loss` orders, *try it first with a very small, instantly executed order*! (e.g. 0.001 BTC)
If there's a bug or misconfiguration, this is much less likely to destroy your money than if you enter big orders immediately.

I do not take responsibility for any bugs you may encounter. Even through I used to trust this piece of code with my money,
I don't recommend you to do so.

## Contributing

1. Fork
2. Make a feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
