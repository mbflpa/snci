<cfprocessingdirective pageencoding = "utf-8">

<cfparam name="attributes.exibirAno" default="true" type="boolean">
<cfparam name="attributes.exibirOrgao" default="false" type="boolean">
<cfparam name="attributes.exibirDiretoria" default="false" type="boolean">
<cfparam name="attributes.exibirStatus" default="false" type="boolean">
<cfparam name="attributes.componenteID" default="filtros-dashboard-#CreateUUID()#">

<!--- Buscar dados apenas quando necessário --->
<cfif attributes.exibirAno>
    <cfquery name="rsAnoDashboard" datasource="#application.dsn_processos#">
        SELECT DISTINCT RIGHT(pc_processo_id, 4) AS ano FROM pc_processos 
        WHERE 1=1
        <cfif application.rsUsuarioParametros.pc_usu_perfil eq 8>
            AND pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#'
        </cfif>
        ORDER BY ano DESC
    </cfquery>
</cfif>

<!--- Definir variável de controle para órgãos --->
<cfset mostrarFiltroOrgao = application.rsUsuarioParametros.pc_usu_perfil neq 8>
<cfset orgaoOrigemSelecionado = "Todos">

<cfif attributes.exibirOrgao AND mostrarFiltroOrgao>
    <cfquery name="rsOrgaosOrigem" datasource="#application.dsn_processos#">
        SELECT pc_org_mcu, pc_org_sigla
        FROM pc_orgaos 
        WHERE pc_org_status = 'O'
        <cfif application.rsUsuarioParametros.pc_usu_perfil eq 8>
            AND pc_org_mcu = '#application.rsUsuarioParametros.pc_usu_lotacao#'
        </cfif>
        ORDER BY pc_org_sigla
    </cfquery>
    
    <cfif NOT mostrarFiltroOrgao AND isDefined("rsOrgaosOrigem") AND rsOrgaosOrigem.recordCount GT 0>
        <cfset orgaoOrigemSelecionado = rsOrgaosOrigem.pc_org_mcu>
    </cfif>
</cfif>

<cfif attributes.exibirStatus>
    <cfquery name="rsStatusProcessos" datasource="#application.dsn_processos#">
        SELECT pc_status_id, pc_status_descricao
        FROM pc_status
        ORDER BY pc_status_descricao
    </cfquery>
</cfif>

<!--- Preparar arrays de dados em JavaScript para evitar aninhamento de cfoutput com query attribute --->
<cfif attributes.exibirAno>
    <cfset anosJS = "">
    <cfloop query="rsAnoDashboard">
        <cfset anosJS = anosJS & "anos.push(parseInt('" & rsAnoDashboard.ano & "', 10));">
    </cfloop>
</cfif>

<cfif attributes.exibirOrgao AND mostrarFiltroOrgao AND isDefined("rsOrgaosOrigem")>
    <cfset orgaosJS = "">
    <cfloop query="rsOrgaosOrigem">
        <cfset orgaosJS = orgaosJS & "orgaos.push({mcu: '" & rsOrgaosOrigem.pc_org_mcu & "', sigla: '" & 
                           replace(rsOrgaosOrigem.pc_org_sigla, "'", "\'", "ALL") & "'.includes('/') ? '" & 
                           replace(rsOrgaosOrigem.pc_org_sigla, "'", "\'", "ALL") & "'.split('/').pop() : '" & 
                           replace(rsOrgaosOrigem.pc_org_sigla, "'", "\'", "ALL") & "'});">
    </cfloop>
</cfif>

