require 'spec_helper'

feature 'Logging in', :js do
  def visit_login
    visit '/login'
  end

  def expect_identity_from_auth_hash(identity)
    expect(identity.provider).to eq(mock_omniauth_hash[:provider])
    expect(identity.provider_uid).to eq(mock_omniauth_hash[:uid])
  end

  def expect_user_created
    user = User.find_by(slug: get_current_uid)
    expect(user.name).to eq(mock_omniauth_hash[:user_info][:name])
    expect(user.image_url).to eq(mock_omniauth_hash[:user_info][:image])
    expect(user.identity.provider).to eq(mock_omniauth_hash[:provider])
    expect(user.identity.provider_uid).to eq(mock_omniauth_hash[:uid])
  end

  scenario 'Logging in without an existing account' do
    expect(User.count).to eq(0)
    expect(Identity.count).to eq(0)
    visit_login
    click_link('Test provider')
    # wait for oauth popup to open and close
    wait_for_oauth_popup
    expect(Identity.count).to eq(1)
    expect_identity_from_auth_hash(Identity.first)
    # user only gets created after confirm profile
    expect(User.count).to eq(0)
    # redirects to profile for confirmation
    expect(current_path).to eq('/profile')
    # make sure new user intro text is showing
    expect(page).to have_content('Bienvenue')
    within('form') do
      expect(find('[name=name]').value).to  eq(mock_omniauth_hash[:info][:name])
      expect(find('[name=email]').value).to eq(mock_omniauth_hash[:info][:email])
    end
    click_on('Enregistrer')
    expect(current_path).to eq('/gate')
    expect(Identity.count).to eq(1)
    expect(User.count).to eq(1)
  end

  # scenario 'Logging in with an existing account' do
  #   user = create(:user)
  #   visit_login
  #   expect_logged_out
  #   click_link 'Test provider'
  #   expect(Identity.count).to eq(1)
  #   expect(User.count).to eq(0)
  #   expect_logged_in
  # end
end

# describe 'authentication', :js do
#   it 'should not display logged in UI items'
# end
