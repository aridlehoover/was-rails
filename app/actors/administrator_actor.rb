class AdministratorActor < Actor
  manufacturable_default

  def to_sym
    :administrator
  end
end
