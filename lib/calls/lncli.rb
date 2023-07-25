module Tinderbox::Calls
  def self.lncli(*cmdline)
    call('lncli', *Tinderbox::Configuration::Lncli.global_options, *cmdline)
  end

  def self.lncli_bakemacaroon(filepath:, permissions:)
    lncli(*%w[bakemacaroon], '--save_to', filepath, *permissions)
  end

  def self.lncli_constrainmacaroon(old_filepath:, new_filepath:, account_id:)
    lncli(*%w[constrainmacaroon], '--custom_caveat_name', 'account', '--custom_caveat_condition', account_id, old_filepath, new_filepath)
  end
end
