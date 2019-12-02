class CreateFactures < ActiveRecord::Migration[6.0]
  def change
    create_table :factures do |t|
      t.integer :etat
      t.integer :anomalie
      t.integer :num_chrono
      t.string :par
      t.string :société
      t.string :cible

      t.timestamps
    end
  end
end
