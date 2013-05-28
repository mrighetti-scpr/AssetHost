require 'spec_helper'

describe AssetHostCore::Api::UtilityController do
  describe '#as_asset' do
    before :each do
      FakeWeb.register_uri(:get, %r{imgur\.com}, 
        body: load_image('fry.png'), content_type: "image/png")
    end

    it 'returns a bad request if URL is not present' do
      get :as_asset, format: :json, use_route: :assethost
      response.status.should eq 400
    end

    it 'creates an asset if the URL is valid' do
      get :as_asset, format: :json, url: "http://imgur.com/someimg.png", use_route: :assethost
      json = JSON.parse(response.body)
      asset = AssetHostCore::Asset.find(json["id"])

      asset.should be_present
    end

    it 'appends to the notes if present' do
      get :as_asset, format: :json, url: "http://imgur.com/someimg.png", note: "Imported via Tests", use_route: :assethost
      json = JSON.parse(response.body)
      asset = AssetHostCore::Asset.find(json["id"])

      asset.notes.should match /Imported via Tests/
    end

    it 'hides the asset if is_hidden is present' do
      get :as_asset, format: :json, url: "http://imgur.com/someimg.png", hidden: 1, use_route: :assethost
      json = JSON.parse(response.body)
      asset = AssetHostCore::Asset.find(json["id"])

      asset.is_hidden.should eq true
    end

    it 'sets attributes that are present' do
      get :as_asset, format: :json, url: "http://imgur.com/someimg.png", 
        caption: "Test Image", owner: "Test Owner", title: "Test Title", use_route: :assethost
      json = JSON.parse(response.body)
      asset = AssetHostCore::Asset.find(json["id"])

      asset.caption.should eq "Test Image"
      asset.owner.should eq "Test Owner"
      asset.title.should eq "Test Title"
    end
  end

  it 'responds with a 404 and returns asset if no asset is found' do
    get :as_asset, format: :json, url: "nogoodbro", use_route: :assethost
    response.status.should eq 404
    response.body["error"].should be_present
  end
end
