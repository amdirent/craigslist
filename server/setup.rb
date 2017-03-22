# Add our application to the load path
$root = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join($root, 'lib'))
$LOAD_PATH.unshift(File.join($root, 'config'))
$LOAD_PATH.unshift($root)

require 'bundler'

Bundler.require(:default)
