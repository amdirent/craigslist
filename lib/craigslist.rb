require "craigslist/version"
require "open-uri"
require "action_view"

module Craigslist
  
  class Helper
    include Singleton
    include ActionView::Helpers::SanitizeHelper
    
    class << self
      include ActionView::Helpers::SanitizeHelper::ClassMethods
    end
  end
  
	def self.query_section(section, query, states=nil)
		term = "#{section}?query=#{query.gsub(' ', '+')}&srchType=T"
		results = {}
		base_url = 'http://geo.craigslist.org/iso/us/'
		states ||= %w{al ak az ar ca co ct de fl ga hi id il in ia ks ky la me md ma mi mn ms md mt ne nv nh nj nm ny nc nd oh ok or pa ri sc sd tn tx ut vt va wa wv wi wy}
	
		threads = []	
		states.each do |state|
			threads << Thread.new(state) do |s|
			  begin
    			doc = open(base_url + state) { |f| Hpricot(f) }
    			doc.search("//div[@id='list']/a").each do |link|
    				url = "#{link[:href]}search/#{term}"
    				post = open(url) { |p| Hpricot(p) }
    				post.search("//blockquote/p/a").each do |link|
    				  results[link[:href]] = link.parent.inner_text
    			  end					
    			end
        rescue OpenURI::HTTPError => e
          logger.error e.message
        rescue RuntimeError => e
          logger.error e.message
        end
			end
		end

		threads.each { |t| t.join } # Make sure the threads finish
		results
	end
	
	def self.parse_post(url)
	  post = {}
	  doc = open(url) { |d| Hpricot(d) }

		doc.at("body").inner_html.each_line do |line|
			if line =~ /Posted:/
				line.gsub!("<br />", '')
				line.gsub!("Posted:", '')
				post[:posted_on] = DateTime.parse(line.to_s)
			end

			if line =~ /Posting ID:/
			  line.gsub!("<br />", "")
			  line.gsub!("Posting ID: ", '')
			  post[:posting_id] = Helper.instance.strip_tags(line)
		  end
			
		  if line =~ /Location:/
			  line = line.split("Location: ")[1]
			  post[:location] = Helper.instance.strip_tags(line)
		  end

		  if line =~ /Compensation:/			
			  line = line.match(/-->.+<!--/)[0]
			  line.gsub!("-->", '')
			  line.gsub!("<!--", '')
			  line.gsub!("Compensation:", '')
			  post[:budget] = Helper.instance.strip_tags(line)
		  end
		end
			  
	  post[:title] = (doc/"h2.postingtitle").first.inner_text
		post[:message] = (doc/"#postingbody").first.inner_text
	  post[:email] = doc.search("a[text()*='@']").first.inner_text
	  post[:url] = url		
		
		post
  end
	
end
