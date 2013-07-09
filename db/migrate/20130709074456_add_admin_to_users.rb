class AddAdminToUsers < ActiveRecord::Migration
  def change
    add_column :users, :admin, :boolean, default: false       # The migration to add a boolean admin attribute to users.
  end
end
