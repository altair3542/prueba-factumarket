module Infrastructure
  module Repositories
    class OracleClientesRepository < Domain::Repositories::ClientesRepository
      def create!(entity)
        rec = Cliente.new(
          "NOMBRE" => entity.nombre,
          "EMAIL"  => entity.email,
          "IDENTIFICACION" => entity.identificacion
        )
        rec.save!
        rec
      end

      def find(id)
        Cliente.find(id)
      end

      def list(limit: 100)
        Cliente.order(ID: :desc).limit(limit)
      end
    end
  end
end
