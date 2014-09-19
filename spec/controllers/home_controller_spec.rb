require 'spec_helper'

module FinePrint
  describe HomeController, :type => :controller do
    before(:each) do
      setup_controller_spec
    end

    it "won't get index unless authorized" do
      expect { get :index, :use_route => :fine_print }
             .to raise_error(ActionController::RoutingError)
      
      sign_in @user
      expect { get :index, :use_route => :fine_print }
             .to raise_error(ActionController::RoutingError)
    end
    
    it 'must get index if authorized' do
      sign_in @user
      @user.is_admin = true
      get :index, :use_route => :fine_print
      assert_response :success
    end
  end
end
