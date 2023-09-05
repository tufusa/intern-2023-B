class AddDefaultToMicroposts < ActiveRecord::Migration[7.0]
  def up
    Micropost.where(is_fixed: nil).update_all(is_fixed: false)
    change_column :microposts, :is_fixed, :boolean, default: false, null: false
  end
end