<!--- Preparar dados das diretorias para JavaScript --->
<cfif attributes.exibirDiretoria>
    <cfquery name="rsDiretorias" datasource="#application.dsn_processos#">
        SELECT pc_org_mcu, pc_org_sigla
        FROM pc_orgaos
        WHERE pc_org_mcu IN ('#Replace(application.listaDiretorias, ",", "','", "all")#')
        ORDER BY pc_org_sigla
    </cfquery>

    <cfset diretoriasJS = "">
    <cfloop query="rsDiretorias">
        <cfset diretoriasJS = diretoriasJS & "diretorias.push({mcu: '" & rsDiretorias.pc_org_mcu & "', sigla: '" & 
                             replace(rsDiretorias.pc_org_sigla, "'", "\'", "ALL") & "'.includes('/') ? '" & 
                             replace(rsDiretorias.pc_org_sigla, "'", "\'", "ALL") & "'.split('/').pop() : '" & 
                             replace(rsDiretorias.pc_org_sigla, "'", "\'", "ALL") & "'});">
    </cfloop>
</cfif>

<cfif attributes.exibirStatus AND isDefined("rsStatusProcessos")>
    <cfset statusJS = "">
    <cfloop query="rsStatusProcessos">
        <cfset statusJS = statusJS & "statusList.push({id: '" & rsStatusProcessos.pc_status_id & "', descricao: '" & 
                          replace(rsStatusProcessos.pc_status_descricao, "'", "\'", "ALL") & "'});">
    </cfloop>
</cfif>

<!--- Processamento do filtro de Diretoria --->
<cfif isDefined("form.filtro_diretoria") AND len(form.filtro_diretoria)>
    <cfset url.filtro_diretoria = form.filtro_diretoria>
<cfelseif NOT isDefined("url.filtro_diretoria")>
    <cfset url.filtro_diretoria = "">
</cfif>

<!--- Adiciona a condição SQL para o filtro de Diretoria --->
<cfif len(url.filtro_diretoria)>
    <!--- Obtém hierarquia de órgãos subordinados à diretoria selecionada --->
    <cfset qDiretoriaHierarquia = queryExecute(
        "WITH OrgHierarchy AS (
            SELECT pc_org_mcu, pc_org_mcu_subord_tec
            FROM pc_orgaos
            WHERE pc_org_mcu = :diretoria
            UNION ALL
            SELECT o.pc_org_mcu, o.pc_org_mcu_subord_tec
            FROM pc_orgaos o
            INNER JOIN OrgHierarchy oh ON o.pc_org_mcu_subord_tec = oh.pc_org_mcu
        )
        SELECT pc_org_mcu
        FROM OrgHierarchy",
        {diretoria = {value=url.filtro_diretoria, cfsqltype="cf_sql_varchar"}},
        {datasource=application.dsn_processos, timeout=120}
    )>
    
    <cfset listaOrgaosDiretoria = ValueList(qDiretoriaHierarquia.pc_org_mcu)>
    
    <!--- Adiciona a diretoria selecionada à lista caso não esteja incluída no resultado da hierarquia --->
    <cfif NOT ListFind(listaOrgaosDiretoria, url.filtro_diretoria)>
        <cfset listaOrgaosDiretoria = ListAppend(listaOrgaosDiretoria, url.filtro_diretoria)>
    </cfif>
    
    <!--- Adiciona a condição SQL --->
    <cfset SQL_WHERE = SQL_WHERE & " AND pc_org_mcu IN ('#Replace(listaOrgaosDiretoria, ",", "','", "all")#')">
</cfif>

