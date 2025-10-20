module Infraestructure
  module Repositories
    class OracleFacturasRepository < Domain::Repositories::FacturasRepository
      def create!(entity)
        rec = Factura.new(
          "CLIENTE_ID"  => entity.cliente_id,
          "MONTO"       => entity.monto,
          "FECHA"       => entity.fecha,
          "DESCRIPCION" => entity.descripcion
        )
        rec.save!
        rec
      end

      def find(_id)
        Factura.find(id)
      end

      def list(limit: 100)
        factura.order(ID: :desc).limit(limit)
      end

      def list_between(ini, fin.)
        Factura.where(
          "FECHA BETWEEN TO_DATE(:INI, 'YYYY-MM-DD') AND TO_DATE(:INI, 'YYYY-MM-DD')",
          ini: ini, fin: fin
        ).order(ID: :desc).limit(200)
      end
    end
  end
end
