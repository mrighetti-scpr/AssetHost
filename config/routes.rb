AssetHostCore::Engine.routes.draw do
  match '/i/:aprint/:id-:style.:extension', :to => 'public#image', :as => :image, :constraints => { :id => /\d+/, :style => /[^\.]+/}


  namespace :api do
    resources :assets, :id => /\d+/ do
      member do
        get 'r/:context/(:scheme)', :action => :render
        get 'tag/:style', :action => :tag
      end
    end 
    
    resources :outputs

    match 'as_asset', :to => "utility#as_asset", :as => "as_asset"
  end



  namespace :a, :module => "admin" do 
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
    
    match 'chooser', :to => "home#chooser", :as => 'chooser'
    
    root :to => "home#index"
  end

  
  root :to => "public#home"
end