<cfoutput>
<!-- CSS do componente de filtros -->
<style>
    ###attributes.componenteID# {
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        gap: 15px;
        width: 100%;
        padding-top: 5px;
        margin-bottom: 0;
    }
    
    .filtro-container.filtro-compacto {
        margin-bottom: 8px;
        flex: 0 0 auto;
        white-space: nowrap;
    }
    
    .filtro-label {
        display: inline-block;
        font-weight: 600;
        margin-right: 8px;
        font-size: 0.9rem;
    }
    
    .card-filtros {
        margin-bottom: 1.5rem;
    }
    
    .card-filtros .card-header {
        background-color: ##f8f9fa;
        padding: 0.75rem 1.25rem;
    }
    
    .card-filtros .card-header i {
        color: ##6c757d;
        margin-right: 0.5rem;
    }
    
    .card-filtros .card-body {
        padding: 0.5rem;
        overflow-x: hidden;
    }
    
    .btn-group-filtros {
        flex-wrap: wrap;
        display: inline-flex;
    }
    
    .btn-group-filtros .btn {
        margin: 0 2px 4px 0;
        border-radius: 0.2rem !important;
    }
    
    .btn-group .btn.active {
        background-color: var(--cor-bg-primary, ##007bff) !important;
        border-color: ##0056b3 !important;
        color: white !important;
    }
    
    .btn-todos.active {
        background-color: ##495057 !important;
        border-color: ##343a40 !important;
    }
    
    /* Responsividade */
    @media (max-width: 992px) {
        .filtro-label {
            font-size: 0.85rem;
            margin-right: 6px;
            min-width: 40px;
        }
        
        .filtro-compacto .btn-group-sm .btn {
            padding: 0.12rem 0.35rem;
            font-size: 0.75rem;
        }
    }
    
    @media (max-width: 768px) {
        ###attributes.componenteID# {
            gap: 10px;
        }
        
        .filtro-container.filtro-compacto {
            margin-bottom: 10px;
            flex: 0 0 100%;
        }
        
        .btn-group-filtros {
            max-width: 100%;
            overflow-x: visible;
        }
    }
    
    @media (max-width: 576px) {
        .card-filtros .card-body {
            padding: 0.75rem;
        }
        
        .filtro-container.filtro-compacto {
            margin-bottom: 12px;
        }
        
        .filtro-label {
            margin-bottom: 5px;
            display: block;
        }
    }
</style>

<!-- Card de Filtros -->
<div class="card card-filtros">
    <div class="card-header">
        <h3 class="card-title">
            <i class="fas fa-filter"></i> Filtros
        </h3>
    </div>
    <div class="card-body">
        <!-- Container principal de filtros -->
        <div id="#attributes.componenteID#" class="filtros-container">
            <!-- Filtro por ano -->
            <cfif attributes.exibirAno>
                <div class="filtro-container filtro-compacto">
                    <div class="filtro-label">Ano Processos:</div>
                    <div id="opcoesAno#attributes.componenteID#" class="btn-group btn-group-toggle btn-group-sm btn-group-filtros" data-toggle="buttons">
                        <!-- Botões gerados via JS -->
                    </div>
                </div>
            </cfif>
            
            <!-- Filtro por órgão -->
            <cfif attributes.exibirOrgao AND mostrarFiltroOrgao>
                <div class="filtro-container filtro-compacto">
                    <div class="filtro-label">Órgão:</div>
                    <div id="opcoesMcu#attributes.componenteID#" class="btn-group btn-group-toggle btn-group-sm btn-group-filtros" data-toggle="buttons">
                        <!-- Botões gerados via JS -->
                    </div>
                </div>
            </cfif>
            
            <!-- Filtro por status -->
            <cfif attributes.exibirStatus>
                <div class="filtro-container filtro-compacto">
                    <div class="filtro-label">Status:</div>
                    <div id="opcoesStatus#attributes.componenteID#" class="btn-group btn-group-toggle btn-group-sm btn-group-filtros" data-toggle="buttons">
                        <!-- Botões gerados via JS -->
                    </div>
                </div>
            </cfif>

            <!-- Filtro de Diretoria -->
            <cfif attributes.exibirDiretoria>
                <div class="filtro-container filtro-compacto">
                    <div class="filtro-label">Diretoria:</div>
                    <div id="opcoesDiretoria#attributes.componenteID#" class="btn-group btn-group-toggle btn-group-sm btn-group-filtros" data-toggle="buttons">
                        <!-- Botões gerados via JS -->
                    </div>
                </div>
            </cfif>
        </div>
    </div>
</div>

