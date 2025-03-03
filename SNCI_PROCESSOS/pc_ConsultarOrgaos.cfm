<cfprocessingdirective pageencoding = "utf-8">
<!--criar estrutura html para um trre da tabela pc_orgaos, com o body divido em duas colunas-->
<!DOCTYPE html>
<html lang="pt-br">
<head>
 	<meta charset="UTF-8">
  	<meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>SNCI</title>
	<link rel="icon" type="image/x-icon" href="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png">	
    
    <!-- Default Theme -->
    <link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/zTree_v3-master/css/zTreeStyle/zTreeStyle.css" />
<style>
    /* Estilos de Base */
    :root {
        --primary-color: #1a365d;
        --secondary-color: #2c5282;
        --accent-color: #b93d30;
        --light-gray: #f5f6f8;
        --border-color: #e2e8f0;
        --text-color: #2d3748;
        --shadow-sm: 0 1px 3px rgba(0,0,0,0.12);
        --shadow-md: 0 4px 6px rgba(0,0,0,0.1);
        --radius-sm: 4px;
        --radius-md: 6px;
    }
    
    .content-wrapper {
        background-color: var(--light-gray) !important;
    }
    
    .content-header h4 {
        color: var(--primary-color);
        font-size: 1.5rem;
        font-weight: 600;
        padding-bottom: 0.5rem;
        margin-bottom: 1.5rem;
        display: inline-block;
    }
    
    /* Cards e Containers */
    .orgao-container {
        background-color: white;
        border-radius: var(--radius-md);
        box-shadow: var(--shadow-md);
        padding: 1.5rem;
        margin-bottom: 1.5rem;
    }
    
    /* Radio Buttons */
    .radio-group {
        display: flex;
        gap: 2rem;
        margin-bottom: 1.5rem;
        background-color: #f8fafc;
        padding: 1rem;
        border-radius: var(--radius-md);
        border-left: 4px solid var(--secondary-color);
    }
    
    .custom-control-input:checked ~ .custom-control-label::before {
        background-color: var(--accent-color) !important;
        border-color: var(--accent-color) !important;
    }
    
    .custom-control-label {
        font-weight: 500;
        color: var(--text-color);
    }
    
    /* Barra de pesquisa */
    #groupPesquisa {
        margin: 1.5rem 0;
        background-color: #f8fafc;
        padding: 1rem;
        border-radius: var(--radius-md);
    }
    
    #filter {
        border: 1px solid var(--border-color);
        border-radius: var(--radius-sm);
        padding: 0.5rem 1rem;
        transition: all 0.3s ease;
    }
    
    #filter:focus {
        border-color: var(--secondary-color);
        box-shadow: 0 0 0 0.2rem rgba(44, 82, 130, 0.25);
    }
    
    /* Botões */
    .btn-info.btn-flat {
        background-color: var(--accent-color) !important;
        border-color: var(--accent-color) !important;
        border-radius: var(--radius-sm);
        transition: all 0.3s ease;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        font-weight: 500;
    }
    
    .btn-info.btn-flat:hover {
        background-color: #9c3328 !important;
        box-shadow: var(--shadow-md);
        transform: translateY(-1px);
    }
    
    /* Estilizando a árvore */
    #divTreeOrgao {
        margin-top: 1.5rem;
        border: 1px solid var(--border-color);
        border-radius: var(--radius-md);
        padding: 1rem;
        background-color: white;
        max-height: 70vh;
        overflow: auto;
    }
    
    .ztree li a {
        padding: 4px 3px;
        margin: 2px 0;
    }
    
    .ztree li a:hover {
        background-color: #edf2f7;
        border-radius: var(--radius-sm);
    }
    
    .ztree li a.curSelectedNode {
        background-color: #e2e8f0;
        border: 1px solid #cbd5e0;
    }
    
    /* Destaque para nós */
    .redNode span {
        color: var(--secondary-color) !important;
        font-weight: bold;
    }
    
    .highlighted {
        background-color: #fef9c3; /* amarelo claro mais suave */
        border-radius: 2px;
        padding: 0px 2px;
        box-shadow: 0 0 0 1px #fde047;
    }
    
    @keyframes blink {
        0% {background-color: transparent;}
        50% {background-color: rgba(184, 61, 48, 0.2);}
        100% {background-color: transparent;}
    }
    
    .blink {
        animation: blink 0.5s ease-in-out 3;
    }
    
    /* Estado vazio */
    .empty-tree {
        text-align: center;
        padding: 3rem 1rem;
        color: #718096;
    }
    
    .empty-tree i {
        font-size: 3rem;
        display: block;
        margin-bottom: 1rem;
        color: #a0aec0;
    }
