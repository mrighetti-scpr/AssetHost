require "resque/server"

Rails.application.routes.draw do
  post '/api/authenticate' => 'api/user_token#create'
  root to: "application#home"
  mount_ember_assets :frontend, to: "/"
  match '/i/:aprint/:id-:style.:extension', to: 'public#image', constraints: { id: /\d+/, style: /[^\.]+/}, via: :all, as: :image

  resque_constraint = ->(request) do
    # 🚨 New authentication system needs to be applied here.
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

  namespace :api do
    resources :assets, :id => /\d+/, defaults: { format: :json } do
      member do
        get 'r/:context/(:scheme)', :action => :render
        get 'tag/:style', :action => :tag
      end
    end

    resources :outputs, defaults: { format: :json }

    resources :sessions, defaults: { format: :json }
  end

end
