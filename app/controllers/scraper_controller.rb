class ScraperController < ApplicationController
  def index; end

  before_action :set_default_response_format, except: [:index]

  # https://www.botreetechnologies.com/blog/how-to-do-web-scraping-of-a-static-or-dynamic-website-with-ruby-on-rails
  # doc = Nokogiri::HTML(open('https://steamdb.info/sales/'))

  def steam_free_to_get
    require 'open-uri'

    page = Nokogiri::HTML(URI.open('https://steamdb.info/sales/?min_discount=95').read)
    page_tbody = page.css("table.table-sales")&.css("tbody")&.first
    @games = []
    itens = page_tbody.css("tr")

    itens.each do |item|
      game_id = item.css("td")[1].css("a").attribute("href").value.split("/").last
      game_image = "https://steamcdn-a.akamaihd.net/steam/apps//capsule_sm_120.jpg"
      game_name   = item.css("td")[2].css("a").first.text
      game_link   = "https://store.steampowered.com/app/#{game_id}/"
      @games << [game_image, game_name, game_link]
    end
  end

  protected

  def set_default_response_format
    request.format = :json
  end
end
