require 'spec_helper'

describe 'Managing API Users' do
  before do
    @user = create :user
    visit login_path
    fill_in 'username', with: @user.username
    fill_in 'password', with: "secret"
    click_button "Submit"
  end

  describe "creation" do
    it "creates a user with valid attributes" do
      visit assethost.new_a_api_user_path
    end
  end
end
