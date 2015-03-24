require 'rubygems'
require 'rack'
require_relative 'make10app'

map "/" do
  run Make10App
end
