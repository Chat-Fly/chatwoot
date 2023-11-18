# == Schema Information
#
# Table name: information_chatfly_accounts
#
#  id         :bigint           not null, primary key
#  email      :string           not null
#  is_active  :boolean          default(FALSE), not null
#  token      :string
#  token_type :string
#  uuid       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  bot_id     :string
#  user_id    :bigint
#
# Indexes
#
#  index_information_chatfly_accounts_on_user_id  (user_id)
#
class InformationChatflyAccount < ApplicationRecord
  belongs_to :user
end
