require 'telegram/bot'
class UpdateRssJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Telegram::Bot::Client.run(ENV["TOKEN"]) do |bot|

      wikinews = MediawikiApi::Client.new "https://it.wikinews.org/w/api.php"
      articles = wikinews.query(:prop => :extracts, :generator => :categorymembers, :gcmtitle => "Categoria:Pubblicati", gcmlimit: 1000, gsort: :timestamp, gcmdir: :newer)["query"]["pages"]

      articles.each do |article|
        next if Article.exists?(guid: article["pageid"], title: article["title"])
        
        Article.create(title: article["title"], guid: article["pageid"])

        Chat.all.each do |chat|
          begin
            bot.api.send_message(chat_id: chat.chat_id, text: "<b>#{article["title"]}</b>\n#{article["extract"]}...\n<a href='https://it.wikinews.org/wiki/#{CGI.escape(article["title"])}'>Leggi tutto l'articolo</a>", parse_mode: :HTML)
          rescue => e
            bot.api.send_message(chat_id: ENV["FALLBACK"].to_i, text: "Errore #{e} nell'invio dell'articolo <b>#{article["title"]}</b> https://it.wikinews.org/wiki/#{CGI.escape(article["title"])} a #{chat.chat_id} - #{chat.username}", parse_mode: :HTML)
          end
        end 
      end
    end
  end
end