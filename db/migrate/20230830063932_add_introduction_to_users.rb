class AddIntroductionToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :Introduce, :text
  end
end
