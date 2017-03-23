class Craigslist
  module DB
    class << self
      def pool
        build_pool if @pool.nil?

        @pool.with { |c| yield c }
      end

      def connect
        build_pool
      end

      private

      def build_pool
        @pool ||= ConnectionPool.new(size: ENV.fetch('DATABASE_SIZE', 10).to_i) do
          c = PG.connect(host: ENV['DATABASE_HOST'],
                         port: ENV.fetch('DATABASE_PORT', 5432).to_i,
                         dbname: ENV['DATABASE_NAME'],
                         user: ENV['DATABASE_USER'],
                         password: ENV['DATABASE_PASS'])

          # Checks for "NOT processed" are to exclude posts that were processed
          # by the old qualifier

          c.prepare('fetch post',
                    'SELECT *
                     FROM posts
                     WHERE id = $1')

          c.prepare('get first unprocessed',
                    'SELECT id, title, body
                     FROM posts
                     WHERE potential_lead IS NULL
                     AND body IS NOT NULL
                     AND NOT processed
                     ORDER BY id
                     LIMIT 1')

          c.prepare('get first unemailed',
                    'SELECT id, url, title
                     FROM posts
                     WHERE NOT email_sent
                     AND potential_lead
                     ORDER BY id
                     LIMIT 1')

          c.prepare('mark bad',
                    'UPDATE posts
                     SET potential_lead = false
                     WHERE id = $1
                     RETURNING id')

          c.prepare('mark good',
                    'UPDATE posts
                     SET potential_lead = true, email = $2
                     WHERE id = $1
                     RETURNING id')

          c.prepare('update with mail',
                    'UPDATE posts
                     SET email = $2, email_sent = true
                     WHERE id = $1
                     RETURNING id')
          c
        end
      end
    end
  end
end
