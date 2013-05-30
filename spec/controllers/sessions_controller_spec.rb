require 'spec_helper'

describe SessionsController do
    describe 'DELETE#destroy' do
    context 'when user is logged in' do
      before :each do
        @user = FactoryGirl.create(:user)
        get :destroy, {}, {:user_id => @user.id}
      end
      it "destroys user session" do
        session[:user_id].should be_nil
      end
    end
  end
end
