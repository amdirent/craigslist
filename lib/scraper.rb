require 'typhoeus'
require 'uri'
require_relative 'utils'

class Scraper
  @@_skip_reply_data = false

  class << self
    def scrape(url, referer=nil)
      base_host = URI.parse(url).host

      page = begin
               Nokogiri::HTML(Utils.get_page(url, { 'Referer' => referer }))
             rescue
               p "Unable to open #{url}"
               return [nil, nil, nil]
             end

      p "Got #{url}"

      post_body = page.css('#postingbody').first.text.strip

      unless @@_skip_reply_data
        reply_link = page.css('#replylink').first

        reply_uri = begin
                      uri = URI.parse(reply_link['href'])
                      uri.host ||= base_host
                      uri.scheme ||= 'https'

                      uri.to_s
                    rescue
                      p "No reply info found for #{url}"
                      return [post_body, nil, nil]
                    end

        reply_data = Nokogiri::HTML(Utils.get_page(reply_uri, { 'Referer' => url }))

        unless reply_data.css('.captcha').first.nil?
          p "Getting captcha'd, skipping reply data from now on."
          @@_skip_reply_data = true
        end

        reply_email = reply_data.css('.reply-email-address a').first.text rescue nil
        reply_phone = begin
                        reply_data.css('.reply-tel-link').first['href'].gsub(/\D/, '')
                      rescue
                        reply_data.css('.reply-tel-number').first.text.gsub(/\D/, '') rescue nil
                      end
      end

      [post_body, reply_email, reply_phone]
    rescue => e
      p "#{e.class}: #{e.message}"
      [nil, nil, nil]
    end
  end
end
