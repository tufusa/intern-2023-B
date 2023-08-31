class AddIntroductionToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :introduce, :text
  end
end
