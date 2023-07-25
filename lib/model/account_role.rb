module Tinderbox::AccountRole
  def get_permissions(role)
    Tinderbox::Configuration::AccountRole.get_permissions(role)
  end
end
