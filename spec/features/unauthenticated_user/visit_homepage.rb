require 'spec_helper'

feature 'unauthenticated user can visit the hompeage' do

  context "unauthenticated user visits the root_url" do

    it "displays the cover title" do
      visit root_url
      within(:css, 'div#title'){
        expect(page).to have_content("Socrada")
      }
    end

    it "has a twitter login button" do
      visit root_url
      within(:css, 'div#central-login'){
        expect(page).to have_css('a#twitter-login')
      }
    end

    xit "twitter login button authenticates and redirects to the users profile" do
    end
  end

end