module Application
  class CreateCliente
    def initialize(repo:, auditor:)
      @repo = repo
      @auditor = auditor
    end

    def call(params)
      nombre = params["NOMBRE"] || params["nombre"]
      raise ArgumentError, "NOMBRE requerido" if nombre.nil? || nombre.strip.empty?

      entity = Domain::ClienteEntity.new(
        nombre: nombre,
        email: params["EMAIL"] || params["email"],
        identificacion: params["IDENTIFICACION"] || params["identificacion"]
      )

      rec = @repo.create!(entity)

      begin
        @auditor.post_event!(
          type: "cliente_creado",
          clienteId: rec.ID,
          payload: { nombre: rec.NOMBRE, email: rec.EMAIL }
        )
      rescue => e
        Rails.logger.warn("[Auditoria] fallo envío evento: #{e.class} #{e.message}")
      end

      rec
    end
  end
end
