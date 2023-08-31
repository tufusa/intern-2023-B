class RenameIsfixedColumnToIsFixed < ActiveRecord::Migration[7.0]
  def change
    rename_column :microposts, :isfixed, :is_fixed
  end
end
