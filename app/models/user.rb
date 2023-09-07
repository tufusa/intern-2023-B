class User < ApplicationRecord
  has_many :microposts, dependent: :destroy do
                          def without_fixed
                            where(is_fixed: false)
                          end
                        end
  has_many :active_relationships,  class_name:  "Relationship",
                                   foreign_key: "follower_id",
                                   dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :following, through: :active_relationships,  source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  has_many :likes, dependent: :destroy
  has_many :liked_microposts, class_name: "Micropost",
                              through: :likes,
                              source: :micropost,
                              dependent: :destroy do
                                def with_count
                                  select(:count, arel_table[Arel.star])
                                end
                              end

  attr_accessor :remember_token, :activation_token, :reset_token

  before_save   :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  VALID_NICKNAME_REGEX = /\A@\w+\Z/.freeze
  validates :nickname, presence: true, length: { maximum: 128 },
                       format: { with: VALID_NICKNAME_REGEX },
                       uniqueness: true


  enum prefecture:{
  登録しない: "登録しない",
  北海道: "北海道",
  青森県: "青森県",
  岩手県: "岩手県",
  宮城県: "宮城県",
  秋田県: "秋田県",
  山形県: "山形県",
  福島県: "福島県",
  茨城県: "茨城県",
  栃木県: "栃木県",
  群馬県: "群馬県",
  埼玉県: "埼玉県",
  千葉県: "千葉県",
  東京都: "東京都",
  神奈川県: "神奈川県",
  新潟県: "新潟県",
  富山県: "富山県",
  石川県: "石川県",
  福井県: "福井県",
  山梨県: "山梨県",
  長野県: "長野県",
  岐阜県: "岐阜県",
  静岡県: "静岡県",
  愛知県: "愛知県",
  三重県: "三重県",
  滋賀県: "滋賀県",
  京都府: "京都府",
  大阪府: "大阪府",
  兵庫県: "兵庫県",
  奈良県: "奈良県",
  和歌山県: "和歌山県",
  鳥取県: "鳥取県",
  島根県: "島根県",
  岡山県: "岡山県",
  広島県: "広島県",
  山口県: "山口県",
  徳島県: "徳島県",
  香川県: "香川県",
  愛媛県: "愛媛県",
  高知県: "高知県",
  福岡県: "福岡県",
  佐賀県: "佐賀県",
  長崎県: "長崎県",
  熊本県: "熊本県",
  大分県: "大分県",
  宮崎県: "宮城県",
  鹿児島県: "鹿児島県",
  沖縄県: "沖縄県",
  アメリカ: "アメリカ",
  中国: "中国",
  韓国: "韓国",
  インド: "インド",
  イギリス: "イギリス"
}
  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
             BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  # セッションハイジャック防止のためにセッショントークンを返す
  # この記憶ダイジェストを再利用しているのは単に利便性のため
  def session_token
    remember_digest || remember
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # ユーザーのステータスフィードを返す
  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR (user_id = :user_id AND is_fixed = FALSE)", user_id: id)
             .includes(:user, image_attachment: :blob)
  end

  #固定マイクロポストを取得する
  def get_fixed_micropost
    Micropost.find_by( user_id: id , is_fixed: true)
  end

  # ユーザーをフォローする
  def follow(other_user)
    following << other_user unless self == other_user
  end

  # ユーザーをフォロー解除する
  def unfollow(other_user)
    following.delete(other_user)
  end

  # 現在のユーザーが他のユーザーをフォローしていればtrueを返す
  def following?(other_user)
    following.include?(other_user)
  end

  # micropostをLikeする
  def like(micropost)
    count = like_count micropost
    if count.zero?
      liked_microposts << micropost
    else
      Like.transaction do
        likes.find_by(micropost_id: micropost.id)&.update(count: count + 1)
      end
    end
  end

  # このユーザによるmicropostのLike数を返す Likeしていなければ0を返す
  def like_count(micropost)
    liked_micropost = liked_microposts.with_count.find_by(id: micropost.id)
    liked_micropost&.count || 0
  end

  # micropostのLikeを解除する
  def delete_like(micropost)
    Like.transaction do
      likes.find_by(micropost_id: micropost.id)&.delete
    end
  end

  private

  # メールアドレスをすべて小文字にする
  def downcase_email
    self.email = email.downcase
  end

  # 有効化トークンとダイジェストを作成および代入する
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

  

end
