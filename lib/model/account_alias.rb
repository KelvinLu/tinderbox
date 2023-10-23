module Tinderbox::AccountAlias
  def self.get_alias(account_id)
    Tinderbox::Configuration::AccountAlias.get_alias(account_id)
  end

  def self.get_id(account_alias)
    Tinderbox::Configuration::AccountAlias.get_id(account_alias)
  end

  def self.add_alias(account_id, account_alias)
    File.write(Tinderbox::Configuration::AccountAlias.filepath, "\n'#{account_alias}': '#{account_id}'", mode: 'a+')
  end

  def self.reload
    Tinderbox::Configuration::AccountAlias.reload
  end
end
