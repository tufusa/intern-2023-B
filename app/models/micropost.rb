class Micropost < ApplicationRecord
  include MicropostsHelper

  has_many :likes, dependent: :destroy
  has_many :liked_users, class_name: "User",
                         through: :likes,
                         source: :user,
                         dependent: :destroy do
                           def with_count
                             select(:count, arel_table[Arel.star])
                           end
                         end

  belongs_to :user
  has_many_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [300, 300]
  end
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image,   content_type: { in: %w[image/jpeg image/gif image/png],
                                      message: 'must be a valid image format' },
                      size: { less_than: 5.megabytes,
                              message: 'should be less than 5MB' }

  validate :validate_number_of_files 
  FILE_NUMBER_LIMIT = 4
  def validate_number_of_files
    return if image.length <= FILE_NUMBER_LIMIT
    errors.add(:image, "Image selection is limited to #{FILE_NUMBER_LIMIT} images")
  end

  def content_splitted
    content.split(LINK_EXP).map do |string|
      { value: string, is_link: link?(string), to: link_generator(string) }
    end
  end

  def content_html(context)
    content_splitted.map do |fragment|
      value = fragment[:value]
      is_link = fragment[:is_link]
      to = fragment[:to]
      is_link ? context.link_to(value, to.call(context), target: '_self') : value
    end.join
  end
end
