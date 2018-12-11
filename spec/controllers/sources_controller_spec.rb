require 'rails_helper'

describe SourcesController, type: :controller do
  let(:valid_attributes) { { channel: 'channel', address: 'address' } }
  let(:invalid_attributes) { { channel: nil, address: nil } }
  let(:valid_session) { {} }

  describe "GET #index" do
    it "returns a success response" do
      Source.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      source = Source.create! valid_attributes
      get :show, params: { id: source.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      source = Source.create! valid_attributes
      get :edit, params: { id: source.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Source" do
        expect { post :create, params: { source: valid_attributes }, session: valid_session }.to change(Source, :count).by(1)
      end

      it "redirects to the created source" do
        post :create, params: { source: valid_attributes }, session: valid_session
        expect(response).to redirect_to(Source.last)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { source: invalid_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { address: new_address } }
      let(:new_address) { 'new_address' }

      it "updates the requested source" do
        source = Source.create! valid_attributes
        put :update, params: { id: source.to_param, source: new_attributes }, session: valid_session
        source.reload
        expect(source.address).to eq(new_address)
      end

      it "redirects to the source" do
        source = Source.create! valid_attributes
        put :update, params: { id: source.to_param, source: valid_attributes }, session: valid_session
        expect(response).to redirect_to(source)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        source = Source.create! valid_attributes
        put :update, params: { id: source.to_param, source: invalid_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested source" do
      source = Source.create! valid_attributes
      expect { delete :destroy, params: { id: source.to_param }, session: valid_session }.to change(Source, :count).by(-1)
    end

    it "redirects to the sources list" do
      source = Source.create! valid_attributes
      delete :destroy, params: { id: source.to_param }, session: valid_session
      expect(response).to redirect_to(sources_url)
    end
  end
end