</style>

</head>   
<body>
    <body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height" >
	<!-- Site wrapper -->
	<div class="wrapper">
		<cfinclude template="includes/pc_navBar.cfm">

        <!-- Content Wrapper. Contains page content -->
        <div class="content-wrapper" >
            <!-- Content Header (Page header) -->
            <section class="content-header">
                <div class="container-fluid">
                    <div class="row mb-2" style="margin-bottom:0px!important;">
                        <div class="col-sm-6">
                            <h4>Consultar Órgãos</h4>
                        </div>
                    </div>
                </div><!-- /.container-fluid -->
            </section>
            
            <section class="content">
                <div class="container-fluid">
                    <div class="orgao-container">
                        <!-- Seção de Seleção de Subordinação -->
                        <div class="radio-group">
                            <div class="custom-control custom-radio">
                                <input class="custom-control-input" type="radio" id="subTec" name="subRadio" value='subTec'>
                                <label for="subTec" class="custom-control-label">Subordinação Técnica</label>
                            </div>
                            <div class="custom-control custom-radio">
                                <input class="custom-control-input" type="radio" id="subAdm" name="subRadio" value='subAdm'>
                                <label for="subAdm" class="custom-control-label">Subordinação Administrativa</label>
                            </div>
                        </div>
                        
                        <!-- Seção de Pesquisa -->
                        <div id="groupPesquisa" class="input-group" style="display:none">
                            <input id="filter" type="text" class="form-control rounded-0 col-sm-5" 
                                   placeholder="Digite uma palavra ou número para filtrar" spellcheck="false">
                            <span class="input-group-append">
                                <button id="btLocalizar" type="button" class="btn btn-info btn-flat" style="font-size: 12px;">
                                    <i class="fa fa-magnifying-glass"></i> Localizar
                                </button>
                                <button type="button" onclick="clearFilter()" class="btn btn-info btn-flat" style="font-size: 12px;margin-left:10px">
                                    <i class="fa fa-rotate-right"></i> Atualizar/Limpar
                                </button>
                            </span>
                        </div>
                        
                        <!-- Árvore de Órgãos -->
                        <div id="divTreeOrgao" class="tree-container">
                            <!-- Estado inicial vazio -->
                            <div class="empty-tree">
                                <i class="fa fa-sitemap"></i>
                                <p>Selecione um tipo de subordinação acima para visualizar a estrutura organizacional</p>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </div> <!-- /.content-wrapper -->
       
        <cfinclude template="includes/pc_footer.cfm">
    </div><!-- ./wrapper -->
    	
	<cfinclude template="includes/pc_sidebar.cfm">
