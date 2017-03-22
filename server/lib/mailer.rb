class Craigslist
  module Mailer
    class << self
      def send_mail(message)
        client.messages.send(message, false)
      end

      private

      def client
        @_client ||= Mandrill::API.new(ENV['MANDRILL_KEY'])
      end
    end
  end
end
