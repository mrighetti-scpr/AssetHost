require "spec_helper"

describe Api::AssetsController, type: :controller do

  before(:each) do
    @user = create :user
    token = JWT.encode({ sub: @user.id }, Rails.application.config.secret_key_base, "HS256")
    request.env["HTTP_AUTHORIZATION"] = "Bearer #{token}"
  end

  describe "GET show" do

    it "returns the asset as json" do
      asset = create :asset
      get :show, params: api_request_params(id: asset.id) 
      JSON.parse(response.body)["id"].should eq asset.id.to_s
    end

    it 'renders an unauthorized error if there is no auth token provided' do
      request.env["HTTP_AUTHORIZATION"] = ""
      get :show, params: api_request_params(id: 1)
      response.status.should eq 401
    end

    it 'renders a forbidden error if user does not have read permission for assets' do
      @user.permissions.clear
      @user.save
      get :show, params: api_request_params(id: 1)
      response.status.should eq 403
    end
  end

  describe 'POST create' do
    before do
      [:head, :get].each do |m|
        FakeWeb.register_uri(m, %r{imgur\.com},
          body: load_image('fry.png'), content_type: "image/png")
      end
    end

    it 'returns a bad request if URL is not present' do
      post :create, params: api_request_params
      response.status.should eq 400
    end

    it 'returns a 401 if no auth token is provided' do
      request.env["HTTP_AUTHORIZATION"] = ""
      post :create, params: api_request_params(url: "http://imgur.com/someimg.png")
      response.status.should eq 401
    end

    it 'returns a 403 if user does not have asset write permission' do
      @user.permissions.clear
      @user.save
      post :create, params: api_request_params(url: "http://url.com/img.png")
      response.status.should eq 403
    end

    it 'responds with a 400 if error in asset uploading' do
      post :create, params: api_request_params(url: "nogoodbro")
      response.status.should eq 400
      # response.body["error"].should be_present
    end

    it 'creates an asset if the URL is valid' do
      post :create, params: api_request_params(url: "http://imgur.com/someimg.png")
      json  = JSON.parse(response.body)
      asset = Asset.find(json["id"])
      asset.should be_present
    end

    it 'returns a bad request if the URL is invalid' do
      post :create, params: {url: "<iframe src='totalnonsense'></iframe>"}
      response.status.should eq 400
    end

    it 'appends to the notes if present' do
      post :create, params: api_request_params(url: "http://imgur.com/someimg.png", note: "Imported via Tests")
      json = JSON.parse(response.body)
      asset = Asset.find(json["id"])

      asset.notes.should match /Imported via Tests/
    end

#     it 'hides the asset if is_hidden is present' do
#       post :create, params: api_request_params(url: "http://imgur.com/someimg.png", hidden: 1)
#       json = JSON.parse(response.body)
#       asset = Asset.find(json["id"])

#       asset.is_hidden.should eq true
#     end

    it 'sets attributes that are present' do
      post :create, params: api_request_params(
        :url        => "http://imgur.com/someimg.png",
        :caption    => "Test Image",
        :owner      => "Test Owner",
        :title      => "Test Title"
      )

      json = JSON.parse(response.body)
      asset = Asset.find(json["id"])

      asset.caption.should eq "Test Image"
      asset.owner.should eq "Test Owner"
      asset.title.should eq "Test Title"
    end
  end

  describe 'PUT update' do

    it 'updates the asset' do
      asset = create :asset
      put :update, params: api_request_params(id: asset.id, asset: { title: "New Title" })
      asset.reload.title.should eq "New Title"
    end

    it 'returns a 401 if no auth token is provided' do
      request.env["HTTP_AUTHORIZATION"] = ""
      put :update, params: api_request_params(id: 0).except(:auth_token)
      response.status.should eq 401
    end

    it 'returns a 403 if user does not have asset write permission' do
      @user.permissions.clear
      @user.save
      put :update, params: api_request_params(id: 0)
      response.status.should eq 403
    end
  end
end
