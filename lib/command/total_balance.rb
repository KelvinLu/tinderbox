class Tinderbox::Command::TotalBalance
  include Tinderbox::Command

  command 'total-balance'

  calling_convention(0) do
    self.banner = 'Usage: total-balance [options]'

    self.on('--details', 'Include other summary details') do
      options[:details] = true
    end
  end

  run do |options:, arguments:|
    output = Tinderbox::Calls.litcli_accounts_list

    accounts = Tinderbox::Account.from_output_list_accounts(output)
    total_balance = accounts.sum(&:current_balance)

    puts "#{'Total balance:'.bold} #{total_balance.to_s.brown.bold} satoshi"

    if options[:details]
      total_initial_balance = accounts.sum(&:initial_balance)
      puts "#{'Total initial balance:'.italic} #{total_initial_balance.to_s.brown.underline} satoshi"
      puts

      invoices = accounts.map(&:invoices).flatten
      payments = accounts.map(&:payments).flatten

      payments_total = payments.filter { |p| p.fetch('state') == 'SUCCEEDED' }.sum { |p| p.fetch('full_amount').to_i }

      puts "#{'Invoice count:'} #{invoices.count.to_s.cyan}"
      puts "#{'Payment count:'} #{payments.count.to_s.magenta} (#{payments_total.to_s.magenta} satoshi)"
    end
  end
end
