class CreateMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :memberships do |t|
      t.references :user, index: true, foreign_key: true
      t.references :conversation, index: true, foreign_key: true

      t.timestamps
    end
  end
end
