module Tinderbox::Configuration::AccountRole
  include Tinderbox::Configuration

  file 'roles.yaml'

  def self.get_permissions(role_name)
    account_roles.fetch(role_name)
  end

  def self.account_roles
    return @account_roles unless @account_roles.nil?

    @account_roles =
      if configuration.nil?
        {}
      else
        raise 'expected a map for configuration' unless configuration.is_a?(Hash)

        unless configuration.keys.all? { |role| role.is_a?(String) }
          raise 'role names must be strings'
        end

        unless configuration.values.all? { |permissions| permissions.is_a?(Enumerable) && permissions.all? { |permission| permission.is_a?(String) } }
          raise 'permissions must be lists of strings'
        end

        configuration
      end
  end
end
