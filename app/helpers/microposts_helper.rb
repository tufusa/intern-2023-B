module MicropostsHelper
  URL_EXP = %r{(https?://[a-z0-9-]+(?:\.[a-z]+)+(?:/[a-zA-Z0-9-]*)*[a-zA-Z0-9\-_?=&#]*)}.freeze

  # stringがURLであればtrueを返す
  def url?(string)
    URL_EXP.match? string
  end
end
