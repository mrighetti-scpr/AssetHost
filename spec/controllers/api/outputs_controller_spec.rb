require 'spec_helper'

describe Api::OutputsController, type: :controller do
  before do
    @user = create :user
  end

  before(:each) do
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

    # it 'returns 403 forbidden if user does not have output read permission' do
    #   @api_user.permissions.clear
    #   get :index, params: api_request_params
    #   response.status.should eq 403
    # end
  end

  describe 'GET show' do
    # before do
    #   @api_user.permissions.create(
    #     :resource => "Output",
    #     :ability  => "read"
    #   )
    # end

    it 'returns the requested output' do
      output = create :output, name: "large"
      get :show, params: api_request_params(id: output.id.to_s)
      assigns(:output).should eq output
      response.body.should match /large/
    end

    # it 'returns 403 forbidden if user does not have output read permission' do
    #   @api_user.permissions.clear
    #   get :show, params: api_request_params(id: "lol")
    #   response.status.should eq 403
    # end
  end
end

