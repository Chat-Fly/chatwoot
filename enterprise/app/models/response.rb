# == Schema Information
#
# Table name: responses
#
#  id                   :bigint           not null, primary key
#  answer               :text             not null
#  embedding            :string
#  question             :string           not null
#  status               :integer          default("pending")
#  vector               :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  account_id           :bigint           not null
#  response_document_id :bigint
#  response_source_id   :bigint           not null
#
# Indexes
#
#  index_responses_on_account_id            (account_id)
#  index_responses_on_embedding             (embedding)
#  index_responses_on_response_document_id  (response_document_id)
#  index_responses_on_response_source_id    (response_source_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (response_source_id => response_sources.id)
#
class Response < ApplicationRecord
  belongs_to :response_document, optional: true
  belongs_to :account
  belongs_to :response_source
  has_neighbors :embedding, normalize: true

  before_save :update_response_embedding
  before_validation :ensure_account

  enum status: { pending: 0, active: 1 }

  def self.search(query)
    embedding = Openai::EmbeddingsService.new.get_embedding(query)
    nearest_neighbors(:embedding, embedding, distance: 'cosine').first(5)
  end

  private

  def ensure_account
    self.account = response_source.account
  end

  def update_response_embedding
    self.embedding = Openai::EmbeddingsService.new.get_embedding("#{question}: #{answer}")
  end
end
