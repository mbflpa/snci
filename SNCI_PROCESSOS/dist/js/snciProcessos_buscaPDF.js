// Variáveis globais para controle da busca
let searchCanceled = false;
let documentProcessing = false;

// Gerenciador de busca em PDFs
const PdfSearchManager = {
  currentSearchResults: [],

  // Inicializar o gerenciador
  init: function () {
    this.loadRecentSearches();

    // Verificar se há termos de busca na URL
    const urlParams = new URLSearchParams(window.location.search);
    const searchTerms = urlParams.get("q");
    if (searchTerms) {
      $("#searchTerms").val(searchTerms);
      this.performSearch(searchTerms);
    }
  },

  // Realizar a busca
  performSearch: function (searchTerms) {
    if (!searchTerms) {
      searchTerms = $("#searchTerms").val().trim();
    }

    // Validação dos termos
    if (!searchTerms || searchTerms.length < 3) {
      if (typeof toastr !== "undefined") {
        toastr.warning("Digite pelo menos 3 caracteres para realizar a busca.");
      } else {
        alert("Digite pelo menos 3 caracteres para realizar a busca.");
      }
      return;
    }

    // Obter as opções de busca selecionadas - ATUALIZADO
    const searchOptions = {
      mode: $('input[name="searchMode"]:checked').val() || "or", // or, exact, proximity
      // Novas opções simplificadas
      useSynonyms: $("#searchUseSynonyms").is(":checked"),
      useSpellingVariants: $("#searchUseSpellingVariants").is(":checked"),
      caseSensitive: $("#searchCaseSensitive").is(":checked"),
      proximityDistance: parseInt($("#proximityDistance").val() || "20"),
      showHighlights: true,
    };

    // NOVO: incluir o ano e o texto do título, se informado
    searchOptions.processYear = $("#searchYear").val().trim();
    searchOptions.titleSearch = $("#searchTitle").val().trim();

    $("#resultsCard").show();
    $("#searchLoading").show();
    $("#searchResults").empty(); // Limpar resultados anteriores
    $("#noResultsAlert").hide();
    $("#errorAlert").hide();
    $("#pdfViewerContainer").hide();
    $("#searchStats").text("");
    $("#realTimeResults").hide(); // Ocultar o container de resultados "em tempo real"

    // Rolar automaticamente para o card de resultados após iniciar a busca
    $("html, body").animate(
      {
        scrollTop: $("#resultsCard").offset().top - 200,
      },
      "slow"
    );

    this.updateUrlWithSearchTerms(searchTerms);
    this.saveRecentSearch(searchTerms);

    // Verificar se o PDF.js está disponível
    if (typeof pdfjsLib !== "undefined") {
      try {
        // Tentar busca no cliente primeiro
        this.searchInClientSide(searchTerms, searchOptions);
      } catch (error) {
        console.error("Erro ao tentar busca no cliente:", error);
        // Se falhar, tenta o método do servidor como fallback
        this.searchInServerSide(searchTerms, searchOptions);
      }
    } else {
      // Se o PDF.js não estiver disponível, usa sempre o servidor
      this.searchInServerSide(searchTerms, searchOptions);
    }
  },

  // Processa os documentos PDF usando PDF.js com extração sequencial página por página
  processDocumentsWithPdfJs: function (
    documents,
    searchTerms,
    startTime,
    searchOptions
  ) {
    const terms = searchTerms.split(" ");
    let processedCount = 0;
    const totalDocuments = documents.length;
    this.currentSearchResults = [];
    let filesRead = 0; // Contador de arquivos que passaram nos filtros

    // Reset do cancelamento de busca
    searchCanceled = false;
    documentProcessing = true;

    // Mostrar o container de resultados em tempo real
    $("#realTimeResults").show();
    $("#realTimeResultsList").empty();

    $("#processingStatus").text(`Buscando em ${totalDocuments} documentos...`);

    // Função para processar um documento por vez
    const processNextDocument = async (index) => {
      // Verificar se a busca foi cancelada
      if (searchCanceled) {
        const searchTime = ((performance.now() - startTime) / 1000).toFixed(2);
        $("#processingStatus").text(
          `Busca cancelada após processar ${processedCount} documentos.`
        );

        // Remover o estado de carregamento do botão cancelar
        $("#cancelSearch")
          .prop("disabled", false)
          .html('<i class="fas fa-times mr-1"></i> Cancelar busca');

        this.displaySearchResults(
          searchTerms,
          searchTime,
          filesRead,
          searchOptions
        );
        documentProcessing = false;
        return;
      }

      if (index >= documents.length) {
        // Finaliza quando todos os documentos forem processados
        const searchTime = ((performance.now() - startTime) / 1000).toFixed(2);

        // Remover o estado de carregamento do botão cancelar
        $("#cancelSearch")
          .prop("disabled", false)
          .html('<i class="fas fa-times mr-1"></i> Cancelar busca');

        this.displaySearchResults(
          searchTerms,
          searchTime,
          filesRead,
          searchOptions
        );
        documentProcessing = false;
        // Rolar automaticamente para o card de resultados
        $("html, body").animate(
          {
            scrollTop: $("#resultsCard").offset().top - 200,
          },
          "slow"
        );
        return;
      }

      const doc = documents[index];
      processedCount++;

      // Atualizar UI
      const progress = Math.round((processedCount / totalDocuments) * 100);
      $("#processingProgress").css("width", `${progress}%`);
      $("#processingStatus").text(
        `Processando: ${processedCount} de ${totalDocuments} (${filesRead} lido(s) até agora)`
      );

      // Pequeno efeito visual de "escaneamento" do documento
      $(".document-item").css(
        "transform",
        `translateY(${index % 2 === 0 ? -5 : 5}px)`
      );
      setTimeout(() => {
        $(".document-item").css("transform", "translateY(0)");
      }, 300);

      // Filtrar por ano do processo, se informado
      if (searchOptions && searchOptions.processYear) {
        const yearMatch = doc.fileName.match(/_PC\d+(\d{4})_/);
        if (!yearMatch || yearMatch[1] !== searchOptions.processYear) {
          processNextDocument(index + 1); // Pula este arquivo
          return;
        }
      }

      // Filtrar por texto no título, se informado (busca exata no título, ignorando case)
      if (
        searchOptions &&
        searchOptions.titleSearch &&
        searchOptions.titleSearch.trim() !== ""
      ) {
        if (
          doc.fileName
            .toLowerCase()
            .indexOf(searchOptions.titleSearch.toLowerCase()) === -1
        ) {
          processNextDocument(index + 1);
          return;
        }
      }

      // Se passou em ambos os filtros, conta este arquivo
      filesRead++;

      // Criar URL para carregar o documento
      const fileUrl = `cfc/pc_cfcBuscaPDF.cfc?method=exibePdfInline&arquivo=${encodeURIComponent(
        doc.filePath
      )}&nome=${encodeURIComponent(doc.fileName)}`;

      try {
        // Carregar PDF usando PDF.js
        const pdf = await pdfjsLib.getDocument({
          url: fileUrl,
        }).promise;

        const pageCount = pdf.numPages;
        let found = false;
        let snippets = [];

        // Expandir termos com sinônimos, se essa opção estiver marcada
        let expandedTerms = searchTerms;
        if (searchOptions.useSynonyms) {
          // Obter sinônimos para os termos de busca
          const terms = searchTerms.split(" ").filter((t) => t.length >= 3);
          const allTerms = new Set(terms);

          // Adicionar sinônimos para cada termo, respeitando case sensitivity
          terms.forEach((term) => {
            const synonyms = this.getSynonyms(term);

            // Adicionar sinônimos com o case apropriado
            synonyms.forEach((syn) => {
              if (searchOptions.caseSensitive) {
                // Se precisamos diferenciar maiúsculas/minúsculas, aplicar o mesmo case do termo original
                allTerms.add(this.matchCase(syn, term));
              } else {
                // Caso contrário, adiciona normalmente
                allTerms.add(syn);
              }
            });
          });

          expandedTerms = Array.from(allTerms).join(" ");
          console.log("Termos expandidos com sinônimos:", expandedTerms);
        }

        // Processar páginas sequencialmente
        for (let i = 1; i <= pageCount; i++) {
          // Verificar cancelamento a cada página
          if (searchCanceled) {
            break;
          }

          // Extrair texto da página atual
          const page = await pdf.getPage(i);
          const content = await page.getTextContent({
            normalizeWhitespace: true,
          });
          const pageText = this.processTextContent(content);

          // Buscar termos na página atual conforme o modo de busca
          let pageSearchResult;

          if (searchOptions.mode === "exact") {
            // Modo de frase exata
            pageSearchResult = this.searchExactPhrase(
              pageText,
              searchTerms,
              searchOptions
            );
          } else if (searchOptions.mode === "proximity") {
            // Modo de proximidade
            const words = searchTerms
              .split(" ")
              .filter((term) => term.length >= 3);
            const proximity = parseInt(searchOptions.proximityDistance);
            pageSearchResult = this.searchProximity(
              pageText,
              words,
              proximity,
              searchOptions
            );
          } else {
            // Modo "OU" (padrão)
            pageSearchResult = this.searchAnyTerm(
              pageText,
              expandedTerms,
              searchOptions
            );
          }

          // Se encontrou na página atual
          if (pageSearchResult.found) {
            found = true;
            snippets.push(...pageSearchResult.snippets);

            // Adicionar informação da página ao snippet
            snippets = snippets.map(
              (snippet) =>
                `<div class="page-info badge badge-light mb-1">Página ${i} de ${pageCount}</div> ${snippet}`
            );

            // Parar a extração, pois já encontramos correspondência
            break;
          }
        }

        if (found) {
          // Criar objeto de resultado otimizado (sem armazenar texto completo)
          const resultObj = {
            fileName: doc.fileName,
            filePath: doc.filePath,
            fileUrl: fileUrl,
            directory: doc.directory || "Diretório PDF",
            size: doc.size,
            pageCount: pageCount,
            dateLastModified: doc.dateLastModified,
            snippets: snippets,
            found: true,
          };

          // Adicionar ao array de resultados
          this.currentSearchResults.push(resultObj);

          // Mostrar resultado em tempo real
          this.addRealTimeResult(resultObj);
        }

        // Processar o próximo documento
        setTimeout(() => processNextDocument(index + 1), 0);
      } catch (error) {
        console.error(`Erro ao processar o documento ${doc.fileName}:`, error);
        // Se ocorrer erro, tentar fallback no servidor
        this.searchSingleDocumentInServer(doc, searchTerms, searchOptions);
        setTimeout(() => processNextDocument(index + 1), 0);
      }
    };

    // Iniciar o processamento com o primeiro documento
    processNextDocument(0);
  },

  // Processar conteúdo de texto do PDF considerando posições
  processTextContent: function (textContent) {
    // Ordenar itens por posição vertical (y) e depois horizontal (x)
    const items = textContent.items.slice();
    const textItems = [];
    // Extrair informações relevantes dos itens
    items.forEach((item) => {
      textItems.push({
        str: item.str,
        x: item.transform[4], // Posição X
        y: item.transform[5], // Posição Y
        width: item.width,
        height: item.height,
      });
    });
    // Ordenar itens primeiro por Y (linhas) e depois por X (posição na linha)
    textItems.sort((a, b) => {
      // Tolerância para considerar itens na mesma linha (geralmente 3-5 unidades)
      const yTolerance = 5;
      // Se estão aproximadamente na mesma linha
      if (Math.abs(a.y - b.y) < yTolerance) {
        return a.x - b.x; // Ordena da esquerda para direita
      }
      return b.y - a.y; // Ordena de cima para baixo (coordenadas Y são invertidas em PDF)
    });
    // Construir o texto final considerando a proximidade dos itens
    let lastY = null;
    let text = "";
    textItems.forEach((item, index) => {
      // Adicionar quebra de linha se for uma nova linha
      if (lastY !== null && Math.abs(item.y - lastY) > 5) {
        text += "\n";
      } else if (index > 0) {
        // Verificar se é preciso adicionar espaço entre palavras na mesma linha
        const lastItem = textItems[index - 1];
        const expectedSpaceWidth = lastItem.width / lastItem.str.length; // Estimativa da largura de um espaço
        // Se a distância entre este item e o anterior for maior que um espaço típico
        if (item.x - (lastItem.x + lastItem.width) > expectedSpaceWidth * 0.5) {
          text += " ";
        }
      }
      text += item.str;
      lastY = item.y;
    });
    // Normalizar espaços múltiplos e espaços no início/fim das linhas
    return text
      .split("\n")
      .map((line) => line.trim())
      .join("\n")
      .replace(/\s+/g, " ") // Substitui sequências de espaços por um único espaço
      .trim();
  },
  // Método para atualizar a animação - removendo o código anterior e deixando o SVG funcionar
  updateCarouselAnimation: function () {
    // A animação do SVG é automática, não precisamos fazer nada aqui
    // As animações SMIL no SVG cuidam de tudo
  },
  // Novo método para adicionar resultados em tempo real
  addRealTimeResult: function (result) {
    // URL direta para visualizar o PDF
    const pdfUrl = `cfc/pc_cfcBuscaPDF.cfc?method=exibePdfInline&arquivo=${encodeURIComponent(
      result.filePath
    )}`;

    // Criar HTML no formato final do resultado
    const resultHTML = `
      <div class="search-result" data-file-path="${
        result.filePath
      }" data-file-url="${pdfUrl}" data-result-id="${
      this.currentSearchResults.length - 1
    }">
        <div class="d-flex justify-content-between align-items-start">
          <h5>
            <a href="${pdfUrl}" target="_blank" class="view-pdf-link">
              <i class="far fa-file-pdf mr-2"></i>${result.fileName}
            </a>
          </h5>
        </div>
        <p class="mb-1 text-muted small">
          <i class="fas fa-folder-open mr-1"></i> ${
            result.directory || "Diretório FAQ"
          }
        </p>
        <div class="search-snippets">
          ${this.formatSnippets(result.snippets)}
        </div>
        
        <div class="d-flex justify-content-between mt-2">
          <div>
            <span class="badge badge-light mr-1">
              <i class="far fa-calendar-alt mr-1"></i> ${this.formatDate(
                result.dateLastModified || new Date()
              )}
            </span>
            <span class="badge badge-light mr-1">
              <i class="fas fa-file-alt mr-1"></i> ${this.formatFileSize(
                result.size || 0
              )}
            </span>
            <span class="badge badge-light">
              <i class="fas fa-file-pdf mr-1"></i> ${
                result.pageCount || "?"
              } página${result.pageCount !== 1 ? "s" : ""}
            </span>
          </div>
        </div>
      </div>
    `;

    // Adicionar o resultado diretamente na área final de resultados
    $("#searchResults").prepend(resultHTML);

    // Atualizar estatísticas em tempo real
    const count = this.currentSearchResults.length;
    $("#searchStats").text(
      `${count} resultado${count !== 1 ? "s" : ""} encontrado${
        count !== 1 ? "s" : ""
      } até o momento...`
    );

    // Se este for o primeiro resultado encontrado, fazer scroll
    if (count === 1) {
      $("html, body").animate(
        {
          scrollTop: $("#searchResults").offset().top - 150,
        },
        "slow"
      );
    }
  },
  // Busca usando o método do servidor
  searchInServerSide: function (searchTerms, searchOptions) {
    $.ajax({
      url: "cfc/pc_cfcBuscaPDF.cfc",
      type: "POST",
      dataType: "json",
      data: {
        method: "searchInPDFs",
        searchTerms: searchTerms,
        searchOptions: JSON.stringify(searchOptions),
      },
      success: (response) => {
        $("#searchLoading").hide();
        // Melhorar o tratamento de respostas não-JSON
        if (typeof response === "string") {
          try {
            // Tentar converter string para JSON
            response = JSON.parse(response);
          } catch (e) {
            // Se falhar, verificar se é resposta HTML de erro
            if (response.includes("<html>") || response.includes("<!DOCTYPE")) {
              console.error(
                "Recebeu HTML em vez de JSON:",
                response.substring(0, 200)
              );
              $("#errorMessage").text(
                "O servidor retornou uma página HTML em vez de JSON. Verifique os logs do servidor."
              );
              $("#errorAlert").show();
              return;
            }
          }
        }
        // Verificar se a resposta é string (possível WDDX) e tentar extrair JSON
        if (typeof response === "string" && response.includes("wddxPacket")) {
          try {
            // Extrair o JSON dentro do WDDX
            const jsonMatch = response.match(/<string>(\{.*?\})<\/string>/s);
            if (jsonMatch && jsonMatch[1]) {
              response = JSON.parse(jsonMatch[1]);
            }
          } catch (e) {
            console.error("Erro ao processar resposta WDDX:", e);
          }
        }
        if (response && response.success) {
          if (response.totalFound > 0) {
            // Adaptar os resultados do servidor para o formato esperado
            this.currentSearchResults = response.results.map((result) => {
              const fileUrl = `cfc/pc_cfcBuscaPDF.cfc?method=exibePdfInline&arquivo=${encodeURIComponent(
                result.filePath
              )}&nome=${encodeURIComponent(result.fileName)}`;
              // Gerar snippets com termos destacados
              const terms = searchTerms.split(" ").filter((t) => t.length >= 3);
              let snippets = [];
              // Usar texto extraído se disponível
              if (result.text) {
                const contextSize = 200;
                // Verificar o modo de busca
                if (searchOptions.mode === "exact") {
                  // Modo de frase exata
                  const phrase = searchTerms.trim();
                  if (phrase.length >= 3) {
                    const regex = new RegExp(this.escapeRegExp(phrase), "gi");
                    let match;
                    // Encontrar até 3 ocorrências da frase
                    let count = 0;
                    let lastIndex = 0;
                    while (
                      count < 3 &&
                      (match = regex.exec(result.text)) !== null
                    ) {
                      const start = Math.max(0, match.index - contextSize);
                      const end = Math.min(
                        result.text.length,
                        match.index + phrase.length + contextSize
                      );
                      let snippet = result.text.substring(start, end);
                      if (start > 0) snippet = "..." + snippet;
                      if (end < result.text.length) snippet += "...";
                      snippet = this.highlightSearchPhrase(snippet, phrase);
                      snippets.push(snippet);
                      count++;
                      if (lastIndex === regex.lastIndex) break;
                      lastIndex = regex.lastIndex;
                    }
                  }
                } else {
                  // Modo "OU" (padrão): processa termos individuais
                  terms.forEach((term) => {
                    const regex = new RegExp(this.escapeRegExp(term), "gi");
                    let match;
                    // Encontrar até 3 ocorrências do termo
                    let count = 0;
                    const lowerText = result.text.toLowerCase();
                    let lastIndex = 0;
                    while (
                      count < 3 &&
                      (match = regex.exec(result.text)) !== null
                    ) {
                      const start = Math.max(0, match.index - contextSize);
                      const end = Math.min(
                        result.text.length,
                        match.index + term.length + contextSize
                      );
                      let snippet = result.text.substring(start, end);
                      if (start > 0) snippet = "..." + snippet;
                      if (end < result.text.length) snippet += "...";
                      snippet = this.highlightSearchTerm(snippet, term);
                      snippets.push(snippet);
                      count++;
                      if (lastIndex === regex.lastIndex) break;
                      lastIndex = regex.lastIndex;
                    }
                  });
                }
              }
              return {
                fileName: result.fileName,
                filePath: result.filePath,
                fileUrl: fileUrl,
                directory: result.displayPath,
                size: result.fileSize,
                dateLastModified: result.fileDate,
                relevanceScore: result.relevanceScore || 10,
                snippets:
                  snippets.length > 0
                    ? snippets
                    : ["<em>Texto não disponível para visualização</em>"],
              };
            });
            this.displaySearchResults(
              searchTerms,
              response.searchTime,
              null,
              searchOptions
            );
          } else {
            $("#noResultsAlert").show();
            $("#searchStats").text(
              `0 resultados encontrados em ${response.searchTime} segundos`
            );
          }
        } else {
          $("#errorMessage").text(
            response.message || "Erro desconhecido na busca"
          );
          $("#errorAlert").show();
        }
      },
      error: (xhr, status, error) => {
        $("#searchLoading").hide();
        // Exibir informações mais detalhadas sobre o erro
        console.error("Detalhes do erro:", xhr.responseText);
        let errorMessage = "Erro ao realizar a busca. ";
        if (xhr.status === 0) {
          errorMessage += "Problemas de conexão de rede.";
        } else if (xhr.status === 404) {
          errorMessage += "Serviço de busca não encontrado.";
        } else if (xhr.status === 500) {
          errorMessage += "Erro interno no servidor.";
        } else {
          errorMessage += `Código: ${xhr.status}, Mensagem: ${
            error || "Desconhecido"
          }`;
        }
        $("#errorMessage").text(errorMessage);
        $("#errorAlert").show();
      },
    });
  },
  // Busca no lado do cliente usando PDF.js
  searchInClientSide: function (searchTerms, searchOptions) {
    const startTime = performance.now();
    $.ajax({
      url: "cfc/pc_cfcBuscaPDF.cfc",
      type: "POST",
      data: {
        method: "listPdfDocuments",
      },
      dataType: "json",
      success: (response) => {
        console.log("Resposta recebida do servidor:", response);
        let parsedResponse = response;
        if (typeof parsedResponse === "string") {
          try {
            parsedResponse = JSON.parse(parsedResponse);
            console.log("Convertido string em objeto JSON:", parsedResponse);
          } catch (e) {
            console.error("Erro ao converter resposta string para objeto:", e);
            if (
              typeof response === "string" &&
              (response.includes("<html") || response.includes("<!DOCTYPE"))
            ) {
              console.error("Recebeu HTML em vez de JSON");
            }
            this.searchInServerSide(searchTerms, searchOptions);
            return;
          }
        }
        const success = parsedResponse.success || parsedResponse.SUCCESS;
        const documents = parsedResponse.documents || parsedResponse.DOCUMENTS;
        if (
          parsedResponse &&
          typeof parsedResponse === "object" &&
          success === true &&
          Array.isArray(documents)
        ) {
          console.log(`Processando ${documents.length} documentos`);
          if (documents.length > 0) {
            const normalizedDocuments = documents.map((doc) => {
              return {
                fileName: doc.fileName || doc.FILENAME,
                filePath: doc.filePath || doc.FILEPATH,
                directory: doc.directory || doc.DIRECTORY,
                displayPath: doc.displayPath || doc.DISPLAYPATH,
                size: doc.size || doc.SIZE,
                dateLastModified: doc.dateLastModified || doc.DATELASTMODIFIED,
              };
            });
            this.distributeProcessingIntelligently(
              normalizedDocuments,
              searchTerms,
              searchOptions,
              startTime
            );
          } else {
            console.warn("Nenhum documento PDF encontrado no diretório");
            this.searchInServerSide(searchTerms, searchOptions);
          }
        } else {
          console.warn(
            "Estrutura de resposta inválida, usando busca no servidor:",
            parsedResponse
          );
          this.searchInServerSide(searchTerms, searchOptions);
        }
      },
      error: (xhr, status, error) => {
        console.error(`Erro ao buscar documentos: ${status} - ${error}`);
        console.log("Texto da resposta:", xhr.responseText);
        this.searchInServerSide(searchTerms, searchOptions);
      },
    });
  },
  // Destacar termo em um texto
  highlightSearchTerm: function (text, term, searchOptions) {
    if (!text || !term) return text;
    try {
      const flags = searchOptions && searchOptions.caseSensitive ? "g" : "gi";
      const escapedTerm = this.escapeRegExp(term);
      const regex = new RegExp(`(${escapedTerm})`, flags);
      return text.replace(regex, "<mark>$1</mark>");
    } catch (e) {
      console.error("Erro ao destacar termos:", e);
      return text;
    }
  },

  // Adicionar nova função para destacar frase exata
  highlightSearchPhrase: function (text, phrase, searchOptions) {
    if (!text || !phrase) return text;
    try {
      const flags = searchOptions && searchOptions.caseSensitive ? "g" : "gi";
      const escapedPhrase = this.escapeRegExp(phrase);
      const regex = new RegExp(`(${escapedPhrase})`, flags);
      return text.replace(regex, "<mark>$1</mark>");
    } catch (e) {
      console.error("Erro ao destacar frase:", e);
      return text;
    }
  },

  // Função aprimorada para destacar todas as palavras pesquisadas
  highlightAllSearchTerms: function (text, terms, caseSensitive) {
    if (!text || !terms || !terms.length) return text;

    let highlightedText = text;
    terms.forEach((term) => {
      if (term.length >= 3) {
        const flags = caseSensitive ? "g" : "gi";
        const regex = new RegExp(`(${this.escapeRegExp(term)})`, flags);
        highlightedText = highlightedText.replace(regex, "<mark>$1</mark>");
      }
    });
    return highlightedText;
  },

  // Função auxiliar para escapar caracteres especiais em expressões regulares
  escapeRegExp: function (string) {
    return string.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  },

  // Função para contar palavras em um texto
  countWords: function (text) {
    return text.trim().split(/\s+/).length;
  },

  // Função para verificar proximidade entre palavras
  checkProximity: function (text, words, proximity, caseSensitive) {
    // Se proximidade for -1, significa "Em qualquer parte"
    if (proximity === -1) {
      return words.every((word) => {
        return text.toLowerCase().includes(word.toLowerCase());
      });
    } else {
      // Dividir o texto em palavras
      const textWords = text.trim().split(/\s+/);
      for (let i = 0; i < textWords.length; i++) {
        // Verificar se a primeira palavra está presente, respeitando case sensitivity
        if (
          caseSensitive
            ? textWords[i].includes(words[0])
            : textWords[i].toLowerCase().includes(words[0].toLowerCase())
        ) {
          // Verificar se todas as outras palavras estão dentro da proximidade especificada
          let allFound = true;
          for (let j = 1; j < words.length; j++) {
            let found = false;
            // Verificar nas próximas 'proximity' palavras
            for (
              let k = i + 1;
              k < Math.min(i + proximity + 1, textWords.length);
              k++
            ) {
              if (
                caseSensitive
                  ? textWords[k].includes(words[j])
                  : textWords[k].toLowerCase().includes(words[j].toLowerCase())
              ) {
                found = true;
                break;
              }
            }
            if (!found) {
              allFound = false;
              break;
            }
          }
          if (allFound) {
            return true;
          }
        }
      }
      return false;
    }
  },

  // Formata os snippets para exibição
  formatSnippets: function (snippets) {
    if (!snippets || snippets.length === 0) {
      return '<p class="text-muted">Sem prévia disponível</p>';
    }
    return snippets
      .map((snippet) => `<div class="snippet">${snippet}</div>`)
      .join("");
  },

  // Exibir resultados de busca
  displaySearchResults: function (
    searchTerms,
    searchTime,
    filesRead,
    searchOptions
  ) {
    $("#searchLoading").hide();
    $("#realTimeResults").hide();
    // Se não há resultados
    if (this.currentSearchResults.length === 0) {
      $("#noResultsAlert").show();
      $("#searchStats").text(
        `0 resultados encontrados em ${searchTime} segundos. Arquivos lidos: ${
          filesRead || "N/A"
        }`
      );
      return;
    }
    // Atualizar apenas as estatísticas, pois os resultados já foram inseridos
    $("#searchStats").text(
      `${this.currentSearchResults.length} resultado${
        this.currentSearchResults.length !== 1 ? "s" : ""
      } encontrado${
        this.currentSearchResults.length !== 1 ? "s" : ""
      } em ${searchTime} segundos. Arquivos lidos: ${filesRead || "N/A"}`
    );
  },

  // Formatar tamanho do arquivo
  formatFileSize: function (bytes) {
    if (bytes < 1024) {
      return bytes + " bytes";
    } else if (bytes < 1048576) {
      return (bytes / 1024).toFixed(1) + " KB";
    } else if (bytes < 1073741824) {
      return (bytes / 1048576).toFixed(1) + " MB";
    } else {
      return (bytes / 1073741824).toFixed(1) + " GB";
    }
  },

  // Formatar data
  formatDate: function (dateStr) {
    try {
      const date = new Date(dateStr);
      return date.toLocaleDateString("pt-BR");
    } catch (e) {
      return "Data desconhecida";
    }
  },

  // Salvar buscas recentes no localStorage
  saveRecentSearch: function (searchTerms) {
    try {
      const recentSearches = JSON.parse(
        localStorage.getItem("recentFaqSearches") || "[]"
      );
      const filteredSearches = recentSearches.filter(
        (term) => term.toLowerCase() !== searchTerms.toLowerCase()
      );
      // Manter apenas as 5 pesquisas mais recentes
      filteredSearches.unshift(searchTerms);
      if (filteredSearches.length > 5) {
        filteredSearches.length = 5;
      }
      localStorage.setItem(
        "recentFaqSearches",
        JSON.stringify(filteredSearches)
      );
      // Atualizar UI
      this.loadRecentSearches();
    } catch (e) {
      console.error("Erro ao salvar busca recente:", e);
    }
  },

  // Carregar e exibir buscas recentes
  loadRecentSearches: function () {
    try {
      const recentSearches = JSON.parse(
        localStorage.getItem("recentFaqSearches") || "[]"
      );

      // Limpar e atualizar container
      const container = $("#recentSearchesContainer");
      container.empty();
      if (recentSearches.length === 0) return;

      let html =
        '<div class="mt-2"><small class="text-muted">Buscas recentes: </small>';
      recentSearches.forEach((term) => {
        html += `
          <a href="javascript:void(0)" class="badge badge-light mr-1" 
             onclick="PdfSearchManager.searchWithTerm('${term.replace(
               /'/g,
               "\\'"
             )}')">${term}</a>
        `;
      });
      html += `
        <button class="btn btn-link btn-sm text-muted px-0 ml-2" 
                onclick="PdfSearchManager.clearRecentSearches()">
          <i class="fas fa-times"></i> Limpar
        </button>
      </div>`;
      container.html(html);
    } catch (e) {
      console.error("Erro ao carregar buscas recentes:", e);
    }
  },

  // Limpar as buscas recentes
  clearRecentSearches: function () {
    try {
      localStorage.removeItem("recentFaqSearches");
      $("#recentSearchesContainer").empty();
      toastr.success("Histórico de buscas removido com sucesso!");
    } catch (e) {
      console.error("Erro ao limpar buscas recentes:", e);
      toastr.error("Erro ao limpar histórico de buscas.");
    }
  },

  // Atualizar a URL com os termos de busca para permitir compartilhamento
  updateUrlWithSearchTerms: function (searchTerms) {
    const newUrl =
      window.location.protocol +
      "//" +
      window.location.host +
      window.location.pathname +
      "?q=" +
      encodeURIComponent(searchTerms);
    window.history.pushState({ path: newUrl }, "", newUrl);
  },

  // Iniciar busca com termo específico
  searchWithTerm: function (term) {
    $("#searchTerms").val(term);
    this.performSearch(term);
    // Não precisamos adicionar o scroll aqui pois já está no performSearch
  },

  // Navegar pelos destaques
  navigateHighlights: function (direction) {
    console.log("Navegação entre destaques: direção =", direction);
  },

  // Salvar estatísticas da busca
  saveSearchStats: function () {
    try {
      const statsData = {
        timestamp: new Date().toISOString(),
        searchTerms: $("#searchTerms").val(),
        totalTime: searchStats.totalTime,
        averageTimePerDoc: searchStats.averageTimePerDoc,
        documentsProcessed: searchStats.documentsProcessed,
        documentsWithMatches: searchStats.documentsWithMatches,
        matchRate:
          searchStats.documentsProcessed > 0
            ? searchStats.documentsWithMatches / searchStats.documentsProcessed
            : 0,
        memoryUsage: {
          average: searchStats.memoryUsage.average,
          peak: searchStats.memoryUsage.peak,
        },
      };
      const existingStats = JSON.parse(
        localStorage.getItem("pdfSearchStats_mixed") || "[]"
      );
      existingStats.push(statsData);
      if (existingStats.length > 20) {
        existingStats.shift();
      }
      localStorage.setItem(
        "pdfSearchStats_mixed",
        JSON.stringify(existingStats)
      );
    } catch (e) {
      console.error("Erro ao salvar estatísticas:", e);
    }
  },

  // Busca com documentos do servidor
  searchWithServerDocuments: function (documents, searchTerms, searchOptions) {
    if (searchCanceled) return;
    const documentPaths = documents.map((doc) => doc.filePath);
    $.ajax({
      url: "cfc/pc_cfcBuscaPDF.cfc",
      type: "POST",
      dataType: "json",
      data: {
        method: "searchInSpecificPDFs",
        filePaths: JSON.stringify(documentPaths),
        searchTerms: searchTerms,
        searchOptions: JSON.stringify(searchOptions),
      },
      success: (response) => {
        if (searchCanceled) return;
        let parsedResponse = this.ensureJsonResponse(response);
        if (parsedResponse && parsedResponse.success) {
          if (parsedResponse.results && parsedResponse.results.length > 0) {
            parsedResponse.results.forEach((result) => {
              const fileUrl = `cfc/pc_cfcBuscaPDF.cfc?method=exibePdfInline&arquivo=${encodeURIComponent(
                result.filePath
              )}&nome=${encodeURIComponent(result.fileName)}`;
              const processedResult = {
                ...result,
                fileUrl: fileUrl,
                found: true,
              };
              this.addSearchResult(processedResult);
            });
          }
          searchStats.documentsProcessed += documents.length;
        }
        this.checkSearchCompletion();
      },
      error: (xhr, status, error) => {
        console.error("Erro na busca pelo servidor:", error);
        searchStats.documentsProcessed += documents.length;
        this.checkSearchCompletion();
      },
    });
  },

  // Busca de documento único no servidor
  searchSingleDocumentInServer: function (doc, searchTerms, searchOptions) {
    $.ajax({
      url: "cfc/pc_cfcBuscaPDF.cfc",
      type: "POST",
      dataType: "json",
      data: {
        method: "searchInSpecificPDFs",
        filePaths: JSON.stringify([doc.filePath]),
        searchTerms: searchTerms,
        searchOptions: JSON.stringify(searchOptions),
      },
      success: (response) => {
        if (searchCanceled) return;
        const parsedResponse = this.ensureJsonResponse(response);
        if (
          parsedResponse &&
          parsedResponse.success &&
          parsedResponse.results &&
          parsedResponse.results.length > 0
        ) {
          const result = parsedResponse.results[0];
          const fileUrl = `cfc/pc_cfcBuscaPDF.cfc?method=exibePdfInline&arquivo=${encodeURIComponent(
            result.filePath
          )}&nome=${encodeURIComponent(result.fileName)}`;
          const processedResult = { ...result, fileUrl: fileUrl, found: true };
          this.addSearchResult(processedResult);
        }
      },
      error: (xhr, status, error) => {
        console.error(`Erro no fallback para ${doc.fileName}:`, error);
      },
    });
  },

  // Garantir resposta JSON
  ensureJsonResponse: function (response) {
    if (typeof response === "string") {
      try {
        return JSON.parse(response);
      } catch (e) {
        console.error("Erro ao converter resposta string para objeto:", e);
        return null;
      }
    }
    return response;
  },

  // Adicionar resultado de busca
  addSearchResult: function (result) {
    this.currentSearchResults.push(result);
    this.addRealTimeResult(result);
  },

  // Verificar conclusão da busca
  checkSearchCompletion: function () {
    if (searchCanceled) return;
    const searchTime = ((performance.now() - startTime) / 1000).toFixed(2);
    this.displaySearchResults(
      searchTerms,
      searchTime,
      filesRead,
      searchOptions
    );
    documentProcessing = false;
    $("html, body").animate(
      { scrollTop: $("#resultsCard").offset().top - 200 },
      "slow"
    );
  },

  // Nova função: Distribuição inteligente de processamento
  distributeProcessingIntelligently: function (
    documents,
    searchTerms,
    searchOptions,
    startTime
  ) {
    const clientDocs = [];
    const serverDocs = [];
    const decisions = [];

    documents.forEach((doc) => {
      const decision = $.ajax({
        url: "cfc/pc_cfcBuscaPDF.cfc",
        type: "POST",
        dataType: "json",
        data: {
          method: "getPdfComplexityScore",
          filePath: doc.filePath,
        },
      })
        .then((response) => {
          if (
            response &&
            response.success &&
            response.processingRecommendation === "server"
          ) {
            serverDocs.push(doc);
          } else {
            clientDocs.push(doc);
          }
        })
        .fail(() => {
          const sizeThreshold = 3 * 1024 * 1024; // 3MB
          if (doc.size > sizeThreshold) {
            serverDocs.push(doc);
          } else {
            clientDocs.push(doc);
          }
        });
      decisions.push(decision);
    });

    $.when.apply($, decisions).always(() => {
      console.log(
        `Distribuição: ${clientDocs.length} para client e ${serverDocs.length} para server`
      );
      if (clientDocs.length > 0) {
        this.processDocumentsWithPdfJs(
          clientDocs,
          searchTerms,
          startTime,
          searchOptions
        );
      }
      if (serverDocs.length > 0) {
        this.searchWithServerDocuments(serverDocs, searchTerms, searchOptions);
      }
    });
  },

  // Função otimizada para busca "OR", para uso com extração sequencial
  searchAnyTerm: function (text, searchTerms, searchOptions) {
    const result = {
      found: false,
      snippets: [],
    };
    if (!text || !searchTerms) return result;
    const terms = searchTerms.split(" ").filter((term) => term.length >= 3);
    if (terms.length === 0) return result;

    // Se a opção de considerar escritas erradas estiver ativada
    if (searchOptions && searchOptions.useSpellingVariants) {
      return this.searchWithSpellingVariants(text, terms, searchOptions);
    }

    // Para cada termo, verificar se está presente no texto
    for (const term of terms) {
      // Aplicar caso sensitivo se configurado
      const flags = searchOptions && searchOptions.caseSensitive ? "g" : "gi";

      // Modificação: Usar expressão regular com limites de palavra (\b) para garantir
      // que encontre apenas palavras inteiras, não substrings
      const regex = new RegExp(`\\b${this.escapeRegExp(term)}\\b`, flags);

      const matches = text.match(regex);

      if (matches && matches.length > 0) {
        result.found = true;

        // Adicionar apenas um snippet para o primeiro termo encontrado (otimização)
        // Também usar a nova expressão regular com limites de palavra para encontrar o índice
        const searchRegex =
          searchOptions && searchOptions.caseSensitive
            ? new RegExp(`\\b${this.escapeRegExp(term)}\\b`, "g")
            : new RegExp(`\\b${this.escapeRegExp(term)}\\b`, "gi");

        let match = searchRegex.exec(text);
        if (match) {
          const firstIndex = match.index;
          const start = Math.max(0, firstIndex - 200);
          const end = Math.min(text.length, firstIndex + term.length + 200);
          let snippet = text.substring(start, end);

          if (start > 0) snippet = "..." + snippet;
          if (end < text.length) snippet += "...";

          snippet = this.highlightSearchTerm(snippet, term, searchOptions);
          result.snippets.push(snippet);
          break; // Sai do loop após encontrar o primeiro termo
        }
      }
    }
    return result;
  },

  // Função para busca exata em texto, retorna resultado preciso para extração sequencial
  searchExactPhrase: function (text, phrase, searchOptions) {
    const result = {
      found: false,
      snippets: [],
    };
    phrase = phrase.trim();
    if (phrase.length < 3 || !text) return result;

    try {
      // Aplicar caso sensitivo se configurado
      const flags = searchOptions && searchOptions.caseSensitive ? "g" : "gi";
      const escapedPhrase = this.escapeRegExp(phrase);

      // Não use limites de palavra aqui, pois estamos procurando uma frase exata
      const regex = new RegExp(escapedPhrase, flags);
      const matches = text.match(regex);

      if (matches && matches.length > 0) {
        result.found = true;

        // Limitar a 1 snippet por página para otimizar
        // Usar indexOf respeitando a sensibilidade de caso
        const firstIndex =
          searchOptions && searchOptions.caseSensitive
            ? text.indexOf(phrase)
            : text.toLowerCase().indexOf(phrase.toLowerCase());

        if (firstIndex !== -1) {
          const start = Math.max(0, firstIndex - 200);
          const end = Math.min(text.length, firstIndex + phrase.length + 200);
          let snippet = text.substring(start, end);

          if (start > 0) snippet = "..." + snippet;
          if (end < text.length) snippet += "...";

          snippet = this.highlightSearchPhrase(snippet, phrase, searchOptions);
          result.snippets.push(snippet);
        }
      }
    } catch (e) {
      console.error("Erro ao buscar frase exata:", e);
    }
    return result;
  },

  // Função otimizada para busca de proximidade, para uso com extração sequencial
  searchProximity: function (text, words, proximity, searchOptions) {
    const result = {
      found: false,
      snippets: [],
    };
    if (!words || words.length === 0 || !text) return result;

    // Verificar proximidade entre palavras
    result.found = this.checkProximity(
      text,
      words,
      proximity,
      searchOptions && searchOptions.caseSensitive
    );
    if (result.found) {
      // Criar único snippet por página para otimização
      const firstWord = words[0];
      const firstIndex =
        searchOptions && searchOptions.caseSensitive
          ? text.indexOf(firstWord)
          : text.toLowerCase().indexOf(firstWord.toLowerCase());

      if (firstIndex !== -1) {
        const start = Math.max(0, firstIndex - 200);
        const end = Math.min(text.length, firstIndex + 400);
        let snippet = text.substring(start, end);

        if (start > 0) snippet = "..." + snippet;
        if (end < text.length) snippet += "...";

        snippet = this.highlightAllSearchTerms(
          snippet,
          words,
          searchOptions && searchOptions.caseSensitive
        );
        result.snippets.push(snippet);
      }
    }
    return result;
  },

  // Versão corrigida da função de busca aproximada para respeitar case sensitivity
  searchWithSpellingVariants: function (text, terms, searchOptions) {
    const result = {
      found: false,
      snippets: [],
    };

    if (!text || terms.length === 0) return result;

    // Para cada termo, verificar variações comuns de escrita
    for (const term of terms) {
      if (term.length < 3) continue;

      // Gerar variações comuns de escrita para o termo (respeitando case sensitivity)
      const variants = this.getSpellingVariants(
        term,
        searchOptions.caseSensitive
      );
      let termFound = false;
      let firstIndex = -1;
      let matchedVariant = "";

      // Se não precisamos diferenciar maiúsculas/minúsculas, usar toLowerCase para facilitar comparação
      const searchText = searchOptions.caseSensitive
        ? text
        : text.toLowerCase();
      const searchTerm = searchOptions.caseSensitive
        ? term
        : term.toLowerCase();

      // Verificar o termo original primeiro
      if (searchOptions.caseSensitive) {
        // Busca exata respeitando maiúsculas/minúsculas
        const regex = new RegExp(this.escapeRegExp(term), "g");
        const matches = text.match(regex);

        if (matches && matches.length > 0) {
          termFound = true;
          matchedVariant = term;
          firstIndex = text.indexOf(term);
        }
      } else {
        // Busca case-insensitive
        const regex = new RegExp(this.escapeRegExp(term), "gi");
        const matches = text.match(regex);

        if (matches && matches.length > 0) {
          termFound = true;
          matchedVariant = matches[0]; // Usar o texto encontrado para preservar o case original no documento
          firstIndex = text.toLowerCase().indexOf(term.toLowerCase());
        }
      }

      // Se não encontrou o termo original, tentar variações
      if (!termFound) {
        for (const variant of variants) {
          if (searchOptions.caseSensitive) {
            // Busca exata com case sensitive
            const regex = new RegExp(this.escapeRegExp(variant), "g");
            const matches = text.match(regex);

            if (matches && matches.length > 0) {
              termFound = true;
              matchedVariant = variant;
              firstIndex = text.indexOf(variant);
              break;
            }
          } else {
            // Busca case insensitive
            const regex = new RegExp(this.escapeRegExp(variant), "gi");
            const matches = text.match(regex);

            if (matches && matches.length > 0) {
              termFound = true;
              matchedVariant = matches[0]; // Preservar o case encontrado no texto
              firstIndex = text.toLowerCase().indexOf(variant.toLowerCase());
              break;
            }
          }
        }
      }

      // Se encontrou o termo ou alguma variante
      if (termFound && firstIndex !== -1) {
        result.found = true;

        const start = Math.max(0, firstIndex - 200);
        const end = Math.min(
          text.length,
          firstIndex + matchedVariant.length + 200
        );
        let snippet = text.substring(start, end);

        if (start > 0) snippet = "..." + snippet;
        if (end < text.length) snippet += "...";

        // Destacar o termo encontrado
        snippet = this.highlightSearchTerm(
          snippet,
          matchedVariant,
          searchOptions
        );

        // Se foi encontrada uma variante diferente do termo original, adicionar informação
        if (matchedVariant.toLowerCase() !== term.toLowerCase()) {
          snippet =
            `<div class="spelling-variant-info">Termo buscado: "${term}" - Encontrado: "${matchedVariant}"</div>` +
            snippet;
        }

        result.snippets.push(snippet);
        break; // Sai do loop após encontrar o primeiro termo
      }
    }

    return result;
  },

  // Função modificada para gerar variações de escrita respeitando case sensitivity
  getSpellingVariants: function (term, caseSensitive) {
    const variants = new Set();
    // Determinar o termo base para gerar variações
    const baseTerm = caseSensitive ? term : term.toLowerCase();

    // Gerar as variantes sempre em minúsculas para processamento interno
    const lowerTerm = term.toLowerCase();

    // Erros comuns em português
    // 1. Troca de 's' por 'z' e vice-versa
    if (lowerTerm.includes("s")) {
      const variant = lowerTerm.replace(/s/g, "z");
      variants.add(caseSensitive ? this.matchCase(variant, term) : variant);
    }
    if (lowerTerm.includes("z")) {
      const variant = lowerTerm.replace(/z/g, "s");
      variants.add(caseSensitive ? this.matchCase(variant, term) : variant);
    }

    // 2. Troca de 'ç' por 'ss' e vice-versa
    if (lowerTerm.includes("ç")) {
      const variant = lowerTerm.replace(/ç/g, "ss");
      variants.add(caseSensitive ? this.matchCase(variant, term) : variant);
    }
    if (lowerTerm.includes("ss")) {
      const variant = lowerTerm.replace(/ss/g, "ç");
      variants.add(caseSensitive ? this.matchCase(variant, term) : variant);
    }

    // 3. Troca de 'x' por 'ch' e vice-versa
    if (lowerTerm.includes("x")) {
      const variant = lowerTerm.replace(/x/g, "ch");
      variants.add(caseSensitive ? this.matchCase(variant, term) : variant);
    }
    if (lowerTerm.includes("ch")) {
      const variant = lowerTerm.replace(/ch/g, "x");
      variants.add(caseSensitive ? this.matchCase(variant, term) : variant);
    }

    // 4. Troca de 'g' por 'j' em algumas combinações
    if (lowerTerm.includes("ge")) {
      const variant = lowerTerm.replace(/ge/g, "je");
      variants.add(caseSensitive ? this.matchCase(variant, term) : variant);
    }
    if (lowerTerm.includes("gi")) {
      const variant = lowerTerm.replace(/gi/g, "ji");
      variants.add(caseSensitive ? this.matchCase(variant, term) : variant);
    }
    if (lowerTerm.includes("je")) {
      const variant = lowerTerm.replace(/je/g, "ge");
      variants.add(caseSensitive ? this.matchCase(variant, term) : variant);
    }
    if (lowerTerm.includes("ji")) {
      const variant = lowerTerm.replace(/ji/g, "gi");
      variants.add(caseSensitive ? this.matchCase(variant, term) : variant);
    }

    // 5. Remoção ou adição de 'h' no início
    if (lowerTerm.startsWith("h")) {
      const variant = lowerTerm.substring(1);
      variants.add(caseSensitive ? this.matchCase(variant, term) : variant);
    } else {
      const variant = "h" + lowerTerm;
      variants.add(caseSensitive ? this.matchCase(variant, term) : variant);
    }

    // 6. Variações de acentuação
    const accentMap = {
      á: "a",
      à: "a",
      â: "a",
      ã: "a",
      é: "e",
      ê: "e",
      í: "i",
      ó: "o",
      ô: "o",
      õ: "o",
      ú: "u",
      ü: "u",
    };

    let noAccents = lowerTerm;
    for (const [accented, plain] of Object.entries(accentMap)) {
      if (lowerTerm.includes(accented)) {
        noAccents = noAccents.replace(new RegExp(accented, "g"), plain);
      }
    }

    if (noAccents !== lowerTerm) {
      variants.add(caseSensitive ? this.matchCase(noAccents, term) : noAccents);
    }

    // 7. Duplicação ou remoção de letras duplas comuns
    const doubleLetters = ["r", "s", "l", "m", "n", "p", "c", "f"];
    for (const letter of doubleLetters) {
      const double = letter + letter;
      if (lowerTerm.includes(double)) {
        const variant = lowerTerm.replace(new RegExp(double, "g"), letter);
        variants.add(caseSensitive ? this.matchCase(variant, term) : variant);
      } else if (lowerTerm.includes(letter)) {
        // Verificar se não é no início ou fim da palavra
        const pos = lowerTerm.indexOf(letter);
        if (pos > 0 && pos < lowerTerm.length - 1) {
          const variant =
            lowerTerm.substring(0, pos) +
            letter +
            letter +
            lowerTerm.substring(pos + 1);
          variants.add(caseSensitive ? this.matchCase(variant, term) : variant);
        }
      }
    }

    return Array.from(variants);
  },

  // Nova função para fazer uma variante respeitar o mesmo padrão de maiúsculas/minúsculas do termo original
  matchCase: function (variant, original) {
    // Se o termo original é todo maiúsculo, retorna a variante em maiúsculo
    if (original === original.toUpperCase()) {
      return variant.toUpperCase();
    }

    // Se o termo original é todo minúsculo, retorna a variante em minúsculo
    if (original === original.toLowerCase()) {
      return variant.toLowerCase();
    }

    // Se o termo original tem a primeira letra maiúscula, faz o mesmo na variante
    if (
      original[0] === original[0].toUpperCase() &&
      original.slice(1) === original.slice(1).toLowerCase()
    ) {
      return variant.charAt(0).toUpperCase() + variant.slice(1).toLowerCase();
    }

    // Caso contrário, tenta fazer um match caractere por caractere
    let result = "";
    for (let i = 0; i < variant.length; i++) {
      // Se o índice está dentro do original, usa o mesmo case
      if (i < original.length) {
        const isUpper = original[i] === original[i].toUpperCase();
        result += isUpper ? variant[i].toUpperCase() : variant[i].toLowerCase();
      } else {
        // Para caracteres extras, mantém o original
        result += variant[i];
      }
    }
    return result;
  },

  // Buscar sinônimos para os termos de busca
  getSynonyms: function (term) {
    // Dicionário simples de sinônimos em português
    const synonymsDict = {
      // Termos originais ampliados
      processo: [
        "ação",
        "procedimento",
        "causa",
        "caso",
        "autos",
        "feito",
        "litígio",
        "demanda",
        "pleito",
        "lide",
      ],
      cliente: [
        "usuário",
        "consumidor",
        "freguês",
        "comprador",
        "contratante",
        "beneficiário",
        "interessado",
        "parte",
        "assistido",
        "constituinte",
      ],
      documento: [
        "arquivo",
        "comprovante",
        "papel",
        "certificado",
        "anexo",
        "registro",
        "escritura",
        "formulário",
        "instrumento",
        "petição",
        "documentação",
      ],
      pagamento: [
        "quitação",
        "liquidação",
        "remuneração",
        "depósito",
        "honorário",
        "adimplemento",
        "transferência",
        "parcela",
        "prestação",
        "valor",
        "débito",
        "crédito",
      ],
      contrato: [
        "acordo",
        "convênio",
        "tratado",
        "compromisso",
        "pacto",
        "convenção",
        "negócio",
        "termo",
        "ajuste",
        "instrumento",
        "escritura",
        "avença",
      ],
      prazo: [
        "período",
        "termo",
        "data",
        "duração",
        "tempo",
        "vencimento",
        "limite",
        "cronograma",
        "lapso temporal",
        "intervalo",
        "dilação",
        "prorrogação",
      ],
      judicial: [
        "jurídico",
        "legal",
        "forense",
        "jurisdicional",
        "processual",
        "judicante",
        "judiciário",
        "judicativo",
        "contencioso",
        "litigioso",
      ],
      advogado: [
        "defensor",
        "procurador",
        "causídico",
        "representante",
        "patrono",
        "constituído",
        "jurista",
        "bacharel",
        "profissional",
        "consultor",
      ],
      serviço: [
        "atendimento",
        "prestação",
        "trabalho",
        "atividade",
        "tarefa",
        "função",
        "assistência",
        "auxílio",
        "suporte",
        "apoio",
        "consultoria",
      ],
      recurso: [
        "apelação",
        "contestação",
        "impugnação",
        "agravo",
        "embargos",
        "revisão",
        "reclamação",
        "remédio processual",
        "inconformismo",
        "insurgência",
      ],

      // Novos termos relacionados a processos
      sentença: [
        "decisão",
        "julgamento",
        "veredicto",
        "deliberação",
        "acórdão",
        "pronunciamento",
        "despacho",
        "provimento",
        "resolução",
      ],
      audiência: [
        "sessão",
        "julgamento",
        "encontro",
        "debate",
        "conferência",
        "reunião",
        "oitiva",
        "conciliação",
        "mediação",
      ],
      juiz: [
        "magistrado",
        "julgador",
        "autoridade",
        "entrada",
        "recibo",
        "comprovante",
        "numeração",
        "cadastro",
        "recepção",
      ],
      certidão: [
        "atestado",
        "declaração",
        "comprovante",
        "documento",
        "certificado",
        "confirmação",
        "prova",
      ],
      custas: [
        "despesas",
        "gastos",
        "valores",
        "taxas",
        "emolumentos",
        "dispêndios",
        "pagamentos",
      ],
      relatório: [
        "informe",
        "parecer",
        "exposição",
        "relato",
        "descrição",
        "memorial",
        "resumo",
        "síntese",
      ],
      ofício: [
        "comunicação",
        "documento",
        "correspondência",
        "expediente",
        "missiva",
        "nota",
        "informação",
      ],

      // NOVOS TERMOS - Inspeções
      inspeção: [
        "fiscalização",
        "vistoria",
        "verificação",
        "exame",
        "averiguação",
        "perícia",
        "checagem",
        "auditoria",
        "monitoramento",
        "avaliação",
      ],
      fiscalização: [
        "supervisão",
        "controle",
        "vigilância",
        "inspeção",
        "acompanhamento",
        "monitoramento",
        "verificação",
        "conferência",
        "vistoria",
      ],
      vistoria: [
        "exame",
        "inspeção",
        "verificação",
        "avaliação",
        "checagem",
        "visita técnica",
        "análise presencial",
        "perícia",
        "conferência local",
      ],

      // NOVOS TERMOS - Auditorias
      auditoria: [
        "verificação",
        "exame",
        "análise",
        "perícia",
        "revisão",
        "avaliação",
        "controle",
        "fiscalização",
        "investigação",
        "apuração",
      ],
      controle: [
        "supervisão",
        "monitoramento",
        "acompanhamento",
        "fiscalização",
        "gestão",
        "verificação",
        "regulação",
        "inspeção",
        "vigilância",
      ],
      conformidade: [
        "adequação",
        "cumprimento",
        "observância",
        "adesão",
        "obediência",
        "alinhamento",
        "regularidade",
        "consonância",
        "legalidade",
        "compliance",
      ],

      // NOVOS TERMOS - Leis
      lei: [
        "legislação",
        "norma",
        "regra",
        "regulamento",
        "decreto",
        "estatuto",
        "código",
        "dispositivo legal",
        "preceito",
        "disposição legal",
      ],
      legislação: [
        "leis",
        "normas",
        "regulamentos",
        "códigos",
        "decretos",
        "estatutos",
        "ordenamento jurídico",
        "regras",
        "sistema legal",
        "direito positivo",
      ],
      regulamento: [
        "norma",
        "instrução",
        "diretriz",
        "portaria",
        "resolução",
        "deliberação",
        "regra",
        "disposição",
        "ordenação",
        "estatuto",
      ],
      decreto: [
        "determinação",
        "ordem",
        "decisão",
        "ato",
        "deliberação",
        "resolução",
        "disposição",
        "regulamentação",
        "ordenação",
      ],

      // NOVOS TERMOS - Órgãos Públicos
      ministério: [
        "pasta",
        "órgão",
        "secretaria",
        "departamento",
        "entidade governamental",
        "instituição pública",
        "autarquia",
        "setor público",
      ],
      agência: [
        "órgão",
        "entidade",
        "instituição",
        "autarquia",
        "departamento",
        "repartição",
        "setor",
        "organismo",
        "unidade",
      ],
      secretaria: [
        "departamento",
        "seção",
        "diretoria",
        "divisão",
        "coordenadoria",
        "assessoria",
        "gerência",
        "superintendência",
      ],
      autarquia: [
        "entidade",
        "órgão",
        "instituição",
        "organismo",
        "repartição",
        "departamento",
        "agência",
        "fundação",
      ],

      // NOVOS TERMOS - Correios do Brasil
      correios: [
        "ECT",
        "empresa brasileira de correios e telégrafos",
        "serviço postal",
        "agência postal",
        "serviço de encomendas",
        "postal",
      ],
      correspondência: [
        "carta",
        "comunicação",
        "documento",
        "ofício",
        "notificação",
        "aviso",
        "comunicado",
        "expediente",
        "missiva",
        "mensagem",
      ],
      entrega: [
        "remessa",
        "envio",
        "despacho",
        "distribuição",
        "expedição",
        "transporte",
        "transmissão",
        "postagem",
        "encaminhamento",
      ],
      postal: [
        "carteiro",
        "agência",
        "serviço de correios",
        "malote",
        "correspondência",
        "entrega",
        "ECT",
        "logística postal",
        "mala direta",
      ],

      // NOVOS TERMOS - Específicos do contexto
      malote: [
        "remessa",
        "pacote",
        "encomenda",
        "volume",
        "valise",
        "saco de documentos",
        "bolsa",
        "transportadora",
        "expedição",
      ],
      rastreamento: [
        "monitoramento",
        "acompanhamento",
        "localização",
        "rastreio",
        "controle",
        "aferição",
        "seguimento",
        "conferência",
      ],
      postagem: [
        "expedição",
        "envio",
        "remessa",
        "despacho",
        "encaminhamento",
        "distribuição",
        "entrega",
        "registro",
      ],
      sedex: [
        "entrega expressa",
        "serviço expresso",
        "entrega rápida",
        "encomenda expressa",
        "remessa urgente",
        "PAC",
        "encomenda",
      ],
      destinatário: [
        "recebedor",
        "receptor",
        "recipiente",
        "beneficiário",
        "consignatário",
        "endereçado",
        "alvo",
        "participante",
      ],
    };

    // Normalizar termo para busca
    const normalizedTerm = term.toLowerCase().trim();

    // Procurar no dicionário
    for (const [word, synonyms] of Object.entries(synonymsDict)) {
      if (word === normalizedTerm) {
        return synonyms;
      }
      if (synonyms.includes(normalizedTerm)) {
        return [word, ...synonyms.filter((s) => s !== normalizedTerm)];
      }
    }

    return []; // Retorna array vazio se não encontrar sinônimos
  },
};

