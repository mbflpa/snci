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

    // Log interno
    function log(mensagem) {
      if (config.debug) {
        console.log(`[${config.nome}] ${mensagem}`);
      }
    }

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

      log("Carregando dependências: " + config.dependencias.join(", "));

      var dependenciasPendentes = config.dependencias.length;

      // Função para verificar se todas as dependências foram carregadas
      function verificarConclusao() {
        dependenciasPendentes--;
        if (dependenciasPendentes === 0) {
          log("Todas as dependências carregadas com sucesso");
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
          log("Tipo de dependência desconhecido: " + dep);
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

        log("Inicializando componente");

        verificarDependencias(function (err) {
          if (err) {
            console.error("Erro ao carregar dependências:", err);
            return;
          }

          try {
            log("Componente inicializado com sucesso");
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
        log("Carregando dados");

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
            log("Dados recebidos com sucesso");

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
            log("Erro ao carregar dados: " + error);

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
        log("Método 'atualizar' chamado, mas não implementado");
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
  };
})();
