class CreateTableResponseSources < ActiveRecord::Migration[7.0]
  def change
    create_table :response_sources do |t|
      t.string :name, null: false
      t.string :source_link
      t.string :source_model_type
      t.integer :source_type, default: 0, null: false
      t.references :account, null: false
      t.bigint :source_model_id

      t.timestamps
    end

    add_index :response_sources, [:source_model_type, :source_model_id]
  end
end
