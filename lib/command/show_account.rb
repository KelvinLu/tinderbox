class Tinderbox::Command::ShowAccount
  include Tinderbox::Command

  command 'show-account'

  calling_convention(1..) do
    self.banner = 'Usage: show-account [options] <account id | account alias> ...'
  end

  run do |options:, arguments:|
    accounts =
      Tinderbox::Account.from_output_list_accounts(
        Tinderbox::Calls.litcli_accounts_list
      )

    arguments.each do |id_or_alias|
      id = Tinderbox::AccountAlias.get_id(id_or_alias) || id_or_alias

      matching_accounts =
        accounts.select { |account| account.instance_variable_get(:@id) == id }

      case matching_accounts.count
      when 0
        Tinderbox.log.error("No account found for #{id_or_alias}")
        next
      when 1
        matching_accounts.first.display(show_details: true)
      else
        Tinderbox.log.error("Multiple account matches for #{id_or_alias}")
        raise 'encountered unexpected output'
      end
    end
  end
end
