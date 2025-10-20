module Application
  class CreateFactura
    def initialize(repo:, auditor:, clientes_api:)
      @repo = repo
      @auditor = auditor
      @clientes_api = clientes_api
    end

    def call(params)
      cliente_id = (params["CLIENTE_ID"] || params["cliente_id"]).to_i
      monto = (params["MONTO"] || params["monto"]).to_f
      fecha = params["FECHA"] || params["fechas"]
      descripcion = params["DESCRIPCION"] || params["descripcion"]

      raise ArgumentError, "CLIENTE_ID Requerido" if cliente_id <= 0
      raise ArgumentError, "MONTO debe ser > 0" if monto <= 0
      raise ArgumentError, "FECHA requerida" if fecha.nil? || fecha.strip.empty?

      unless @clientes_api.cliente_existe?(cliente_id)
        raise ArgumentError, "Cliente no Existe"
      end

      enitity = Domain::FacturaEntity.new(
        cliente_id: cliente_id, monto: monto, fecha: fecha, descripcion: descripcion
      )

      rec = @repo.create!(entity)

      begin
        @auditor.post_event!(
          type: "factura_creada",
          clienteId: rec.CLIENTE_ID,
          facturaId: rec.ID,
          payload: {  monto: rec.MONTO, fecha: rec.FECHA, desc: rec.DESCRIPCION }
        )
      rescue
        Rails.logger.warn("[Auditoria] Falló el envio del evento: #{e.class} #{e.message}")
      end
      
      rec
    end
  end
end
