require 'spec_helper'

describe AssetHostCore::Admin::AssetsController do
  render_views

  before do
    @user = create :user
    controller.stub(:current_user) { @user }
  end

  describe "GET metadata" do
    it 'gets all the assets in the ID param' do
      assets = create_list :asset, 2
      get :metadata, admin_request_params(ids: assets.map(&:id).join(","))
      assigns(:assets).should eq assets
    end
  end

  describe 'PUT update_metadata' do
    it 'finds the passed-in assets and updates them' do
      assets = create_list :asset, 2

      put :update_metadata, admin_request_params(
        :assets => {
          assets.first.id => { title: "New Title 1" },
          assets.last.id => { title: "New Title 2" }
        }
      )

      assets.first.reload.title.should eq "New Title 1"
      assets.last.reload.title.should eq "New Title 2"
    end
  end
end
