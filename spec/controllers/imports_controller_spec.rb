require 'rails_helper'

describe ImportsController, :type => :controller do
  let(:valid_attributes) { { import_type: 'recipients' } }
  let(:invalid_attributes) { { import_type: nil } }
  let(:valid_session) { {} }

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Import" do
        expect { post :create, params: { import: valid_attributes }, session: valid_session }.to change(Import, :count).by(1)
      end

      it "redirects to the created import" do
        post :create, params: { import: valid_attributes }, session: valid_session
        expect(response).to redirect_to('/')
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { import: invalid_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end
  end
end
