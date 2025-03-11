/**
 * Classe base para componentes de dashboard
 * Fornece funcionalidades comuns para todos os componentes
 * @version 1.0.1
 */
var DashboardComponentFactory = (function () {
  // Contador global para IDs únicos
  var componentCounter = 0;

  // Cache de componentes
  var registeredComponents = {};

  // Cache de dependências
  var loadedDependencies = {};

  /**
   * Carrega um script JavaScript de forma assíncrona
   * @param {string} url - URL do script a ser carregado
   * @param {function} callback - Função a ser chamada após o carregamento
   */
  function carregarScript(url, callback) {
    // Verificar se o script já está carregado
    if (loadedDependencies[url]) {
      if (callback) setTimeout(callback, 0);
      return;
    }

    // Verificar no DOM se o script já está carregado
    var scripts = document.getElementsByTagName("script");
    for (var i = 0; i < scripts.length; i++) {
      if (scripts[i].src.indexOf(url) !== -1) {
        loadedDependencies[url] = true;
        if (callback) setTimeout(callback, 0);
        return;
      }
    }

    // Criar o elemento script
    var script = document.createElement("script");
    script.type = "text/javascript";
    script.src = url;
    script.onload = function () {
      loadedDependencies[url] = true;
      if (callback) callback();
    };
    script.onerror = function () {
      console.error("Erro ao carregar: " + url);
      if (callback) callback(new Error("Falha ao carregar script: " + url));
    };
    document.head.appendChild(script);
  }

  /**
   * Carrega um estilo CSS de forma assíncrona
   * @param {string} url - URL do estilo a ser carregado
   * @param {function} callback - Função a ser chamada após o carregamento
   */
  function carregarEstilo(url, callback) {
    // Verificar se o estilo já está carregado
    if (loadedDependencies[url]) {
      if (callback) setTimeout(callback, 0);
      return;
    }

    // Verificar no DOM se o estilo já está carregado
    var links = document.getElementsByTagName("link");
    for (var i = 0; i < links.length; i++) {
      if (links[i].href.indexOf(url) !== -1) {
        loadedDependencies[url] = true;
        if (callback) setTimeout(callback, 0);
        return;
      }
    }

    // Criar o elemento link
    var link = document.createElement("link");
    link.rel = "stylesheet";
    link.href = url;
    link.onload = function () {
      loadedDependencies[url] = true;
      if (callback) callback();
    };
    link.onerror = function () {
      console.error("Erro ao carregar estilo: " + url);
      if (callback) callback(new Error("Falha ao carregar estilo: " + url));
    };
    document.head.appendChild(link);
  }

  /**
   * Cria um novo componente de dashboard
   * @param {object} config - Configuração do componente
   * @returns {object} - Instância do componente
   */
  function createComponent(config) {
    // Configuração padrão
    var defaultConfig = {
      nome: "ComponenteSemNome",
      dependencias: [], // Array de URLs de scripts e estilos
      containerId: "", // ID do container do componente
      cardId: "", // ID do card que contém o componente
      path: "", // Caminho do componente para favoritos
      titulo: "", // Título do componente para favoritos
      debug: false, // Modo de debug
    };

    // Mesclar configuração padrão com a fornecida
    config = Object.assign({}, defaultConfig, config || {});

    // Gerar ID único se não fornecido
    var componentId = config.nome + "-" + ++componentCounter;

    // Dados e estado interno do componente
    var dadosGlobais = null;
    var componenteInicializado = false;
    var dependenciasCarregadas = false;
    var callbacksDependencias = [];

    

    /**
     * Verificar e carregar todas as dependências
     * @param {function} callback - Função a ser chamada após todas as dependências carregadas
     */
    function verificarDependencias(callback) {
      if (dependenciasCarregadas) {
        if (callback) callback();
        return;
      }

      // Se não há dependências, marcar como carregado
      if (!config.dependencias || config.dependencias.length === 0) {
        dependenciasCarregadas = true;
        if (callback) callback();
        return;
      }

      // Adicionar callback à fila
      if (callback) {
        callbacksDependencias.push(callback);
      }

      // Se já estamos carregando, não iniciar novamente
      if (callbacksDependencias.length > 1) {
        return;
      }

     

      var dependenciasPendentes = config.dependencias.length;

      // Função para verificar se todas as dependências foram carregadas
      function verificarConclusao() {
        dependenciasPendentes--;
        if (dependenciasPendentes === 0) {
         
          dependenciasCarregadas = true;

          // Chamar todos os callbacks registrados
          callbacksDependencias.forEach(function (cb) {
            cb();
          });
          callbacksDependencias = [];
        }
      }

      // Carregar cada dependência
      config.dependencias.forEach(function (dep) {
        // Verificar o tipo de dependência pela extensão
        if (dep.toLowerCase().endsWith(".js")) {
          carregarScript(dep, verificarConclusao);
        } else if (dep.toLowerCase().endsWith(".css")) {
          carregarEstilo(dep, verificarConclusao);
        } else {
          
          verificarConclusao();
        }
      });
    }

    // API pública do componente
    var componentAPI = {
      /**
       * Obtém o ID do componente
       * @returns {string} - ID do componente
       */
      getId: function () {
        return componentId;
      },

      /**
       * Obtém o nome do componente
       * @returns {string} - Nome do componente
       */
      getNome: function () {
        return config.nome;
      },

      /**
       * Obtém o ID do container do componente
       * @returns {string} - ID do container
       */
      getContainerId: function () {
        return config.containerId;
      },

      /**
       * Inicializa o componente carregando suas dependências
       * @param {function} callback - Função chamada após inicialização
       */
      init: function (callback) {
        if (componenteInicializado) {
          if (callback) callback();
          return componentAPI;
        }


        verificarDependencias(function (err) {
          if (err) {
            console.error("Erro ao carregar dependências:", err);
            return;
          }

          try {
           
            componenteInicializado = true;

            // Inicializar ícone favorito se possível
            if (
              config.cardId &&
              config.path &&
              config.titulo &&
              typeof initFavoriteIcon === "function"
            ) {
              try {
                initFavoriteIcon(config.cardId, config.path, config.titulo);
              } catch (e) {
                console.error("Erro ao inicializar ícone de favorito:", e);
              }
            }

            if (callback) callback();

            // Se já temos dados, atualizar o componente
            if (dadosGlobais) {
              componentAPI.atualizar(dadosGlobais);
            }

            // Verificar dados globais da página
            else if (window.dadosAtuais) {
              componentAPI.atualizar(window.dadosAtuais);
            }
          } catch (e) {
            console.error("Erro ao inicializar componente:", e);
          }
        });

        return componentAPI;
      },

      /**
       * Carrega dados via AJAX usando os parâmetros fornecidos
       * @param {object} params - Parâmetros para a chamada AJAX
       * @param {function} callback - Função chamada após carregar os dados
       */
      carregarDados: function (params, callback) {
       

        params = params || {};

        // Usar valores globais se disponíveis
        var ano = params.ano || window.anoSelecionado || "Todos";
        var mcuOrigem = params.mcuOrigem || window.mcuSelecionado || "Todos";
        var statusFiltro =
          params.statusFiltro || window.statusSelecionado || "Todos";

        // Se tivermos um container, mostrar indicador de carregamento
        if (config.containerId) {
          var containerEl = document.getElementById(config.containerId);
          if (containerEl) {
            $(containerEl).html(
              '<div class="loader-placeholder" style="text-align:center;padding:20px;"><i class="fas fa-spinner fa-spin"></i> Carregando dados...</div>'
            );
          }
        }

        // Fazer a chamada AJAX para buscar os dados
        $.ajax({
          url: "cfc/pc_cfcProcessosDashboard.cfc?method=getEstatisticasDetalhadas&returnformat=json",
          method: "POST",
          data: {
            ano: ano,
            mcuOrigem: mcuOrigem,
            statusFiltro: statusFiltro,
          },
          dataType: "json",
          success: function (dados) {
            

            // Armazenar dados globalmente
            dadosGlobais = dados;

            // Se o componente foi inicializado, atualizar com os novos dados
            if (componenteInicializado) {
              componentAPI.atualizar(dados);
            }

            // Chamar o callback se fornecido
            if (callback) callback(dados);
          },
          error: function (xhr, status, error) {
          

            // Se tivermos um container, mostrar mensagem de erro
            if (config.containerId) {
              var containerEl = document.getElementById(config.containerId);
              if (containerEl) {
                $(containerEl).html(
                  '<div class="alert alert-danger">Erro ao carregar dados: ' +
                    error +
                    "</div>"
                );
              }
            }

            if (callback) callback(null, error);
          },
        });

        return componentAPI;
      },

      /**
       * Método para ser sobrescrito pelos componentes específicos
       * @param {object} dados - Dados para atualizar o componente
       */
      atualizar: function (dados) {
        return componentAPI;
      },

      /**
       * Registra o componente no sistema global
       */
      registrar: function () {
        // Registrar no array global de componentes
        if (typeof window.atualizarDadosComponentes === "undefined") {
          window.atualizarDadosComponentes = [];
        }

        // Adicionar a função de atualização ao array global se ainda não estiver lá
        var encontrado = false;
        for (var i = 0; i < window.atualizarDadosComponentes.length; i++) {
          if (
            window.atualizarDadosComponentes[i].toString() ===
            componentAPI.atualizar.toString()
          ) {
            encontrado = true;
            break;
          }
        }

        if (!encontrado) {
          window.atualizarDadosComponentes.push(componentAPI.atualizar);
        }

        // Compatibilidade com o sistema de notificação existente
        if (
          config.notificationKey &&
          typeof window.componentesCarregados !== "undefined"
        ) {
          window.componentesCarregados[config.notificationKey] = true;

          // Verificar condições de carregamento para callbacks globais
          if (
            config.notificationCheck &&
            typeof window.atualizarDados === "function"
          ) {
            var checkResult = false;
            try {
              checkResult = eval(config.notificationCheck);
            } catch (e) {
              console.error("Erro ao avaliar notificationCheck:", e);
            }

            if (checkResult) {
              window.atualizarDados();
            }
          }
        }

        // Registrar no cache global
        registeredComponents[componentId] = componentAPI;

        return componentAPI;
      },
    };

    return componentAPI;
  }

  // API pública da fábrica
  return {
    /**
     * Cria um novo componente de dashboard
     * @param {object} config - Configuração do componente
     * @returns {object} - Instância do componente
     */
    criar: createComponent,

    /**
     * Obtém um componente pelo ID
     * @param {string} id - ID do componente
     * @returns {object} - Instância do componente ou null se não encontrado
     */
    obter: function (id) {
      return registeredComponents[id] || null;
    },

    /**
     * Obtém todos os componentes registrados
     * @returns {object} - Objeto com todos os componentes registrados
     */
    obterTodos: function () {
      return Object.assign({}, registeredComponents);
    },

    /**
     * Inicializa um componente específico para dashboard de favoritos
     * @param {string} tipo - Tipo de componente ('metricas', 'status', 'tipos', 'classificacao', 'orgaos', 'graficos')
     * @param {string} containerId - ID do container do componente
     * @param {string} widgetId - ID do widget no grid
     * @returns {object} - Instância do componente inicializado ou null em caso de erro
     */
    inicializarComponenteFavorito: function (tipo, containerId, widgetId) {
      try {
      
        if (!tipo || !containerId) {
          console.error(
            "[DashboardComponentFactory] Tipo ou containerId não especificados"
          );
          return null;
        }

        // Configuração padrão baseada no tipo de componente
        var config = {
          nome: tipo.charAt(0).toUpperCase() + tipo.slice(1) + "Favorito",
          dependencias: [],
          containerId: containerId,
          cardId: widgetId || "widget-" + tipo,
          debug: false,
        };

        // Configurações específicas por tipo de componente
        switch (tipo.toLowerCase()) {
          case "metricas":
            config.path =
              "includes/pc_dashboard_processo/pc_dashboard_cards_metricas_processo.cfm";
            config.titulo = "Indicadores de Processos";
            break;
          case "status":
            config.path =
              "includes/pc_dashboard_processo/pc_dashboard_distribuicao_status.cfm";
            config.titulo = "Distribuição de Processos por Status";
            break;
          case "tipos":
            config.path =
              "includes/pc_dashboard_processo/pc_dashboard_tipos_processo.cfm";
            config.titulo = "Tipos de Processos";
            break;
          case "classificacao":
            config.path =
              "includes/pc_dashboard_processo/pc_dashboard_classificacao_processo.cfm";
            config.titulo = "Classificação de Processos";
            break;
          case "orgaos":
            config.path =
              "includes/pc_dashboard_processo/pc_dashboard_orgaos_processo.cfm";
            config.titulo = "Órgãos Avaliados";
            break;
          case "graficos":
            config.path =
              "includes/pc_dashboard_processo/pc_dashboard_graficos_processo.cfm";
            config.titulo = "Gráficos";
            // Adicionar dependência do Chart.js para os gráficos
            config.dependencias = ["plugins/chart.js/Chart.min.js"];
            break;
          default:
            console.error(
              "[DashboardComponentFactory] Tipo de componente desconhecido:",
              tipo
            );
            return null;
        }

        // Criar o componente com a configuração
        var componente = createComponent(config);

        // Customizar método de atualização com base no tipo
        switch (tipo.toLowerCase()) {
          case "metricas":
            componente.atualizar = function (dados) {
              if (!dados) return componente;
              const totalProcessos = parseInt(dados.totalProcessos) || 0;
              const elTotalProcessos =
                document.getElementById("totalProcessos");
              if (
                elTotalProcessos &&
                typeof window.animateNumberValue === "function"
              ) {
                window.animateNumberValue(
                  elTotalProcessos,
                  0,
                  totalProcessos,
                  1000
                );
              } else if (elTotalProcessos) {
                elTotalProcessos.textContent = totalProcessos;
              }
              return componente;
            };
            break;
          case "status":
            componente.atualizar = function (dados) {
              if (
                !dados ||
                !dados.distribuicaoStatus ||
                !dados.distribuicaoStatus.length
              ) {
                $("#" + containerId).html(
                  '<div class="sem-dados-status">Nenhum dado disponível para os filtros selecionados.</div>'
                );
                return componente;
              }

              var statusData = dados.distribuicaoStatus;
              let htmlStatus = "";

              statusData.forEach(function (status) {
                // Determinar o ícone com base no ID do status
                let statusIcon = "fas fa-question-circle";
                let statusClass = "bg-secondary";

                switch (parseInt(status.id)) {
                  case 1:
                    statusIcon = "fas fa-calendar-check";
                    statusClass = "bg-warning";
                    break;
                  case 2:
                    statusIcon = "fas fa-tasks";
                    statusClass = "bg-info";
                    break;
                  case 3:
                    statusIcon = "fas fa-clipboard-check";
                    statusClass = "bg-info";
                    break;
                  case 4:
                    statusIcon = "fas fa-check-circle";
                    statusClass = "bg-success";
                    break;
                  case 5:
                    statusIcon = "fas fa-award";
                    statusClass = "bg-success";
                    break;
                  case 6:
                    statusIcon = "fas fa-times-circle";
                    statusClass = "bg-danger";
                    break;
                  case 7:
                    statusIcon = "fas fa-pause-circle";
                    statusClass = "bg-secondary";
                    break;
                }

                if (status.estilo && status.estilo.trim() !== "") {
                  statusClass = "";
                }

                htmlStatus += `
                <div class="status-card-col">
                  <div class="status-card ${statusClass}" style="${
                  status.estilo || ""
                }">
                    <div class="status-info">
                      <div class="status-number">${status.quantidade}</div>
                      <div class="status-label" title="${status.descricao}">${
                  status.descricao
                }</div>
                    </div>
                    <div class="status-icon">
                      <i class="${statusIcon}"></i>
                    </div>
                  </div>
                </div>`;
              });

              $("#" + containerId).html(htmlStatus);
              return componente;
            };
            break;
          case "tipos":
            componente.atualizar = function (dados) {
              if (
                !dados ||
                !dados.distribuicaoTipos ||
                !dados.distribuicaoTipos.length
              ) {
                $("#" + containerId).html(
                  '<div class="sem-dados-tipos">Nenhum tipo de processo disponível para os filtros selecionados.</div>'
                );
                return componente;
              }

              const coresTipos = [
                "#007bff",
                "#6f42c1",
                "#e83e8c",
                "#fd7e14",
                "#20c997",
                "#17a2b8",
                "#28a745",
                "#ffc107",
                "#dc3545",
              ];

              let tiposData = [...dados.distribuicaoTipos].sort(
                (a, b) => b.quantidade - a.quantidade
              );
              const anoSelecionado = window.anoSelecionado || "Todos";

              // Limitar a 10 itens se ano for "Todos"
              if (anoSelecionado === "Todos" && tiposData.length > 10) {
                tiposData = tiposData.slice(0, 10);
              }

              const totalProcessos = dados.totalProcessos || 0;
              let htmlTipos = "";

              tiposData.forEach(function (tipo, index) {
                const percentual =
                  totalProcessos > 0
                    ? ((tipo.quantidade / totalProcessos) * 100).toFixed(1)
                    : 0;
                const corIndex = index % coresTipos.length;
                const corTipo = coresTipos[corIndex];

                htmlTipos += `
                <div class="tipo-processo-item">
                  <div class="tipo-processo-badge" style="background-color: ${corTipo}; color: white;">
                    ${index + 1}
                  </div>
                  <div class="tipo-processo-info">
                    <div class="tipo-processo-descricao">${tipo.descricao}</div>
                    <div class="tipo-processo-metricas">
                      <div class="tipo-processo-quantidade">${
                        tipo.quantidade
                      } <span class="tipo-processo-label">processo(s)</span></div>
                      <div class="tipo-processo-percentual">${percentual}% dos processos</div>
                    </div>
                    <div class="tipo-processo-grafico-barra">
                      <div class="tipo-processo-grafico-progresso" style="width: ${percentual}%; background: linear-gradient(90deg, ${corTipo}, ${corTipo}CC);"></div>
                    </div>
                  </div>
                </div>`;
              });

              $("#" + containerId).html(htmlTipos);
              return componente;
            };
            break;
          case "classificacao":
            componente.atualizar = function (dados) {
              if (
                !dados ||
                !dados.distribuicaoClassificacao ||
                !dados.distribuicaoClassificacao.length
              ) {
                $("#" + containerId).html(
                  '<div class="sem-dados-classificacao">Nenhuma classificação disponível para os filtros selecionados.</div>'
                );
                return componente;
              }

              const coresClassificacao = [
                "#6f42c1",
                "#007bff",
                "#e83e8c",
                "#fd7e14",
                "#20c997",
                "#17a2b8",
                "#28a745",
                "#ffc107",
                "#dc3545",
              ];

              const classificacaoData = dados.distribuicaoClassificacao;
              const totalProcessos = dados.totalProcessos || 0;

              let htmlClassificacao = "";

              classificacaoData.forEach(function (classificacao, index) {
                const percentual =
                  totalProcessos > 0
                    ? (
                        (classificacao.quantidade / totalProcessos) *
                        100
                      ).toFixed(1)
                    : 0;
                const corIndex = index % coresClassificacao.length;
                const corClassificacao = coresClassificacao[corIndex];

                htmlClassificacao += `
                <div class="classificacao-item">
                  <div class="classificacao-badge" style="background-color: ${corClassificacao}; color: white;">
                    ${index + 1}
                  </div>
                  <div class="classificacao-info">
                    <div class="classificacao-descricao">${
                      classificacao.descricao
                    }</div>
                    <div class="classificacao-metricas">
                      <div class="classificacao-quantidade">${
                        classificacao.quantidade
                      } <span class="classificacao-label">processo(s)</span></div>
                      <div class="classificacao-percentual">${percentual}% dos processos</div>
                    </div>
                    <div class="classificacao-grafico-barra">
                      <div class="classificacao-grafico-progresso" style="width: ${percentual}%; background: linear-gradient(90deg, ${corClassificacao}, ${corClassificacao}CC);"></div>
                    </div>
                  </div>
                </div>`;
              });

              $("#" + containerId).html(htmlClassificacao);
              return componente;
            };
            break;
          case "orgaos":
            componente.atualizar = function (dados) {
              if (
                !dados ||
                !dados.orgaosMaisAvaliados ||
                !dados.orgaosMaisAvaliados.length
              ) {
                $("#" + containerId).html(
                  '<div class="sem-dados">Nenhum dado de órgãos disponível para os filtros selecionados.</div>'
                );
                return componente;
              }

              const coresOrgaos = [
                "#007bff",
                "#6f42c1",
                "#e83e8c",
                "#fd7e14",
                "#20c997",
                "#17a2b8",
                "#28a745",
                "#ffc107",
                "#dc3545",
              ];

              const orgaosOrdenados = [...dados.orgaosMaisAvaliados].sort(
                (a, b) => b.quantidade - a.quantidade
              );

              // Verificar se o ano selecionado é "Todos" para aplicar limite
              let orgaosExibidos = orgaosOrdenados;
              const anoSelecionado = window.anoSelecionado || "Todos";
              if (anoSelecionado === "Todos" && orgaosOrdenados.length > 10) {
                orgaosExibidos = orgaosOrdenados.slice(0, 10);
              }

              // Usar o total geral de processos fornecido pelos dados
              const totalProcessos =
                dados.totalProcessos ||
                orgaosExibidos.reduce((sum, o) => sum + o.quantidade, 0);

              // Encontrar o maior valor entre os órgãos exibidos para cálculo da barra de progresso
              const maxQuantidade =
                orgaosExibidos.length > 0 ? orgaosExibidos[0].quantidade : 0;

              let html = "";

              orgaosExibidos.forEach((orgao, index) => {
                if (
                  !orgao.sigla ||
                  !orgao.mcu ||
                  orgao.quantidade === undefined
                ) {
                  return; // Skip este item
                }

                const percentual =
                  totalProcessos > 0
                    ? (orgao.quantidade / totalProcessos) * 100
                    : 0;
                const larguraBarra =
                  maxQuantidade > 0
                    ? (orgao.quantidade / maxQuantidade) * 100
                    : 0;
                const corIndex = index % coresOrgaos.length;
                const corOrgao = coresOrgaos[corIndex];

                html += `
                <div class="orgao-card" style="--animOrder: ${index}">
                  <div class="orgao-posicao" style="background-color: ${corOrgao};">${
                  index + 1
                }</div>
                  <div class="orgao-info">
                    <div class="orgao-sigla">${orgao.sigla}
                      <span class="orgao-badge">${orgao.mcu}</span>
                    </div>
                    <div class="orgao-metricas">
                      <div class="orgao-quantidade">${
                        orgao.quantidade
                      } <span class="orgao-label">processo(s)</span></div>
                      <div class="orgao-percentual">${percentual.toFixed(
                        1
                      )}% do total</div>
                    </div>
                    <div class="orgao-grafico-barra">
                      <div class="orgao-grafico-progresso" style="width: ${larguraBarra}%; background: linear-gradient(90deg, ${corOrgao}, ${corOrgao}CC);"></div>
                    </div>
                  </div>
                </div>`;
              });

              if (html === "") {
                html = `<div class="sem-dados">Não foi possível exibir órgãos com os dados fornecidos.</div>`;
              }

              $("#" + containerId).html(html);
              return componente;
            };
            break;
          case "graficos":
            componente.atualizar = function (dados) {
              if (!dados) return componente;

              // Remove indicador de carregamento
              $("#" + containerId + " .tab-loader").hide();

              // Função interna para renderizar gráficos
              setTimeout(() => {
                try {
                  // Verificar se chart.js está carregado
                  if (typeof Chart === "undefined") {
                    console.error(
                      "[Dashboard Gráficos] Chart.js não está carregado"
                    );
                    $("#" + containerId).html(
                      '<div class="alert alert-warning">Biblioteca Chart.js não disponível</div>'
                    );
                    return;
                  }

                  // Configurar canvas para os gráficos
                  const containerId1 = containerId + "-evolucao";
                  const containerId2 = containerId + "-classificacao";

                  // Estrutura básica dos containers de gráficos
                  $("#" + containerId).html(`
                    <div class="row">
                      <div class="col-md-6">
                        <div class="chart-card">
                          <h5 class="chart-title"><i class="fas fa-chart-line"></i>Evolução Anual de Processos</h5>
                          <div class="chart-container" id="${containerId1}-container"></div>
                        </div>
                      </div>
                      <div class="col-md-6">
                        <div class="chart-card">
                          <h5 class="chart-title"><i class="fas fa-chart-pie"></i>Distribuição por Classificação</h5>
                          <div class="chart-container" id="${containerId2}-container"></div>
                        </div>
                      </div>
                    </div>
                  `);

                  // Criar canvas para os gráficos
                  $(`#${containerId1}-container`).html(
                    `<canvas id="${containerId1}" height="250"></canvas>`
                  );
                  $(`#${containerId2}-container`).html(
                    `<canvas id="${containerId2}" height="250"></canvas>`
                  );

                  // Renderizar gráficos se existirem dados
                  if (dados.evolucaoMensal && dados.evolucaoMensal.length > 0) {
                    // Agrupar dados por ano para evolução anual
                    const dadosPorAno = {};
                    dados.evolucaoMensal.forEach((d) => {
                      let partes = d.periodo.split("/");
                      let ano = partes[2];

                      if (!dadosPorAno[ano]) dadosPorAno[ano] = 0;
                      dadosPorAno[ano] += parseInt(d.quantidade);
                    });

                    // Converter para arrays para o gráfico
                    const labels = Object.keys(dadosPorAno).sort();
                    const quantidades = labels.map((ano) => dadosPorAno[ano]);

                    // Criar gráfico de barras para evolução anual
                    new Chart(document.getElementById(containerId1), {
                      type: "bar",
                      data: {
                        labels: labels,
                        datasets: [
                          {
                            label: "Quantidade de Processos",
                            data: quantidades,
                            backgroundColor: "rgba(0, 123, 255, 0.7)",
                            borderColor: "#007bff",
                            borderWidth: 1,
                          },
                        ],
                      },
                      options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: { y: { beginAtZero: true } },
                        plugins: { legend: { display: true } },
                      },
                    });
                  } else {
                    $(`#${containerId1}-container`).html(
                      '<div class="no-data"><i class="fas fa-chart-line"></i><p>Não há dados disponíveis</p></div>'
                    );
                  }

                  // Gráfico de distribuição por classificação
                  if (
                    dados.distribuicaoClassificacao &&
                    dados.distribuicaoClassificacao.length > 0
                  ) {
                    // Preparar dados para o gráfico
                    const coresDiversas = [
                      "#007bff",
                      "#6f42c1",
                      "#e83e8c",
                      "#fd7e14",
                      "#20c997",
                      "#17a2b8",
                      "#28a745",
                      "#ffc107",
                      "#dc3545",
                      "#6c757d",
                    ];

                    const labels = dados.distribuicaoClassificacao.map(
                      (d) => d.descricao
                    );
                    const valores = dados.distribuicaoClassificacao.map(
                      (d) => d.quantidade
                    );
                    const cores = coresDiversas.slice(0, labels.length);

                    // Criar gráfico de pizza para classificação
                    new Chart(document.getElementById(containerId2), {
                      type: "doughnut",
                      data: {
                        labels: labels,
                        datasets: [
                          {
                            data: valores,
                            backgroundColor: cores,
                            borderColor: "#fff",
                            borderWidth: 1,
                          },
                        ],
                      },
                      options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                          legend: { display: true, position: "right" },
                        },
                      },
                    });
                  } else {
                    $(`#${containerId2}-container`).html(
                      '<div class="no-data"><i class="fas fa-chart-pie"></i><p>Não há dados disponíveis</p></div>'
                    );
                  }
                } catch (e) {
                  console.error(
                    "[Dashboard Gráficos] Erro ao renderizar gráficos:",
                    e
                  );
                  $("#" + containerId).html(
                    `<div class="alert alert-danger">Erro ao renderizar gráficos: ${e.message}</div>`
                  );
                }
              }, 200);

              return componente;
            };
            break;
        }

        // Inicializar o componente
        componente.init();

        // Registrar funções de atualização global (se houver)
        switch (tipo.toLowerCase()) {
          case "metricas":
            window.atualizarCardsProcMet = componente.atualizar;
            break;
          case "status":
            window.atualizarDistribuicaoStatus = componente.atualizar;
            break;
          case "tipos":
            window.atualizarTiposProcesso = componente.atualizar;
            break;
          case "classificacao":
            window.atualizarClassificacaoProcesso = componente.atualizar;
            break;
          case "orgaos":
            window.atualizarViewOrgaos = componente.atualizar;
            break;
          case "graficos":
            window.atualizarGraficos = componente.atualizar;
            break;
        }

        // Adicionar à lista global de funções de atualização
        if (typeof window.atualizarDadosComponentes === "undefined") {
          window.atualizarDadosComponentes = [];
        }
        window.atualizarDadosComponentes.push(componente.atualizar);

       
        return componente;
      } catch (error) {
        console.error(
          "[DashboardComponentFactory] Erro ao inicializar componente favorito:",
          error
        );
        return null;
      }
    },
  };
})();
