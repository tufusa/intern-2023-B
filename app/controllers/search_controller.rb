class SearchController < ApplicationController
  before_action :logged_in_user, only: [:search]

  def index
    words = params[:"search-words"]&.split(/\p{white-space}/)&.map { Micropost.sanitize_sql_like _1 } || []
    @microposts = search_microposts(words).paginate(page: params[:page])
    @locale = params[:locale]
  end

  def search_microposts(words)
    tags,        words = words.partition { _1 =~ /\A#.+\Z/ }
    minus_words, words = words.partition { _1 =~ /\A-.+\Z/ }
    froms,       words = words.partition { _1 =~ /\Afrom:.+\Z/ }
    tags       .each { _1.delete_prefix! '#' }
    minus_words.each { _1.delete_prefix! '-' }
    froms      .each { _1.delete_prefix! 'from:' }

    microposts = Micropost.includes(:user)

    # 普通のAND検索
    microposts = words.inject(microposts) do |posts, word|
      posts.where('content LIKE :word', word: "%#{word}%")
    end

    # タグ 完全一致
    microposts = tags.inject(microposts) do |posts, tag|
      posts.where('content REGEXP :tag', tag: "(\\A|\\s)##{tag}(\\s|\\Z)")
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
