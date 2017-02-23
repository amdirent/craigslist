module Utils
  class << self
    def nap(time=:random)
      sleep(time == :random ? Random.rand(10..25) : time)
    end

    def get_page(url, headers={})
      nap

      response = Typhoeus.get(board_url, headers: { 'Referer' => previous_url })

      unless response.success?
        if response.response_code == 403
          p "Current IP has been banned.  Terminating"
          exit(1)
        end

        # TODO: Proper error?
        raise 'Page pull unsuccessful'
      end

      response.body
    end
  end
end
