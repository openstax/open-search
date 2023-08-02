# Load the Rails application.
require_relative 'application'

require 'patches/openstax_cnx'
require 'prefix_logger'
require 'rescue_from_unless_local'
require 'ox_open_search_client'

# Initialize the Rails application.
Rails.application.initialize!
