module Tinderbox::Calls
  def self.litcli(*cmdline)
    call('litcli', *Tinderbox::Configuration::Litcli.global_options, *cmdline)
  end

  def self.litcli_accounts_list
    json_output(litcli(*%w[accounts list]))
  end

  def self.litcli_accounts_create(balance:, expiration_date: -1)
    cmdline = [*%w[accounts create], '--balance', balance.to_s]
    cmdline = [*cmdline, '--expiration_date', expiration_date.to_i.to_s] unless expiration_date.nil?

    json_output(litcli(*cmdline))
  end

  def self.litcli_accounts_update(id:, balance: -1, expiration_date: -1)
    cmdline = [*%w[accounts update], '--id', id]
    cmdline = [*cmdline, '--new_balance', balance.to_s] unless balance.nil?
    cmdline = [*cmdline, '--new_expiration_date', expiration_date.to_i.to_s] unless expiration_date.nil?

    json_output(litcli(*cmdline))
  end

  def self.litcli_accounts_remove(id:)
    litcli(*%w[accounts remove], '--id', id)
  end
end
