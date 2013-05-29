require 'spec_helper'

describe AssetHostCore::Api::AssetsController do
  describe 'GET show' do
    it 'returns the asset as json' do
      asset = create :asset
      get :show, format: :json, id: asset.id, use_route: :assethost
      JSON.parse(response.body)["id"].should eq asset.id
    end
  end
end
