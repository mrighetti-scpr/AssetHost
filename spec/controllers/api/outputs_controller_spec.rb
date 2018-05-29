require 'spec_helper'

describe Api::OutputsController, type: :controller do

  before(:each) do
    @user = create :user
    @user.permissions.clear
    @user.permissions << {
      resource: "outputs",
      ability:  "read"
    }
    @user.save
    token = Knock::AuthToken.new({payload: { sub: @user.id }}).token
    request.env["HTTP_AUTHORIZATION"] = "Bearer #{token}"
  end

  describe 'GET index' do
    it 'returns all outputs' do
      output = create :output, name: "thumb"
      get :index, params: api_request_params
      assigns(:outputs).should eq [output]
      response.body.should match /thumb/
    end

    it 'returns 403 forbidden if user does not have output read permission' do
      @user.permissions.clear
      @user.save
      get :index, params: api_request_params
      response.status.should eq 403
    end
  end

  describe 'GET show' do
    before(:each) do
      @user.permissions.clear
      @user.permissions << {
        "resource" => "outputs",
        "ability"  => "read"
      }
      @user.save
    end

    it 'returns the requested output' do
      output = create :output, name: "large"
      get :show, params: api_request_params(id: output.id.to_s)
      assigns(:output).should eq output
      response.body.should match /large/
    end

    it 'returns 403 forbidden if user does not have output read permission' do
      @user.permissions.clear
      @user.save
      get :show, params: api_request_params(id: "lol")
      response.status.should eq 403
    end
  end

  describe 'POST create' do
    before(:each) do
      @user.permissions.clear
      @user.permissions << {
        "resource" => "outputs",
        "ability"  => "write"
      }
      @user.save
    end
    it 'returns a 401 if no auth token is provided' do
      request.env["HTTP_AUTHORIZATION"] = ""
      post :create, params: api_request_params(name: "somename")
      response.status.should eq 401
    end

    it 'returns a 403 if user does not have output write permission' do
      @user.permissions.clear
      @user.save
      post :create, params: api_request_params(name: "somename")
      response.status.should eq 403
    end

    it 'responds with a 422 if error in output creation' do
      post :create, params: api_request_params(name: nil)
      response.status.should eq 422
    end

  end


end

