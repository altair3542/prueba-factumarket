module Infrastructure
  module Clients
    class AuditoriaClient
      AUD_URL = ENV.fetch("AUDITORIA_URL", "http://localhost:5240")

      def self.post_event!(type:, clienteId: nil, facturaId: nil, payload: {})
        Faraday.post("#{AUD_URL}/events") do |req|
          req.options.timeout = 2
          req.headers["Content-Type"] = "application/json"
          req.headers["X-Correlation-Id"] = SecureRandom.uuid
          req.body = {
            type: type,
            clienteId: clienteId,
            facturaId: facturaId,
            payload: payload
          }.to_json
        end
      end
    end
  end
end
