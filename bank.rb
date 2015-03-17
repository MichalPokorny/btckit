require 'money'
require 'eu_central_bank'

module BtcKit
	class Bank
		def initialize(filename)
			@filename = filename

			@bank = EuCentralBank.new
			if cache_is_valid?
				@bank.update_rates @filename
			else
				@bank.update_rates
				@bank.save_rates @filename
			end
		end

		def exchange(amount, from, to)
			@bank.exchange(amount, from, to)
		end

		private

		def cache_is_valid?
			File.exists?(@filename) && (Time.now - File.stat(@filename).mtime) < 24 * 60 * 60
		end
	end
end
