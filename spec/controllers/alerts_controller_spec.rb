require 'rails_helper'

describe AlertsController, type: :controller do
  let(:valid_attributes) { { uuid: 'uuid', title: 'title', location: 'location', publish_at: '2018-12-11 02:24:00-0800' } }
  let(:invalid_attributes) { { uuid: nil, title: nil, location: nil, publish_at: nil } }
  let(:valid_session) { {} }

  describe "GET #index" do
    it "returns a success response" do
      Alert.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      alert = Alert.create! valid_attributes
      get :show, params: { id: alert.to_param }, session: valid_session
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
      alert = Alert.create! valid_attributes
      get :edit, params: { id: alert.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Alert" do
        expect { post :create, params: { alert: valid_attributes }, session: valid_session }.to change(Alert, :count).by(1)
      end

      it "redirects to the created alert" do
        post :create, params: { alert: valid_attributes }, session: valid_session
        expect(response).to redirect_to(Alert.last)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { alert: invalid_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { title: new_title } }
      let(:new_title) { 'new_title' }

      it "updates the requested alert" do
        alert = Alert.create! valid_attributes
        put :update, params: { id: alert.to_param, alert: new_attributes }, session: valid_session
        alert.reload
        expect(alert.title).to eq(new_title)
      end

      it "redirects to the alert" do
        alert = Alert.create! valid_attributes
        put :update, params: { id: alert.to_param, alert: valid_attributes }, session: valid_session
        expect(response).to redirect_to(alert)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        alert = Alert.create! valid_attributes
        put :update, params: { id: alert.to_param, alert: invalid_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested alert" do
      alert = Alert.create! valid_attributes
      expect { delete :destroy, params: { id: alert.to_param }, session: valid_session }.to change(Alert, :count).by(-1)
    end

    it "redirects to the alerts list" do
      alert = Alert.create! valid_attributes
      delete :destroy, params: { id: alert.to_param }, session: valid_session
      expect(response).to redirect_to(alerts_url)
    end
  end
end
