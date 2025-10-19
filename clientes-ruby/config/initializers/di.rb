Rails.application.config.to_prepare do
  # Domain
  require_relative '../../app/domain/cliente_entity'
  require_relative '../../app/domain/repositories/clientes_repository'

  # Application
  require_relative '../../app/application/create_cliente'

  # Infrastructure
  require_relative '../../app/infrastructure/repositories/oracle_clientes_repository'
  require_relative '../../app/infrastructure/clients/auditoria_client'

  # Setup dependencies
  $clientes_repo     = Infrastructure::Repositories::OracleClientesRepository.new
  $create_cliente_uc = Application::CreateCliente.new(
    repo: $clientes_repo,
    auditor: Infrastructure::Clients::AuditoriaClient
  )
end
