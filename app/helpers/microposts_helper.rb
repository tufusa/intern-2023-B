module MicropostsHelper
  URL_EXP = %r{(https?://[a-z0-9-]+(?:\.[a-z]+)+(?:/[a-zA-Z0-9-]*)*[a-zA-Z0-9\-_?=&#]*)}.freeze
  NICKNAME_EXP = /(@\w{,127})/.freeze

  LINK_EXP = Regexp.union(URL_EXP, NICKNAME_EXP).freeze

  # stringがリンクにすべき文字列であればtrueを返す
  def link?(string)
    return false unless LINK_EXP.match? string
    return false if NICKNAME_EXP.match?(string) && !get_user_in_following_followers(string)

    true
  end

  # stringのリンクのパス(`href`)を返す リンクにすべき文字列でなければnilを返す
  def generate_link_path(string)
    case string
    when ->(s) { url? s }
      return string
    when ->(s) { nickname? s }
      user_mentioned = get_user_in_following_followers(string)
      return "/users/#{user_mentioned.id}" if user_mentioned
    end

    nil
  end

  # stringがURLであればtrueを返す
  def url?(string)
    URL_EXP.match? string
  end

  # stringがnicknameであればtrueを返す
  def nickname?(string)
    NICKNAME_EXP.match? string
  end

  # フォロー, フォロワー内でnicknameが一致した場合はそのユーザを, 一致しなければnilを返す
  def get_user_in_following_followers(nickname)
    (user.following + user.followers).find { _1.nickname == nickname }
  end
end
