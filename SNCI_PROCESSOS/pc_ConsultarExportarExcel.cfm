<cfprocessingdirective pageencoding = "utf-8">

<!DOCTYPE html>
<html lang="pt-br">
<head>
 	<meta charset="UTF-8">
  	<meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>SNCI</title>
		<link rel="icon" type="image/x-icon" href="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png">	
           
		

		

	<style>
			textarea {
				text-align: justify!important;
			}
			.card-body{
				text-align: justify!important;
			}
			.btn-secondary {
				margin-left: 10px!important;
				border-radius: 5px!important;
			}
			div.dt-button-collection.fixed.three-column {
				margin-left:-500px!important;
				width: auto!important;
				padding:10px!important;
				
			}
			div.dt-button-collection.fixed.four-column {
				margin-left:-500px!important;
				width: auto!important;
				padding:10px!important;
			}
			.dropdown-item.active, .dropdown-item:active {
				color: #fff;
				background-color: #2581c8!important;
				
			}
			.dropdown-item {
				font-size: 0.7rem!important;
			}
			
			
	</style>
</head>
<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height" >
	<!-- Site wrapper -->
	<div class="wrapper">
	
		
		
		<cfinclude template="includes/pc_navBar.cfm">

	<!-- Content Wrapper. Contains page content -->
	<div class="content-wrapper" style="background:none" >
		<!-- Content Header (Page header) -->
		
		<section class="content-header">
			<div class="container-fluid">
				
				<div class="row mb-2" style="margin-bottom:0px!important;">
					<div class="col-sm-6">
						<h4>Consulta para Exportação</h4>
					</div>
				</div>
			</div><!-- /.container-fluid -->
		</section>


		<!-- Main content -->
		<section class="content">
			<div class="container-fluid" >
				<div style="display: flex;align-items: center;">
					<span class="azul_claro_correios_textColor" style="font-size:20px;margin-right:10px">Consultar Por:</span>
					<div id="opcaoTipoConsulta" class="btn-group btn-group-toggle" data-toggle="buttons">
						<label style="border:none!important;border-radius:10px!important;margin-left:2px" class="btn bg-yellow active efeito-grow"><input type="radio" checked="" name="opcaoTipoConsulta" id="tipoProcesso" autocomplete="off" value="p" /> PROCESSOS</label><br>
						<label style="border:none!important;border-radius:10px!important;margin-left:2px" class="btn bg-yellow active efeito-grow"><input type="radio"  name="opcaoTipoConsulta" id="tipoItens" autocomplete="off" value="i" /> ITENS</label><br>
						<label style="border:none!important;border-radius:10px!important;margin-left:2px" class="btn bg-yellow active efeito-grow"><input type="radio"  name="opcaoTipoConsulta" id="tipoOrientacoes" autocomplete="off" value="o" /> ORIENTAÇÕES</label><br>
						<label style="border:none!important;border-radius:10px!important;margin-left:2px" class="btn bg-yellow active efeito-grow"><input type="radio"  name="opcaoTipoConsulta" id="tipoOrientacoes" autocomplete="off" value="m" /> PROP. MELHORIA</label><br>
					</div>
				</div>
				<div style="display: flex;align-items: center;">
					<span class="azul_claro_correios_textColor" style="font-size:20px;margin-right:10px">Ano:</span>
					<div id="opcoesAno" class="btn-group btn-group-toggle" data-toggle="buttons" style=" margin-left: 82px;"></div><br><br>
				</div>
				<div class="row" id="divTabela">
				<div class="col-12">
					<div class="card card-success" style="margin-top:20px;">
						<div class="card-header card-header_backgroundColor"></div>
						<!-- /.card-header -->
						<div class="card-body card_border_correios">
							<table id="tabProcessos" class="table table-striped table-hover text-nowrap table-responsive" ></table>
						</div>
						<!-- /.card-body -->
						<div id="exibirGrafico"></div>
					</div>
					<!-- /.card -->
				</div>
			</div>
		</section>
		<!-- /.content -->
	</div>
	<!-- /.content-wrapper -->
	<cfinclude template="includes/pc_footer.cfm">
	</div>
	<!-- ./wrapper -->
	<cfinclude template="includes/pc_sidebar.cfm">

   <!-- Gráficos -->
    <script src="plugins/chart.js/Chart.js"></script>
    <script src="plugins/chart.js/Chart.bundle.min.js"></script>
	<!--Para charmar o plugin que inclui lengenda dentro do gráfico-->		
	<script src="plugins/chart.js/chartjs-plugin-datalabels.min.js"></script>
	
	<script language="JavaScript">
		
		$(window).on("load",function(){
           
			const radio_name="opcaoAno";
			const ano = [];
			const anoCorrente = new Date();
			const anoAtual = anoCorrente.getFullYear();

			// Verifica se o ano 2024 está no array e o adiciona se não estiver
			if (!ano.includes(2024)) {
				ano.push(2024);
			}

			// Verifica se o ano atual está no array e o adiciona se não estiver
			if (!ano.includes(anoAtual)) {
				ano.push(anoAtual);
			}
			
			if( ano.length === 0 ){
				ano.push(anoAtual);
			}
			if( ano.length > 1 ){
				ano.push("TODOS");
			}
			const anoq = ano.length-1;
			$.each(ano.sort().reverse(), function(i,val){
				if(i == anoq){
					$('<label style="border:none!important;border-radius:10px!important;margin-left:1px;" class="efeito-grow btn bg-blue "><input type="radio" name="opcaoAno" id="option_b'+i+'" autocomplete="off" value="'+val+'" />'+val+'</label><br>').prependTo('#opcoesAno');
				}else{
					$('<label style="border:none!important;border-radius:10px!important;margin-left:1px;" class="efeito-grow btn bg-blue"><input type="radio" name="opcaoAno" id="option_b'+i+'" autocomplete="off" value="'+val+'" />'+val+'</label><br>').prependTo('#opcoesAno');
				}
			})

			var radioValueAno = $("input[name='opcaoAno']:checked").val();
			var radioValueTipo = $("input[name='opcaoTipoConsulta']:checked").val();
				
			
			exibirTabExportarDiv(radioValueTipo,radioValueAno);		
					

			$("input[type='radio']").click(function(){
				radioValueAno = $("input[name='opcaoAno']:checked").val();
				radioValueTipo = $("input[name='opcaoTipoConsulta']:checked").val();
				exibirTabExportarDiv(radioValueTipo,radioValueAno);
			});
		});

		


		function exibirTabExportarDiv(tipo, ano){
			let tipoConsulta = "";
			let tipoSelecao = "";
			let metodo = "";
			let titleExportarExcel = "";
			let columns = [];
			if(tipo ==='p'){
				tipoConsulta ="tabConsultaExportarProcessos"; 
				if(ano === undefined){
					tipoSelecao="PROCESSOS (não selecionou o ano)";
				}else{
					tipoSelecao="PROCESSOS: " + ano;
					$('.card-header_backgroundColor').html(tipoSelecao);
					metodo = "getProcessosJSON";
					titleExportarExcel = "SNCI_Processos_";
					$('#modalOverlay').modal('show');
				}
			}

			if(tipo ==='i'){
				tipoConsulta ="tabConsultaExportarItens"
				if(ano === undefined){
					tipoSelecao="ITENS (não selecionou o ano)";
				}else{
					tipoSelecao="ITENS: " + ano;
					$('.card-header_backgroundColor').html(tipoSelecao);
					metodo = "getItensJSON";
					titleExportarExcel = "SNCI_Itens_";
					
					$('#modalOverlay').modal('show');
				}
			};
			if(tipo ==='o'){
				tipoConsulta ="tabConsultaExportarOrientacoes";
				if(ano === undefined){
					tipoSelecao="ORIENTAÇÕES (não selecionou o ano)";
				}else{
					tipoSelecao="ORIENTAÇÕES: " + ano;
					$('.card-header_backgroundColor').html(tipoSelecao);
					metodo = "getOrientacoesJSON";
					titleExportarExcel = "SNCI_Orientacoes_";

					$('#modalOverlay').modal('show');
				}
			};
			if(tipo ==='m'){
				tipoConsulta ="tabConsultaExportarMelhorias";
				if(ano === undefined){
					tipoSelecao="PROPOSTAS DE MELHORIA (não selecionou o ano)";
				}else{
					tipoSelecao="PROPOSTAS DE MELHORIA: " + ano;
					$('.card-header_backgroundColor').html(tipoSelecao);
					metodo = "getPropostasMelhoriaJSON";
					titleExportarExcel = "SNCI_Propostas_Melhoria_";
					
					$('#modalOverlay').modal('show');
				}
			};
			
			var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()

			var d = day + "-" + month + "-" + year;	
			
			// Criação dinâmica do array de colunas
			columns = [
				{ data: 'PC_PROCESSO_ID', title: 'N°Processo SNCI' },
				{ data: 'PC_STATUS_DESCRICAO', title: 'Status do Processo' },
				{ data: 'DATA_FIM_PROCESSO', title: 'Data Fim Processo' },
				{ data: 'SE_ORGAO_AVALIADO', title: 'SE/CS' },
				{ data: 'PC_ANO_PACIN', title: 'Ano PACIN' },
				{ data: 'PC_NUM_SEI', title: 'N° SEI' },
				{ data: 'PC_NUM_REL_SEI', title: 'N° Relat. SEI' },
				{ data: 'DATA_INICIO', title: 'Início Avaliação' },
				{ data: 'DATA_FIM', title: 'Fim Avaliação' },
				{ data: 'SIGLA_ORGAO_ORIGEM', title: 'Órgão Origem' },
				{ data: 'SIGLA_ORGAO_AVALIADO', title: 'Órgão Avaliado' },
				{ data: 'PC_AVAL_TIPO_DESCRICAO', title: 'Tipo de Avaliação' },
				{ data: 'TIPOPROCESSON3', title: 'Tipo de Avaliação - N3' },
				{ data: 'MODALIDADE', title: 'Modalidade' },
				{ data: 'PC_CLASS_DESCRICAO', title: 'Classificação' },
				{ data: 'TIPO_DEMANDA', title: 'Tipo Demanda' },
				{ data: 'AVALIADORES', title: 'Avaliador(es)' },
				{ data: 'COORDENADOR_REGIONAL', title: 'Coordenador Regional' },
				{ data: 'COORDENADOR_NACIONAL', title: 'Coordenador Nacional' },
				{ data: 'OBJETIVOSESTRATEGICOSLIST', title: 'Objetivos Estratégicos'},
				{ data: 'RISCOSESTRATEGICOSLIST', title: 'Riscos Estratégicos'},
				{ data: 'INDICADORESESTRATEGICOSLIST', title: 'Indicadores Estratégicos'},

			];

			// Adiciona colunas adicionais com base no tipo
			if (tipo === 'i' || tipo === 'o' || tipo === 'm') {
				columns.push(
					{ data: 'PC_AVAL_ID', title: 'Cód. Item' },
					{ data: 'PC_AVAL_NUMERACAO', title: 'N° do Item' },
					{ data: 'PC_AVAL_DESCRICAO', title: 'Título da situação encontrada' },
					{ data: 'PC_AVAL_TESTE', title: 'Teste (Pergunta do Plano)' },
					{ data:	'PC_AVAL_CONTROLETESTADO', title: 'Controle Testado' },	
					{ data:	'TIPOSCONTROLESLIST', title: 'Tipo de Controle' },
					{ data:	'CATEGORIASCONTROLESLIST', title: 'Categoria do Controle Testado' },
					{ data:	'PC_AVAL_SINTESE', title: 'Síntese' },
					{ data:	'RISCOSLIST', title: 'Risco Identificado' },
					{ data:	'PC_AVAL_COSOCOMPONENTE', title: 'Componente COSO' },
					{ data:	'PC_AVAL_COSOPRINCIPIO', title: 'Princípio COSO' },
					{ data:	'PC_AVAL_CRITERIOREF_DESCRICAO',title: 'Critérios e Referências Normativas' },
					{ data:	'CLASSIFRISCO', title: 'Classificação do Item' },
					{ data:	'PC_AVAL_VALORESTIMADORECUPERAR', title: 'P.V.E. Recuperar' },
					{ data:	'PC_AVAL_VALORESTIMADORISCO', title: 'P.V.E. Risco ou Valor Envolvido' },
					{ data:	'PC_AVAL_VALORESTIMADONAO_PLANEJADO', title: 'P.V.E. Não Planejado/Extrapolado/Sobra' },
					{ data:	'PC_AVAL_STATUS_DESCRICAO', title: 'Status do Item' },
					
					
				);
			}

			if (tipo === 'o') {
				columns.push(
					{ data: 'PC_AVAL_ORIENTACAO_ID', title: 'Cód. Orientação' },
					{ data: 'PC_AVAL_ORIENTACAO_DESCRICAO', title: 'Orientação' },
					{ data: 'ORIENTACAO_ORGAO_RESP', title: 'Órgão Responsável' },
					{ data: 'CATEGORIASCONTROLESORIENTACAOLIST', title: 'Categoria do Controle Proposto' },
					{ data: 'PC_AVAL_ORIENTACAO_BENEFICIO_NAO_FINANCEIRO', title: 'Benefício Não Financeiro' },
					{ data: 'PC_AVAL_ORIENTACAO_BENEFICIOFINANCEIRO', title: 'Benefício Financeiro' },
					{ data: 'PC_AVAL_ORIENTACAO_CUSTOFINANCEIRO', title: 'Custo Financeiro' },
					{ data: 'PC_AVAL_ORIENTACAO_STATUS_DESCRICAO', title: 'Status da Orientação' },
					{ data: 'PC_AVAL_ORIENTACAO_STATUS_DATA', title: 'Data Status Orientação' },
					{ data: 'PC_AVAL_ORIENTACAO_DATA_PREVISTA_RESP', title: 'Data Prev. Resp.' },
					{ data: 'PC_ORIENTACAO_STATUS_FINALIZADOR', title: 'Acomp. Finalizado?' },

				);
			}

			if (tipo === 'm') {
				columns.push(
					{ data: 'PC_AVAL_MELHORIA_ID', title: 'Cód. Prop. Melhoria' },
					{ data: 'PC_AVAL_MELHORIA_DESCRICAO', title: 'Proposta de Melhoria' },
					{ data: 'ORGAORESP', title: 'Órgão Responsável' },
					{ data: 'CATEGORIASCONTROLESMELHORIALIST', title: 'Categoria do Controle Proposto' },
					{ data: 'PC_AVAL_MELHORIA_BENEFICIO_NAO_FINANCEIRO', title: 'Benefício Não Financeiro' },
					{ data: 'PC_AVAL_MELHORIA_BENEFICIOFINANCEIRO', title: 'Benefício Financeiro' },
					{ data: 'PC_AVAL_MELHORIA_CUSTOFINANCEIRO', title: 'Custo Financeiro' },
					{ data: 'STATUSMELHORIA', title: 'Status da Prop. Melhoria' },
					{ data: 'DATAPREV', title: 'Data Prev.' },
					{ data: 'PC_AVAL_MELHORIA_SUGESTAO', title: 'Melhoria Sugerida pelo Órgão' },
					{ data: 'ORGAORESPSUG', title: 'Órgão Resp. Sugerido' },
					{ data: 'PC_AVAL_MELHORIA_NAOACEITA_JUSTIF', title: 'Justificativa da Recusa' }	
				);
			}

			if ($.fn.DataTable.isDataTable('#tabProcessos')) {
				$('#tabProcessos').DataTable().clear().destroy(); // Remove a tabela anterior e dados
				$('#tabProcessos').empty(); // Remove a tabela anterior do DOM
			}
			
			$('#divTabela').css('visibility', 'hidden');
			
			if(ano !== undefined){
				$(function () {
					$('#tabProcessos').DataTable( {
						ajax: {
							url: `cfc/pc_cfcConsultasDiversas.cfc?method=${metodo}`, // URL para obter dados JSON
							dataType: "json",
							dataSrc: "", // Usamos uma string vazia para evitar problemas com objetos aninhados
							data: {
								ano: ano // Valor estático para o parâmetro ano
							}
						},
						destroy: true,
						ordering: false,
						stateSave: false,
						filter: false,
						autoWidth: true,
						deferRender: true, // Aumentar desempenho para tabelas com muitos registros
						pageLength: 3,
						buttons: [{
								extend: 'excelHtml5',
								text: '<i class="fas fa-file-excel fa-2x grow-icon" ></i>',
								title : titleExportarExcel + d,
								className: 'btExcel',
								exportOptions: {
									columns: ':visible',
									format: {
										body: function(data, row, column, node) {
											// Verifica se a coluna é a de "N° do Item"
											if (column === $('th:contains("N° do Item")').index()) {
												// Verifica se data é uma string antes de aplicar replace
												if (typeof data === 'string') {
													// Substitui todos os pontos por " . "
													return data.replace(/\./g, ' . '); // Usando replace para compatibilidade
												}
											}
											// Retorna o dado original se não for a coluna desejada ou não for uma string
											return data;
										}
									}
								},
								customize: function(xlsx) {
									var sheet = xlsx.xl.worksheets['sheet1.xml'];
									
									$('row:eq(0) c', sheet).attr('s','50');//centraliza 1° linha (título)
									$('row:eq(0) c', sheet).attr('s','2');//1° linha em negrito
									$('row:eq(1) c', sheet).attr('s','51');//2° linha centralizada
									$('row:eq(1) c', sheet).attr('s','2');//2° linha em negrito
								
									//PARA PERCORRER TODAS AS COLUNAS E APLICAR UM STYLE
									// var twoDecPlacesCols = ['A','B','C','D','E','F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P'];           
									// for ( i=0; i < twoDecPlacesCols.length; i++ ) {
									// 	$('row c[r^='+twoDecPlacesCols[i]+']', sheet).attr( 's', '25' );
									// }
								},
								customizeData: function (data) {
									// Percorre os dados exportados
									for (var i = 0; i < data.body.length; i++) {
										var rowData = data.body[i];
										// Percorre as células da linha
										for (var j = 0; j < rowData.length; j++) {
											var cellData = rowData[j];
											// Verifica se cellData é uma string e contém "&nbsp;"
											if (typeof cellData === 'string' && cellData.includes('&nbsp;')) {
												// Substitui todas as ocorrências de "&nbsp;" por espaços regulares
												rowData[j] = cellData.replace(/&nbsp;/g, ' ');
											}
										}
									}
								}
							},
							{
								extend: 'colvis',
								text: 'Selecionar Colunas',
								className: 'btSelecionarColuna',
								collectionLayout: 'fixed four-column',
								colvisButton: true,
								
							},
								
							{
								text: '<i class="fas fa-eye" title="Visualizar todas as colunas."></i>',
								action: function (e, dt, node, config) {
									$('#modalOverlay').modal('show');
									setTimeout(function() {
										dt.columns().visible(true);
									}, 500);
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
									});

								}
							},
							{
								text: '<i class="fas fa-eye-slash" title="Oculta todas as colunas."></i>',
								action: function (e, dt, node, config) {
									$('#modalOverlay').modal('show');
									setTimeout(function() {
										dt.columns().visible(false);
									}, 500);
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
									});

								}
							},
						],
						dom: "<'row'<'col-sm-4'<'dtsp-dataTable'Bf>><'col-sm-8 text-left'p>>" + "<'col-sm-12 text-left'i>" + "<'row'<'col-sm-12'tr>>",
						
						language: {
							url: "../SNCI_PROCESSOS/plugins/datatables/traducao.json"
						},
						columns: columns,
						drawCallback: function(settings) {//após a tabela se renderizada
							
						},
						initComplete: function () {
  
							$('#modalOverlay').delay(1000).hide(0, function() {
								$('#divTabela').css('visibility', 'visible');
								$('.table thead').addClass('table_thead_backgroundColor'); // Aplica a classe ao <thead> ao finalizar a inicialização
								
								$('#modalOverlay').modal('hide');
							});
							
						},
						

					}).buttons().container().appendTo('#tabProcessos_wrapper .col-md-6:eq(0)');
				} );
				
			}	

			
			
				
			

		}


			
		
	</script>

</body>
</html>
