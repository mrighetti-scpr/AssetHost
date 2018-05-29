require 'spec_helper'

describe Api::AuthenticationController, type: :controller do

  before do
    @user = User.create username: "testuser", password: "12345"
  end

  describe 'POST create' do
    it "returns a token for a user given valid credentials" do
      post :create, params: api_request_params(username: "testuser", password: "12345")
      response.body.should match /jwt/
    end

    it 'returns 422 for incorrect credentials' do
      post :create, params: api_request_params(username: "wronguser", password: "wrongpass")
      response.status.should eq 422
    end
  end

end

