class DeleteUnusedFields < ActiveRecord::Migration[6.0]
  def change
    remove_column :factures, :etat 
    remove_column :factures, :cible 
    remove_column :cibles, :opérateur 
  end
end
