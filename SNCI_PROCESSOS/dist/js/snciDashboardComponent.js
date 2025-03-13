/**
 * Fábrica simplificada de componentes de dashboard
 * API flexível para gerenciar componentes independentes
 * Compatível com GridStack.js v11.4.0
 * @version 2.0.0
 */
var DashboardComponentFactory = (function () {
  // Contador global para IDs únicos
  var componentCounter = 0;

  // Cache de componentes registrados
  var registeredComponents = {};

  // Cache de dependências carregadas
  var loadedDependencies = {};

  /**
   * Carrega um script JavaScript de forma assíncrona
   * @param {string} url - URL do script a ser carregado
   * @param {function} callback - Função a ser chamada após o carregamento
   */
  function loadScript(url, callback) {
    if (loadedDependencies[url]) {
      if (callback) setTimeout(callback, 0);
      return;
    }

    const scripts = document.getElementsByTagName("script");
    for (let i = 0; i < scripts.length; i++) {
      if (scripts[i].src.indexOf(url) !== -1) {
        loadedDependencies[url] = true;
        if (callback) setTimeout(callback, 0);
        return;
      }
    }

    const script = document.createElement("script");
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
  function loadStyle(url, callback) {
    if (loadedDependencies[url]) {
      if (callback) setTimeout(callback, 0);
      return;
    }

    const links = document.getElementsByTagName("link");
    for (let i = 0; i < links.length; i++) {
      if (links[i].href.indexOf(url) !== -1) {
        loadedDependencies[url] = true;
        if (callback) setTimeout(callback, 0);
        return;
      }
    }

    const link = document.createElement("link");
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
   * Carrega dependências assíncronas (scripts e estilos)
   * @param {Array} dependencies - Array de URLs de dependências
   * @param {function} callback - Função a ser chamada após todas as dependências serem carregadas
   */
  function loadDependencies(dependencies, callback) {
    if (!dependencies || dependencies.length === 0) {
      if (callback) setTimeout(callback, 0);
      return;
    }

    let pendingDependencies = dependencies.length;

    dependencies.forEach(function (dep) {
      const checkLoaded = function (err) {
        pendingDependencies--;
        if (pendingDependencies === 0) {
          if (callback) callback();
        }
      };

      if (dep.toLowerCase().endsWith(".js")) {
        loadScript(dep, checkLoaded);
      } else if (dep.toLowerCase().endsWith(".css")) {
        loadStyle(dep, checkLoaded);
      } else {
        checkLoaded();
      }
    });
  }

  /**
   * Cria um novo componente de dashboard
   * @param {object} config - Configuração do componente
   * @returns {object} - API do componente
   */
  function createComponent(config) {
    // Configuração padrão
    const defaultConfig = {
      id: "component-" + ++componentCounter,
      nome: "GenericComponent",
      dependencias: [],
      containerId: "",
      cardId: "",
      path: "",
      titulo: "",
      dataUrl: "", // URL deve ser especificada por quem usa o componente
      dataMethod: "POST", // Método HTTP padrão
      debug: false,
    };

    // Mesclar configurações
    config = Object.assign({}, defaultConfig, config || {});

    // Estado interno
    let isInitialized = false;
    let componentData = null;

    // API pública do componente
    const componentAPI = {
      /**
       * Obtém o ID do componente
       * @returns {string} ID do componente
       */
      getId: function () {
        return config.id;
      },

      /**
       * Obtém o nome do componente
       * @returns {string} Nome do componente
       */
      getNome: function () {
        return config.nome;
      },

      /**
       * Obtém o container do componente
       * @returns {string} Container do componente
       */
      getContainer: function () {
        return config.containerId;
      },

      /**
       * Inicializa o componente carregando suas dependências
       * @param {function} callback - Função chamada após inicialização
       * @returns {object} API do componente (para encadeamento)
       */
      init: function (callback) {
        if (isInitialized) {
          if (callback) setTimeout(callback, 0);
          return componentAPI;
        }

        loadDependencies(config.dependencias, function (err) {
          isInitialized = true;
          if (componentData) {
            componentAPI.atualizar(componentData);
          }
          if (callback) callback(err);
        });

        return componentAPI;
      },

      /**
       * Atualiza o componente com novos dados
       * @param {any} data - Dados para atualizar o componente
       * @returns {object} API do componente (para encadeamento)
       */
      atualizar: function (data) {
        componentData = data;
        return componentAPI;
      },

      /**
       * Carrega dados via AJAX
       * @param {object} params - Parâmetros para a requisição
       * @param {function} callback - Função chamada após carregar dados
       * @param {string} [url] - URL opcional para sobrescrever a configuração
       * @returns {object} API do componente (para encadeamento)
       */
      carregarDados: function (params, callback, url) {
        // Usar a URL fornecida ou a configurada no componente
        const dataUrl = url || config.dataUrl;

        if (!dataUrl) {
          console.error(
            "URL de dados não fornecida para o componente",
            config.nome
          );
          if (callback) callback(new Error("URL de dados não fornecida"));
          return componentAPI;
        }

        // Mostrar indicador de carregamento se houver um container específico
        if (config.containerId) {
          const container = document.getElementById(config.containerId);
          if (container) {
            $(container).html(
              '<div class="loader-placeholder text-center p-3"><i class="fas fa-spinner fa-spin"></i> Carregando dados...</div>'
            );
          }
        }

        $.ajax({
          url: dataUrl,
          method: config.dataMethod || "POST",
          data: params || {},
          dataType: "json",
          success: function (data) {
            componentData = data;
            if (isInitialized) {
              componentAPI.atualizar(data);
            }
            if (callback) callback(null, data);
          },
          error: function (xhr, status, error) {
            console.error(
              "Erro ao carregar dados para componente",
              config.nome,
              error
            );

            // Mostrar erro no container, se existir
            if (config.containerId) {
              const container = document.getElementById(config.containerId);
              if (container) {
                $(container).html(
                  '<div class="alert alert-danger">Erro ao carregar dados: ' +
                    error +
                    "</div>"
                );
              }
            }

            if (callback) callback(error);
          },
        });

        return componentAPI;
      },

      /**
       * Registra o componente no sistema global
       * @returns {object} API do componente (para encadeamento)
       */
      registrar: function () {
        // Registrar no array global de atualizadores
        if (typeof window.atualizarDadosComponentes === "undefined") {
          window.atualizarDadosComponentes = [];
        }

        // Adicionar a função de atualização ao array global
        window.atualizarDadosComponentes.push(componentAPI.atualizar);

        // Registrar no cache de componentes
        registeredComponents[config.id] = componentAPI;

        return componentAPI;
      },

      /**
       * Define uma configuração personalizada
       * @param {string} key - Chave da configuração
       * @param {any} value - Valor da configuração
       * @returns {object} API do componente (para encadeamento)
       */
      setConfig: function (key, value) {
        config[key] = value;
        return componentAPI;
      },

      /**
       * Obtém uma configuração personalizada
       * @param {string} key - Chave da configuração
       * @returns {any} Valor da configuração
       */
      getConfig: function (key) {
        return config[key];
      },

      /**
       * Obtém todas as configurações
       * @returns {object} Configurações completas
       */
      getConfigs: function () {
        return Object.assign({}, config);
      },
    };

    return componentAPI;
  }

  // API pública da fábrica
  return {
    /**
     * Cria um novo componente
     * @param {object} config - Configuração do componente
     * @returns {object} API do componente
     */
    criar: createComponent,

    /**
     * Obtém um componente pelo ID
     * @param {string} id - ID do componente
     * @returns {object} API do componente
     */
    obter: function (id) {
      return registeredComponents[id];
    },

    /**
     * Obtém todos os componentes registrados
     * @returns {object} Objeto com todos os componentes
     */
    obterTodos: function () {
      return Object.assign({}, registeredComponents);
    },

    /**
     * Carrega uma dependência (script ou estilo)
     * @param {string} url - URL da dependência
     * @param {function} callback - Função chamada após carregamento
     */
    carregarDependencia: function (url, callback) {
      if (url.toLowerCase().endsWith(".js")) {
        loadScript(url, callback);
      } else if (url.toLowerCase().endsWith(".css")) {
        loadStyle(url, callback);
      } else {
        if (callback) setTimeout(callback, 0);
      }
    },
  };
})();
