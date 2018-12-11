require 'rails_helper'

describe Alert, type: :model do
  it { is_expected.to validate_presence_of(:uuid) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:location) }
end
