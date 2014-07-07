require 'net/http'
require 'json'
require 'bigdecimal'

require_relative 'config'

module BtcKit
	class BtcPrice
		def initialize
			@config = Config.new
		end

		private

		def average(array)
			array.inject(&:+) / array.size
		end

		public

		def current_value
			@config.wallet_btc * average([btc_localbitcoins_manual, btc_avg_localbitcoins].compact)
		end

		# TODO: this method returns at most 500 trades, it must be iterated!
		def btc_localbitcoins_manual
			trades = nil

			while trades.nil? || trades.size > 5
				try_start = trades ? trades[-2][:tid] : 580000
				response = Net::HTTP::get_response(URI.parse "https://localbitcoins.com/bitcoincharts/CZK/trades.json?since=#{try_start}").body
				trades = JSON.parse(response).map { |json|
					{
						tid: json["tid"],
						date: Time.at(json["date"]),
						amount: BigDecimal(json["amount"]),
						price: BigDecimal(json["price"])
					}
				}
			end

			if (Time.now - trades.last[:date]) > 4 * 24 * 60 * 60
				raise "Last entry older than 4 days"
			end

			trades.map { |trade| trade[:price] }.inject(&:+) / trades.size
		end

		def btc_avg_localbitcoins
			response = Net::HTTP::get_response(URI.parse "https://localbitcoins.com/bitcoinaverage/ticker-all-currencies/").body
			json = JSON.parse(response)

			ticker = json["CZK"] or return nil

			%w{avg_1h avg_12h avg_24h}.each do |key|
				ticker.delete(key) unless ticker[key] > 0
			end
			avg = ticker["avg_1h"] || ticker["avg_12h"] || ticker["avg_24h"] or raise "Cannot get average price (ticker: #{ticker.inspect})"

			avg.to_f
		end
	end
end
