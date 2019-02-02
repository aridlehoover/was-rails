shared_examples 'a model with logging' do
  let(:class_name) { described_class.name.downcase }

  before { allow(WASLogger).to receive(:json) }

  describe '.create' do
    subject(:create) { described_class.create(attributes) }

    let(:action) { :"create_#{class_name}" }

    before { create }

    context 'when the model is persisted' do
      it 'logs success' do
        expect(WASLogger).to have_received(:json).with(action: action, status: :succeeded, params: attributes)
      end
    end

    context 'when the model is NOT persisted' do
      let(:attributes) { {} }

      it 'logs failure' do
        expect(WASLogger).to have_received(:json).with(action: action, status: :failed, params: attributes)
      end
    end
  end

  describe '.update' do
    subject(:update) { model.update(updated_attributes) }

    let(:action) { :"update_#{class_name}" }
    let!(:model) { described_class.create(attributes) }
    let(:updated_attributes) { { updated_at: Time.current } }

    before { update }

    context 'when the model is persisted' do
      it 'logs success' do
        expect(WASLogger).to have_received(:json).with(action: action, status: :succeeded, params: updated_attributes)
      end
    end

    context 'when the model is NOT persisted' do
      let(:updated_attributes) { invalid_attributes }

      it 'logs failure' do
        expect(WASLogger).to have_received(:json).with(action: action, status: :failed, params: updated_attributes)
      end
    end
  end

  describe '.destroy' do
    subject(:destroy) { model.destroy }

    let(:action) { :"destroy_#{class_name}" }
    let!(:model) { described_class.create(attributes) }

    before { destroy }

    context 'when the alert is destroyed' do
      it 'logs success' do
        expect(WASLogger).to have_received(:json).with(action: action, status: :succeeded, params: model.attributes)
      end
    end
  end
end
