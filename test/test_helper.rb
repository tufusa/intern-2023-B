ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # 指定のワーカー数でテストを並列実行する
  parallelize(workers: :number_of_processors)

  # test/fixtures/*.ymlにあるすべてのfixtureをセットアップする
  fixtures :all

  # テストユーザーがログイン中の場合にtrueを返す
  def is_logged_in?
    !session[:user_id].nil?
  end

  # テストユーザーとしてログインする
  def log_in_as(user)
    session[:user_id] = user.id
  end
end

module AddQueryParametersToPath
  # Railsが自動生成したパスメソッドをクエリパラメータを含むようにオーバーライドする
  def add_query_parameters_to(*path_methods)
    path_with_query_parameters = lambda do |*values|
      "#{super(*values)}?locale=#{I18n.locale}"
    end

    path_methods.each { define_method _1, path_with_query_parameters }
  end
end

class ActionDispatch::IntegrationTest
  extend AddQueryParametersToPath

  path_url_methods = %w[root login logout user help about contact users].flat_map { %I[#{_1}_path #{_1}_url] }
  add_query_parameters_to *path_url_methods

  # テストユーザーとしてログインする
  def log_in_as(user, password: 'password', remember_me: '1')
    post login_path, params: { session: { email: user.email,
                                          password: password,
                                          remember_me: remember_me } }
  end
end
