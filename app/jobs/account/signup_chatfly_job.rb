class Account::SignupChatflyJob < ApplicationJob
  queue_as :default

  def perform(user, _account)
    Accounts::ChatflyBaseService.new(user, _account).create_account_chatfly
  end
end
