class Micropost < ApplicationRecord
  include MicropostsHelper

  belongs_to :user
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [500, 500]
  end
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image,   content_type: { in: %w[image/jpeg image/gif image/png],
                                      message: 'must be a valid image format' },
                      size: { less_than: 5.megabytes,
                              message: 'should be less than 5MB' }

  def content_url_splitted
    content.split(URL_EXP).map do |text|
      { value: text, is_url: url?(text) }
    end
  end
end
