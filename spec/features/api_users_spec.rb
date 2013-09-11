require 'spec_helper'

describe 'Managing API Users' do
  before do
    @user = create :user, is_admin: true
    visit login_path
    fill_in 'username', with: @user.username
    fill_in 'password', with: "secret"
    click_button "Submit"
  end

  describe "creation" do
    context 'with valid attributes' do
      it "creates a user" do
        AssetHostCore::ApiUser.count.should eq 0

        visit assethost.new_a_api_user_path
        fill_in 'api_user_name', with: "KPCC"
        fill_in 'api_user_email', with: 'scprweb@scpr.org'
        #check 'api_user_is_active'
        click_button 'Save'

        api_user = AssetHostCore::ApiUser.last
        api_user.name.should eq "KPCC"
      end
    end

    context 'with invalid attributes' do
      it "rerenders the form and shows error messages" do
        visit assethost.new_a_api_user_path
        click_button 'Save'

        page.should have_css '.alert.alert-error'
        page.should have_content "can't be blank"
      end
    end
  end

  describe "updating" do
    before do
      @api_user = create :api_user
      visit assethost.edit_a_api_user_path(@api_user)
    end

    context 'with valid attributes' do
      it "updates the user" do
        fill_in 'api_user_name', with: "New Name"
        click_button 'Update'

        @api_user.reload
        @api_user.name.should eq 'New Name'
      end
    end

    context 'with invalid attributes' do
      it 'rerenders the form and shows error messages' do
        fill_in 'api_user_name', with: ""
        click_button "Update"

        page.should have_css '.alert.alert-error'
        page.should have_content "can't be blank"
      end
    end
  end

  describe 'deleting' do
    before do
      @api_user = create :api_user
      visit assethost.edit_a_api_user_path(@api_user)
    end

    it "deletes the record" do
      AssetHostCore::ApiUser.count.should eq 1
      click_link "Delete"
      AssetHostCore::ApiUser.count.should eq 0
    end
  end
end
