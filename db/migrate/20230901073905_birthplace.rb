class Birthplace < ActiveRecord::Migration[7.0]
  def change
    add_column :birthplace, :region, :string
  end
end



