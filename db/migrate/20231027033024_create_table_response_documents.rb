class CreateTableResponseDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :response_documents do |t|
      t.text :content
      t.string :document_link
      t.string :document_type
      t.bigint :account_id, null: false
      t.bigint :document_id
      t.references :response_source, null: false

      t.timestamps
    end

    add_index :response_documents, [:document_type, :document_id]
  end
end
