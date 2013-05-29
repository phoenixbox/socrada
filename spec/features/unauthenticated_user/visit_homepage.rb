require 'spec_helper'

feature 'unauthenticated user can visit the hompeage' do

  context "unauthenticated user visits the root_url" do
    it "root url is the homepage" do
      visit root_url
      expect(current_path).to eq home_url
    end

    xit "displays the cover copy" do
      visit root_url
      expect(page).to have_content("Social Relationship Data Visualised")
    end

    xit "has a twitter login button" do
    end

    xit "twitter login button authenticates and redirects to the users profile" do
    end
  end

end