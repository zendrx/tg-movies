# search.rb
require 'httparty'

module Handlers
 module Search
   API_BASE = "https://api.dailymotion.com"

   def self.register(bot)
     bot.command('search') do |ctx|
       query = ctx.command_args&.strip

       if query.nil? || query.empty?
         ctx.reply("🎬 *Search for a movie or series*\n\nUsage: `/search Movie Name`", parse_mode: "Markdown")
         next
       end

       ctx.typing

       results = search_videos(query)

       if results.empty?
         ctx.reply("❌ No results found for *#{query}*\n\nTry a different title.", parse_mode: "Markdown")
         next
       end

       results.each do |video|
         message = <<~MSG
           ✅ *#{video[:title]}*

           ⭐ Rating: #{video[:rating] || 'N/A'}
           👁 Views: #{format_views(video[:views])}
           ⏱ Duration: #{format_duration(video[:duration])}
         MSG

         ctx.reply(message, parse_mode: "Markdown")
       end
     end
   end

   private

   def self.search_videos(query)
     response = HTTParty.get("#{API_BASE}/videos", query: {
       search: query,
       limit: 5,
       fields: "id,title,duration,views_total,rating"
     })

     return [] unless response.success?

     data = response.parsed_response
     return [] unless data["list"]

     data["list"].map do |v|
       {
         id: v["id"],
         title: v["title"],
         duration: v["duration"],
         views: v["views_total"],
         rating: v["rating"]
       }
     end
   rescue => e
     []
   end

   def self.format_views(num)
     return "N/A" unless num
     num >= 1_000_000 ? "#{(num / 1_000_000.0).round(1)}M" : num >= 1_000 ? "#{(num / 1_000.0).round(1)}K" : num.to_s
   end

   def self.format_duration(seconds)
     return "N/A" unless seconds
     min, sec = seconds.divmod(60)
     hr, min = min.divmod(60)
     hr > 0 ? "#{hr}h #{min}m" : "#{min}m #{sec}s"
   end
 end
end
