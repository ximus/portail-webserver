# Allow you to require anything in lib/
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

# Always have bundler check and manage deps.
require 'rubygems'
require 'bundler'
Bundler.require

require 'app'

App.init