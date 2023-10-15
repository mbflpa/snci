<cfprocessingdirective pageencoding = "utf-8">

<!DOCTYPE html>
<html lang="pt-br">
<head>
 	<meta charset="UTF-8">
  	<meta http-equiv="X-UA-Compatible" content="IE=edge">
  	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>SNCI</title>
	<link rel="stylesheet" href="dist/css/stylesSNCI_PaineisFiltro.css">
	<style>
        /* Estilo dos cartões de usuário */
        .user-card {
			background: #f8f9fa;
			border: 1px solid #dee2e6;
			border-radius: 10px;
			padding: 5px;
			box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
			width: 260px;
			height: 115px;
			display: flex;
			flex-direction: column;
			justify-content: center;
			position: relative; /* Adiciona posição relativa para posicionar o ícone */
		}

		.user-card .fa-user {
			transition: transform 0.3s linear;
		}

		.user-card:hover .fa-user {
			transform: scale(1.3);
		}
		
		.user-card-desativado {
			background: #ff6a6a;
		}
		
		.user-card-cell {
			padding: 0; /* Remova o padding da célula para encaixar o card */
		}

		/* Mantenha as mesmas classes existentes */
		.user-icon {
			position: absolute;
			top: 50%;
			left: 50%;
			transform: translate(-50%, -50%);
			font-size: 85px;
			opacity: 0.1;
			color:rgba(0, 0, 0, 62%);
		}

		.card-icons {
			display: flex;
			justify-content: space-between; /* Espaço entre os ícones */
			align-items: center; /* Centraliza verticalmente */
			gap: 25px; /* Espaçamento entre os ícones */
		}

		.card-icons i {
			font-size: 15px;
			cursor: pointer;
			/* Outros estilos dos ícones */
		}

		.user-name {
			font-size: 12px;
			font-weight: bold;
			color: #343a40;
			margin-bottom: 10px;
			white-space: nowrap;
			overflow: hidden;
			text-overflow: ellipsis;
		}

		.user-info {
			font-size: 12px;
			color: #6c757d;
			line-height: 0;
		}
		.user-info p {
			margin-bottom: 0.5rem;
			white-space: nowrap;
			overflow: hidden;
			text-overflow: ellipsis;
		}

		
		.user-desativado {
			color: #fff;
		}
		

				

		.user-controles {
			font-size: 12px;
			font-weight: bold;
			display: flex;
    		justify-content: space-between;
			float: right;
		}
		.grid-container{
			display: flex;
			flex-wrap: wrap;
			grid-row-gap: 10px!important;
			grid-column-gap: 35px!important;
			justify-content: space-around;
			max-height: 350px;
			overflow-y: auto;
			overflow-x: hidden!important;
			justify-items: center;
		}
		

    </style>
