class Tinderbox::Command::TotalBalance
  include Tinderbox::Command

  command 'total-balance'

  calling_convention(0) do
    self.banner = 'Usage: total-balance [options]'
  end

  run do |options:, arguments:|
    output = Tinderbox::Calls.litcli_accounts_list

    total = Tinderbox::Account.from_output_list_accounts(output).sum(&:current_balance)

    puts "#{'Total balance:'.bold} #{total.to_s.brown.underline} satoshi"
  end
end
