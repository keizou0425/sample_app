class AddNoticeToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :notice, :boolean, default: true
  end
end
