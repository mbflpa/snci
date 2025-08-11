<cfprocessingdirective pageencoding = "utf-8">
<cfinclude template="../SNCI_AVALIACOES_AUTOMATIZADAS/includes/aa_modal_overlay.cfm ">
<cfinclude template="../SNCI_AVALIACOES_AUTOMATIZADAS/includes/aa_modal_preloader.cfm">

<cftry>
    <cfobject name="testesObj" component="cfc.TestesAplicados">
    <cfset dadosTestes = testesObj.rsTestesAplicados()>
    <cfcatch>
        <cfset dadosTestes = structNew()>
        <cfset dadosTestes.erro = cfcatch.message>
    </cfcatch>
</cftry>

<!DOCTYPE html>
<html lang="pt-br">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>SNCI - Testes Aplicados</title>
    <link rel="icon" type="image/x-icon" href="../SNCI_AVALIACOES_AUTOMATIZADAS/dist/img/icone_sistema_standalone_ico.png">
    
    <style>
        .testes-aplicados-layout {
            padding: 16px;
        }
        
        .testes-table-container {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        #testesAplicadosTable td,
        #testesAplicadosTable th {
            text-align: justify;
        }

        @media (max-width: 1200px) {
            .testes-aplicados-layout {
                flex-direction: column;
            }
        }
    </style>
</head>
<body class="hold-transition layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height" >

	<div class="wrapper">
        <cfinclude template="includes/aa_navBar.cfm">
        <cfinclude template="includes/aa_sidebar.cfm">
        
        <div class="content-wrapper">
            <section class="content">
                <div class="container-fluid">
                    <div class="row">
                        <div class="col-12">
                            <h3 class="m-3">Testes Aplicados
                                <i class="fas fa-info-circle info-icon-automatizadas" style="position: relative;right: 3px;bottom: 13px;font-size: 1rem;" 
                                    data-toggle="popover" 
                                    data-trigger="hover" 
                                    data-placement="right"
                                    data-html="false"
                                    data-content="Lista todos os testes aplicados conforme o tipo de unidade.">
                                </i>
                            </h3>
                        </div>
                    </div>
                </div>
 
                <div class="testes-aplicados-layout">
                    <div class="testes-table-container">
                        <cfif structKeyExists(dadosTestes, "erro")>
                            <div class="alert alert-danger">
                                <strong>Erro:</strong> <cfoutput>#dadosTestes.erro#</cfoutput>
                            </div>
                        </cfif>
                        
                        <table id="testesAplicadosTable" class="table table-striped table-bordered" style="width:100%">
                            <thead>
                                <tr>
                                    <th>N° do Teste</th>
                                    <th>Assunto</th>
                                    <th>Teste</th>
                                    <th>Fonte de Dados</th>
                                    <th>Critério</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfif structKeyExists(dadosTestes, "testes") AND dadosTestes.testes.recordcount GT 0>
                                    <cfoutput>
                                        <cfloop query="dadosTestes.testes">
                                            <tr>
                                                <td>#TESTE#</td>
                                                 <td>#MANCHETE#</td>
                                                <td>#DESCRIÇÃO#</td>
                                                <td>#fonte_dados#</td>
                                                <td>#criterio#</td>
                                            </tr>
                                        </cfloop>
                                    </cfoutput>
                                <cfelse>
                                    <tr>
                                        <td colspan="3" class="text-center">Nenhum teste encontrado</td>
                                    </tr>
                                </cfif>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>
        </div>

        <cfinclude template="includes/aa_footer.cfm">
   </div>
    
    <script language="JavaScript">
        $(document).ready(function(){
            $.widget.bridge('uibutton', $.ui.button);
            $('#modalOverlay').modal('hide');
                $('#testesAplicadosTable').DataTable({
                     // Idioma em português
                   language: {
							url: "../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/datatables/traducao.json"
						},
                    responsive: true,
                    autoWidth: false,
                    paging:false,
                    order: [[ 0, "asc" ]],
                   
                });
           
        });
    </script>
</body>

</html>

