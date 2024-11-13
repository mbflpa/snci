<cfprocessingdirective pageEncoding ="utf-8">
<cfsetting requesttimeout="500">

<!--- 	<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
		<cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
	</cfif> --->
	<cfquery name="qAcesso" datasource="#dsn_inspecao#">
		select Usu_DR,Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido,Usu_Coordena from usuarios 
	select Usu_DR,Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido,Usu_Coordena from usuarios 
		select Usu_DR,Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido,Usu_Coordena from usuarios 
		where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
	</cfquery>

	<cfif  isDefined("form.formAtivarDesativar")>
		<cfparam name="form.acao" default="#form.acao#">
	<cfelse>
		<cfparam name="form.acao" default="">
	</cfif>


	<cfif isDefined("form.formAtivarDesativar") >
		<cfparam name="form.selAtivar" default="#form.selAtivar#">
		<cfparam name="form.selAnoGrupoItem" default="#form.selAnoGrupoItem#">
		<cfparam name="form.selTipoUnidadeGrupoItem" default="#form.selTipoUnidadeGrupoItem#">
		<cfparam name="form.selModalidadeGrupoItem" default="#form.selModalidadeGrupoItem#"> 
    <cfparam name="form.selModalidadeGrupoItem" default="#form.selModalidadeGrupoItem#">   
		<cfparam name="form.selModalidadeGrupoItem" default="#form.selModalidadeGrupoItem#"> 
		<cfparam name="form.selGrupo" default="#form.selGrupo#">  
		<cfparam name="form.selItem" default="#form.selItem#">
	<cfelse>
		<cfparam name="form.selAtivar" default="">
		<cfparam name="form.selAnoGrupoItem" default="">
		<cfparam name="form.selTipoUnidadeGrupoItem" default="">
		<cfparam name="form.selModalidadeGrupoItem" default=""> 
	<cfparam name="form.selModalidadeGrupoItem" default="">  
		<cfparam name="form.selModalidadeGrupoItem" default=""> 
		<cfparam name="form.selGrupo" default="">  
		<cfparam name="form.selItem" default=""> 
	</cfif>

	<cfset anoAtual = year(Now())> 
	<cfquery name="qAnosCadAtivarDesativar" datasource="#dsn_inspecao#">
		SELECT DISTINCT TUI_Ano FROM TipoUnidade_ItemVerificacao 
		 <cfif '#form.selAtivar#' eq 0>WHERE TUI_Ativo = 1 <cfelseif '#form.selAtivar#' eq 1>WHERE TUI_Ativo = 0 <cfelse>WHERE TUI_Ativo = null</cfif>
		ORDER BY TUI_Ano desc
	</cfquery>
	
	<cfquery name="qTipoUnidadesAtivarDesativar" datasource="#dsn_inspecao#">
		SELECT DISTINCT TUI_TipoUnid, TUN_Descricao FROM TipoUnidade_ItemVerificacao
		INNER JOIN Tipo_Unidades ON TUI_TipoUnid = TUN_Codigo
 		WHERE TUI_Ano = '#form.selAnoGrupoItem#'
		<cfif '#form.selAtivar#' eq 0>
			AND TUI_Ativo = 1 
		<cfelseif '#form.selAtivar#' eq 1>
			AND TUI_Ativo = 0 
		<cfelse>
			AND TUI_Ativo = 2
		</cfif>
		ORDER BY TUN_Descricao
	</cfquery>


	<cfquery name="qModalidadeGrupoItem" datasource="#dsn_inspecao#">
			SELECT DISTINCT TUI_Modalidade FROM TipoUnidade_ItemVerificacao
			INNER JOIN Tipo_Unidades ON TUI_TipoUnid = TUN_Codigo
			WHERE TUI_Ano = '#form.selAnoGrupoItem#'
			<cfif '#form.selTipoUnidadeGrupoItem#' neq 'todos'>
				<cfif '#form.selAtivar#' eq 0>
					AND TUI_Ativo = 1  and TUI_TipoUnid ='#form.selTipoUnidadeGrupoItem#'
				<cfelseif '#form.selAtivar#' eq 1>
					AND TUI_Ativo = 0  and TUI_TipoUnid ='#form.selTipoUnidadeGrupoItem#'
				<cfelse>
					AND TUI_Ativo = 2
				</cfif>
			<cfelse>
				<cfif '#form.selAtivar#' eq 0>
					AND TUI_Ativo = 1  
				<cfelseif '#form.selAtivar#' eq 1>
					AND TUI_Ativo = 0 
				<cfelse>
					AND TUI_Ativo = 2
				</cfif>
			</cfif>
	</cfquery>

	<cfquery name="qGruposCadAtivarDesativar" datasource="#dsn_inspecao#">
		SELECT DISTINCT TUI_GrupoItem, Grp_Descricao FROM TipoUnidade_ItemVerificacao
		INNER JOIN Grupos_Verificacao ON Grp_Codigo = TUI_GrupoItem AND Grp_Ano = TUI_Ano
		WHERE TUI_Ano = '#form.selAnoGrupoItem#'
		<cfif '#form.selTipoUnidadeGrupoItem#' neq 'todos'>
			<cfif '#form.selAtivar#' eq 0>
					AND TUI_Ativo = 1  AND TUI_TipoUnid ='#form.selTipoUnidadeGrupoItem#'
			<cfelseif '#form.selAtivar#' eq 1>
					AND TUI_Ativo = 0  AND TUI_TipoUnid ='#form.selTipoUnidadeGrupoItem#'
			<cfelse>
					AND TUI_Ativo = 2
			</cfif>
		<cfelse>
			<cfif '#form.selAtivar#' eq 0>
					AND TUI_Ativo = 1   
			<cfelseif '#form.selAtivar#' eq 1>
					AND TUI_Ativo = 0 
			<cfelse>
					AND TUI_Ativo = 2
			</cfif>
		</cfif>
		<cfif '#form.selModalidadeGrupoItem#' neq 'todas'> and TUI_Modalidade = '#form.selModalidadeGrupoItem#'</cfif>
	</cfquery>

	<cfquery name="qItensCadAtivarDesativar" datasource="#dsn_inspecao#">
		SELECT DISTINCT TUI_ItemVerif, Itn_Descricao FROM TipoUnidade_ItemVerificacao
		INNER JOIN Itens_Verificacao ON Itn_NumItem = TUI_ItemVerif AND Itn_NumGrupo = TUI_GrupoItem AND Itn_Ano = TUI_Ano and TUI_Modalidade = Itn_Modalidade
		WHERE TUI_Ano = '#form.selAnoGrupoItem#'
		<cfif '#form.selTipoUnidadeGrupoItem#' neq 'todos'>
			<cfif '#form.selAtivar#' eq 0>
					AND TUI_Ativo = 1  AND TUI_TipoUnid ='#form.selTipoUnidadeGrupoItem#'
			<cfelseif '#form.selAtivar#' eq 1>
					AND TUI_Ativo = 0  AND TUI_TipoUnid ='#form.selTipoUnidadeGrupoItem#'
			<cfelse>
					AND TUI_Ativo = 2
			</cfif>
		<cfelse>
			<cfif '#form.selAtivar#' eq 0>
					AND TUI_Ativo = 1  
			<cfelseif '#form.selAtivar#' eq 1>
					AND TUI_Ativo = 0 
			<cfelse>
					AND TUI_Ativo = 2
			</cfif>
		</cfif>
		<cfif '#form.selModalidadeGrupoItem#' neq 'todas'> and TUI_Modalidade = '#form.selModalidadeGrupoItem#'</cfif>
		<cfif '#form.selGrupo#' neq 'todos'>AND TUI_GrupoItem = '#form.selGrupo#'</cfif>
	</cfquery>

   	<cfquery name="qGruposItensSelecionadosAtivarDesativar" datasource="#dsn_inspecao#">
		SELECT TipoUnidade_ItemVerificacao.*, TUN_Descricao FROM TipoUnidade_ItemVerificacao
		INNER JOIN Tipo_Unidades ON TUN_Codigo = TUI_TipoUnid
		WHERE TUI_Ano = '#form.selAnoGrupoItem#'
		<cfif '#form.selTipoUnidadeGrupoItem#' neq 'todos'> AND TUI_TipoUnid ='#form.selTipoUnidadeGrupoItem#'</cfif>
		<cfif '#form.selModalidadeGrupoItem#' neq 'todas'> AND TUI_Modalidade = '#form.selModalidadeGrupoItem#'</cfif>
		<cfif '#form.selGrupo#' neq 'todos'>AND TUI_GrupoItem = '#form.selGrupo#'</cfif>
		<cfif '#form.selItem#' neq 'todos'>AND TUI_ItemVerif = '#form.selItem#'</cfif>
		<cfif '#form.selAtivar#' eq 0> AND TUI_Ativo = 1 <cfelseif '#form.selAtivar#' eq 1> AND TUI_Ativo = 0 <cfelse> AND TUI_Ativo = 2</cfif>
	</cfquery>
	
