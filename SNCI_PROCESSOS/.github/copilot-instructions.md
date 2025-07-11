# Copilot Instructions for SNCI_PROCESSOS

## Visão Geral

Este projeto é um sistema ColdFusion para gestão de processos, com interface web baseada em arquivos `.cfm` e lógica de negócio em componentes `.cfc`. O acesso a dados é feito via queries SQL embutidas nos arquivos CFML.

## Estrutura Principal

- **Arquivos `.cfm`**: Representam páginas e funcionalidades da interface do usuário.
- **Diretório `cfc/`**: Contém componentes ColdFusion (lógica de negócio, consultas, integrações).
- **Diretório `bd/`**: Scripts SQL auxiliares.
- **Diretório `includes/`**: Partes reutilizáveis de interface e lógica.
- **Plugins/ckeditor/**: Recursos de terceiros para edição e UI.

## Convenções e Padrões

- **Consultas SQL**: Usar `<cfquery>` com datasource definido em `application.dsn_processos`.
- **Laços de dados**: Usar `<cfloop query="nomeQuery">` para renderizar listas/tabelas.
- **Links dinâmicos**: Montar URLs usando variáveis de contexto e parâmetros do usuário.
- **Componentização**: Lógica complexa deve ser movida para arquivos `.cfc` em `cfc/`.
- **Sessão/Permissões**: Controle de acesso via variáveis de sessão e queries em `pc_controle_acesso`.

## Fluxos Críticos

- **Login e controle de acesso**: Verificar permissões em cada página usando perfil do usuário.
- **Menu rápido**: Gerado dinamicamente a partir do banco, pode incluir links externos (exemplo: Power BI).
- **Upload de arquivos**: Usar `formUploadImagem.cfm`.

## Integrações e Dependências

- **Power BI**: Links externos podem ser adicionados ao menu rápido.
- **Plugins JS**: zTree, CKEditor, FontAwesome.

## Exemplos de Padrão

- Renderização de menu dinâmico:
  ```cfm
  <cfloop query="rsMenuRapido">
    <cfoutput>
      <a href="#link#"><div class="menuRapido_iconGrid">...</div></a>
    </cfoutput>
  </cfloop>
  ```
- Consulta SQL:
  ```cfm
  <cfquery name="rs" datasource="#application.dsn_processos#">
    SELECT ... FROM ... WHERE ...
  </cfquery>
  ```

## Observações

- Evite hardcode de caminhos; use variáveis de contexto.
- Siga o padrão de permissões e sessões já implementado.
- Consulte arquivos em `cfc/` para lógica reutilizável.

Para dúvidas sobre padrões, consulte exemplos em `pc_menuRapido.cfm`, `cfc/pc_cfcConsultasDiversas.cfc` e `Application.cfc`.
