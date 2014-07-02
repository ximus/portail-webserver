require 'spec_helper'

feature 'Logging in', :js do
  def visit_login
    visit '/login'
  end

  def expect_logged_out
    expect(page).to_not have_selector('#logged-in-user-badge')
    expect(get_current_uid).to be_blank
  end

  def expect_logged_in
    expect(page).to_not have_selector('#logged-in-user-badge')
    expect(get_current_uid).to_not be_blank
  end

  def get_current_uid
    script = "angular.element('[ng-app]').scope().currentUser['id']"
    page.evaluate_script(script)
  end

  def expect_user_created
    user = User.find_by(slug: get_current_uid)
    expect(user.name).to eq(mock_omniauth_hash[:user_info][:name])
    expect(user.image_url).to eq(mock_omniauth_hash[:user_info][:image])
    expect(user.identity.provider).to eq(mock_omniauth_hash[:provider])
    expect(user.identity.provider_uid).to eq(mock_omniauth_hash[:uid])
  end

  scenario 'Logging in without an existing account' do
    user = build(:user)
    visit_login
    click_link 'Test provider'
    omniauth_hash

  end

  scenario 'Logging in with an existing account' do
    user = create(:user)
    visit_login
    expect_logged_out
    click_link 'Test provider'
    expect(User.count).to eq(1)
    expect_logged_in
  end
end

describe 'authentication', :js do
  it 'should not display logged in UI items'
end