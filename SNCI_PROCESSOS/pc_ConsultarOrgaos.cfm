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
            <div class="col-sm-8">
                <section class="content">
                    <div class="container-fluid">
                        <div>
                            <cfquery name="rsOrgaos" datasource="#application.dsn_processos#">
                                SELECT pc_orgaos.*
                                FROM pc_orgaos
                                order by pc_org_se_sigla, pc_org_mcu_subord_adm, pc_org_sigla, pc_org_mcu
                            </cfquery>       
                            <input type="text" id="filter" placeholder="Digite uma palavra ou número para filtrar" spellcheck="false">
                            <button onclick="filterTree()"><i class="fa fa-search"></i> Filtrar</button>
                            <button onclick="clearFilter()"><i class="fa fa-filter"></i> Limpar Filtro</button>
                            <ul id="treeDemo" class="ztree"></ul>    
                        </div>  
                    </div><!-- /.container-fluid -->
                </section>
            </div>
            <div class="col-sm-4">
                <section class="content">
                    <div class="container-fluid">
                        <div>
                            <div>
                                <h6>Estrutura dos Órgãos:</h6>
                            </div>
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
    <script language="JavaScript">

        
        $(document).ready(function(){
            $.fn.zTree.init($("#treeDemo"), setting, zNodes);
        });

     var zNodes =[
                <cfoutput query="rsOrgaos">
                    { 
                        id: #rsOrgaos.pc_org_mcu#, // unique ID
                        pId: #rsOrgaos.pc_org_mcu_subord_adm#, // parent ID
                        name: "#rsOrgaos.pc_org_sigla# (#rsOrgaos.pc_org_descricao#-#rsOrgaos.pc_org_mcu#)", 
                        open: false, // open this node on page load
                        status: "#rsOrgaos.pc_org_status#" // status of the node
                    },
                </cfoutput>
                
            ];
        var setting = {
            data: {
                simpleData: {
                    enable: true
                }
            },
            view: {
                fontCss: getFontCss,
             }
        };
        
        function getFontCss(treeId, treeNode) {
            return treeNode.status == 'D' ? {color:"red"} : {};
        }

        function filterTree() {
            var treeObj = $.fn.zTree.getZTreeObj("treeDemo");
            var filterValue = document.getElementById('filter').value.toUpperCase();

            // Define a função para encontrar os nós filhos
            var findChildNodes = function(node) {
                var childNodes = [];
                for (var i = 0; i < zNodes.length; i++) {
                    if (zNodes[i].pId === node.id) {
                        childNodes.push(zNodes[i]);
                        childNodes = childNodes.concat(findChildNodes(zNodes[i]));
                    }
                }
                return childNodes;
            };

            // Define a função de filtro
            var filterFunc = function(node) {
                return node.name.toUpperCase().indexOf(filterValue) > -1;
            };

            // Filtra os dados originais
            var filteredNodes = zNodes.filter(filterFunc);

            // Adiciona todos os nós filhos dos nós filtrados
            for (var i = 0; i < filteredNodes.length; i++) {
                filteredNodes = filteredNodes.concat(findChildNodes(filteredNodes[i]));
            }

            // Remove duplicatas
            filteredNodes = filteredNodes.filter(function(node, index) {
                return filteredNodes.indexOf(node) === index;
            });

            // Reconstrói a árvore com os dados filtrados
            treeObj.destroy();
            $.fn.zTree.init($("#treeDemo"), setting, filteredNodes);
        }

        function clearFilter() {
            var treeObj = $.fn.zTree.getZTreeObj("treeDemo");

            // Reinicializa a árvore com todos os nós originais
            treeObj.destroy();
            $.fn.zTree.init($("#treeDemo"), setting, zNodes);
            $('#filter').val('');
        }






        

    </script>

</body>
</html>
```