<!--- retirado a ppedido do Adriano --->
<!--- 	<cfif isDefined("form.acao") and "#form.selModalidadeGrupoItem#" neq '' AND '#form.selAtivar#' eq 1> 
			<!---Se a solicitação for para ativar, verifica se existem itens já ativos para o tipo de unidade e modalidade escolhida.--->
				<cfquery name="qVerificaExisteAtivo" datasource="#dsn_inspecao#">
					SELECT TipoUnidade_ItemVerificacao.*, TUN_Descricao, TUI_Modalidade FROM TipoUnidade_ItemVerificacao
					INNER JOIN Tipo_Unidades ON TUN_Codigo = TUI_TipoUnid
					<cfif '#form.selModalidadeGrupoItem#' eq 'todas'>
						WHERE  TUI_Ativo = '#form.selAtivar#' 
					<cfelse>
						WHERE  TUI_Ativo = '#form.selAtivar#' AND TUI_Modalidade = '#form.selModalidadeGrupoItem#'
					</cfif>
					<cfif '#form.selTipoUnidadeGrupoItem#' neq 'todos'> AND TUI_TipoUnid ='#form.selTipoUnidadeGrupoItem#'</cfif>
				</cfquery>
				<cfif '#qVerificaExisteAtivo.recordcount#' neq 0 >
					<script>
						<cfoutput>
							var quantItens = '#qVerificaExisteAtivo.recordcount#';
							<cfif '#form.selTipoUnidadeGrupoItem#' neq 'todos'>
								var tipo = '#trim(qVerificaExisteAtivo.TUN_Descricao)#';
							<cfelse>
								var tipo = 'TODOS';
							</cfif>

							<cfif '#form.selModalidadeGrupoItem#' neq 'todas'>
								var mod = <cfif '#qVerificaExisteAtivo.TUI_Modalidade#' eq 0>"PRESENCIAL"<cfelse>"A DISTÂNCIA"</cfif>;
							<cfelse>
								var mod = 'TODAS';
							</cfif>

							var ano = '#qVerificaExisteAtivo.TUI_Ano#';
							mens = 'Existem ' + quantItens + ' itens ativos para o tipo de unidade "' + tipo  + '", Modalidade "' + mod + '" e ano "' + ano + '".\n\nDesative estes itens e tente novamente. \n\nEsta ação foi cancelada!';
							
						</cfoutput>
						alert(mens);
						window.open('cadastroGruposItens.cfm','_self');
					</script>
				</cfif>
			<!---FIM Verifica se existem itens já ativos para o tipo de unidade e modalidade escolhida.--->
	</cfif>--->

  	<cfif isDefined("form.acao") and "#form.acao#" eq 'ativarDesativar'>
			<cfoutput query="qGruposItensSelecionadosAtivarDesativar">
				<cfquery  datasource="#dsn_inspecao#">
					UPDATE Grupos_Verificacao            SET Grp_Situacao = <cfif '#form.selAtivar#' eq 1>'A'<cfelse>'D'</cfif>, Grp_DtUltAtu=CONVERT(char, getdate(), 120), Grp_UserName ='#qAcesso.Usu_Matricula#'  WHERE Grp_Codigo = #TUI_GrupoItem# and Grp_Ano =#TUI_Ano#
				</cfquery>
				<cfquery  datasource="#dsn_inspecao#">	
					UPDATE Itens_Verificacao             SET Itn_Situacao = <cfif '#form.selAtivar#' eq 1>'A'<cfelse>'D'</cfif>, Itn_DtUltAtu=CONVERT(char, getdate(), 120), Itn_UserName ='#qAcesso.Usu_Matricula#' 
					WHERE Itn_NumGrupo = #TUI_GrupoItem# and Itn_NumItem = #TUI_ItemVerif# and Itn_Ano =#TUI_Ano# and Itn_Modalidade = #TUI_Modalidade# and Itn_TipoUnidade =#TUI_TipoUnid# 
				</cfquery>
				<cfquery  datasource="#dsn_inspecao#">
					UPDATE TipoUnidade_ItemVerificacao   SET TUI_Ativo = #form.selAtivar#, TUI_DtUltAtu=CONVERT(char, getdate(), 120), TUI_UserName ='#qAcesso.Usu_Matricula#' WHERE TUI_Modalidade = #TUI_Modalidade# and TUI_TipoUnid =#TUI_TipoUnid# and TUI_GrupoItem =#TUI_GrupoItem# and TUI_ItemVerif =#TUI_ItemVerif# and TUI_Ano =#TUI_Ano#
				</cfquery>
			</cfoutput>

			<script>
				var ativarDesativar = '';
				<cfoutput>
					<cfif '#form.selAtivar#' eq '1'>ativarDesativar = 'Ativados';<cfelse>ativarDesativar = 'Desativados';</cfif>
				</cfoutput>
				alert('Os itens selecionados foram ' + ativarDesativar + ' com sucesso!');	
			
				var frm = document.getElementById('formAtivarDesativar');
				frm.selAtivar.value = '';
				frm.selTipoUnidadeGrupoItem.value = '';
				frm.selModalidadeGrupoItem.value = '';
				frm.selAnoGrupoItem.value = '';
				frm.selGrupo.value = 'todos';
				frm.selItem.value = 'todos';
				frm.acao.value='';							
		</script>	
	</cfif>

	<cfquery name="qGruposItensSelecionadosAtivadosDesativados" datasource="#dsn_inspecao#">
		SELECT TipoUnidade_ItemVerificacao.*, TUN_Descricao FROM TipoUnidade_ItemVerificacao
		INNER JOIN Tipo_Unidades ON TUN_Codigo = TUI_TipoUnid
		WHERE  TUI_Ativo = '#form.selAtivar#'   AND TUI_Ano = '#form.selAnoGrupoItem#'
		<cfif '#form.selTipoUnidadeGrupoItem#' neq 'todos'> AND TUI_TipoUnid ='#form.selTipoUnidadeGrupoItem#'</cfif>
		<cfif '#form.selModalidadeGrupoItem#' neq 'todas'> AND TUI_Modalidade = '#form.selModalidadeGrupoItem#'</cfif>
	</cfquery>


