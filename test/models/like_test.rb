require "test_helper"

class LikeTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    @micropost = @user.microposts.build(content: 'Lorem ipsum').tap(&:save)
    @like = Like.new(user_id: @user.id, micropost_id: @micropost.id)
  end

  test 'should be valid' do
    assert @like.valid?
  end

  test 'should require a user_id' do
    @like.user_id = nil
    assert_not @like.valid?
  end

  test 'should require a micropost_id' do
    @like.micropost_id = nil
    assert_not @like.valid?
  end

  test 'default count should equal 1' do
    assert_equal @like.count, 1
  end
end
