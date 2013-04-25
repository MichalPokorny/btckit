require 'net/http'
require 'json'

class Bitstamp
	def initialize(user, password)
		@user = user.to_s
		@password = password.to_s

		if @user.blank?
			raise 'Username empty.'
		end

		if @password.blank?
			raise 'Password empty.'
		end

		@http = Net::HTTP.new("www.bitstamp.net", 443)
		@http.use_ssl = true
	end

	def balance
		req = Net::HTTP::Post.new("/api/balance/")
		req.set_form_data({
			user: @user.to_s	,
			password: @password
		})
		response = JSON.parse(@http.request(req).body)

		if response.key? "error"
			raise "Error getting balance: #{response["error"]}"
		end

		{
			:USD => response["usd_balance"].to_f,
			:BTC => response["btc_balance"].to_f
		}
	end

	def ticker
		req = Net::HTTP::Get.new("/api/ticker/")
		JSON.parse(@http.request(req).body)["last"].to_f
	end

	def limit_order!(type, amount, price)
		raise unless [ :buy, :sell ].include? type

		price = 0.01 if price == :any # Minimum allowed price.
		
		req = Net::HTTP::Post.new("/api/#{type.to_s}/")
		req.set_form_data({
			user: @user.to_s,
			password: @password,
			amount: amount,
			price: price
		})
		JSON.parse(@http.request(req).body)
	end
end
