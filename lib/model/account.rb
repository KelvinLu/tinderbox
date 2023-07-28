require_relative 'account_alias'

class Tinderbox::Account
  attr_reader *%i[
    id
    account_alias

    initial_balance
    current_balance

    last_update
    expiration_date

    invoices
    payments
  ]

  def initialize(params, account_alias: nil)
    @id               = params.fetch('id')
    @account_alias    = account_alias

    @initial_balance  = params.fetch('initial_balance').to_i
    @current_balance  = params.fetch('current_balance').to_i

    @last_update      = Time.at(params.fetch('last_update').to_i)
    @expiration_date  =
      if ((expiration_date = params.fetch('expiration_date').to_i) > 0)
        Time.at(expiration_date)
      else
        false
      end

    @invoices         = params.fetch('invoices')
    @payments         = params.fetch('payments')
  end

  def self.from_output_list_accounts(output)
    output.fetch('accounts').map do |account|
      self.new(
        account,
        account_alias: Tinderbox::AccountAlias.get_alias(account.fetch('id'))
      )
    end
  end

  def display(show_details: false)
    puts "#{'Account:'.bold} #{id.blue.bold.underline}"
    puts "#{'Alias:'} #{account_alias.cyan.bold}" unless account_alias.nil?
    puts "#{'Last update:'} #{last_update.to_s.italic}"

    if show_details
      puts
      puts "#{'Expiration date:'} #{expiration_date}"
      puts
      puts "#{'Initial balance:'} #{initial_balance} satoshi"
      puts "#{'Current balance:'.bold} #{current_balance.to_s.brown.bold} satoshi"
      puts
      display_net_invoices_and_payments
    end

    puts
    puts '...'
    puts
  end

  def display_net_invoices_and_payments
    payments_total = payments.filter { |p| p.fetch('state') == 'SUCCEEDED' }.sum { |p| p.fetch('full_amount').to_i }

    puts "#{'Invoice count:'} #{invoices.count.to_s.cyan}"
    puts "#{'Payment count:'} #{payments.count.to_s.magenta} (#{payments_total.to_s.magenta} satoshi)"
  end

  def display_list_invoices(items)
    items.each do |item|
      payment_hash = item.fetch('hash')

      puts payment_hash
    end
  end

  def display_list_payments(items)
    items.each do |item|
      state = item.fetch('state')
      amount = item.fetch('full_amount')
      payment_hash = item.fetch('hash')

      state =
        case state
        when 'SUCCEEDED'
          ('%-16.16s' % state).green
        when 'FAILED'
          ('%-16.16s' % state).red
        when 'IN_FLIGHT'
          ('%-16.16s' % state).brown
        else
          ('%-16.16s' % state)
        end

      puts "#{state} | #{('%16.16s' % amount).cyan.bold} satoshi | #{payment_hash}"
    end
  end
end
