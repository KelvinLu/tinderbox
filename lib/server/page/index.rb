class Tinderbox::Page::Index < OpenStruct
  def initialize
    Tinderbox::AccountAlias.reload

    accounts = Tinderbox::Account.from_output_list_accounts(
      Tinderbox::Calls.litcli_accounts_list
    )

    total_balance = accounts.sum(&:current_balance)
    total_initial_balance = accounts.sum(&:initial_balance)

    invoices = accounts.map(&:invoices).flatten
    payments = accounts.map(&:payments).flatten

    payments_total = payments.filter { |p| p.fetch('state') == 'SUCCEEDED' }.sum { |p| p.fetch('full_amount').to_i }

    super(
      accounts: accounts,

      total_balance: total_balance,
      total_initial_balance: total_initial_balance,

      invoices: invoices,
      payments: payments,

      payments_total: payments_total,
    )
  end
end
