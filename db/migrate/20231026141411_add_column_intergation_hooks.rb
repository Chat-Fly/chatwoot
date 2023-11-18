class AddColumnIntergationHooks < ActiveRecord::Migration[7.0]
  def change
    add_column :integrations_hooks, :auto_reply, :boolean, default: false, null: false
  end
end
