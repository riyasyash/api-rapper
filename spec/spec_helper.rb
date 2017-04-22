require 'webmock/rspec'
require 'rest-client'
require 'wrapper'

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.raise_errors_for_deprecations!

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.mock_with :rspec
end

# always run with ruby warnings enabled (see above)
$VERBOSE = true
