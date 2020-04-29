class ScraperController < ApplicationController
  def index; end

  before_action :set_default_response_format, except: [:index]
  before_action :set_open_uri, except: [:index]

  def steam_free_to_get
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

    base_error if @games.empty?
  end

  def epic_free_to_get
    browser_args = %w[--headless --no-sandbox --disable-dev-shm-usage --disable-gpu]
    chrome_bin   = ENV["GOOGLE_CHROME_SHIM"]

    browser = Watir::Browser.new(:chrome, driver_path: chrome_bin, args: browser_args)
    browser.goto 'https://www.epicgames.com/store/pt-BR/free-games'
    sleep 1

    frees = []
    browser.spans().each do |span|
      frees << span if span.text.include?("GRÁTIS") or span.text.include?("BREVE")
    end

    @games = []
    frees.each do |free|
      element = free.parent.parent
      game_name   = element.span("data-testid": "offer-title-info-title").text
      game_image  = element.imgs().first.src
      game_link   = element.parent.parent.attributes[:href]
      game_date_from = element.times().first.text
      game_date_to = element.times().last.text

      @games << [game_name, game_image, game_link, game_date_from, game_date_to]
    end

    base_error if @games.empty?
  end

  def base_error
    render json: { errors: ["Sorry master Ice, I failed. -_-"] }
  end

  protected

  def set_default_response_format
    request.format = :json
  end

  def set_open_uri
    require 'open-uri'
  end
end
