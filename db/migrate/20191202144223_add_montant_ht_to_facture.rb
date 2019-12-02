class AddMontantHtToFacture < ActiveRecord::Migration[6.0]
  def change
    add_column :factures, :montantHT, :decimal, precision: 10, scale: 2
  end
end
