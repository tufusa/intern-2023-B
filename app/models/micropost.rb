class Micropost < ApplicationRecord
  include MicropostsHelper

  belongs_to :user
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [300, 300]
  end
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image,   content_type: { in: %w[image/jpeg image/gif image/png],
                                      message: 'must be a valid image format' },
                      size: { less_than: 5.megabytes,
                              message: 'should be less than 5MB' }

  def content_splitted
    content.split(LINK_EXP).map do |string|
      { value: string, is_link: link?(string), to: generate_link_path(string) }
    end
  end

  def content_html
    content_splitted.map do |fragment|
      value = fragment[:value]
      is_link = fragment[:is_link]
      to = fragment[:to]
      is_link ? %(<a href="#{to}">#{value}</a>) : value
    end.join
  end
end
