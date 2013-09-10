require 'spec_helper'

describe AssetHostCore::Api::AssetsController do
  request_params = {
    :use_routes   => :assethost,
    :format       => :json
  }

  describe 'GET show' do
    it 'returns the asset as json' do
      asset = create :asset
      get :show, request_params(id: asset.id)
      JSON.parse(response.body)["id"].should eq asset.id
    end
  end

  describe 'POST create' do
    before :each do
      FakeWeb.register_uri(:get, %r{imgur\.com}, 
        body: load_image('fry.png'), content_type: "image/png")
    end

    it 'returns a bad request if URL is not present' do
      post :create, request_params
      response.status.should eq 400
    end

    it 'responds with a 404 and returns asset if no asset is found' do
      post :create, request_params(url: "nogoodbro")
      response.status.should eq 404
      response.body["error"].should be_present
    end

    it 'creates an asset if the URL is valid' do
      post :create, request_params(url: "http://imgur.com/someimg.png")
      json = JSON.parse(response.body)
      asset = AssetHostCore::Asset.find(json["id"])

      asset.should be_present
    end

    it 'appends to the notes if present' do
      post :create, request_params(url: "http://imgur.com/someimg.png", note: "Imported via Tests")
      json = JSON.parse(response.body)
      asset = AssetHostCore::Asset.find(json["id"])

      asset.notes.should match /Imported via Tests/
    end

    it 'hides the asset if is_hidden is present' do
      post :create, request_params(url: "http://imgur.com/someimg.png", hidden: 1)
      json = JSON.parse(response.body)
      asset = AssetHostCore::Asset.find(json["id"])

      asset.is_hidden.should eq true
    end

    it 'sets attributes that are present' do
      post :create, request_params(
        :url        => "http://imgur.com/someimg.png",
        :caption    => "Test Image",
        :owner      => "Test Owner",
        :title      => "Test Title"
      )

      json = JSON.parse(response.body)
      asset = AssetHostCore::Asset.find(json["id"])

      asset.caption.should eq "Test Image"
      asset.owner.should eq "Test Owner"
      asset.title.should eq "Test Title"
    end
  end
end
