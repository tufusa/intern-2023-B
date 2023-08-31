class AddIsfixedToMicroposts < ActiveRecord::Migration[7.0]
  def change
    add_column :microposts, :isfixed, :boolean
  end
end
