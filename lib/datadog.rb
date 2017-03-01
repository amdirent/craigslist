module Datadog
  @@_client = Dogapi::Client.new(ENV['DD_API_KEY']) rescue nil

  DEFAULTS = { aggregation_key: 'craigslist_scraper' }.freeze

  def self.emit_event(msg, options={})
    opts = DEFAULTS.merge(options)

    @@_client.emit_event(
      Dogapi::Event.new(msg, opts)
    )
  rescue NoMethodError
    # catch when DD client is nil
  end
end
