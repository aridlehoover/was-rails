require 'rails_helper'

describe AlertsController, type: :controller do
  let(:valid_attributes) { { uuid: 'uuid', title: 'title', location: 'location', publish_at: '2018-12-11 02:24:00-0800' } }
  let(:invalid_attributes) { { uuid: '', title: '', location: '', publish_at: '' } }
  let(:valid_session) { {} }

  before do
    allow(ExternalLogger).to receive(:log_and_increment)
  end

  describe "GET #index" do
    let(:params) { { page: '1' } }

    before do
      Alert.create! valid_attributes
      get :index, params: params, session: valid_session
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

      it "logs and increments a create alert action" do
        post :create, params: params, session: valid_session
        expect(ExternalLogger).to have_received(:log_and_increment).with(
          action: :create_alert,
          actor: :administrator,
          status: :succeeded,
          params: params[:alert].stringify_keys
        )
      end

      it 'Notifies the user that the record was created' do
        post :create, params: { alert: valid_attributes }, session: valid_session
        expect(controller).to set_flash[:notice].to('Alert was successfully created.')
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

      it "redirects to the alert" do
        put :update, params: params, session: valid_session

        expect(response).to redirect_to(alert)
      end

      it "logs and increments a update alert action" do
        post :update, params: params, session: valid_session
        expect(ExternalLogger).to have_received(:log_and_increment).with(
          action: :update_alert,
          actor: :administrator,
          status: :succeeded,
          params: params[:alert].stringify_keys
        )
      end

      it 'Notifies the user that the record was updated' do
        put :update, params: { id: alert.to_param, alert: new_attributes }, session: valid_session
        expect(controller).to set_flash[:notice].to('Alert was successfully updated.')
      end
    end

    context "with invalid params" do
      let(:params) { { id: alert.to_param, alert: invalid_attributes } }

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

    it "redirects to the alerts list" do
      delete :destroy, params: params, session: valid_session

      expect(response).to redirect_to(alerts_url)
    end

    it "logs and increments a destroy alert action" do
      delete :destroy, params: params, session: valid_session

      expect(ExternalLogger).to have_received(:log_and_increment).with(
        action: :destroy_alert,
        actor: :administrator,
        status: :succeeded,
        params: params
      )
    end

    it 'Notifies the user that the record was deleted' do
      delete :destroy, params: { id: alert.to_param }, session: valid_session
      expect(controller).to set_flash[:notice].to('Alert was successfully destroyed.')
    end
  end
end
