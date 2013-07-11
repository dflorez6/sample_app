class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end

    # Since we will be finding relationships by follower_id and by followed_id, we should add an index on each column for efficiency.
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    add_index :relationships, [:follower_id, :followed_id], unique: true        #  includes a composite index that enforces uniqueness of pairs of (follower_id, followed_id), so that a user can’t follow another user more than once
  end
end
