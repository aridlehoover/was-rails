class Actor
  extend Industrialist::Manufacturable

  def to_sym
    self.class.name.gsub('Actor','').downcase.to_sym
  end
end