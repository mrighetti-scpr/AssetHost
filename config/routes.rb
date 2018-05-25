require "resque/server"

Rails.application.routes.draw do
  post '/api/authenticate'         => 'api/user_token#create'
  post '/api/authenticate/refresh' => 'api/user_token#update'
  
  match '/i/:aprint/:id-:style.:extension', to: 'public#image', constraints: { id: /[a-z0-9]+/, style: /[^\.]+/}, via: :all, as: :image

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
    resources :assets, id: /[a-z0-9]+/, defaults: { format: :json } do
      member do
        get 'r/:context/(:scheme)', :action => :render
        get 'tag/:style', :action => :tag
      end
    end

    resources :outputs, defaults: { format: :json }

  end

  mount_ember_app :frontend, to: "/"

end