$(document).ready(function () {
  if (typeof pdfjsLib === "undefined") {
    console.error(
      "PDF.js não foi carregado corretamente. Verifique se o script foi importado."
    );
    // Forçar fallback para busca no servidor
    PdfSearchManager.searchInServerSide = function (
      searchTerms,
      searchOptions
    ) {
      // ...existing server side code...
    };
  } else {
    console.log("PDF.js inicializado e pronto para uso.");
  }

  $("#searchFaqForm").on("submit", function (e) {
    e.preventDefault();
    PdfSearchManager.performSearch();
  });

  $('input[name="searchType"]').on("change", function () {
    const searchType = $(this).val();
    $("#fuzzyThreshold").prop("disabled", searchType !== "fuzzy");

    // Se selecionar "fuzzy", mostrar dica sobre sinônimos
    if (searchType === "fuzzy") {
      if (!$("#fuzzy-info").length) {
        $("#fuzzyThreshold").after(infoText);
      }
    } else {
      $("#fuzzy-info").remove();
    }
  });

  $("#cancelSearch").on("click", function () {
    if (documentProcessing) {
      searchCanceled = true;
      $(this)
        .prop("disabled", true)
        .html('<i class="fas fa-spinner fa-spin mr-1"></i> Cancelando...');
    }
  });

  PdfSearchManager.init();
});

$("#cancelSearch").on("click", function () {
  if (documentProcessing) {
    searchCanceled = true;
    $(this)
      .prop("disabled", true)
      .html('<i class="fas fa-spinner fa-spin mr-1"></i> Cancelando...');
  }
});

PdfSearchManager.init();
