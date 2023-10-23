class Tinderbox::Page::RemoveAccount < OpenStruct
  def initialize(account_id:)
    super(
      account_id: account_id,
    )
  end
end
