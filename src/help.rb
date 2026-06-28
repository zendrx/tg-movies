# help.rb
module Handlers
module Help
  def self.register(bot)
    bot.command('help') do |ctx|
      text = <<~MSG
        🎬 *TGMovies Bot Commands*

        /start — Welcome message
        /search <name> — Search for a movie
        /watch <name> <code> — Watch a movie
        /account — Your account info
        /help — Show this help message

        🔑 *How to get a code:*
        Join the group and get daily codes there.
      MSG

      ctx.reply(text, parse_mode: "Markdown")
    end
  end
end
end
