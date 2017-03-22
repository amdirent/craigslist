require_relative 'setup'

require 'application'
require 'db'
require 'mailer'

use Rack::CommonLogger
use Rack::ContentLength
use Rack::Deflater

use Rack::Session::Cookie, secret: ENV['COOKIE_SECRET'],
                           coder: Rack::Session::Cookie::Base64::ZipJSON.new

use Rack::Static, root: 'public'

require 'authorizer'
use Craigslist::Authorizer

use Rack::Static, root: 'protected'

run Craigslist
