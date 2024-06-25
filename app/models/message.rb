class Message < ApplicationRecord
  validates :sender, presence: true
  validates :content, presence: true
end
