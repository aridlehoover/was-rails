require 'rails_helper'

describe Import, type: :model do
  subject(:import) { described_class.new(import_type: import_type) }

  let(:import_type) { 'recipients' }

  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:import_type).in_array(Import::VALID_IMPORT_TYPES) }
  end

  describe 'after create' do
    before do
      allow(ImportRecipientsJob).to receive(:perform_later)

      import.save
    end

    it 'notifies the receipient of the latest published alert' do
      expect(ImportRecipientsJob).to have_received(:perform_later).with(import)
    end
  end
end
