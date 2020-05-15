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
    browser   = prepare_browser_scraped_page
    free_list = create_free_list(browser)
    @games    = create_game_list(free_list)

    base_error if @games.empty?
  end

  def prepare_browser_scraped_page
    browser_args = %w[--headless --no-sandbox --disable-dev-shm-usage --disable-gpu]
    chrome_bin   = ENV["GOOGLE_CHROME_SHIM"]
    Watir.default_timeout = 5
    browser = Watir::Browser.new(:chrome, driver_path: chrome_bin, args: browser_args)
    browser.goto 'https://www.epicgames.com/store/pt-BR/free-games'
    sleep 1
    browser
  end

  def create_game_list(free_list)
    games = []
    free_list.each do |free|
      begin
        game = epic_dom_to_game(free)
        games << game if game.present?
      rescue => error
        scraper_logger(error, self.class)
      end
    end
    games
  end

  def scraper_logger(error, class_name)
    Rails.logger.error "Error at #{class_name}, message: #{error}"
  end

  def create_free_list(browser)
    free_list = []
    # https://www.w3schools.com/cssref/css_selectors.asp
    browser.divs(css: 'div[class^="CardGrid-card_"]').each do |game_dom|
      free_list << game_dom
    end
    free_list
  end

  def epic_dom_to_game(dom)
    game_name   = dom.span("data-testid": "offer-title-info-title").text
    game_image  = dom.imgs().first.src
    game_link   = dom.as.first.attributes[:href]
    game_date_from = dom.times().first.text
    game_date_to = dom.times().last.text

    [game_name, game_image, game_link, game_date_from, game_date_to]
  end

  def check_if_span_is_game(span_text)
    return true if span_text == 'GRÁTIS | Requer ADF'
    return true if span_text == 'EM BREVE'
    # return true if span_text == 'REQUER'
    # return true if span_text.include?('JOGO')
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
