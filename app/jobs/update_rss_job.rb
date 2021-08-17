require 'telegram/bot'
class UpdateRssJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Telegram::Bot::Client.run(ENV["TOKEN"]) do |bot|
      url = ENV["FEED"]
      open(url) do |rss|
        feed = RSS::Parser.parse(rss)
        feed.items.each do |item|
          unless Article.where(title: item.title).any? || Article.where(guid: item.guid.content).any?
            description = item.description.match(/<p>([^<]*)<\/p>/)
            unless description.nil?
              Article.create(title: item.title, guid: item.guid.content)

              Chat.all.each do |chat|
                begin
                  bot.api.send_message(chat_id: chat.chat_id, text: "<b>#{item.title}</b>\n#{description[1]}\n<a href='#{item.link}'>Leggi tutto l'articolo</a>", parse_mode: :HTML)
                rescue => e
                  bot.api.send_message(chat_id: ENV["FALLBACK"].to_i, text: "Errore #{e} nell'invio dell'articolo <b>#{item.title}</b> #{item.link} a #{chat.chat_id} - #{chat.username}", parse_mode: :HTML)
                end
              end
            else
              bot.api.send_message(chat_id: ENV["FALLBACK"].to_i, text: "Il bot non è riuscito a processare l'articolo <b>#{item.title}</b> #{item.link}", parse_mode: :HTML)
            end
          end
        end
      end
    end
  end
end