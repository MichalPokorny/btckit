require 'net/http'
require 'json'

require_relative 'config'

module BtcKit
	class BtcPrice
		def initialize
			@config = Config.new
		end

		def current_value
			@config.wallet_btc * btc_avg_localbitcoins # btc_localbitcoins_manual
		end

		# TODO: this method returns at most 500 trades, it must be iterated!
		def btc_localbitcoins_manual
			response = Net::HTTP::get_response(URI.parse "https://localbitcoins.com/bitcoincharts/CZK/trades.json?since=311531").body
			json = JSON.parse(response)

			last = json.sort { |x, y| y["date"] <=> x["date"] }.take(5)
			# require 'pp'
			# pp last_10

			last.map! { |trade| trade["price"].to_f }
			last.inject(&:+) / last.size
		end

		def btc_avg_localbitcoins
			response = Net::HTTP::get_response(URI.parse "https://localbitcoins.com/bitcoinaverage/ticker-all-currencies/").body
			json = JSON.parse(response)

			raise "Response doesn't contain CZK: #{response}" unless json["CZK"]
			ticker = json["CZK"]

			%w{avg_1h avg_12h avg_24h}.each do |key|
				ticker.delete(key) unless ticker[key] > 0
			end
			avg = ticker["avg_1h"] || ticker["avg_12h"] || ticker["avg_24h"] or raise "Cannot get average price (ticker: #{ticker.inspect})"

			avg.to_f
		end

		# BitCash API (dropped)
		def btc_price_bitcash
			json = JSON.parse(Net::HTTP.get_response(URI.parse "http://bitcash.cz/market/api/BTCCZK/ticker.json").body)
			raise unless json["result"] == "success"
			json["data"]["sell"]["value"].to_f
		end
	end
end
