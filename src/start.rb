# start.rb
module Handlers
module Start
 def self.register(bot)
   bot.command('start') do |ctx|
     welcome_text = <<~TEXT
       🎬 *Welcome to TGMovies Bot!*

       Watch movies & series *ad-free* — no interruptions, no ads.

       👇 Join our group for daily content updates:
     TEXT

     keyboard = Telegem.inline do
       row url("🍿 Join TGMovies", "https://t.me/tgtomovies2")
     end

     ctx.photo(File.open("img/welcome.jpg"), caption: welcome_text, parse_mode: "Markdown", reply_markup: keyboard)
   end
 end
end
end
