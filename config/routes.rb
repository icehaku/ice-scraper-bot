Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "scraper#index"

  get '/steam_free_to_get', to: 'scraper#steam_free_to_get'
  get '/epic_free_to_get', to: 'scraper#epic_free_to_get'
  get '/epic_next_week', to: 'scraper#epic_next_week'
end
