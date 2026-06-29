# bot.rb
require 'telegem'
require 'httparty'
require 'webrick'
require_relative 'start'
require_relative 'search'
require_relative 'watch'
require_relative 'account'
require_relative 'admin'
require_relative 'help'

bot = Telegem.new(ENV['BOT_TOKEN'])

Handlers::Start.register(bot)
Handlers::Search.register(bot)
Handlers::Watch.register(bot)
Handlers::Account.register(bot)
Handlers::Admin.register(bot)
Handlers::Help.register(bot)

Thread.new do
port = ENV['PORT'] || '3000'
server = WEBrick::HTTPServer.new(Port: port, Logger: WEBrick::Log.new("/dev/null"), AccessLog: [])
server.mount_proc '/' do |req, res|
 res.content_type = 'text/plain'
 res.body = 'TGMovies Bot is running'
end
server.start
end

bot.start_polling
