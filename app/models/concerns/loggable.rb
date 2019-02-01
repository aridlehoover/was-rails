module Loggable
  extend ActiveSupport::Concern

  module ClassMethods
    def create(attributes)
      super(attributes).tap do |alert|
        if alert.persisted?
          WASLogger.json(action: :"#{__method__}_#{name.downcase}", status: :succeeded, params: attributes)
        else
          WASLogger.json(action: :"#{__method__}_#{name.downcase}", status: :failed, params: attributes)
        end
      end
    end
  end

  def update(attributes)
    super(attributes).tap do |updated|
      if updated
        WASLogger.json(action: :"#{__method__}_#{self.class.name.downcase}", status: :succeeded, params: attributes)
      else
        WASLogger.json(action: :"#{__method__}_#{self.class.name.downcase}", status: :failed, params: attributes)
      end
    end
  end

  def destroy
    super.tap do |alert|
      WASLogger.json(action: :"#{__method__}_#{self.class.name.downcase}", status: :succeeded, params: alert.attributes)
    end
  end
end
