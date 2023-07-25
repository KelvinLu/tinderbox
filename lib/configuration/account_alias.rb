module Tinderbox::Configuration::AccountAlias
  include Tinderbox::Configuration

  file 'aliases.yaml'

  def self.get_alias(account_id)
    account_aliases.select { |_, v| v == account_id }.first&.first
  end

  def self.get_id(account_alias)
    account_aliases.fetch(account_alias, nil)
  end

  def self.account_aliases
    return @account_aliases unless @account_aliases.nil?

    @account_aliases =
      if configuration.nil?
        {}
      else
        raise 'expected a map for configuration' unless configuration.is_a?(Hash)

        unless [*configuration.keys, *configuration.values].all? { |item| item.is_a?(String) }
          raise 'keys and values must be strings'
        end

        configuration
      end
  end
end