<!-- Script do componente -->
<script>
$(document).ready(function() {
    // Identificador único para este componente
    const componenteID = '#attributes.componenteID#';
    
    // Handler para alteração nos filtros
    function onFiltroAlterado(tipo, valor) {
        
        // Atualizar variáveis globais
        if (tipo === 'ano') {
            window.anoSelecionado = valor;
            
        } else if (tipo === 'orgao') {
            window.mcuSelecionado = valor;
           
        } else if (tipo === 'status') {
            window.statusSelecionado = valor;
            
        } else if (tipo === 'diretoria') {
            window.diretoriaSelecionada = valor;
        }
        
        // Disparar evento personalizado que pode ser capturado pela página
        const evento = new CustomEvent('filtroAlterado', { 
            detail: { 
                tipo: tipo,
                valor: valor,
                componenteID: componenteID
            } 
        });
        
        // Disparar o evento
        document.dispatchEvent(evento);
       
    }

    // Configuração do filtro de anos - apenas se o filtro estiver habilitado
    <cfif attributes.exibirAno>
        let anos = [];
        // Adicionar anos da query usando cfloop em vez de cfoutput aninhado
        #anosJS#
        
        // Ordena os anos em ordem crescente
        anos = anos.sort((a, b) => a - b);
        
        const opcoesAnoEl = $("##opcoesAno" + componenteID);
        opcoesAnoEl.empty();
        
        // Adicionar botão "Todos"
        const btnTodosAno = `<label class="btn btn-outline-secondary btn-todos">
                        <input type="radio" name="opcaoAno${componenteID}" autocomplete="off" value="Todos"/> Todos
                    </label>`;
        opcoesAnoEl.append(btnTodosAno);
        
        // Ano selecionado (último ano da lista ou ano atual)
        const anoSelecionado = anos.length > 0 ? anos[anos.length - 1] : (new Date().getFullYear() - 1);
        window.anoSelecionado = anoSelecionado;
        
        // Adicionar botões para cada ano
        anos.forEach(function(ano) {
            const checked = (ano === anoSelecionado) ? 'checked' : '';
            const btn = `<label class="btn btn-outline-primary" style="margin-left:2px;">
                            <input type="radio" name="opcaoAno${componenteID}" ${checked} autocomplete="off" value="${ano}"/> ${ano}
                        </label>`;
            opcoesAnoEl.append(btn);
        });
        
        // Ativar o botão do ano selecionado
        $(`input[name="opcaoAno${componenteID}"][value="${anoSelecionado}"]`).parent().addClass('active');
        
        // Disparar o evento inicial para notificar que já tem um ano selecionado
        setTimeout(function() {
            console.log('Disparando evento inicial de filtro para ano:', anoSelecionado);
            onFiltroAlterado('ano', anoSelecionado);
        }, 50);
        
        // Event handler
        $(`input[name="opcaoAno${componenteID}"]`).change(function() {
            const novoAno = $(this).val();
            console.log('Filtro de ano alterado via UI para:', novoAno);
            onFiltroAlterado('ano', novoAno);
        });
    </cfif>
    
    // Configuração do filtro de órgãos - apenas se o filtro estiver habilitado e o usuário tiver permissão
    <cfif attributes.exibirOrgao AND mostrarFiltroOrgao AND isDefined("rsOrgaosOrigem")>
        let orgaos = [];
        // Adicionar órgãos da query usando string preparada
        #orgaosJS#
        
        const opcoesMcuEl = $("##opcoesMcu" + componenteID);
        opcoesMcuEl.empty();
        
        // Adicionar botão "Todos"
        const btnTodosMcu = `<label class="btn btn-outline-secondary btn-todos">
                        <input type="radio" name="opcaoMcu${componenteID}" checked autocomplete="off" value="Todos"/> Todos
                    </label>`;
        opcoesMcuEl.append(btnTodosMcu);
        
        // Valor selecionado sempre começa como "Todos"
        const mcuSelecionado = 'Todos';
        window.mcuSelecionado = mcuSelecionado;
        
        // Adicionar botões para cada órgão
        orgaos.forEach(function(orgao) {
            const btn = `<label class="btn btn-outline-info" style="margin-left:2px;">
                            <input type="radio" name="opcaoMcu${componenteID}" autocomplete="off" value="${orgao.mcu}"/> ${orgao.sigla}
                        </label>`;
            opcoesMcuEl.append(btn);
        });
        
        // Ativar o botão "Todos" para órgãos inicialmente
        $(`input[name="opcaoMcu${componenteID}"][value="Todos"]`).parent().addClass('active');
        
        // Event handler
        $(`input[name="opcaoMcu${componenteID}"]`).change(function() {
            const novoMcu = $(this).val();
            onFiltroAlterado('orgao', novoMcu);
        });
    </cfif>
    
    // Configuração do filtro de status - apenas se o filtro estiver habilitado
    <cfif attributes.exibirStatus>
        let statusList = [];
        // Adicionar status da query usando string preparada
        #statusJS#
        
        const opcoesStatusEl = $("##opcoesStatus" + componenteID);
        opcoesStatusEl.empty();
        
        // Adicionar botão "Todos"
        const btnTodosStatus = `<label class="btn btn-outline-secondary btn-todos">
                            <input type="radio" name="opcaoStatus${componenteID}" checked autocomplete="off" value="Todos"/> Todos
                       </label>`;
        opcoesStatusEl.append(btnTodosStatus);
        
        // Valor selecionado
        const statusSelecionado = 'Todos';
        window.statusSelecionado = statusSelecionado;
        
        // Adicionar botões para cada status
        statusList.forEach(function(status) {
            const btn = `<label class="btn btn-outline-info" style="margin-left:2px;">
                            <input type="radio" name="opcaoStatus${componenteID}" autocomplete="off" value="${status.id}"/> ${status.descricao}
                        </label>`;
            opcoesStatusEl.append(btn);
        });
        
        // Ativar o botão "Todos" para status inicialmente
        $(`input[name="opcaoStatus${componenteID}"][value="Todos"]`).parent().addClass('active');
        
        // Event handler
        $(`input[name="opcaoStatus${componenteID}"]`).change(function() {
            const novoStatus = $(this).val();
            onFiltroAlterado('status', novoStatus);
        });
    </cfif>
    
    // Configuração do filtro de diretorias - apenas se o filtro estiver habilitado
    <cfif attributes.exibirDiretoria>
        let diretorias = [];
        // Adicionar diretorias da query usando string preparada
        #diretoriasJS#
        
        const opcoesDiretoriaEl = $("##opcoesDiretoria" + componenteID);
        opcoesDiretoriaEl.empty();
        
        // Adicionar botão "Todos"
        const btnTodasDiretorias = `<label class="btn btn-outline-secondary btn-todos active">
                            <input type="radio" name="opcaoDiretoria${componenteID}" checked autocomplete="off" value="Todos"/> Todos
                       </label>`;
        opcoesDiretoriaEl.append(btnTodasDiretorias);
        
        // Valor selecionado
        const diretoriaSelecionada = 'Todos';
        window.diretoriaSelecionada = diretoriaSelecionada;
        
        // Adicionar botões para cada diretoria
        diretorias.forEach(function(diretoria) {
            const btn = `<label class="btn btn-outline-primary" style="margin-left:2px;">
                            <input type="radio" name="opcaoDiretoria${componenteID}" autocomplete="off" value="${diretoria.mcu}"/> ${diretoria.sigla}
                        </label>`;
            opcoesDiretoriaEl.append(btn);
        });
        
        // Event handler
        $(`input[name="opcaoDiretoria${componenteID}"]`).change(function() {
            const novaDiretoria = $(this).val();
            onFiltroAlterado('diretoria', novaDiretoria);
            
            // Se estiver usando form, adicionar ao formulário
            if ($("##filtro_diretoria").length) {
                $("##filtro_diretoria").val(novaDiretoria);
                // Fazer submit do form se necessário
                // $("form").submit();
            }
        });
    </cfif>
});
</script>
</cfoutput>