</head>
<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed " data-panel-auto-height-mode="height">
	<!-- Site wrapper -->
	<div class="wrapper" >

		<cfinclude template="pc_Modal_preloader.cfm">
		<cfinclude template="pc_NavBar.cfm">

		<!-- Content Wrapper. Contains page content -->
		<div class="content-wrapper" >

			<!-- Main content -->
			<div class="content" style="overflow: auto;">
				
				<div class="container-fluid">
					
					<div class="card-body" >
						<div class="row mb-2" style="margin-bottom:0px!important;">
							<div class="col-sm-6">
								<h4>Usuários Cadastrados</h4>
							</div>
						</div>

						<form id="formCadUsuarios" class="row g-3 needs-validation was-validated" novalidate format="html"   name="formCadUsuarios" format="html"  style="height: auto;">
							<div id="cadastroUsuarios" class="card card-primary collapsed-card" style="margin-left: 8px;">
								<div  class="card-header" style="background-color: #0083ca;color:#fff;">
									<a   class="d-block" data-toggle="collapse" href="#collapseOne" style="font-size:16px;" data-card-widget="collapse">
										<button type="button" class="btn btn-tool" data-card-widget="collapse"><i id="maisMenos" class="fas fa-plus"></i>
										</button></i><span id="cabecalhoAccordion">Clique aqui para cadastrar um novo Usuário</span>
									</a>
									
								</div>
								
								
								<input id="usuarioEditar" hidden></input>
								<div id="matriculaCadastradaDiv"></div>

								<div class="card-body" style="border: solid 3px #0083ca">
									<div class="row" style="font-size:16px">

										<div class="col-sm-2">
											<div class="form-group">
												<label for="usuarioMatricula" >Matrícula:</label>
												<input id="usuarioMatricula"  required  name="usuarioMatricula" type="text" class="form-control"  data-inputmask="'mask': '9.999.999-9'" data-mask="99999999" inputmode="text" placeholder="Matricula...">
											</div>
										</div>

										<div class="col-sm-8">
											<div class="form-group">
												<label for="usuarioNome" >Nome:</label>
												<input id="usuarioNome"  required  name="usuarioNome" type="text" class="form-control "  inputmode="text" placeholder="Informe o nome do usuario...">
											</div>
										</div>
										<div id="usuarioStatusDiv" class="col-sm-2" hidden>
											<div class="form-group">
												<label for="usuarioStatus">Status:</label>
												<select id="usuarioStatus" required name="usuarioStatus" class="form-control"  style="height:40px;">
													<option selected="" disabled="" value=""></option>
													<option  value="A" >Ativo</option>
													<option  value="D" >Desativado</option>
												</select>
											</div>
										</div>

										<cfquery name="rsLotacao" datasource="#application.dsn_processos#">
											SELECT pc_orgaos.* FROM pc_orgaos WHERE pc_org_status in ('A','O') ORDER BY pc_org_sigla
										</cfquery>
										<div class="col-sm-6">
											<div class="form-group">
												<label for="usuarioLotacao">Lotação:</label>
												<select id="usuarioLotacao" required name="usuarioLotacao" class="form-control"  style="height:40px">
													<option selected="" disabled="" value="">Selecione a lotação...</option>
													<cfoutput query="rsLotacao">
														<option value="#pc_org_mcu#">#pc_org_sigla#</option>
													</cfoutput>
												</select>
											</div>
										</div>

										<cfquery name="rsPerfil" datasource="#application.dsn_processos#">
											SELECT pc_perfil_tipos.* FROM pc_perfil_tipos 
											WHERE pc_perfil_tipo_status = 'A' and not pc_perfil_tipo_id = 3
											ORDER BY pc_perfil_tipo_descricao
										</cfquery>
										<div class="col-sm-6">
											<div class="form-group">
												<label for="usuarioPerfil">Perfil:</label>
												<select id="usuarioPerfil" required name="usuarioPerfil" class="form-control"  style="height:40px">
													<option selected="" disabled="" value="">Selecione o perfil...</option>
													<cfoutput query="rsPerfil">
														<option value="#pc_perfil_tipo_id#">#pc_perfil_tipo_descricao#</option>
													</cfoutput>
												</select>
											</div>
										</div>

										<div style="justify-content:center; display: flex; width: 100%;margin-top:20px">
											<div id="btSalvarDiv" >
												<button id="btSalvar" class="btn btn-block btn-primary " >Salvar</button>
												
											
											</div>
											<div style="margin-left:100px">
												
												<button id="btCancelar"  class="btn btn-block btn-danger " >Cancelar</button>
											</div>
											
										</div>
									</div> <!-- fim row -->
								</div><!--fim card-body -->
								<!--fim collapseOne -->
							</div><!--fim card card-primary -->
						</form><!-- fim formCadUsuarios -->



						<!--xxxxxxxxxxxxxxx TABELA XXXXXXXX-->						
						<div id="tabUsuarios">
							<div class="card-body" style="border: solid 3px #ffD400;background: #fff;">
								
									<table id="tabUsuariosCad" class="table ">
										<thead>
											<tr style="background: none;border:none">
												<th style="background: none;border:none"></th>
											</tr>
										</thead>
										<tbody class="grid-container" style="min-height:275px"></tbody>
									</table>
								
							</div>
						</div>
						<!--xxxxxxxxxxxxxxx FIM TABELA XXXXXXXX-->
			
					</div>	<!-- fim card-body -->
				</div><!-- /.container-fluid-->
			</div><!-- /.content-->
		</div><!-- /.content-wrapper -->
		
		<cfinclude template="pc_Footer.cfm">
	</div>
	<!-- ./wrapper -->
	
	<cfinclude template="pc_Sidebar.cfm">


	<script language="JavaScript">
 
		// inicializar o DataTable
		var currentDate = new Date();
		var day = currentDate.getDate();
		var month = currentDate.getMonth() + 1; // Mês começa em 0, por isso somamos 1
		var year = currentDate.getFullYear();
		var d = day + "-" + month + "-" + year; // Formato da data: dia-mês-ano

		// Obtém o perfil do usuário do servidor (usando ColdFusion)
		<cfoutput>
			var perfilUsuario = #application.rsUsuarioParametros.pc_usu_perfil#;
		</cfoutput>

		// Inicializa o DataTable com configurações e dados via AJAX
		const tabUsuariosCad = $('#tabUsuariosCad').DataTable({
			ajax: {
				url: "cfc/pc_cfcPaginasApoio.cfc?method=getUsuariosJSON", // URL para obter dados JSON
				dataType: "json",
				dataSrc: "", // Usamos uma string vazia para evitar problemas com objetos aninhados
			},
			select: true, // Permitir seleção de linhas
			ordering: false, // Desativar ordenação
			responsive: true, // Tornar a tabela responsiva
			lengthChange: true, // Permitir ao usuário alterar o número de itens exibidos por página
			autoWidth: false, // Desativar ajuste automático da largura das colunas
			deferRender: true, // Aumentar desempenho para tabelas com muitos registros
			pageLength:10,
			//dom: '<"dtsp-verticalContainer"<"dtsp-verticalPanes"P><"dtsp-dataTable"Brfitp>>',
			dom: 
								"<'row'<'col-sm-4 dtsp-verticalContainer'<'dtsp-verticalPanes'P><'dtsp-dataTable'Bf>><'col-sm-8 text-left'p>>" +
								"<'col-sm-12 text-left'i>" +
								"<'row'<'col-sm-12'tr>>" ,
			buttons: [
				{
					extend: 'excel', // Botão de exportação para Excel
					text: '<i class="fas fa-file-excel fa-2x grow-icon" style="margin-right:30px"></i>',
					title: 'SNCI_Orientacoes_Pendentes_Acao_Controle_interno_' + d, // Título do arquivo Excel
					className: 'btExcel',
				},
				{// Botão abertura do ctrol-sidebar com os filtros
					text: '<i class="fas fa-filter fa-2x grow-icon" style="margin-right:30px" data-widget="control-sidebar"></i>',
					className: 'btFiltro',
				},
				
			],
			language: {
				searchPanes: {
					clearMessage: 'Retirar filtro',
					loadMessage: 'Carregando Painéis de Pesquisa...',
					showMessage: 'Mostrar painéis',
					collapseMessage: 'Recolher painéis',
					title: 'Filtros Ativos - %d',
					emptyMessage: '<em>Sem dados</em>',
					emptyPanes: 'Sem painéis de filtragem relevantes para exibição',
					
				}
			},
			columns: [
				{
					// Coluna dos cards
					data: null, // Não há dados associados à coluna
				},
				{ data: 'PC_USU_MATRICULA', title: 'Matrícula', className: 'matricula-column' },
				{ data: 'PC_USU_NOME', title: 'Nome', className: 'nome-column' },
				{ data: 'PC_PERFIL_TIPO_DESCRICAO', title: 'Perfil', className: 'perfil-column' },
				{ data: 'PC_ORG_SIGLA', title: 'Lotação', className: 'lotacao-column' },
				{ data: 'PC_USU_LOGIN', title: 'Login' },
				{
					data: 'PC_USU_STATUS',
					title: 'Status',
					render: function (data) {
						return data === 'A' ? 'Ativo' : 'Desativado';
					}
				}
			],
			createdRow: function (row, data, dataIndex) {
				// Renderizar os dados como cards
				//const cardCell = $(row).find('.user-card-cell');
				var buttonsHtml = '';	// HTML dos botões de ação
				if (perfilUsuario === 3) {	// Se o usuário for do perfil 3 (Desenvolvedor)
					buttonsHtml = `
						 <div class="card-icons">
						 	<i class="fas fa-user-edit grow-icon edit-button" onclick="usuarioEditar('${data.PC_USU_MATRICULA}', '${data.PC_USU_NOME}', '${data.PC_USU_STATUS}', '${String(data.PC_USU_MCU)}', ${data.PC_USU_TIPO_ID}, this);" data-toggle="tooltip" title="Editar" style="cursor: pointer;z-index:100;font-size:15px;color:${data.PC_USU_STATUS === 'A' ? '#0083ca' : 'user-desativado'}"></i>
						
							<i class="fas fa-trash-alt grow-icon delete-button" onclick="excluirUsuario('${data.PC_USU_MATRICULA}');" data-toggle="tooltip" title="Excluir" style="cursor: pointer;z-index:100;font-size:15px;color: ${data.PC_USU_STATUS === 'A' ? '#dc3545' : 'user-desativado'}"></i>
						</div>`;
				} else {
					buttonsHtml = `
						 <div class="card-icons">
							<i class="fas fa-user-edit grow-icon edit-button" onclick="usuarioEditar('${data.PC_USU_MATRICULA}', '${data.PC_USU_NOME}', '${data.PC_USU_STATUS}', '${String(data.PC_USU_MCU)}', ${data.PC_USU_TIPO_ID}, this);" data-toggle="tooltip" title="Editar" style="cursor: pointer;z-index:100;font-size:15px;color:${data.PC_USU_STATUS === 'A' ? '#0083ca' : 'user-desativado'}"></i>
						</div>`;
				}
				const userCardHtml = `
					<div class="row">
						<div class="col-md-3 col-sm-6 col-12">
							<div class="user-card ${data.PC_USU_STATUS === 'A' ? '' : 'user-card-desativado'}">
								<div class="user-icon"><i class="fas fa-user"></i></div>
								<div class="user-name ${data.PC_USU_STATUS === 'A' ? '' : 'user-desativado'}"><i class="fas fa-user" style="margin-left: 3px;margin-right: 3px;"></i> ${data.PC_USU_NOME}</div>
								<div class="user-info ${data.PC_USU_STATUS === 'A' ? '' : 'user-desativado'}">
									<p><i class="fas fa-id-badge" style="margin-left: 3px;margin-right: 4px;"></i> ${data.PC_USU_MATRICULA} (<strong>${data.PC_USU_STATUS === 'A' ? 'Ativo' : 'Desativado'}</strong>)</p>
									<p><i class="fas fa-users"></i> ${data.PC_PERFIL_TIPO_DESCRICAO}</p>
									<p><i class="fas fa-house" style="margin-right: 2px;"></i> ${data.PC_ORG_SIGLA}</p>
									<span class="user-controles">
										${buttonsHtml}
									</span>
								</div>
							</div>
						</div>
					</div>
				`;
				
				// Inserir o HTML do card na linha
  					$(row).empty().append(userCardHtml);
			},
			// Ajuste a largura da tabela para acomodar quatro cards por linha
			columnDefs: [
				{
					targets: 0, // Coluna dos cards
					width: '25%', // Largura da coluna
				},
			],
			
			searchPanes: {
				cascadePanes: true, // Exibir apenas opções que combinam com os filtros anteriores
				columns:[3, 4, 6],// Colunas que terão filtro
				threshold: 1,// Número mínimo de registros para exibir Painéis de Pesquisa
				layout: 'columns-1', //layout do filtro com uma coluna
				initCollapsed: true, // Colapsar Painéis de Pesquisa
			},
			initComplete: function () {// Função executada ao finalizar a inicialização do DataTable
				initializeSearchPanesAndSidebar(this,'nome ou matrícula')//inicializa o searchPanes dentro do controlSidebar
			}
			
		});
		// Fim da função de inicialização do DataTable



		// Função para atualizar a tabela
		function atualizarTabela() {
			$('#modalOverlay').modal('show');
			setTimeout(function () {
				tabUsuariosCad.ajax.reload(); // Recarregar a tabela usando AJAX
				$('#modalOverlay').delay(1000).hide(0, function() {
					toastr.success('Operação realizada com sucesso!');
					$('#modalOverlay').modal('hide');
				});	
			}, 1000);
			
		}
		// Fim da função para atualizar a tabela

	
        $(function () {
			$('[data-mask]').inputmask()//mascara de campos
		})
				
		//Initialize Select2 Elements
		$('select').select2({
			theme: 'bootstrap4',
			placeholder: 'Selecione...'
		});
		//fim Initialize Select2 Elements
		
		$("#usuarioMatricula").on('focusout', function (event)  {
			var matricula=$("#usuarioMatricula").val().replace(/([^\d])+/gim, '');

			$.ajax({
						type: "POST",
						url:"cfc/pc_cfcPaginasApoio.cfc",
						data:{
							method: "verificaMatricula",
							pc_usu_matricula: matricula
						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#matriculaCadastradaDiv').html(result)
						if($('#matriculaCadastrada').val() == 'yes'){
							toastr.error('Esta matrícula já está cadastrada!');
							$('#usuarioMatricula').focus();
							$('#matriculaCadastradaDiv').html('')
						}					
					})//fim done
					.fail(function(xhr, ajaxOptions, thrownError) {
						
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)

					})//fim fail

		})

		$("#btSalvar").on('click', function (event)  {
			event.preventDefault()
			event.stopPropagation()

			var matricula=$("#usuarioMatricula").val().replace(/([^\d])+/gim, '');

			if (!$('#usuarioNome').val() || matricula.length != 8 || !$('#usuarioLotacao').val() || !$('#usuarioPerfil').val() ){
				//mostra mensagem de erro, se algum campo necessário nesta fase não estiver preenchido	
				toastr.error('Todos os campos devem ser preenchidos!');
				return false;
			}

			var mensagem = ""
	        if($('#usuarioEditar').val() ==''){
				mensagem = "Deseja cadastrar este usuário?"
			}else{
				mensagem = "Deseja editar este usuário?"
			}

			swalWithBootstrapButtons.fire({//sweetalert2
			html: logoSNCIsweetalert2(mensagem),
			showCancelButton: true,
			confirmButtonText: 'Sim!',
			cancelButtonText: 'Cancelar!'
			}).then((result) => {
				if (result.isConfirmed) {
			
					$('#modalOverlay').modal('show');
					setTimeout(function() {
						$.ajax({
							type: "POST",
							url:"cfc/pc_cfcPaginasApoio.cfc",
							data:{
								method: "cadUsuario",
								usuarioEditar: $('#usuarioEditar').val(),
								pc_usu_matricula: matricula,
								pc_usu_Nome: $('#usuarioNome').val().toUpperCase(),
								pc_usu_status: $('#usuarioStatus').val(),
								pc_usu_lotacao: $('#usuarioLotacao').val(),
								pc_usu_perfil: $('#usuarioPerfil').val()
							},
							async: false
						})//fim ajax
						.done(function(result) {
							$("#usuarioStatusDiv").attr("hidden",true)
							$('#usuarioMatricula').removeAttr('disabled')
							$('#usuarioEditar').val(null)
							$('#usuarioMatricula').val(null)
							$('#usuarioNome').val(null)
							$('#usuarioStatus').val(null).trigger('change')
							$('#usuarioLotacao').val(null).trigger('change')
							$('#usuarioPerfil').val(null).trigger('change')
							$('#cabecalhoAccordion').text("Clique aqui para cadastrar um novo Usuário");
							$('#cadastroUsuarios').CardWidget('collapse')
							atualizarTabela(); // Recarregar a tabela usando AJAX
						})//fim done
						.fail(function(xhr, ajaxOptions, thrownError) {
							$('#modalOverlay').delay(1000).hide(0, function() {
								$('#modalOverlay').modal('hide');
							});	
							$('#modal-danger').modal('show')
							$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
							$('#modal-danger').find('.modal-body').text(thrownError)

						})//fim fail
					}, 500);
				}else {
					// Lidar com o cancelamento: fechar o modal de carregamento, exibir mensagem, etc.
					$('#modalOverlay').modal('hide');
					Swal.fire('Operação Cancelada', '', 'info');
				}
			})

		})
		
		$("#btCancelar").on('click', function (event)  {
				event.preventDefault()
				event.stopPropagation()
				$('#usuarioEditar').val(null),
				$('#usuarioMatricula').removeAttr('disabled')
				$('#usuarioMatricula').val(null),
				$('#usuarioNome').val(null),
				$('#usuarioStatus').val(null).trigger('change')
				$('#usuarioLotacao').val(null).trigger('change')
				$('#usuarioPerfil').val(null).trigger('change')
				
				$("#usuarioStatusDiv").attr("hidden",true)
				$('#cadastroUsuarios').CardWidget('collapse')
				$('#cabecalhoAccordion').text("Clique aqui para cadastrar um novo Usuário");
		})

		function usuarioEditar(usuarioMatricula,usuarioNome,usuarioStatus,usuarioLotacao,usuarioPerfil,linha)  {
			event.preventDefault()
			event.stopPropagation()
			var usuarioLotacao =  usuarioLotacao.toString().padStart(8, '0');

			$(linha).closest("tr").children("td:nth-child(2)").click();//seleciona a linha onde o botão foi clicado
			$('#cabecalhoAccordion').text("Editar o usuário:" + ' ' + usuarioNome + ' (' + usuarioMatricula + ')');
			$('#usuarioEditar').val('yes')
 			$('#usuarioMatricula').val(usuarioMatricula)
			$('#usuarioMatricula').attr('disabled', 'disabled')
			$('#usuarioNome').val(usuarioNome)
			$('#usuarioLotacao').val(usuarioLotacao).trigger('change')
			$('#usuarioPerfil').val(usuarioPerfil).trigger('change')
			$('#usuarioStatus').val(usuarioStatus).trigger('change')
			
			$("#usuarioStatusDiv").attr("hidden",false)
			$('#cadastroUsuarios').CardWidget('expand')
			$('html, body').animate({ scrollTop: ($('.wrapper').offset().top)-50} , 500);
		}

		function excluirUsuario(usuarioMatricula){
			var mensagem = "Deseja excluir o usuário matrícula: " + usuarioMatricula;
			swalWithBootstrapButtons.fire({//sweetalert2
			html: logoSNCIsweetalert2(mensagem),
			showCancelButton: true,
			confirmButtonText: 'Sim!',
			cancelButtonText: 'Cancelar!'
			}).then((result) => {
				if (result.isConfirmed) {		
					$('#modalOverlay').modal('show');
					setTimeout(function() {
						$.ajax({
							type: "post",
							url: "cfc/pc_cfcPaginasApoio.cfc",
							data:{
								method:"delUsuario",
								pc_usu_matricula: usuarioMatricula
							},
							async: false,
							success: function(result) {	
								//limpa painéis de pesquisa
								$('#tabUsuariosCad').DataTable().searchPanes.clearSelections();
								//atualiza a tabela
								atualizarTabela();
							},
							error: function(xhr, ajaxOptions, thrownError) {
								$('#modalOverlay').delay(1000).hide(0, function() {
									$('#modalOverlay').modal('hide');
								});	
								$('#modal-danger').modal('show')
								$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
								$('#modal-danger').find('.modal-body').text(thrownError)				
							}
						})
					}, 500);

				}else {
					// Lidar com o cancelamento: fechar o modal de carregamento, exibir mensagem, etc.
					$('#modalOverlay').modal('hide');
					Swal.fire('Operação Cancelada', '', 'info');
				}
			})
		}

	


		
		
		
			
		
	</script>

</body>
</html>
