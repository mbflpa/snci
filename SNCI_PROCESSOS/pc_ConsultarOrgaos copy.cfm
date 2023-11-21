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
                            <cfquery name="rsOrgaos" datasource="#application.dsn_processos#">
                                SELECT pc_orgaos.*
                                FROM pc_orgaos
                                order by pc_org_sigla
                            </cfquery>       

                            <div class="form-group">
                                <div class="custom-control custom-radio">
                                    <input class="custom-control-input" type="radio" id="subTec" name="subRadio" checked>
                                    <label for="subTec" class="custom-control-label">Subordinação Técnica</label>
                                </div>
                                <div class="custom-control custom-radio">
                                    <input class="custom-control-input" type="radio" id="subAdm" name="subRadio" >
                                    <label for="subAdm" class="custom-control-label">Subordinação Administrativa</label>
                                </div>
                            </div>
                            
                            <div class="input-group ">
                                <input  id="filter" type="text" class="form-control rounded-0 col-sm-4"  placeholder="Digite uma palavra ou número para filtrar" spellcheck="false">
                                <span class="input-group-append">
                                    <button type="button" onclick="clearFilter()" class="btn btn-info btn-flat" style="font-size: 12px;"><i class="fa fa-filter"></i> Limpar Filtro</button>
                                    <button type="button" id="cutNodeBtn" class="btn btn-info btn-flat" style="font-size: 12px;"><i class="fa fa-scissors"></i> Recortar</button>
                                    <button type="button"id="pasteNodeBtn" class="btn btn-info btn-flat" style="font-size: 12px;display:none"><i class="fa fa-paste"></i> Transferir</button>
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
    <script src="../SNCI_PROCESSOS/plugins/zTree_v3-master/js/jquery.ztree.excheck.min.js"></script>
    <script src="../SNCI_PROCESSOS/plugins/zTree_v3-master/js/jquery.ztree.exedit.min.js"></script>
    <script src="../SNCI_PROCESSOS/plugins/zTree_v3-master/js/fuzzysearchModificado.js"></script>
    <script language="JavaScript">
        var zNodes =[
                        <cfoutput query="rsOrgaos">
                            { 
                                id: "#rsOrgaos.pc_org_mcu#", // unique ID
                                pId: "#rsOrgaos.pc_org_mcu_subord_tec#", // parent ID
                                name: "#rsOrgaos.pc_org_sigla# (#rsOrgaos.pc_org_descricao# - MCU: #rsOrgaos.pc_org_mcu# - <i class='fa fa-envelope'></i> #rsOrgaos.pc_org_email#)", 
                                open: false, // open this node on page load
                                status: "#rsOrgaos.pc_org_status#", // status of the node
                                extraData:"#rsOrgaos.pc_org_sigla# (#rsOrgaos.pc_org_mcu#)"
                            },
                        </cfoutput>
                    ]
        
        $(document).ready(function(){
           

            var selectedRadio = sessionStorage.getItem('selectedRadio');
            if (selectedRadio) {
                $('#' + selectedRadio).prop('checked', true);

                // Atualize zNodes com base na seleção do rádio
                if (selectedRadio === 'subTec') {
                    var zNodes =[
                        <cfoutput query="rsOrgaos">
                            { 
                                id: "#rsOrgaos.pc_org_mcu#", // unique ID
                                pId: "#rsOrgaos.pc_org_mcu_subord_tec#", // parent ID
                                name: "#rsOrgaos.pc_org_sigla# (#rsOrgaos.pc_org_descricao# - MCU: #rsOrgaos.pc_org_mcu# - <i class='fa fa-envelope'></i> #rsOrgaos.pc_org_email#)", 
                                open: false, // open this node on page load
                                status: "#rsOrgaos.pc_org_status#", // status of the node
                                extraData:"#rsOrgaos.pc_org_sigla# (#rsOrgaos.pc_org_mcu#)"
                            },
                        </cfoutput>
                    ]
                } else {
                    var zNodes =[
                        <cfoutput query="rsOrgaos">
                            { 
                                id: "#rsOrgaos.pc_org_mcu#", // unique ID
                                pId: "#rsOrgaos.pc_org_mcu_subord_adm#", // parent ID
                                name: "#rsOrgaos.pc_org_sigla# (#rsOrgaos.pc_org_descricao# - MCU: #rsOrgaos.pc_org_mcu# - <i class='fa fa-envelope'></i> #rsOrgaos.pc_org_email#)", 
                                open: false, // open this node on page load
                                status: "#rsOrgaos.pc_org_status#", // status of the node
                                extraData:"#rsOrgaos.pc_org_sigla# (#rsOrgaos.pc_org_mcu#)"
                            },
                        </cfoutput>
                    ]
                }
            }

             $.fn.zTree.init($("#treeDemo"), setting, zNodes);
            fuzzySearch('treeDemo','#filter',null,true); // initialize fuzzy search function
            setEdit();
            $("#cutNodeBtn").bind("click", cutNodeBtnClick);
            $("#pasteNodeBtn").bind("click", pasteNodeBtnClick);
        });

        
          
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
            if (treeNode.status == 'D' && treeNode.cut || treeNode.cut) {
                return {color:"gray"}; // Se o status for 'D' e o nó foi cortado, muda a cor para cinza
            } else if (treeNode.status == 'D' && treeNode.pasted || treeNode.pasted) {
                return {color:"blue"}; // Se o nó foi colado, muda a cor para azul
            } else if (treeNode.status == 'D') {
                return {color:"red"}; // Se apenas o status for 'D', muda a cor para vermelho
            } else {
                return {};
            }
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

       function cutNodeBtnClick() {
            var treeObj = $.fn.zTree.getZTreeObj("treeDemo");
            var nodes = treeObj.getSelectedNodes();
            if (nodes.length > 0) {
                cutNode = nodes[0];
                cutNode.cut = true; // Adiciona uma propriedade 'cut' ao nó
                treeObj.updateNode(cutNode); // Atualiza o nó para aplicar o novo estilo
                var nomeOrgao = cutNode.extraData;
                Swal.fire({
                    html: logoSNCIsweetalert2('<p style="text-align: justify;">Você selecionou o  órgão <strong>' + nomeOrgao +   '</strong> para alterar o a subordinação técnica.<br><br>Clique em OK, depois selecione o órgão que será a nova subordinação técnica e clique em "Transferir".<br><br>Obs.: Par retirar esse órgão de qualquer estrutura, basta não selecionar nenhum outro órgão e clicar em "Transferir".</p>'),
                    title: '',
                    confirmButtonText: 'OK!'
                });
                                    
                $('#pasteNodeBtn').show(); // Mostra o botão usando jQuery
                //alert("Órgão " + cutNode.extraData + " foi recortado.");
            }
        }

       function pasteNodeBtnClick() {
            var treeObj = $.fn.zTree.getZTreeObj("treeDemo");
            var nodes = treeObj.getSelectedNodes();
            if (nodes.length > 0 && cutNode) {// Verifica se existe algum nó selecionado e se cutNode não é null
                treeObj.moveNode(nodes[0], cutNode, "inner");
                cutNode.pasted = true; // Adiciona uma propriedade 'pasted' ao nó
                cutNode.cut = false; // Define 'cut' como false
                treeObj.updateNode(cutNode); // Atualiza o nó para aplicar o novo estilo
                $('#pasteNodeBtn').hide(); // Esconde o botão usando jQuery

                //ajax para o metodo trocaSubordTecnicaOrgao do cfc pc_cfcPaginasApoio.cfc
                if (cutNode !== null) { // Verifica se cutNode não é null antes de acessar a propriedade id
                    var mcuOrgao = cutNode.id;
                    var nomeOrgao = cutNode.extraData;
                    var mcuOrgaoSubordTec = nodes[0].id;
                    var nomeOrgaoSubordTec = nodes[0].extraData;
                    $('#modalOverlay').modal('show')
                        setTimeout(function() {
                            $.ajax({
                                type: "POST",
                                url: "../SNCI_PROCESSOS/cfc/pc_cfcPaginasApoio.cfc?method=trocaSubordTecnicaOrgao",
                                data: {
                                    "mcuOrgao": mcuOrgao,
                                    "mcuOrgaoSubordTec": mcuOrgaoSubordTec
                                },
                                success: function (data) {
                                    $('#modalOverlay').delay(1000).hide(0, function() {
                                        $('#modalOverlay').modal('hide');
                                        Swal.fire({
                                            html: logoSNCIsweetalert2('<p style="text-align: justify;">Rotina executada com sucesso! <br><br>O órgão <strong>' + nomeOrgao +   '</strong> agora está subordinado tecnicamente a <strong>' + nomeOrgaoSubordTec + '</strong>.<br><br>A página será recarregada.</p>'),
                                            title: '',
                                            confirmButtonText: 'OK!',
                                        }).then((result) => {
                                            if (result.isConfirmed) {
                                                location.reload(); // Recarrega a página
                                            }
                                        });
                                    });
                                    
                                },
                                error: function (xhr, ajaxOptions, thrownError) {
                                    alert(xhr.status);
                                    alert(thrownError);
                                }
                            });
                        }, 500);
                }
                cutNode = null;
            }
        }


        function setEdit() {
            var zTree = $.fn.zTree.getZTreeObj("treeDemo");
           
        }

       
        // Adicione um ouvinte de evento 'change' aos botões de rádio
        $('input[name="subRadio"]').change(function() {
            // Altere o valor de pId com base na seleção do rádio
            if (this.id === 'subTec') {
                var zNodes =[
                        <cfoutput query="rsOrgaos">
                            { 
                                id: "#rsOrgaos.pc_org_mcu#", // unique ID
                                pId: "#rsOrgaos.pc_org_mcu_subord_tec#", // parent ID
                                name: "#rsOrgaos.pc_org_sigla# (#rsOrgaos.pc_org_descricao# - MCU: #rsOrgaos.pc_org_mcu# - <i class='fa fa-envelope'></i> #rsOrgaos.pc_org_email#)", 
                                open: false, // open this node on page load
                                status: "#rsOrgaos.pc_org_status#", // status of the node
                                extraData:"#rsOrgaos.pc_org_sigla# (#rsOrgaos.pc_org_mcu#)"
                            },
                        </cfoutput>
                    ]
            } else {
                var zNodes =[
                        <cfoutput query="rsOrgaos">
                            { 
                                id: "#rsOrgaos.pc_org_mcu#", // unique ID
                                pId: "#rsOrgaos.pc_org_mcu_subord_adm#", // parent ID
                                name: "#rsOrgaos.pc_org_sigla# (#rsOrgaos.pc_org_descricao# - MCU: #rsOrgaos.pc_org_mcu# - <i class='fa fa-envelope'></i> #rsOrgaos.pc_org_email#)", 
                                open: false, // open this node on page load
                                status: "#rsOrgaos.pc_org_status#", // status of the node
                                extraData:"#rsOrgaos.pc_org_sigla# (#rsOrgaos.pc_org_mcu#)"
                            },
                        </cfoutput>
                    ]
            }

            // Armazene a seleção do rádio no sessionStorage
            sessionStorage.setItem('selectedRadio', this.id);

            // Recarregue a página
            location.reload();
        });




        






        

    </script>

</body>
</html>
```

