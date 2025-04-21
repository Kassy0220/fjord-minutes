class AddKindToCourses < ActiveRecord::Migration[7.2]
  def change
    add_column :courses, :kind, :integer
  end
end
