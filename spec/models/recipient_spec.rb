require 'rails_helper'

describe Recipient, type: :model do
  it { is_expected.to validate_presence_of(:channel) }
  it { is_expected.to validate_presence_of(:address) }
end
