Rails.application.config.to_prepare do
  require_relative '../../app/domain/factura_entity'
  require_relative '../../app/domain/repositories/facturas_repository'

  require_relative '../../app/application/create_factura'

  require_relative '../../app/infrastructure/repositories/oracle_facturas_repository'
  require_relative '../../app/infrastructure/clients/auditoria_client'
  require_relative '../../app/infrastructure/clients/clientes_api'

  $facturas_repo = Infrastructure::Repositories::OracleFacturasRepository.new
  $create_factura_uc = Application::CreateFactura.new(
    repo: $facturas_repo,
    auditor: Infrastructure::Clients::AuditoriaClient,
    clientes_api: Infrastructure::Clients::ClientesApi
  )
end
