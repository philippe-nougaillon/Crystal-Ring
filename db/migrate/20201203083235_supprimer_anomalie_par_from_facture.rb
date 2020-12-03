class SupprimerAnomalieParFromFacture < ActiveRecord::Migration[6.0]
  def change
    remove_column :factures, :anomalie
    remove_column :factures, :par
  end
end