<html xmlns="http://www.w3.org/1999/xhtml">

<head>
	<title>SNCI - CADASTRO DE GRUPOS E ITENS</title>
<!--- 	<cfinclude template="cabecalho.cfm"> --->
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <link rel="stylesheet" type="text/css" href="view.css" media="all">
</head>



<style type="text/css">

	.tituloDiv{
		padding:5px;
		position:relative;
		top: -22px;
		background: #003366;
		border:3px solid #fff;
	}

</style>

<script language="JavaScript" type="text/JavaScript">
        //limpa selects
		function removeOptions(selectElement) {
			var i, L = selectElement.options.length - 1;
			for(i = L; i >= 0; i--) {
				selectElement.remove(i);
			}
		}



        function valida_formAtivarDesativar(){
			var frm2 = document.getElementById('formAtivarDesativar');
            
			if (frm2.selAtivar.value == '') {
				alert('Informe se deseja Ativar ou Desativar Grupos e Itens!');
				frm2.selAtivar.focus();
				return false;
			}

            if (frm2.selTipoUnidadeGrupoItem.value == '') {
				alert('Informe o Tipo de Unidade que deseja Ativar ou Desativar Grupos e Itens!');
				frm2.selTipoUnidadeGrupoItem.focus();
				return false;
			}

			if (frm2.selModalidadeGrupoItem.value == '') {
				alert('Informe a Modalidade que deseja Ativar ou Desativar Grupos e Itens!');
				frm2.selModalidadeGrupoItem.focus();
				return false;
			}
			
			if (frm2.selAnoGrupoItem.value == '') {
				alert('Informe o Ano que deseja Ativar ou Desativar Grupos e Itens!');
				frm2.selAnoGrupoItem.focus();
				return false;
			}

			now = new Date;
			anoAtual = now.getFullYear();
			if(frm2.selAnoGrupoItem.value > anoAtual && frm2.selAtivar.value==1){
            msg="O ano selecionado não é o ano corrente.\n\nDeseja continuar?"
			  if(window.confirm(msg)){
                
			  }else{
				 return false; 
			  }
					
			}

			if(frm2.selAtivar.value == 1){
				msgFinal = 'Deseja Ativar os Grupos e Itens Selecionados?';
			}else{
                msgFinal = 'Deseja Desativar os Grupos e Itens Selecionados?';
			}
			
			if(window.confirm(msgFinal)){
				
				frm2.acao.value = 'ativarDesativar';
				aguarde();
				setTimeout('document.getElementById("formAtivarDesativar").submit();',2000);
				return true;
			}else{
				return false;
			}		

		}

		//fim das funções que validam os formulários
