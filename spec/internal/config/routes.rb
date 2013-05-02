Rails.application.routes.draw do
  mount AssetHostCore::Engine => "/", as: :assethost
end
