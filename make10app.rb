# coding: utf-8
require 'sinatra'
require_relative 'lib/make10'

class Make10App < Sinatra::Base
  @@last_modified = File.mtime(File.expand_path('lib/make10.rb', File.dirname(__FILE__)))

  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  get '/:numbers?' do
    if settings.environment == :production
      expires (60 * 60 * 24 * 90), :public
      last_modified @@last_modified
    end

    numbers = params[:numbers].to_s.strip
    case
    when numbers =~ /\A\d+\z/
      r = Make10.calc(numbers)
      "#{r.sort.join("<br>\n")}<br>\n"
    when (not params[:numbers] and settings.environment == :development)
      erb :index
    else
      "Error: 入力は受け付けられませんでした。4桁の数字を入力してください。"
    end
  end
end
