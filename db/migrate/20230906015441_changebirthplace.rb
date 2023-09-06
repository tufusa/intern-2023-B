class Changebirthplace < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :birthplace, :string
  end
end
