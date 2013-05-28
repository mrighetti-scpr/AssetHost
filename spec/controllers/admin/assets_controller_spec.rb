require 'spec_helper'

describe AssetHostCore::Admin::AssetsController do
  render_views

  describe "GET metadata" do
    it 'gets all the assets in the ID param' do
      assets = create_list :asset, 2
      get :metadata, ids: assets.map(&:id).join(","), use_route: :assethost
      assigns(:assets).should eq assets
    end
  end

  describe 'PUT update_metadata' do
    it 'finds the passed-in assets and updates them' do
      assets = create_list :asset, 2

      put :update_metadata, assets: { assets.first.id => { title: "New Title 1" }, assets.last.id => { title: "New Title 2"} }, use_route: :assethost

      assets.first.reload.title.should eq "New Title 1"
      assets.last.reload.title.should eq "New Title 2"
    end
  end
end
