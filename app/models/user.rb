class User < ActiveRecord::Base
    has_secure_password

    mount_uploader :avatar, AvatarUploader
    attr_accessor :crop_x, :crop_y,:crop_w,:crop_h
    after_update :crop_avatar
    def crop_avatar
      avatar.recreate_versions! if crop_x.present?
    end

    before_save do
      self.category.gsub!(/[\[\]\"\, ]/,"") if self.category !=nil
    end

    has_many :posts, dependent: :destroy
    has_many :comments, dependent: :destroy
    has_many :likes, dependent: :destroy
    has_many :folders, dependent: :destroy
    has_many :draws, dependent: :destroy
    has_many :drawmsgs, dependent: :destroy
    has_many :messages, dependent: :destroy

    has_many :follower_relationships, foreign_key: :following_id, class_name: 'Relationship', dependent: :destroy
    has_many :followers, through: :follower_relationships, source: :follower, dependent: :destroy
    has_many :following_relationships, foreign_key: :follower_id, class_name: 'Relationship', dependent: :destroy
    has_many :following, through: :following_relationships, source: :following, dependent: :destroy

    validates_length_of :password, :minimum => 8 , :message => "密碼長度須大於8", on: :create
    validates_uniqueness_of :email, :message => "信箱已被使用", on: :create
    validates_uniqueness_of :name, :message => "用戶名已被使用"
    validates_format_of :email, :with => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i, :message => "請輸入信箱"
    validates_presence_of :avatar , :message => "請上傳大頭照"
    validates_presence_of :name , :message => "請填寫名稱"
    validates_presence_of :about,:message => "請填寫自我介紹"
    validates_acceptance_of :agreement,:message => "請勾選我同意"

    def follow(user_id)
      following_relationships.create(following_id: user_id)
    end
    def unfollow(user_id)
      following_relationships.find_by(following_id: user_id).destroy
    end

    def mypost
      @post=Post.where(user_id: id).order("created_at desc").limit(4)
    end

    def notifycount
      @number=Message.where("receiver_id = ? AND types != ? AND status = ?",id,'0','0').count
    end

    def msgcount
      @number=Message.where("receiver_id = ? AND types = ? AND status = ?",id,'0','0').count
    end
end
