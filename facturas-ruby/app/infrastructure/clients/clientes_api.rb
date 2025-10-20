module Infrastructure
  module Clients
    class ClientesApi
      BASE = ENV.fetch("CLIENTES_URL", "http://localhost:3000")

      def self.cliente_existe?(id)
        resp = Faraday.get("#{BASE}/clientes/#{id}")
        resp.status == 200
      rescue
        false
      end
    end
  end
end
