require 'rails_helper'

describe AlertsController, type: :controller do
  let(:valid_attributes) { { uuid: 'uuid', title: 'title', location: 'location', publish_at: '2018-12-11 02:24:00-0800' } }
  let(:invalid_attributes) { { uuid: '', title: '', location: '', publish_at: '' } }
  let(:valid_session) { {} }

  before do
    allow(WASLogger).to receive(:json)
  end

  describe "GET #index" do
    let(:params) { { page: '1' } }

    before do
      Alert.create! valid_attributes
      get :index, params: params, session: valid_session
    end

    it 'logs success' do
      expect(WASLogger).to have_received(:json).with(action: :find_alerts, status: :succeeded, params: params)
    end

    it "returns a success response" do
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    let!(:alert) { Alert.create! valid_attributes }
    let(:params) { { id: alert.to_param } }

    before do
      get :show, params: params, session: valid_session
    end

    it 'logs success' do
      expect(WASLogger).to have_received(:json).with(action: :find_alert, status: :succeeded, params: params)
    end

    it "returns a success response" do
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
      let(:params) { { alert: valid_attributes } }

      it "creates a new Alert" do
        expect { post :create, params: params, session: valid_session }.to change(Alert, :count).by(1)
      end

      it "redirects to the created alert" do
        post :create, params: params, session: valid_session
        expect(response).to redirect_to(Alert.last)
      end
    end

    context "with invalid params" do
      let(:params) { { alert: invalid_attributes } }

      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: params, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe "PUT #update" do
    let!(:alert) { Alert.create! valid_attributes }

    context "with valid params" do
      let(:params) { { id: alert.to_param, alert: new_attributes } }
      let(:new_attributes) { { title: new_title } }
      let(:new_title) { 'new_title' }

      it "updates the requested alert" do
        expect { put :update, params: params, session: valid_session }.to change { alert.reload.title }.to(new_title)
      end

      it 'logs success' do
        put :update, params: params, session: valid_session

        expect(WASLogger).to have_received(:json).with(action: :update_alert, status: :succeeded, params: params)
      end

      it "redirects to the alert" do
        put :update, params: params, session: valid_session

        expect(response).to redirect_to(alert)
      end
    end

    context "with invalid params" do
      let(:params) { { id: alert.to_param, alert: invalid_attributes } }

      it 'logs failure' do
        put :update, params: params, session: valid_session

        expect(WASLogger).to have_received(:json).with(action: :update_alert, status: :failed, params: params)
      end

      it "returns a success response (i.e. to display the 'edit' template)" do
        put :update, params: params, session: valid_session

        expect(response).to be_successful
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:alert) { Alert.create! valid_attributes }
    let(:params) { { id: alert.to_param } }

    it "destroys the requested alert" do
      expect { delete :destroy, params: params, session: valid_session }.to change(Alert, :count).by(-1)
    end

    it 'logs success' do
      delete :destroy, params: params, session: valid_session

      expect(WASLogger).to have_received(:json).with(action: :destroy_alert, status: :succeeded, params: params)
    end

    it "redirects to the alerts list" do
      delete :destroy, params: params, session: valid_session

      expect(response).to redirect_to(alerts_url)
    end
  end
end
