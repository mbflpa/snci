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
                <div class="col-sm-4">
                    <section class="content">
                        <div class="container-fluid">
                            <div class="row mb-5" style="margin-top:20px;margin-bottom:0px!important;">
                                <div class="col-sm-4">
                                    <h6>Órgãos:</h6>
                               
                                    <!--Criar a cfquery da tabela pc_orgaos agrupada por pc_org_se_sigla e depois por pc_org_mcu_subord_adm-->
                                    <cfquery name="rsOrgaos" datasource="#application.dsn_processos#">
                                        SELECT pc_org_se_sigla, pc_org_mcu_subord_adm, pc_org_sigla, pc_org_mcu
                                        FROM pc_orgaos
                                        GROUP BY pc_org_se_sigla, pc_org_mcu_subord_adm, pc_org_sigla, pc_org_mcu  
                                        order by pc_org_se_sigla, pc_org_mcu_subord_adm, pc_org_sigla, pc_org_mcu
                                    </cfquery>       
                                    
                                    

                       
                                  
                                </div>    
                            </div>    
                        </div><!-- /.container-fluid -->
                    </section>
                </div>
                <div class="col-sm-7">
                    <section class="content">
                        <div class="container-fluid">
                            <div class="row mb-4" style="margin-top:20px;margin-bottom:0px!important;">
                                <div class="col-sm-4">
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
</body>
</html>
```

