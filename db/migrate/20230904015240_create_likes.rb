class CreateLikes < ActiveRecord::Migration[7.0]
  def change
    create_table :likes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :micropost, null: false, foreign_key: true
      t.integer :count, null: false, default: 1

      t.timestamps

      t.check_constraint 'count > 0', name: 'count_check'
    end
    add_index :likes, [:user_id, :micropost_id], unique: true
  end
end
