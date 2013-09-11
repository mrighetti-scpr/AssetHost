Rails.application.routes.draw do
  resources :sessions, only: [:create, :destroy]
  get 'login'  => "sessions#new", as: :login
  match 'logout' => "sessions#destroy", as: :logout

  mount AssetHostCore::Engine => "/", as: :assethost
end
