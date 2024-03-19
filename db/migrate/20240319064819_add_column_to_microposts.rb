class AddColumnToMicroposts < ActiveRecord::Migration[7.1]
  def change
    add_column :microposts, :in_reply_to, :string
  end
end