<!-- ZtreeCore JavaScript -->
    <script src="../SNCI_PROCESSOS/plugins/zTree_v3-master/js/jquery.ztree.core.min.js"></script>
    <script src="../SNCI_PROCESSOS/plugins/zTree_v3-master/js/jquery.ztree.exhide.min.js"></script>
    <script src="../SNCI_PROCESSOS/plugins/zTree_v3-master/js/jquery.ztree.excheck.min.js"></script>
    <script src="../SNCI_PROCESSOS/plugins/zTree_v3-master/js/jquery.ztree.exedit.min.js"></script>
    <script src="../SNCI_PROCESSOS/plugins/zTree_v3-master/js/fuzzysearch.js"></script>
    <script language="JavaScript">
        $(document).ready(function(){
            $(".content-wrapper").css("height","auto");
            var selectedRadio = localStorage.getItem('selectedRadio');
            if (selectedRadio) {
                $('#' + selectedRadio).prop('checked', true);

                // Atualize zNodes com base na seleção do rádio
                carregaTreeOrgao();
            }
        });

        function carregaTreeOrgao() {
			$('#cutNodeBtn').hide();	
            $('#modalOverlay').modal('show')
            $('#groupPesquisa').show();
            setTimeout(function() {
                $.ajax({
                    type: "POST",
                    url: "cfc/pc_cfcPaginasApoio.cfc",
					data:{
						method: "criarTreeOrgao",
                        tipoSubordinacao: $('input[name="subRadio"]:checked').val(),
					},
                    success: function (data) {
                        $('#divTreeOrgao').html(data);
                        $('#modalOverlay').delay(1000).hide(0, function() {
                            $('#modalOverlay').modal('hide');
                            
                        });
                        
                    },
                    error: function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)
					}
                });
            }, 500);
        }

        // Adicione um ouvinte de evento 'change' aos botões de rádio
        $('input[name="subRadio"]').change(function() {
            carregaTreeOrgao();

            // Armazene a seleção do rádio no localStorage
            localStorage.setItem('selectedRadio', this.id);

        });

        function clearFilter() {
            carregaTreeOrgao();
            $('#filter').val('');
        }

       $('#btLocalizar').click(function() {
            // ...existing code...
            var treeObj = $.fn.zTree.getZTreeObj("treeOrgao");
            var searchValue = $('#filter').val().toLowerCase(); // obtém o valor do campo de entrada e converte para minúsculas
            if (searchValue !== null && searchValue !== '') {  
                $('#modalOverlay').modal('show')  
                // Remove o destaque de todos os nós
                $('.highlighted').removeClass('highlighted');

                // realiza uma pesquisa difusa
                var nodes = treeObj.getNodesByFilter(function(node) {
                    return node.name.toLowerCase().indexOf(searchValue) > -1;
                }, false);

                if (nodes.length > 0) {
                    // Colapsa todos os nós
                    treeObj.expandAll(false);
                    setTimeout(function() {
                        // expande os nós pai e mostra os nós filho do nó correspondente
                        nodes.forEach(function(node, index) {
                             // Obtenha o caminho do nó atual até a raiz
                            var path = node.getPath();
                            // Expanda todos os nós no caminho
                            path.forEach(function(pathNode) {
                                treeObj.expandNode(pathNode, true, false, false);
                            });
                            treeObj.expandNode(node, true, false, true);
                            // Divida o nome do nó em partes
                            var nodeParts = node.name.split(new RegExp(`(${searchValue})`, 'gi'));
                            // Destaque a parte que corresponde à palavra pesquisada e junte as partes novamente
                            var nodeNameHighlighted = '';
                            for (var i = 0; i < nodeParts.length; i++) {
                                if (nodeParts[i].toLowerCase() === searchValue) {
                                    nodeNameHighlighted += '<span class="highlighted">' + nodeParts[i] + '</span>';
                                } else {
                                    nodeNameHighlighted += nodeParts[i];
                                }
                            }
                            // Atualize o nome do nó com o nome destacado
                            node.name = nodeNameHighlighted;
                            treeObj.updateNode(node);

                            if (index === 0) { // se for a primeira ocorrência
                                var $nodeDom = $("#" + node.tId);
                                if ($nodeDom.length > 0) {
                                    $('html, body').animate({// role para o nó
                                        scrollTop: $nodeDom.offset().top-100 // - 100 para compensar a altura da barra de navegação
                                    }, 1000, function() {
                                        // Adicione a classe 'blink' ao nó após a rolagem
                                        $nodeDom.addClass('blink');
                                        // Remova a classe 'blink' após 1 seg.
                                        setTimeout(function() {
                                            $nodeDom.removeClass('blink');
                                        }, 1000);
                                    });
                                }
                            }
                            
                        });
                        $('#modalOverlay').delay(1000).hide(0, function() {
                            $('#modalOverlay').modal('hide');
                        });
                    },500);
                    $(".content-wrapper").css("height","auto");
                } else {
                    $('#modalOverlay').delay(1000).hide(0, function() {
                        $('#modalOverlay').modal('hide');
                        toastr.error('Nenhum órgão encontrado!');
                        // Colapsa todos os nós
                        treeObj.expandAll(false);
                    });
                }
            } else {
                toastr.error('Informe um valor para pesquisa!');
            }
        });

        // Permitir usar a tecla Enter para acionar a pesquisa
        $("#filter").keypress(function(e) {
            if(e.which == 13) {
                $("#btLocalizar").click();
                return false;
            }
        });
    </script>
</body>
</html>

