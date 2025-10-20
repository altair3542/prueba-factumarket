class Factura
  attr_accessor :ID, :CLIENTE_ID, :MONTO, :FECHA, :DESCRIPCION

  def initialize(attributes = {})
    attributes.each do |key, value|
      send("#{key}=", value)
    end
  end

  def save!
    true
  end
end
