class CreateFacturas < ActiveRecord::Migration[7.1]
  def change
    create_table :FACTURAS, if_not_exists: true do |t|
      t.integer :CLIENTE_ID, null: false
      t.decimal :MONTO, precision: 10, scale: 2, null: false
      t.date :FECHA, null: false
      t.string :DESCRIPCION, limit: 1000

      t.timestamps
    end

    add_index :FACTURAS, :CLIENTE_ID, if_not_exists: true
    add_index :FACTURAS, :FECHA, if_not_exists: true
  end
end
