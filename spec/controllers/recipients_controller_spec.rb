require 'rails_helper'

describe RecipientsController, type: :controller do
  let(:valid_attributes) { { channel: 'channel', address: 'address' } }
  let(:invalid_attributes) { { channel: nil, address: nil } }
  let(:valid_session) { {} }

  describe "GET #index" do
    it "returns a success response" do
      Recipient.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      recipient = Recipient.create! valid_attributes
      get :show, params: { id: recipient.to_param }, session: valid_session
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
      recipient = Recipient.create! valid_attributes
      get :edit, params: { id: recipient.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Recipient" do
        expect { post :create, params: { recipient: valid_attributes }, session: valid_session }.to change(Recipient, :count).by(1)
      end

      it "redirects to the created recipient" do
        post :create, params: { recipient: valid_attributes }, session: valid_session
        expect(response).to redirect_to(Recipient.last)
      end

      it 'Notifies the user that the record was created' do
        post :create, params: { recipient: valid_attributes }, session: valid_session
        expect(controller).to set_flash[:notice].to('Recipient was successfully created.')
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { recipient: invalid_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe "PUT #update" do
    let!(:recipient) { Recipient.create! valid_attributes }

    context "with valid params" do
      let(:new_attributes) { { address: new_address } }
      let(:new_address) { 'new_address' }

      it "updates the requested recipient" do
        put :update, params: { id: recipient.to_param, recipient: new_attributes }, session: valid_session
        recipient.reload
        expect(recipient.address).to eq(new_address)
      end

      it "redirects to the recipient" do
        put :update, params: { id: recipient.to_param, recipient: new_attributes }, session: valid_session
        expect(response).to redirect_to(recipient)
      end

      it 'Notifies the user that the record was updated' do
        put :update, params: { id: recipient.to_param, recipient: new_attributes }, session: valid_session
        expect(controller).to set_flash[:notice].to('Recipient was successfully updated.')
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        put :update, params: { id: recipient.to_param, recipient: invalid_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:recipient) { Recipient.create! valid_attributes }

    it "destroys the requested recipient" do
      expect { delete :destroy, params: { id: recipient.to_param }, session: valid_session }.to change(Recipient, :count).by(-1)
    end

    it "redirects to the recipients list" do
      delete :destroy, params: { id: recipient.to_param }, session: valid_session
      expect(response).to redirect_to(recipients_url)
    end

    it 'Notifies the user that the record was deleted' do
      delete :destroy, params: { id: recipient.to_param }, session: valid_session
      expect(controller).to set_flash[:notice].to('Recipient was successfully destroyed.')
    end
  end
end
