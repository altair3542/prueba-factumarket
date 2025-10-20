class Factura < ApplicationRecord
  self.table_name = "FACTURAS"
  self.primary_key = "ID"
  self.sequence_name = "FACTURAS_SEQ"

  validates :CLIENTE_ID, presence: true
  validates :MONTO, numericality: { greater_than: 0}
  validates :FECHA, presence: true
end