</script>

<body id="main_body" style="background:#fff;" onLoad="" >
    <div align="left" >
				

					<form id="formAtivarDesativar" nome="formAtivarDesativar" enctype="multipart/form-data" method="post" >
						
						 <input type="hidden" value="" id="acao" name="acao">
						 <div align="left" style="float: left;padding:20px;border:1px solid: #036">
							<div align="left">
								<span class="tituloDivConsulta" >Ativar Itens / PLANO DE TESTE</span>
							</div>							

							<div style="color:#036;margin-bottom:10px;">
								<label  for="selAtivar" style="color:#036;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px"><strong>ATIVAR/DESATIVAR:</strong></label>
								<select name="selAtivar" id="selAtivar" class="form" onChange="aguarde(); setTimeout('javascript:formAtivarDesativar.submit();',2000)">			
									<option selected="selected" value=""></option>
									<option <cfif '#form.selAtivar#' eq '1'>selected</cfif> value="1">ATIVAR</option>
									<option <cfif '#form.selAtivar#' eq '0'>selected</cfif>  value="0">DESATIVAR</option>
								</select>
							</div>

							<div style="margin-bottom:10px;">
								<label  for="selAnoGrupoItem" style="color:#036;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px"><strong>ANO:</strong></label>	
								<select name="selAnoGrupoItem" id="selAnoGrupoItem" class="form" onChange="aguarde(); setTimeout('javascript:formAtivarDesativar.submit();',2000)" style="margin-left:105px;display:inline-block;">
									
										<option selected="selected" value=""></option>
										<cfoutput query="qAnosCadAtivarDesativar">
											<option <cfif '#form.selAnoGrupoItem#' eq "#TUI_Ano#">selected</cfif> value="#TUI_Ano#">#TUI_Ano#</option>
										</cfoutput>
								
								</select>
							</div>

						
							<div style="margin-bottom:10px;">
								<label  for="selTipoUnidadeGrupoItem" style="color:#036;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px"><strong>TIPO UNIDADE:</strong></label>
								<select name="selTipoUnidadeGrupoItem" id="selTipoUnidadeGrupoItem" class="form" onChange="aguarde(); setTimeout('javascript:formAtivarDesativar.submit();',2000)"  
								        style="margin-left:47px;display:inline-block;">			
									<option selected="selected" value=""></option>
									<cfif qTipoUnidadesAtivarDesativar.recordcount neq 0>
									    <cfif qTipoUnidadesAtivarDesativar.recordcount gt 1>
										    <option <cfif '#form.selTipoUnidadeGrupoItem#' eq 'todos'>selected</cfif> value="todos">TODOS</option>	
										</cfif>
										<cfoutput query="qTipoUnidadesAtivarDesativar">
											<option <cfif '#form.selTipoUnidadeGrupoItem#' eq "#TUI_TipoUnid#">selected</cfif> value="#TUI_TipoUnid#">#TUN_Descricao#</option>
										</cfoutput>
									</cfif>
								</select>
							</div>

							<div style="margin-bottom:10px;">
								<label  for="selModalidadeGrupoItem" style="color:#036;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px"></strong>MODALIDADE:</strong></label>
								<select name="selModalidadeGrupoItem" id="selModalidadeGrupoItem" class="form" onChange="aguarde(); setTimeout('javascript:formAtivarDesativar.submit();',2000)" style="margin-left:55px;display:inline-block;">			
									<option selected="selected" value=""></option>
									<cfif qModalidadeGrupoItem.recordcount neq 0>
										
										<cfif qModalidadeGrupoItem.recordcount gt 1>
											<option <cfif '#form.selModalidadeGrupoItem#' eq  'todas'>selected</cfif> value="todas">TODAS</option>
										</cfif>

										<cfoutput query="qModalidadeGrupoItem">
											<option <cfif '#form.selModalidadeGrupoItem#' eq  '#TUI_Modalidade#' and '#form.selModalidadeGrupoItem#' neq  'todas'>selected</cfif> value="#TUI_Modalidade#"><cfif "#TUI_Modalidade#" eq 0>PRESENCIAL<CFELSE>A DISTÂNCIA</cfif></option>
										</cfoutput>
									</cfif>
								</select>
							</div>

							<div style="margin-bottom:10px;">
								<label  for="selGrupo" style="color:#036;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
								<strong>GRUPO:</strong></label>
								<select name="selGrupo" id="selGrupo" class="form" onChange="aguarde(); setTimeout('javascript:formAtivarDesativar.submit();',2000)" style="margin-left:88px;width:280px">			
									<option selected="selected" value="todos">TODOS</option>
									
									<cfif qGruposCadAtivarDesativar.recordcount neq 0>
										<cfoutput query="qGruposCadAtivarDesativar">
											<option <cfif '#form.selGrupo#' eq  '#TUI_GrupoItem#' and '#form.selGrupo#' neq  'todos'>selected</cfif> value="#TUI_GrupoItem#">#TUI_GrupoItem# - #Grp_Descricao#</option>
										</cfoutput>
									</cfif>
								</select>
							</div>

							<div style="margin-bottom:20px;">
								<label  for="selItem" style="color:#036;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
								<strong>ITEM:</strong></label>
								<select name="selItem" id="selItem" class="form" onChange="aguarde(); setTimeout('javascript:formAtivarDesativar.submit();',2000)" style="margin-left:101px;width:280px">			
									<option selected="selected" value="todos">TODOS</option>
									<cfif qItensCadAtivarDesativar.recordcount neq 0>
										<cfoutput query="qItensCadAtivarDesativar">
											<option <cfif '#form.selItem#' eq  '#TUI_ItemVerif#' and '#form.selItem#' neq  'todos'>selected</cfif> value="#TUI_ItemVerif#">#TUI_ItemVerif# - #Itn_Descricao#</option>
										</cfoutput>
									</cfif>
								</select>
							</div>


							<cfif '#qAnosCadAtivarDesativar.recordcount#' eq 0 and '#form.selModalidadeGrupoItem#' neq ''>
							   <div align="center" style="color:#fff;font-size:12px;margin-bottom:20px;">Não existem CHECKLIST disponíveis para os parâmetros selecionados.</div>
							   <cfif '#form.selAtivar#' eq 1>
							     <div align="center" style="color:#fff;font-size:12px;margin-bottom:20px;">Obs.: Não é possível "ATIVAR" CHECKLIST de anos anteriores ao ano corrente.</div>
							   </cfif>
							</cfif>

							<div align="center">     									
								<a type="button" onClick="return valida_formAtivarDesativar();" href="#" class="btn btn-primary">
									<cfif #form.selAtivar# eq 0>Desativar<cfelseif #form.selAtivar# eq 1>Ativar<cfelse>Ativar/Desativar</cfif></a>     
							 	<a type="button" onClick="javascript:if(confirm('Deseja cancelar esta Ativação/Desativação?\n\nObs: Esta ação não cancela as Ativações/Desativações já confirmadas.\n\nCaso afirmativo, clique em OK.')){window.open('cadastroGruposItens.cfm','_self')}" href="#" class="btn btn-danger">
                                    Cancelar</a>
							</div>  
						</div>
						<!---Início da tabela com a apresentação dos itns selecionados para Ativação / Desativação--->
					    <cfif isDefined("form.acao") and "#form.acao#" eq 'ativarDesativar'>
							<cfif qGruposItensSelecionadosAtivadosDesativados.recordCount neq 0>
									<div id="form_container" style="width:360px;height:281px;overflow-y:auto;position:relative;left:14px">
										<table align="left" id="tabInspecao" >
											<tr>
												<td colspan="7" align="center" class="titulos" style="border:none">												
											    	<h1 style="font-size:10px;background:#003366"><cfif '#form.selAtivar#' eq 0 >FORAM DESATIVADOS<cfelse>FORAM ATIVADOS</cfif>: <cfoutput>#qGruposItensSelecionadosAtivadosDesativados.recordcount#</cfoutput> itens<BR>Tabelas atualizadas: Grupos_Verificacao, Itens_Verificacao e TipoUnidade_ItemVerificacao</h1>
												</td>
											</tr>

											<tr bgcolor="<cfif "#form.acao#" eq 'ativarDesativar'>#003366<cfelse>red</cfif>" class="exibir" align="center" style="color:#fff">
												<td width="10%">
													<div align="center">Modalidade</div>
												</td>
												<td width="10%">
													<div align="center">Tipo Unidade</div>
												</td>
												<td width="10%">
													<div align="center">Grupo</div>
												</td>
												<td width="10%">
													<div align="center">Item</div>
												</td>
												<td width="10%">
													<div align="center">Ano</div>
												</td>
												<td width="10%">
													<div align="center">Situação</div>
												</td>
											</tr>

											<cfset scor='white'>
												<cfoutput query="qGruposItensSelecionadosAtivadosDesativados">
													<form id="formNaoFinalizadas" action="" method="POST">
														<tr valign="middle" bgcolor="#scor#" class="exibir">
															<td width="10%">
																<div align="center"><cfif #TUI_Modalidade# eq 0>Presencial<cfelse>A Dist.</cfif></div>
															</td>
															<td width="10%">
																<div align="center">#TUN_Descricao#</div>
															</td>
															<td width="10%">
																<div align="center">#TUI_GrupoItem#</div>
															</td>
															<td width="10%">
																<div align="center">#TUI_ItemVerif#</div>
															</td>
															<td width="10%">
															    <div align="center">#TUI_Ano#</div>	 								
															</td>
															<td width="10%">
															    <div align="center"><cfif '#TUI_Ativo#' eq 0><span style="color:red">DESATIVADO</span><cfelse><strong>ATIVADO</strong></cfif></div>								
															</td>
														</tr>
													</form>

													<cfif scor eq 'white'>
														<cfset scor='f7f7f7'>
													<cfelse>
														<cfset scor='white'>
													</cfif>
												</cfoutput>
												
										</table>
										
									</div>
																		
							</cfif>
								    <script>	
										var frm = document.getElementById('formAtivarDesativar');
										frm.selAtivar.value = '';
										frm.selTipoUnidadeGrupoItem.value = '';
										frm.selModalidadeGrupoItem.value = '';
										frm.selAnoGrupoItem.value = '';
										frm.selGrupo.value = 'todos';
										frm.selItem.value = 'todos';
										frm.acao.value='';
										removeOptions(document.getElementById('selTipoUnidadeGrupoItem'));
										removeOptions(document.getElementById('selModalidadeGrupoItem'));
										removeOptions(document.getElementById('selAnoGrupoItem'));
									</script>
									
							
						<cfelse>
						    <cfif qGruposItensSelecionadosAtivarDesativar.recordCount neq 0>
									<div id="form_container" style="width:360px;height:281px;overflow-y:auto;position:relative;left:14px">
										<table align="left" id="tabInspecao" >
											<tr>
												<td colspan="7" align="center" class="titulos" style="border:none">
													<h1 style="font-size:10px;background:red"><cfif '#form.selAtivar#' eq 0 >DESATIVAÇÃO<cfelse>ATIVAÇÃO</cfif>: GRUPO E ITENS SELECIONADOS (<cfoutput>#qGruposItensSelecionadosAtivarDesativar.recordcount#</cfoutput> itens)</h1>
												</td>
											</tr>

											<tr bgcolor="<cfif "#form.acao#" eq 'ativarDesativar'>#003366<cfelse>red</cfif>" class="exibir" align="center" style="color:#fff">
												<td width="10%">
													<div align="center">Modalidade</div>
												</td>
												<td width="10%">
													<div align="center">Tipo Unidade</div>
												</td>
												<td width="10%">
													<div align="center">Grupo</div>
												</td>
												<td width="10%">
													<div align="center">Item</div>
												</td>
												<td width="10%">
													<div align="center">Ano</div>
												</td>
												<td width="10%">
													<div align="center">Situação</div>
												</td>
											</tr>

											<cfset scor='white'>
												<cfoutput query="qGruposItensSelecionadosAtivarDesativar">
													<form id="formNaoFinalizadas" action="" method="POST">
														<tr valign="middle" bgcolor="#scor#" class="exibir">
															<td width="10%">
																<div align="center"><cfif #TUI_Modalidade# eq 0>Presencial<cfelse>A Dist.</cfif></div>
															</td>
															<td width="10%">
																<div align="center">#TUN_Descricao#</div>
															</td>
															<td width="10%">
																<div align="center">#TUI_GrupoItem#</div>
															</td>
															<td width="10%">
																<div align="center">#TUI_ItemVerif#</div>
															</td>
															<td width="10%">
															<div align="center">#TUI_Ano#</div>	 								
															</td>
															<td width="10%">
															<div align="center"><cfif '#TUI_Ativo#' eq 0><span style="color:red">DESATIVADO</span><cfelse><strong>ATIVADO</strong></cfif></div>								
															</td>
														</tr>
													</form>

													<cfif scor eq 'white'>
														<cfset scor='f7f7f7'>
													<cfelse>
														<cfset scor='white'>
													</cfif>
												</cfoutput>
												
																					
												
										</table>
										
									</div>
							</cfif>
						</cfif>
					<!---Fim da tabela com a apresentação dos itens selecionados--->

					</form>

					
	</div>			



</body>

</html>