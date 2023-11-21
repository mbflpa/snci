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
    .redNode span{
        color: #17a2b8 !important;
    }
</style>

</head>   
<body>
    <body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height" >
	<!-- Site wrapper -->
	<div class="wrapper">
	
		
		<cfinclude template="pc_Modal_preloader.cfm">
		<cfinclude template="pc_NavBar.cfm">

        <!-- Content Wrapper. Contains page content -->
        <div class="content-wrapper" >
            <!-- Content Header (Page header) -->
            <section class="content-header">
                <div class="container-fluid">
                    <div class="row mb-2" style="margin-top:20px;margin-bottom:0px!important;">
                        <div class="col-sm-6">
                            <h4>Consultar Órgãos</h4>
                        </div>
                    </div>
                </div><!-- /.container-fluid -->
            </section>
            <!--criar div dividindo o body em duas colunas-->
            <div class="row">
            <div class="col-sm-12">
                <section class="content">
                    <div class="container-fluid">
                        <div>
                                 

                            <div class="form-group" style="display:flex">
                                <div class="custom-control custom-radio" style="margin-left: 10px;margin-right:50px">
                                    <input class="custom-control-input" type="radio" id="subTec" name="subRadio" value='subTec' checked>
                                    <label for="subTec" class="custom-control-label">Subordinação Técnica</label>
                                </div>
                                <div class="custom-control custom-radio">
                                    <input class="custom-control-input" type="radio" id="subAdm" name="subRadio"  value='subAdm'>
                                    <label for="subAdm" class="custom-control-label">Subordinação Administrativa</label>
                                </div>
                            </div>
                            
                            <div class="input-group " style="margin-left:10px">
                                <input  id="filter" type="text" class="form-control rounded-0 col-sm-4"  placeholder="Digite uma palavra ou número para filtrar" spellcheck="false">
                                <span class="input-group-append">
                                    <button id="btFiltrar" type="button" class="btn btn-info btn-flat" style="font-size: 12px;background: #b93d30;"><i class="fa fa-filter"></i> Filtrar</button>
                                    <button type="button" onclick="clearFilter()" class="btn btn-info btn-flat" style="font-size: 12px;background: #b93d30;"><i class="fa fa-filter-circle-xmark"></i> Limpar Filtro/Seleção</button>
                                </span>
                            </div>
                            <div id="divTreeOrgao"></div> 
                        </div>  
                    </div><!-- /.container-fluid -->
                </section>
            </div>
            
        </div>




        </div> <!-- /.content-wrapper -->
       
        <cfinclude template="pc_Footer.cfm">
    </div><!-- ./wrapper -->
    	
	<cfinclude template="pc_Sidebar.cfm">
<!-- ZtreeCore JavaScript -->
    <script src="../SNCI_PROCESSOS/plugins/zTree_v3-master/js/jquery.ztree.core.min.js"></script>
    <script src="../SNCI_PROCESSOS/plugins/zTree_v3-master/js/jquery.ztree.exhide.min.js"></script>
    <script src="../SNCI_PROCESSOS/plugins/zTree_v3-master/js/jquery.ztree.excheck.min.js"></script>
    <script src="../SNCI_PROCESSOS/plugins/zTree_v3-master/js/jquery.ztree.exedit.min.js"></script>
    <script src="../SNCI_PROCESSOS/plugins/zTree_v3-master/js/fuzzysearch.js"></script>
    <script language="JavaScript">

        
        $(document).ready(function(){
           
            var selectedRadio = sessionStorage.getItem('selectedRadio');
            if (selectedRadio) {
                $('#' + selectedRadio).prop('checked', true);

                // Atualize zNodes com base na seleção do rádio
                carregaTreeOrgao();
            }
            
        });


        function carregaTreeOrgao() {
			$('#cutNodeBtn').hide();	
            $('#modalOverlay').modal('show')
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

            // Armazene a seleção do rádio no sessionStorage
            sessionStorage.setItem('selectedRadio', this.id);

        });

        function clearFilter() {
            carregaTreeOrgao();
            $('#filter').val('');
        }

        $('#btFiltrar').click(function() {
            
            var treeObj = $.fn.zTree.getZTreeObj("treeOrgao");
            var searchValue = $('#filter').val(); // obtém o valor do campo de entrada
   
            // realiza uma pesquisa difusa
            var nodes = treeObj.getNodesByParamFuzzy("name", searchValue, null);

            // expande os nós pai e mostra os nós filho do nó correspondente
            nodes.forEach(function(node) {
                treeObj.expandNode(node, true, false, true);
            });
        });

					


       

        

       





        






        

    </script>

</body>
</html>
```

