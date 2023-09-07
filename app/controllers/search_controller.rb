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
    words = @keywords&.split(/\p{white-space}/)&.map { Micropost.sanitize_sql_like _1 } || []
    @microposts = search_microposts(words).paginate(page: params[:page])
    @locale = params[:locale]
  end

  def search_microposts(words)
    tags,        words = words.partition { _1 =~ /\A#.+\Z/ }
    minus_words, words = words.partition { _1 =~ /\A-.+\Z/ }
    froms,       words = words.partition { _1 =~ /\Afrom:.+\Z/ }
    tags.each { _1.delete_prefix! '#' }
    minus_words.each { _1.delete_prefix! '-' }
    froms.each { _1.delete_prefix! 'from:' }

    microposts = Micropost.includes(:user)

    # 普通のAND検索
    microposts = words.inject(microposts) do |posts, word|
      posts.where('content LIKE :word', word: "%#{word}%")
    end

    # タグ 完全一致
    microposts = tags.inject(microposts) do |posts, tag|
      posts.where('content REGEXP :tag', tag: "(\\A|#{SPACES.join('|')})##{tag}(#{SPACES.join('|')}|\\Z)")
    end

    # マイナス検索
    microposts = minus_words.inject(microposts) do |posts, minus_word|
      posts.where('content NOT LIKE :minus', minus: "%#{minus_word}%")
    end

    # fromのOR検索
    microposts = microposts.where('user.nickname': froms) if froms.any?

    microposts
  end
end
