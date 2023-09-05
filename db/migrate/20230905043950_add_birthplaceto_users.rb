class AddBirthplacetoUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :birthplace, :string
  end
end
