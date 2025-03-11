<cfprocessingdirective pageencoding = "utf-8">

<cfquery name="rsAnoDashboard" datasource="#application.dsn_processos#">
    SELECT DISTINCT RIGHT(pc_processo_id, 4) AS ano FROM pc_processos 
    WHERE 1=1
    <cfif application.rsUsuarioParametros.pc_usu_perfil eq 8>
        AND pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#'
    </cfif>
    ORDER BY ano DESC
</cfquery>

<cfquery name="rsOrgaosOrigem" datasource="#application.dsn_processos#">
    SELECT pc_org_mcu, pc_org_sigla
    FROM pc_orgaos 
    WHERE pc_org_status = 'O'
    <cfif application.rsUsuarioParametros.pc_usu_perfil eq 8>
        AND pc_org_mcu = '#application.rsUsuarioParametros.pc_usu_lotacao#'
    </cfif>
    ORDER BY pc_org_sigla
</cfquery>

<cfset mostrarFiltroOrgao = application.rsUsuarioParametros.pc_usu_perfil neq 8>
<cfif NOT mostrarFiltroOrgao AND rsOrgaosOrigem.recordCount GT 0>
    <cfset orgaoOrigemSelecionado = rsOrgaosOrigem.pc_org_mcu>
</cfif>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Filtros</title>
    <link rel="stylesheet" href="dist/css/stylesSNCI_ProcessosDashboard.css">
    
    <style>
        /* Estilos aprimorados para os filtros na mesma linha com melhor responsividade */
        .filtros-container {
            display: flex;
            flex-wrap: nowrap;
            align-items: center;
            gap: 15px;
            background-color: #fff;
            padding: 10px 15px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            margin-bottom: 1.5rem;
            overflow-x: auto;
        }
        
        .filtro-container.filtro-compacto {
            margin-bottom: 0;
            flex: 0 0 auto;
            white-space: nowrap;
            min-width: auto;
        }
        
        .filtro-label {
            display: inline-block;
            font-weight: 600;
            margin-right: 8px;
            font-size: 0.9rem;
        }
        
        /* Melhor comportamento responsivo para os filtros */
        @media (max-width: 992px) {
            .filtros-container {
                padding: 8px 12px;
                gap: 10px;
            }
            
            .filtro-label {
                font-size: 0.8rem;
                margin-right: 6px;
            }
            
            .filtro-compacto .btn-group-sm .btn {
                padding: 0.12rem 0.35rem;
                font-size: 0.7rem;
            }
        }
        
        /* Para telas muito pequenas, permitir que os filtros quebrem em linhas */
        @media (max-width: 576px) {
            .filtros-container {
                flex-wrap: wrap;
                gap: 6px;
            }
            
            .filtro-container.filtro-compacto {
                margin-bottom: 5px !important;
            }
        }
    </style>
