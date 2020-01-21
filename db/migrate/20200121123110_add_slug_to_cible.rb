class AddSlugToCible < ActiveRecord::Migration[6.0]
  def change
    add_column :cibles, :slug, :string
    add_index :cibles, :slug, unique: true
  end
end
