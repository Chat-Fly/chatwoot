class CreateResponses < ActiveRecord::Migration[7.0]
  def change
    create_table :responses do |t|
      t.text :answer, null: false
      t.string :embedding, :vector
      t.string :question, null: false
      t.integer :status, default: 0
      t.timestamps
      t.references :account, null: false, foreign_key: true
      t.references :response_document
      t.references :response_source, null: false, foreign_key: true
    end

    add_index :responses, :embedding
  end
end
