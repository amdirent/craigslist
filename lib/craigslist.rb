require "craigslist/version"
require "action_view"
require "uri"
require "time"
require "open-uri"
require "nokogiri"

module Craigslist

  class Helper
    include Singleton
    include ActionView::Helpers::SanitizeHelper

    class << self
      include ActionView::Helpers::SanitizeHelper::ClassMethods
    end
  end

	def self.query_section(section, query, states)
		term = "#{section}?query=#{query.gsub(' ', '+')}&srchType=T"
		results = {}
		base_url = 'http://geo.craigslist.org/iso/us/'
		states ||= %w{al ak az ar ca co ct de fl ga hi id il in ia ks ky la me md ma mi mn ms md mt ne nv nh nj nm ny nc nd oh ok or pa ri sc sd tn tx ut vt va wa wv wi wy}

		pool = Thread.pool(3)
		states.each do |state|
			pool.process {
			  begin
          url = base_url + state
          page = Nokogiri::HTML(open(url, :read_timeout=>nil))
          page.css('div#list a').each do |link|
            url = "#{link['href']}search/#{term}"
            post = Nokogiri::HTML(open(url, :read_timeout=>nil))
            post.css('p.row a').each do |plink|
              if plink['href'].include?('craigslist')
                results[plink['href']] = plink.parent.text.strip
              end
            end
          end
        rescue OpenURI::HTTPError => e
          puts e.message
        rescue RuntimeError => e
          puts e.message
        end
			}
		end

		pool.shutdown
		results
	end

  def self.extract_email(url)
    uri = URI(url)
    posting_id = url.split('/').last.split('.')[0]
    page = Nokogiri::HTML(open("http://#{uri.host}/reply/#{posting_id}"))
    page.css('a.mailto').text.strip
  end

	def self.parse_post(url)
	  post = {}

    page = Nokogiri::HTML(open(url))

    post[:posted_on] = DateTime.parse(page.css('p.postinginfo time')[0]['datetime'])
    post[:posted_on] = Time.parse(page.css('time')[0]['datetime']).to_s
    post[:title] = page.css('h2.postingtitle')[0].text.strip
    post[:message] = page.css('section#postingbody').text.strip
    post[:email] = extract_email(url).strip
    post[:url] = url

    page.css('ul.blurbs').each do |li|
      if li.text =~ /Location:/
        loc = li.text.split("Location: ")[1]
        post[:location] = Helper.instance.strip_tags(loc).strip
      end

      if li.text =~ /Compensation:/
        comp = li.text.split("Compensation: ")[1]
        post[:budget] = Helper.instance.strip_tags(comp).strip
      end
    end

    return post
  end

end
