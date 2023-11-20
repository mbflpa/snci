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
            <div class="col-sm-12">
                <section class="content">
                    <div class="container-fluid">
                        <div>
                            <cfquery name="rsOrgaos" datasource="#application.dsn_processos#">
                                SELECT pc_orgaos.*
                                FROM pc_orgaos
                                order by pc_org_sigla
                            </cfquery>       
                           
                            <div class="input-group ">
                                <input  id="filter" type="text" class="form-control rounded-0 col-sm-4"  placeholder="Digite uma palavra ou número para filtrar" spellcheck="false">
                                <span class="input-group-append">
                                    <button type="button" onclick="clearFilter()" class="btn btn-info btn-flat" style="font-size: 12px;"><i class="fa fa-filter"></i> Limpar Filtro</button>
                                </span>
                            </div>
                            <ul style="margin-bottom:80px" id="treeDemo" class="ztree"></ul>    
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
    <script src="../SNCI_PROCESSOS/plugins/zTree_v3-master/js/fuzzysearchModificado.js"></script>
    <script language="JavaScript">

        
        $(document).ready(function(){
            $.fn.zTree.init($("#treeDemo"), setting, zNodes);
            fuzzySearch('treeDemo','#filter',null,true); // initialize fuzzy search function
        });

     var zNodes =[
                <cfoutput query="rsOrgaos">
                    { 
                        id: #rsOrgaos.pc_org_mcu#, // unique ID
                        pId: #rsOrgaos.pc_org_mcu_subord_adm#, // parent ID
                        name: "#rsOrgaos.pc_org_sigla# (#rsOrgaos.pc_org_descricao# - MCU: #rsOrgaos.pc_org_mcu# - <i class='fa fa-envelope'></i> #rsOrgaos.pc_org_email#)", 
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
            keep: {
                leaf: true
            },
            view: {
                fontCss: getFontCss,
                dblClickExpand: false,
                nameIsHTML: true
             },
             callback: {
				onClick: onClick
			}
        };
        
        function getFontCss(treeId, treeNode) {
            return treeNode.status == 'D' ? {color:"red"} : {};
        }

       

        function clearFilter() {
            var treeObj = $.fn.zTree.getZTreeObj("treeDemo");

            // Reinicializa a árvore com todos os nós originais
            treeObj.destroy();
            $.fn.zTree.init($("#treeDemo"), setting, zNodes);
            $('#filter').val('');
        }

       function onClick(e,treeId, treeNode) {
			var zTree = $.fn.zTree.getZTreeObj("treeDemo");
			zTree.expandNode(treeNode);
		}





        






        

    </script>

</body>
</html>
```

