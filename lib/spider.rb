require 'typhoeus'
require_relative 'utils'
require 'uri'

class Spider
  def self.crawl(base_url, boards=%w{ eng sof cpg })
    base_host = URI.parse(base_url).host

    boards.each do |board|
      previous_url = base_url
      board_url = URI.join(base_url, '/search/', board)

      loop do
        page = begin
                 Nokogiri::HTML(Utils.get_page(board_url, { 'Referer' => previous_url }))
               rescue
                 p "Unable to pull #{board_url}"
                 break
               end

        page.css('a.result-title').map do |post|
          uri = URI.parse(post['href'])
          uri.host ||= base_host
          uri.scheme ||= 'https'

          yield uri.to_s, post.text.strip, board_url
        end

        next_link = page.css('.paginator:not(.lastpage) a.next').first

        p "pulled #{board_url}"

        break if next_link.nil?

        previous_url = board_url
        board_url = begin
                      uri = URI.parse(next_link['href'])
                      uri.host ||= base_host
                      uri.scheme ||= 'https'

                      uri.to_s
                    end
      end
    end

    nil
  end
end
