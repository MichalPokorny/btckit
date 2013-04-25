require 'pathname'
require 'active_support/core_ext/hash/indifferent_access'

module BtcKit
	class Config
		def config_dir
			path = Pathname.new("~") + ".btckit"
			path.expand_path
		end

		def initialize
			raise "btckit config dir (#{config_dir}) does not exist."	unless Dir.exist? config_dir
		end

		private
		def load_credentials
			begin
				@credentials = YAML.load_file(config_dir + "credentials.yaml")
			rescue
				raise "Failed to load Bitstamp credentials"
			end

			unless @credentials.is_a? Hash
				raise "Credentials are not a hash."
			end
		end

		public
		def credentials
			load_credentials unless @credentials
			@credentials.with_indifferent_access
		end

		private
		def orders_path
			config_dir + "orders.yaml"
		end

		def load_orders
			begin
				@orders = YAML.load_file(orders_path)
			rescue
				raise "Failed to load orders."
			end
		end

		public
		def save_orders(new_orders = nil)
			@orders = new_orders if new_orders
			File.open(orders_path, "w") { |f|
				f.write @orders.to_yaml
			}
		end

		public
		def orders
			load_orders unless @orders
			@orders
		end

		def orders=(new_orders)
			@orders = new_orders
			save_orders
		end

		def bank_filename
			config_dir + "bank_last_rates"		
		end

		def initial_czk
			f = File.open(config_dir + "initial_czk", "r")
			return f.read.to_i
		end

		def mail_target
			# TODO: make this changable
			[ 'pok@rny.cz', '+420720182089@sms.cz.o2.com' ]
		end
	end
end
