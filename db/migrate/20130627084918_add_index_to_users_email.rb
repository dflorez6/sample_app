class AddIndexToUsersEmail < ActiveRecord::Migration
  def change
    add_index :users, :email, unique: true    #Garantees uniqueness at the database level!
  end
end
