module MicropostsHelper
  URL_EXP = %r{(https?://[a-z0-9-]+(?:\.[a-zA-Z0-9-]+)+(?:/[a-zA-Z0-9-]*)*[a-zA-Z0-9\-_?=&#]*)}.freeze
  NICKNAME_EXP = /(@\w{,127})/.freeze
  HASHTAG_EXP = /(?<=\A|\p{white-space})(#\p{^white-space}+)(?=\p{white-space}|\Z)/.freeze

  LINK_EXP = Regexp.union(URL_EXP, NICKNAME_EXP, HASHTAG_EXP).freeze

  # stringがリンクにすべき文字列であればtrueを返す
  def link?(string)
    url?(string) || hashtag?(string) || (nickname?(string) && get_user_in_following_followers(string))
  end

  # stringのリンク先オブジェクトをview_contextを引数に取って生成するラムダを返す リンクにすべき文字列でなければnilを返す
  def link_generator(string)
    case string
    when ->(s) { url? s }
      ->(_context) { string }
    when ->(s) { nickname? s }
      ->(_context) { get_user_in_following_followers(string) }
    when ->(s) { hashtag? s }
      ->(context) { context.search_path(keywords: string) }
    end
  end

  # stringがURLであればtrueを返す
  def url?(string)
    URL_EXP.match? string
  end

  # stringがnicknameであればtrueを返す
  def nickname?(string)
    NICKNAME_EXP.match? string
  end

  def hashtag?(string)
    HASHTAG_EXP.match? string
  end

  # フォロー, フォロワー内でnicknameが一致した場合はそのユーザを, 一致しなければnilを返す
  def get_user_in_following_followers(nickname)
    (user.following + user.followers).find { _1.nickname == nickname }
  end
end
