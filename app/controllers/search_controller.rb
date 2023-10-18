class SearchController < ApplicationController
  before_action :logged_in_user, only: [:search]
  SPACES = [
    "\s",
    "\xE1\x9A\x80", "\xE2\x80\x82", "\xE2\x80\x83", "\xE2\x80\x82", "\xE2\x80\x83",
    "\xE2\x80\x84", "\xE2\x80\x85", "\xE2\x80\x86", "\xE2\x80\x87", "\xE2\x80\x88",
    "\xE2\x80\x89", "\xE2\x80\x8A", "\xE2\x80\xAF", "\xE2\x81\x9F", "\xE3\x80\x80"
  ].freeze

  def index
    @keywords = params[:keywords]
    @sort_options = [
      [I18n.t(:recently_posted), :recently_posted],
      [I18n.t(:least_recently_posted), :least_recently_posted],
      [I18n.t(:most_likes), :most_likes],
      [I18n.t(:fewest_likes), :fewest_likes]
    ]

    sort_by = params[:sort_by]&.to_sym || @sort_options[0][1]
    words = @keywords&.split(/\p{white-space}/)&.map { Micropost.sanitize_sql_like _1 } || []

    @microposts = search_microposts(words, sort_by).paginate(page: params[:page])
    @locale = params[:locale]
  end

  def search_microposts(words, sort_by)
    tags,        words = words.partition { _1 =~ /\A#.+\Z/ }
    minus_words, words = words.partition { _1 =~ /\A-.+\Z/ }
    froms,       words = words.partition { _1 =~ /\Afrom:.+\Z/ }
    tags.each { _1.delete_prefix! '#' }
    minus_words.each { _1.delete_prefix! '-' }
    froms.each { _1.delete_prefix! 'from:' }

    microposts = Micropost.includes(:user)
                          .select('microposts.*, SUM(likes.count) AS like_count')
                          .left_joins(:likes)
                          .group(:id)

    # 普通のAND検索
    microposts = words.inject(microposts) do |posts, word|
      posts.where('content LIKE :word', word: "%#{word}%")
    end

    regexp = Rails.env.production? ? '~' : 'REGEXP'
    # タグ 完全一致
    microposts = tags.inject(microposts) do |posts, tag|
      posts.where(
        'content :regexp :tag',
        regexp: regexp,
        tag: "(\\A|#{SPACES.join('|')})##{tag}(#{SPACES.join('|')}|\\Z)"
      )
    end

    # マイナス検索
    microposts = minus_words.inject(microposts) do |posts, minus_word|
      posts.where('content NOT LIKE :minus', minus: "%#{minus_word}%")
    end

    # fromのOR検索
    microposts = microposts.where('user.nickname': froms) if froms.any?

    # ソート
    case sort_by
    when :recently_posted
      microposts.reorder created_at: :desc
    when :least_recently_posted
      microposts.reorder created_at: :asc
    when :most_likes
      microposts.reorder like_count: :desc, created_at: :desc
    when :fewest_likes
      microposts.reorder like_count: :asc, created_at: :desc
    else
      microposts
    end
  end
end
