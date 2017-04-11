require 'spec_helper'

describe Admin::ApiUsersController, type: :controller do
  it 'allows admins' do
    user = create :user, is_admin: true
    controller.stub(:current_user) { user }

    get :index, params: admin_request_params

    response.should be_success
  end

  it 'does not allow non-admins' do
    user = create :user, is_admin: false
    controller.stub(:current_user) { user }

    get :index, params: admin_request_params

    response.should be_redirect
  end
end
