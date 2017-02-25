require 'typhoeus'
require 'uri'
require_relative 'utils'

class Scraper
  class << self
    def scrape(url, referer=nil)
      page = begin
               Nokogiri::HTML(Utils.get_page(url, { 'Referer' => referer }))
             rescue
               p "Unable to open #{url}"
               return [nil, nil, nil]
             end

      p "Got #{url}"

      post_body = page.css('#postingbody').first.text.strip

      [post_body, nil, nil]
    rescue => e
      p "#{e.class}: #{e.message}"
      [nil, nil, nil]
    end
  end
end
