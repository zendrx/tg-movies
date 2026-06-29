# bot.rb
require 'telegem'
require 'httparty'
require 'webrick'
require_relative 'start'
require_relative 'anime'
require_relative 'donghua'
require_relative 'account'
require_relative 'refer'
require_relative 'admin'
require_relative 'help'

bot = Telegem.new(ENV['BOT_TOKEN'])

Handlers::Start.register(bot)
Handlers::Anime.register(bot)
Handlers::Donghua.register(bot)
Handlers::Account.register(bot)
Handlers::Refer.register(bot)
Handlers::Admin.register(bot)
Handlers::Help.register(bot)

# Keep-alive web server
Thread.new do
  port = ENV['PORT'] || '3000'
  server = WEBrick::HTTPServer.new(
    Port: port,
    Logger: WEBrick::Log.new("/dev/null"),
    AccessLog: []
  )
  server.mount_proc '/' do |req, res|
    res.content_type = 'text/plain'
    res.body = 'AniStream Bot is running'
  end
  server.start
end

# Stupid cron to keep Render awake every 7 minutes
Thread.new do
  loop do
    sleep 420

    stupid_things = [
      "Me staring at the server logs wondering if it's alive",
      "Server just did a backflip. It was ugly.",
      "Pinged myself. I'm still here. Unfortunately.",
      "Counting sheep... server sheep... zzz...",
      "Just vibing. Server status: confused but online",
      "Sent a telegram to myself. It said 'help'.",
      "Checking if I'm awake. I am. Regrettably.",
      "Server doing pushups. It's not going well.",
      "Just breathed manually. You're welcome.",
      "Still here. Still sad. Still serving anime."
    ]

    puts "[#{Time.now}] #{stupid_things.sample}"

    begin
      HTTParty.get("https://#{ENV['RENDER_EXTERNAL_HOSTNAME'] || 'localhost'}/", timeout: 10)
    rescue => e
      puts "[#{Time.now}] Ping failed: #{e.message}. But we're still vibing."
    end
  end
end

bot.start_polling
