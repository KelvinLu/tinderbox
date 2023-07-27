class Tinderbox::Command::ListAccounts
  include Tinderbox::Command

  command 'list-accounts'

  calling_convention(0) do
    self.banner = 'Usage: list-accounts [options]'

    self.on('--details', 'Show more details') do
      options[:details] = true
    end
  end

  run do |options:, arguments:|
    output = Tinderbox::Calls.litcli_accounts_list

    Tinderbox::Account.from_output_list_accounts(output).each do |account|
      account.display(show_details: options[:details])
    end
  end
end
