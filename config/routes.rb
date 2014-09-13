Rails.application.routes.draw do
  root "main#index"
  resources :regions, only: [:index]
end
