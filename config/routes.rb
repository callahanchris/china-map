Rails.application.routes.draw do
  root "main#index"
  get "/about", to: "static#about"
  resources :provinces
end
