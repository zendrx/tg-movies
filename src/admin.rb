# admin.rb
module Handlers
module Admin
 CODES_FILE = "codes.txt"

 def self.register(bot)
   admin_id = ENV["ADMIN_ID"]&.to_i

   bot.command('addcode') do |ctx|
     unless ctx.from&.id == admin_id
       ctx.reply("❌ Admin only.", parse_mode: "Markdown")
       next
     end

     code = ctx.command_args&.strip

     if code.nil? || code.empty?
       ctx.reply("🔑 *Add Access Code*\n\nUsage: `/addcode <code>`", parse_mode: "Markdown")
       next
     end

     File.open(CODES_FILE, "w") do |f|
       f.puts(code)
     end

     ctx.reply("✅ Code `#{code}` added. Old codes replaced.", parse_mode: "Markdown")
   end
 end
end
end
