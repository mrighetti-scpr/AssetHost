require "resque/server"

Rails.application.routes.draw do
  mount_ember_assets :frontend, to: "/"
  match '/i/:aprint/:id-:style.:extension', :to => 'public#image', :constraints => { :id => /\d+/, :style => /[^\.]+/}, via: [:get, :post, :put, :patch, :delete], :as => :image
  match '/a', to: redirect('/'), via: :all, status: 302
  match '/a/chooser', to: redirect('/chooser'), via: :all # to support legacy Outpost client
  match '/a/:path', to: redirect('/'), via: :all, status: 302

  resque_constraint = ->(request) do
    user_id = request.session.to_hash["user_id"]

    if user_id && u = User.where(id: user_id).first
      u.is_admin?
    else
      false
    end
  end

  constraints resque_constraint do
    mount Resque::Server, at: '/resque'
  end

  resources :sessions, only: [:create, :destroy]
  get 'login'  => "sessions#new", as: :login
  match 'logout' => "sessions#destroy", as: :logout, via: [:get, :post, :put, :patch, :delete]

  namespace :api do
    resources :assets, :id => /\d+/, defaults: { format: :json } do
      member do
        get 'r/:context/(:scheme)', :action => :render
        get 'tag/:style', :action => :tag
      end
    end

    resources :outputs, defaults: { format: :json }
  end

  scope module: "admin" do
    resources :assets, :id => /\d+/ do
      collection do
        get '/search(/:q)', action: 'search', as: "search"
        get '/p/(:page)', action: 'index'
        get '/p/:page/:q', action: 'search'

        post :upload
        get :metadata
        put :metadata, :action => "update_metadata"
      end

      member do
        get :preview
        post :replace
      end
    end

    resources :outputs

    resources :api_users do
      put 'reset_token', on: :member
    end

    get 'chooser', :to => "home#chooser"

    root :to => "assets#index"
  end

  root :to => "public#home"
end
