class AddPolymorphicAssociationToTopics < ActiveRecord::Migration[7.2]
  def change
    add_column :topics, :topicable_id, :bigint
    add_column :topics, :topicable_type, :string

    add_index :topics, [ :topicable_id, :topicable_type ]
  end
end
