require 'money'
require 'eu_central_bank'

module BtcKit
	class Bank
		def initialize(filename)
			@filename = filename

			@bank = EuCentralBank.new
			if File.exists? @filename and (Time.now - File.stat(@filename).mtime) < 24 * 60 * 60
				@bank.update_rates @filename
			else
				@bank.update_rates
				@bank.save_rates @filename
			end
		end

		def exchange(amount, from, to)
			@bank.exchange(amount, from, to)
		end
	end
end
