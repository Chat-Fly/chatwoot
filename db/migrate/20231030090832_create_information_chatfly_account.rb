class CreateInformationChatflyAccount < ActiveRecord::Migration[7.0]
  def change
    create_table :information_chatfly_accounts do |t|
      t.string :uuid, null: false
      t.string :email, null: false
      t.references :user
      t.boolean :is_active, default: false, null: false
      t.string :token
      t.string :token_type
      t.string :bot_id

      t.timestamps
    end
  end
end
