module Domain
  class FacturaEntity
    attr_reader :cliente_id, :monto, :fecha, :descripcion

    def initialize(cliente_id:, monto:, fecha:, descripcion: nil)
      @cliente_id = cliente_id
      @monto = monto
      @fecha = fecha
      @descripcion = descripcion
    end
  end
end
