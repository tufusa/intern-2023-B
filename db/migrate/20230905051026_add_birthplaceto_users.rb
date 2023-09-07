class AddBirthplacetoUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :birthplace, :integer
  end
end
