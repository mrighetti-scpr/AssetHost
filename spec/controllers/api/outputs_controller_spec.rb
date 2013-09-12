require 'spec_helper'

describe AssetHostCore::Api::OutputsController do
  before do
    @api_user = create :api_user
  end

  describe 'GET index' do
    before do
      @api_user.permissions.create(
        :resource => "AssetHostCore::Output",
        :ability  => "read"
      )
    end

    it 'returns all outputs' do
      output = create :output, code: "thumb"
      get :index, api_request_params
      assigns(:outputs).should eq [output]
      response.body.should match /thumb/
    end

    it 'returns 403 forbidden if user does not have output read permission' do
      @api_user.permissions.clear
      get :index, api_request_params
      response.status.should eq 403
    end
  end

  describe 'GET show' do
    before do
      @api_user.permissions.create(
        :resource => "AssetHostCore::Output",
        :ability  => "read"
      )
    end

    it 'returns the requested output' do
      output = create :output, code: "large"
      get :show, api_request_params(id: output.code)
      assigns(:output).should eq output
      response.body.should match /large/
    end

    it 'returns 403 forbidden if user does not have output read permission' do
      @api_user.permissions.clear
      get :show, api_request_params(id: "lol")
      response.status.should eq 403
    end
  end
end