</head>
<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height">
    <div class="wrapper">
        <!-- Cabeçalho e Sidebar -->
        <cfinclude template="includes/pc_navBar.cfm">
        
        <!-- Conteúdo principal -->
        <div class="content-wrapper">
            <div class="container-fluid">
                <!-- Filtros agrupados em um container -->
                <div class="filtros-container">
                    <!-- Filtro por ano -->
                    <div class="filtro-container filtro-compacto">
                        <div class="filtro-label">Ano:</div>
                        <div id="opcoesAno" class="btn-group btn-group-toggle btn-group-sm" data-toggle="buttons">
                            <!-- Botões gerados via JS -->
                        </div>
                    </div>
                    
                    <!-- Filtro por órgão - exibido conforme perfil do usuário -->
                    <cfif mostrarFiltroOrgao>
                        <div class="filtro-container filtro-compacto">
                            <div class="filtro-label">Órgão:</div>
                            <div id="opcoesMcu" class="btn-group btn-group-toggle btn-group-sm" data-toggle="buttons">
                                <!-- Botões gerados via JS -->
                            </div>
                        </div>
                    </cfif>
                </div>
            </div>
        </div>
        <cfinclude template="includes/pc_footer.cfm">
    </div>
    <cfinclude template="includes/pc_sidebar.cfm">

    <script>
        $(document).ready(function() {
            var anos = [];
            var orgaos = [];
            var currentYear = new Date().getFullYear();
            
            // Preencher array com os anos da query rsAnoDashboard
            <cfoutput query="rsAnoDashboard">
                anos.push(parseInt("#rsAnoDashboard.ano#", 10));
            </cfoutput>
            
            // Ordena os anos em ordem crescente
            anos = anos.sort(function(a, b){ return a - b; });
            
            console.log("Anos disponíveis:", anos);
            
            // Configuração do filtro de anos
            var radioName = "opcaoAno";
            $("#opcoesAno").empty();
            
            // Adicionar botão "Todos" antes dos anos específicos
            var btnTodos = `<label class="btn btn-outline-secondary btn-todos">
                            <input type="radio" name="${radioName}" autocomplete="off" value="Todos"/> Todos
                       </label>`;
            $("#opcoesAno").append(btnTodos);
            
            // Defina o ano selecionado como o último ano (mais recente) da consulta
            var anoSelecionado = anos.length > 0 ? anos[anos.length - 1] : (currentYear - 1);
            
            anos.forEach(function(val) {
                var btnClass = "btn-outline-primary";
                var checked = (val === anoSelecionado) ? 'checked' : '';
                var btn = `<label class="btn ${btnClass}" style="margin-left:2px;">
                                <input type="radio" name="${radioName}" ${checked} autocomplete="off" value="${val}"/> ${val}
                           </label>`;
                $("#opcoesAno").append(btn);
            });

            // Ativar o botão do ano selecionado
            $(`input[name="${radioName}"][value="${anoSelecionado}"]`).parent().addClass('active');
            
            // Preencher array com os órgãos da query rsOrgaosOrigem
            <cfoutput query="rsOrgaosOrigem">
                var sigla = "#rsOrgaosOrigem.pc_org_sigla#";
                var mcu = "#rsOrgaosOrigem.pc_org_mcu#";
                var ultimaParte = sigla.includes('/') ? sigla.split('/').pop() : sigla;
                orgaos.push({
                    mcu: mcu,
                    sigla: ultimaParte
                });
            </cfoutput>
            
            console.log("Órgãos disponíveis:", orgaos);
        
            // Configuração do filtro de órgãos - somente se o perfil permitir
            <cfif mostrarFiltroOrgao>
                var radioMcu = "opcaoMcu";
                $("#opcoesMcu").empty();
                
                // Adicionar botão "Todos" para os órgãos
                var btnTodosMcu = `<label class="btn btn-outline-secondary btn-todos">
                                <input type="radio" name="${radioMcu}" checked autocomplete="off" value="Todos"/> Todos
                           </label>`;
                $("#opcoesMcu").append(btnTodosMcu);
                
                // Adicionar botões para cada órgão
                orgaos.forEach(function(orgao) {
                    var btn = `<label class="btn btn-outline-info" style="margin-left:2px;">
                                    <input type="radio" name="${radioMcu}" autocomplete="off" value="${orgao.mcu}"/> ${orgao.sigla}
                               </label>`;
                    $("#opcoesMcu").append(btn);
                });
                
                // Ativar o botão "Todos" para órgãos inicialmente
                $(`input[name='opcaoMcu'][value='Todos']`).parent().addClass('active');
                
                var mcuSelecionado = "Todos";
            <cfelse>
                // Se o usuário tem perfil 8, define o MCU diretamente
                var mcuSelecionado = "<cfoutput>#orgaoOrigemSelecionado#</cfoutput>";
            </cfif>
            
            // Tornar as variáveis disponíveis globalmente
            window.mcuSelecionado = mcuSelecionado;
            window.anoSelecionado = anoSelecionado;
            
            console.log("Configuração inicial dos filtros:", {
                anoSelecionado: anoSelecionado,
                mcuSelecionado: mcuSelecionado
            });
        
            // Handler para mudança de ano
            $("input[name='opcaoAno']").change(function() {
                anoSelecionado = $(this).val();
                window.anoSelecionado = anoSelecionado; // Atualizar a variável global
                console.log("Filtro de ano alterado:", anoSelecionado);
            });
            
            <cfif mostrarFiltroOrgao>
                // Handler para mudança de órgão (apenas se o filtro estiver visível)
                $("input[name='opcaoMcu']").change(function() {
                    mcuSelecionado = $(this).val();
                    window.mcuSelecionado = mcuSelecionado;
                    console.log("Filtro de órgão alterado:", mcuSelecionado);
                });
            </cfif>
        });
    </script>
</body>
</html>
