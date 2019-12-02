class AddSlugToFactures < ActiveRecord::Migration[6.0]
  def change
    add_column :factures, :slug, :string
    add_index :factures, :slug, unique: true
  end
end
