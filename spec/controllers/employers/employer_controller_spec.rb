require 'rails_helper'

RSpec.describe Employers::EmployerController, :type => :controller do
  let(:person) {FactoryGirl.create(:person, gender: "male", dob: "10/10/1974", ssn: "123456789" )}

  let(:valid_params) do
    {
      email: "test@test.com",
      password: "test1234",
      password_confirmation: "test1234",
      approved: true,
      person: person
    }
  end

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = User.create(**valid_params)
    sign_in user
  end

  describe "GET new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET my_account" do
    it "returns http success" do
      get :my_account, employer_id: 1
      expect(response).to have_http_status(:success)
    end
  end

end
