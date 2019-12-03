class CreateCibles < ActiveRecord::Migration[6.0]
  def change
    create_table :cibles do |t|
      t.references :facture, null: false, foreign_key: true
      t.string :opérateur
      t.string :email
      t.datetime :repondu_le
      t.string :réponse

      t.timestamps
    end
  end
end
