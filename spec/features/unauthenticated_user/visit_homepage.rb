require 'spec_helper'

feature 'unauthenticated user can visit the hompeage' do

  context "they visit the root_url" do

    it "displays the cover title" do
      visit root_url
      within(:css, 'div#title'){
        expect(page).to have_content("Socrada")
      }
    end

    it "displays the cover tagline" do
      visit root_url
      within(:css, 'div#tagline'){
        expect(page).to have_content("Social Relationship Data Visualised")
      }
    end

    it "displays the cover tagline" do
      visit root_url
      within(:css, 'div#product-description'){
        expect(page).to have_content("Socrada will help you visualise your social connections and strategize your networking")
      }
    end

    it "has a twitter login button" do
      visit root_url
      within(:css, 'div#central-login'){
        expect(page).to have_css('a#twitter-login')
      }
    end

    context "login through twitter with valid credentials" do
      before(:each) do
        visit 'http://lvh.me:3000/'
        mock_auth_hash
      end

      it "validates and redirects to the users profile" do
        click_link('twitter-login')
        expect(page).to have_content("Signed in")
      end
    end

    context "login through twitter with invalid credentials" do
      before(:each) do
        visit 'http://lvh.me:3000/'
        invalid_mock_auth_hash
      end

      it "invalidates and redirects to the users profile" do
        click_link('twitter-login')
        expect(current_path).to eq root_path
      end
    end

  end

end