 <cfprocessingdirective pageEncoding ="utf-8"/>
 <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	<cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
  </cfif>   


  <cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_DR, Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido,Usu_Coordena from usuarios 
	where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
  </cfquery>

 <cfif isDefined("form.formReplica") >
    <cfparam name="form.acao" default="#form.acao#">
 <cfelse>
    <cfparam name="form.acao" default="">
 </cfif>
<!---ROTINA REPLICAR--->
  <cfif isDefined("form.formReplica") >
    <cfparam name="form.selAnoDe" default="#form.selAnoDe#">
	<cfparam name="form.selAnoPara" default="#form.selAnoPara#">
    <cfparam name="form.selTipoUnidade" default="#form.selTipoUnidade#">
	<cfparam name="form.selModalidade" default="#form.selModalidade#">
  <cfelse>
    <cfparam name="form.selAnoDe" default="">
	<cfparam name="form.selAnoPara" default="">
	<cfparam name="form.selTipoUnidade" default="">
	<cfparam name="form.selModalidade" default="">
  </cfif>

  <cfquery name="qAnosCadastrados" datasource="#dsn_inspecao#">
    SELECT DISTINCT TUI_Ano FROM TipoUnidade_ItemVerificacao order by TUI_Ano desc
  </cfquery>

 
  <cfquery name="qTipoUnidades" datasource="#dsn_inspecao#">
    SELECT DISTINCT TUI_TipoUnid, TUN_Descricao FROM TipoUnidade_ItemVerificacao
	INNER JOIN Tipo_Unidades ON TUI_TipoUnid = TUN_Codigo
	WHERE TUI_Ano = '#form.selAnoDe#'
	ORDER BY TUN_Descricao
  </cfquery>

  <cfquery name="qModalidade" datasource="#dsn_inspecao#">
	SELECT DISTINCT TUI_Modalidade FROM TipoUnidade_ItemVerificacao
	INNER JOIN Tipo_Unidades ON TUI_TipoUnid = TUN_Codigo
	<cfif '#form.selTipoUnidade#' eq 'todos'>  
		WHERE TUI_Ano = '#form.selAnoDe#'
	<cfelse>
		WHERE TUI_Ano = '#form.selAnoDe#' and TUI_TipoUnid ='#form.selTipoUnidade#'
	</cfif> 

  </cfquery>

  

  <cfquery name="qGruposItensAnoPara" datasource="#dsn_inspecao#">
       SELECT * FROM TipoUnidade_ItemVerificacao
       <cfif '#form.selTipoUnidade#' eq 'todos'>  
		 WHERE TUI_Ano = '#form.selAnoPara#' <cfif '#form.selModalidade#' eq 'todas'> and TUI_Modalidade in (0,1)<cfelse>and TUI_Modalidade = '#form.selModalidade#'</cfif>
	   <cfelse>
		 WHERE TUI_Ano = '#form.selAnoPara#' and TUI_TipoUnid ='#form.selTipoUnidade#' <cfif '#form.selModalidade#' eq 'todas'> and TUI_Modalidade in (0,1)<cfelse>and TUI_Modalidade = '#form.selModalidade#'</cfif>
	   </cfif>
  </cfquery>
  
  <cfquery name="qGruposItensAnoParaVerificacoes" datasource="#dsn_inspecao#">
      SELECT INP_NumInspecao FROM Inspecao 
	  INNER JOIN Unidades on Und_Codigo = INP_Unidade
	  WHERE right(INP_NumInspecao,4) = '#form.selAnoPara#' 
	  <cfif '#form.selTipoUnidade#' neq 'todos' > and Und_TipoUnidade = '#form.selTipoUnidade#'</cfif>
	  <cfif '#form.selModalidade#' neq 'todas' > and INP_Modalidade = '#form.selModalidade#'</cfif>
  </cfquery>
  
  <cfquery name="qGruposItensSelecionados" datasource="#dsn_inspecao#">
       SELECT TipoUnidade_ItemVerificacao.*, TUN_Descricao FROM TipoUnidade_ItemVerificacao
	   INNER JOIN Tipo_Unidades ON TUN_Codigo = TUI_TipoUnid
      <cfif '#form.selTipoUnidade#' eq 'todos'>  
		WHERE TUI_Ano = '#form.selAnoDe#' <cfif '#form.selModalidade#' eq 'todas'> and TUI_Modalidade in (0,1)<cfelse>and TUI_Modalidade = '#form.selModalidade#'</cfif>
	  <cfelse>
		WHERE TUI_Ano = '#form.selAnoDe#' and TUI_TipoUnid ='#form.selTipoUnidade#' <cfif '#form.selModalidade#' eq 'todas'> and TUI_Modalidade in (0,1)<cfelse>and TUI_Modalidade = '#form.selModalidade#'</cfif>
	 </cfif> 
  </cfquery>
	
  <cfif isDefined("form.acao") and "#form.acao#" eq 'replicar'>
   <cftransaction>	
		<!--- Insere os grupos selecionados na tabela Grupos_Verificacao---> 
		<cfquery name="qGruposSelecionados" dbtype = "query">
			SELECT DISTINCT TUI_GrupoItem, TUI_Ano FROM qGruposItensSelecionados
		</cfquery>
		<cfoutput query="qGruposSelecionados">
			<cfquery name="qGrupoExiste" datasource="#dsn_inspecao#">
				SELECT * FROM Grupos_Verificacao WHERE Grp_Codigo = #TUI_GrupoItem# and Grp_Ano =#form.selAnoPara#
            </cfquery>
            <cfif '#qGrupoExiste.recordcount#' lte 0>
				<cfquery name="qGruposReplicar"datasource="#dsn_inspecao#">
					SELECT * FROM Grupos_Verificacao WHERE Grp_Codigo = #TUI_GrupoItem# and Grp_Ano =#form.selAnoDe#
				</cfquery>
				<cfquery datasource="#dsn_inspecao#">
					INSERT INTO Grupos_Verificacao VALUES(#qGruposReplicar.Grp_Codigo#,'#qGruposReplicar.Grp_Descricao#','#qGruposReplicar.Grp_Orientacao#'
														,'D', CONVERT(DATETIME, getdate(), 103),'#qAcesso.Usu_Matricula#'
														, #qGruposReplicar.Grp_tp_grupo#, #form.selAnoPara#)
				</cfquery>
            </cfif>
		</cfoutput>
		<!--- FIM Insere os grupos selecionados na tabela Grupos_Verificacao --->
		
		<!--- Insere os itens selecionados na tabela Itens_Verificacao --->
		<cfquery name="qItensSelecionados" dbtype = "query">
			SELECT DISTINCT TUI_GrupoItem, TUI_ItemVerif, TUI_Ano, TUI_TipoUnid, TUI_Modalidade FROM qGruposItensSelecionados
		</cfquery>

		<cfoutput query="qItensSelecionados">
			<cfquery name="qItensReplicar"datasource="#dsn_inspecao#">
				SELECT * FROM Itens_Verificacao 
				WHERE Itn_NumGrupo = #TUI_GrupoItem# and 
				Itn_NumItem =#TUI_ItemVerif # and 
				Itn_Ano =#form.selAnoPara# and
				Itn_TipoUnidade =#TUI_TipoUnid# and
				Itn_Modalidade = '#TUI_Modalidade#'
			</cfquery>
		</cfoutput>
		<!--- FIM Insere os itens selecionados na tabela Itens_Verificacao --->
        
		<!--- Insere os itens selecionados na tabela TipoUnidade_ItemVerificacao --->
		<cfquery datasource="#dsn_inspecao#">
			DELETE FROM TipoUnidade_ItemVerificacao
			<cfif '#form.selTipoUnidade#' eq 'todos'>  
				WHERE TUI_Ano = '#form.selAnoPara#' 
				<cfif '#form.selModalidade#' eq 'todas'> 
				  and TUI_Modalidade in (0,1)
				<cfelse>
				  and TUI_Modalidade = '#form.selModalidade#'
				</cfif>
			<cfelse>
				WHERE TUI_Ano = '#form.selAnoPara#' and TUI_TipoUnid ='#form.selTipoUnidade#' 
			   <cfif '#form.selModalidade#' eq 'todas'> 
			   	and TUI_Modalidade in (0,1)
			   <cfelse>
			   	and TUI_Modalidade = '#form.selModalidade#'
			   </cfif>
			</cfif> 
		</cfquery>
		
		<!--- Insere os itens selecionados na tabela ItemVerificacao --->
		<cfquery datasource="#dsn_inspecao#">
			DELETE FROM Itens_Verificacao
			<cfif '#form.selTipoUnidade#' eq 'todos'>  
				WHERE Itn_Ano = '#form.selAnoPara#' 
				<cfif '#form.selModalidade#' eq 'todas'> 
				  and Itn_Modalidade in (0,1)
				<cfelse>
				  and Itn_Modalidade = '#form.selModalidade#'
				</cfif>
			<cfelse>
				WHERE Itn_Ano = '#form.selAnoPara#' and Itn_TipoUnidade ='#form.selTipoUnidade#' 
			   <cfif '#form.selModalidade#' eq 'todas'> 
			   	and Itn_Modalidade in (0,1)
			   <cfelse>
			   	and Itn_Modalidade = '#form.selModalidade#'
			   </cfif>
			</cfif> 
		</cfquery>

        <cfoutput query="qGruposItensSelecionados">
				<cfquery name="qItensReplicar"datasource="#dsn_inspecao#">
					SELECT * FROM Itens_Verificacao 
					WHERE Itn_NumGrupo = #TUI_GrupoItem# and 
					Itn_NumItem =#TUI_ItemVerif # and 
					Itn_Ano =#form.selAnoDe# and
					Itn_TipoUnidade =#TUI_TipoUnid# and
					Itn_Modalidade = '#TUI_Modalidade#'
				</cfquery>	
			
				<cfquery datasource="#dsn_inspecao#">
					INSERT INTO Itens_Verificacao (Itn_Modalidade,Itn_TipoUnidade,Itn_Ano,Itn_NumGrupo,Itn_NumItem,Itn_Descricao,Itn_Orientacao,Itn_Situacao,Itn_DtUltAtu,Itn_UserName,Itn_ValorDeclarado,Itn_Amostra,Itn_Norma,Itn_ValidacaoObrigatoria,Itn_PreRelato,Itn_OrientacaoRelato,Itn_Pontuacao,Itn_Classificacao,Itn_PTC_Seq,Itn_Reincidentes,Itn_ImpactarTipos,Itn_CodArea,Itn_CodAtividade,Itn_AvisoAlteracao,Itn_DataAvisoAlteracao,Itn_Tolerancia,Itn_FatorValor,Itn_ModoAvaliar,Itn_Manchete,Itn_ClassificacaoControle,Itn_ControleTestado,Itn_CategoriaControle,Itn_RiscoIdentificadoOutros,Itn_MacroProcesso,Itn_ProcessoN1NaoAplicar,Itn_ProcessoN3Outros,Itn_ObjetivoEstrategico,Itn_RiscoEstrategico,Itn_IndicadorEstrategico,Itn_Coso2013Componente,Itn_Coso2013Principios,Itn_GestorProcessoDir,Itn_GestorProcessoDepto,Itn_RiscoIdentificado,Itn_ProcessoN1,Itn_ProcessoN2,Itn_ProcessoN3)
					VALUES (
					'#TUI_Modalidade#',
					#TUI_TipoUnid#,
					#form.selAnoPara#,
					#TUI_GrupoItem#,
					#TUI_ItemVerif#,
					'#qItensReplicar.Itn_Descricao#',
					'#qItensReplicar.Itn_Orientacao#',
					'D',
					CONVERT(DATETIME,getdate(),103),
					'#qAcesso.Usu_Matricula#',
					'#qItensReplicar.Itn_ValorDeclarado#',
					'#qItensReplicar.Itn_Amostra#',
					'#qItensReplicar.Itn_Norma#',
					'#qItensReplicar.Itn_ValidacaoObrigatoria#',
					'#qItensReplicar.Itn_PreRelato#',
					'#qItensReplicar.Itn_OrientacaoRelato#',
					#qItensReplicar.Itn_Pontuacao#,
					'#qItensReplicar.Itn_Classificacao#',
					'#qItensReplicar.Itn_PTC_Seq#',
					'#qItensReplicar.Itn_Reincidentes#',
					'#qItensReplicar.Itn_ImpactarTipos#',
					'#qItensReplicar.Itn_CodArea#',
					'#qItensReplicar.Itn_CodAtividade#',
					'#qItensReplicar.Itn_AvisoAlteracao#',
					'#qItensReplicar.Itn_DataAvisoAlteracao#',
					'#qItensReplicar.Itn_Tolerancia#',
					'#qItensReplicar.Itn_FatorValor#',
					'#qItensReplicar.Itn_ModoAvaliar#',
					'#qItensReplicar.Itn_Manchete#',
					'#qItensReplicar.Itn_ClassificacaoControle#',
					'#qItensReplicar.Itn_ControleTestado#',
					'#qItensReplicar.Itn_CategoriaControle#',
					'#qItensReplicar.Itn_RiscoIdentificadoOutros#',
					'#qItensReplicar.Itn_MacroProcesso#',
					'#qItensReplicar.Itn_ProcessoN1NaoAplicar#',
					'#qItensReplicar.Itn_ProcessoN3Outros#',
					'#qItensReplicar.Itn_ObjetivoEstrategico#',
					'#qItensReplicar.Itn_RiscoEstrategico#',
					'#qItensReplicar.Itn_IndicadorEstrategico#',
					'#qItensReplicar.Itn_Coso2013Componente#',
					'#qItensReplicar.Itn_Coso2013Principios#',
					'#qItensReplicar.Itn_GestorProcessoDir#',
					'#qItensReplicar.Itn_GestorProcessoDepto#',
					'#qItensReplicar.Itn_RiscoIdentificado#',
					'#qItensReplicar.Itn_ProcessoN1#',
					'#qItensReplicar.Itn_ProcessoN2#',
					'#qItensReplicar.Itn_ProcessoN3#'																																
					) 			
				</cfquery> 
<!---  --->
	    <cfquery datasource="#dsn_inspecao#"> 
              INSERT INTO TipoUnidade_ItemVerificacao (TUI_Modalidade,TUI_TipoUnid,TUI_GrupoItem,TUI_ItemVerif,TUI_DtUltAtu,TUI_UserName,TUI_Ano,TUI_Ativo,TUI_Pontuacao,TUI_Pontuacao_Seq,TUI_Classificacao)
			  VALUES('#TUI_Modalidade#',
			  #TUI_TipoUnid#,
			  #TUI_GrupoItem#,
			  #TUI_ItemVerif#,
			  CONVERT(DATETIME, getdate(),120),
			  '#qAcesso.Usu_Matricula#',
			  #form.selAnoPara#,
			  0,
			  #TUI_Pontuacao#,
			  '#TUI_Pontuacao_Seq#',
			  '#TUI_Classificacao#') 
            </cfquery> 
	    </cfoutput>
        <!--- FIM Insere os itens selecionados na tabela TipoUnidade_ItemVerificacao --->
	<cftransaction>

  </cfif>

 

  <cfquery name="qGruposItensReplicados" datasource="#dsn_inspecao#">
       SELECT TipoUnidade_ItemVerificacao.*, TUN_Descricao FROM TipoUnidade_ItemVerificacao
	   INNER JOIN Tipo_Unidades ON TUN_Codigo = TUI_TipoUnid
      <cfif '#form.selTipoUnidade#' eq 'todos'>  
		WHERE TUI_Ano = '#form.selAnoPara#' <cfif '#form.selModalidade#' eq 'todas'> and TUI_Modalidade in (0,1)<cfelse>and TUI_Modalidade = '#form.selModalidade#'</cfif>
	  <cfelse>
		WHERE TUI_Ano = '#form.selAnoPara#' and TUI_TipoUnid ='#form.selTipoUnidade#' <cfif '#form.selModalidade#' eq 'todas'> and TUI_Modalidade in (0,1)<cfelse>and TUI_Modalidade = '#form.selModalidade#'</cfif>
	 </cfif> 
  </cfquery>



<!---FIM ROTINA REPLICAR--->


<!DOCTYPE html>
<html lang="pt-BR">

<head>
	<title>SNCI - CADASTRO DE GRUPOS E ITENS</title>
<!--- 	<cfinclude template="cabecalho.cfm"> --->
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<link rel="stylesheet" href="public/bootstrap/bootstrap.min.css"> 
</head>



<style type="text/css">

.tituloDiv{
	padding:5px;
	position:relative;
	top: -22px;
	background: #003366;
	border:3px solid #036;

}

</style>
<script src="public/bootstrap/bootstrap.bundle.min.js"></script>
        <script src="public/jquery-3.7.1.min.js"></script>
<script language="JavaScript" type="text/JavaScript">

		//fun��es que validam os formul�rios

        function valida_formReplicar(){

			var frm = document.getElementById('formReplicar');

			if (frm.selAnoDe.value == '') {
				alert('Informe o ano que deseja replicar!');
				frm.selAnoDe.focus();
				return false;
			}
			if (frm.selAnoPara.value == '') {
				alert('Informe o ano para os itens que serão replicados!');
				frm.selAnoPara.focus();
				return false;
			}
			if (frm.selTipoUnidade.value == '') {
				alert('Informe o Tipo de Unidade cujos itens serão replicados!');
				frm.selTipoUnidade.focus();
				return false;
			}
			if (frm.selModalidade.value == '') {
				alert('Informe a modalidade dos itens que serão replicados!');
				frm.selModalidade.focus();
				return false;
			}
            
			<cfoutput>
			    var verificacoes = '#qGruposItensAnoParaVerificacoes.recordcount#';
			    var itensJaCadastrados = "#qGruposItensAnoPara.recordcount#";
				var quantItensSelecionados = "#qGruposItensSelecionados.recordcount#";
			</cfoutput>
			    var tipoUnidade = frm.selTipoUnidade.options[frm.selTipoUnidade.selectedIndex].text;
				var modalidade = frm.selModalidade.options[frm.selModalidade.selectedIndex].text;
				var anoDe = frm.selAnoDe.value;
		        var anoPara = frm.selAnoPara.value;
            


            if(itensJaCadastrados != 0){
                mensagem = 'Já existem '+ itensJaCadastrados  +' itens cadastrados para o ano '+ anoPara +', tipo de unidade "'+ tipoUnidade + '" e modalidade "'+ modalidade +'", selecionados no formulário "Replicar Grupos / Itens".\n\nDeseja excluir esses registros e continuar com essa Replicação?\n\nObs.: A exclusão só será executada se não existirem Avaliações de Controle cadastradas para os parâmetros selecionados.';
                if(window.confirm(mensagem)){				   
				   if(verificacoes != 0){
				       mensagem = 'Já existem '+ verificacoes  +' verificações cadastradas para o ano '+ anoDe +', tipo de unidade "'+ tipoUnidade + '" e modalidade "'+ modalidade +'".\n\nNão será possível concluir esta replicação.';
                       alert(mensagem);
				       return false; 
				   }else{
                       frm.acao.value = 'replicar';
			           aguarde();
                       setTimeout('document.getElementById("formReplicar").submit();',2000);
                       return true;	
				   }
				}else{
				   return false;
				}

			}else{
				msgFinal = 'Deseja replicar '+ quantItensSelecionados + ' Itens de ' + anoDe + ' para ' + anoPara + ', tipo de unidade "'+ tipoUnidade + '" e modalidade "'+ modalidade +'"?'
				 if(window.confirm(msgFinal)){
                       frm.acao.value = 'replicar';
			           aguarde();
                       setTimeout('document.getElementById("formReplicar").submit();',2000);
                       return true;	
				 }else{
                       return false;
				 }
			}


        }

</script>

<body id="main_body" style="background:#036;" onLoad="" >
    <div align="left" style="background:#003366">
					<form id="formReplicar" nome="formReplicar" enctype="multipart/form-data" method="post">
						
						<input type="hidden" value="" id="acao" name="acao">

						<div align="left" style="float: left;width:45%;padding:20px;border:1px"> 
							<div align="left">
								<span class="tituloDivConsulta" >Replicar PLANO DE TESTE</span>
							</div>
							<div style="margin-bottom:10px;">
								<label  for="selAnoDe" style="color:#036;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px"><strong>REPLICAR DO ANO:</strong></label>	
								<select name="selAnoDe" id="selAnoDe" class="form-select" onChange="aguarde(); setTimeout('javascript:formReplicar.submit();',2000)">
									<option selected="selected" value="">---</option>
									<cfoutput query="qAnosCadastrados">
										<option <cfif '#TUI_Ano#' eq "#form.selAnoDe#">selected</cfif> value="#TUI_Ano#">#TUI_Ano#</option>
									</cfoutput>
								
								</select>
							</div>
						
							<div style="margin-bottom:10px;">
								<label  for="selAnoPara" style="color:#036;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px"><strong>REPLICAR P/ O ANO:</strong></label>
								<select name="selAnoPara" id="selAnoPara" class="form-select" onChange="aguarde(); setTimeout('javascript:formReplicar.submit();',2000)">										
									<cfset anoInic = year(Now())> 							
									<cfset anoFinal = anoInic + 1>
									<option selected="selected" value="">---</option>
									<cfoutput>
										<option <cfif "#anoFinal#" eq "#form.selAnoPara#">selected</cfif> value="#anoFinal#">#anoFinal#</option>
										<option <cfif "#anoInic#" eq "#form.selAnoPara#">selected</cfif> value="#anoInic#">#anoInic#</option>
									</cfoutput>
								</select>
							</div>

							<div style="margin-bottom:10px;">
								<label  for="selTipoUnidade" style="color:#036;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px"><strong>TIPO DE UNIDADE:</strong></label>
								<select name="selTipoUnidade" id="selTipoUnidade" class="form-select" onChange="aguarde(); setTimeout('javascript:formReplicar.submit();',2000)">			
									<option selected value="">---</option>
									<cfif qTipoUnidades.recordcount neq 0>
									    <cfif qTipoUnidades.recordcount gt 1>
									        <option <cfif '#form.selTipoUnidade#' eq 'todos'>selected</cfif> value="todos">TODOS</option>
										</cfif>
										<cfoutput query="qTipoUnidades">
											<option  <cfif '#form.selTipoUnidade#' eq '#qTipoUnidades.TUI_TipoUnid#'>selected</cfif> value="#TUI_TipoUnid#">#TUN_Descricao#</option>
										</cfoutput>
									</cfif>
								</select>
							</div>

							<div style="margin-bottom:20px;">
								<label  for="selModalidade" style="color:#036;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px"><strong>MODALIDADE:</strong></label>
								<select name="selModalidade" id="selModalidade" class="form-select" onChange="aguarde(); setTimeout('javascript:formReplicar.submit();',2000)">			
									<option selected="selected" value=""></option>
									<cfif qTipoUnidades.recordcount neq 0>
										
										<cfif qModalidade.recordcount gt 1>
											<option <cfif '#form.selModalidade#' eq  'todas'>selected</cfif> value="todas">TODAS</option>
										</cfif>

										<cfoutput query="qModalidade">
											<option <cfif '#form.selModalidade#' eq  '#TUI_Modalidade#' and '#form.selModalidade#' neq  'todas'>selected</cfif> value="#TUI_Modalidade#"><cfif "#TUI_Modalidade#" eq 0>PRESENCIAL<CFELSE>A DISTÂNCIA</cfif></option>
										</cfoutput>
									</cfif>
								</select>
							</div>
						
							
							<div class="row">   
								<div class="col" align="center">
									<a type="button" onClick="return valida_formReplicar()" href="#" class="btn btn-primary">Replicar</a>   
								</div> 	
								<div class="col" align="center">						  
							 		<a type="button" onClick="javascript:if(confirm('Deseja cancelar esta replicação?\n\nObs: Esta ação não cancela as replicações já confirmadas.\n\nCaso afirmativo, clique em OK.')){window.open('cadastroGruposItens.cfm','_self')}" href="#" class="btn btn-danger">Cancelar</a>
								</div> 
							</div>                        
						</div>
						<!---In�cio da tabela com a apresenta��o dos itns selecionados--->
					    <cfif isDefined("form.acao") and "#form.acao#" eq 'replicar'>
							<cfif qGruposItensReplicados.recordCount neq 0>
								<div id="form_container" style="width:360px;height:221px;overflow-y:auto;position:relative;left:100px">
									<table align="left" id="tabInspecao" >
										<tr>
											<td colspan="7" align="center" class="titulos" style="border:none">
								
											   <h1 style="font-size:10px;background:#003366">FORAM REPLICADOS <cfoutput>#qGruposItensSelecionados.recordcount#</cfoutput> itens<BR>Tabelas atualizadas: Grupos_Verificacao, Itens_Verificacao e TipoUnidade_ItemVerificacao</h1>
											  
											</td>
										</tr>

										<tr bgcolor="<cfif "#form.acao#" eq 'replicar'>#003366<cfelse>red</cfif>" class="exibir" align="center" style="color:#fff">
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
											<cfoutput query="qGruposItensReplicados">
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
							<cfif "#form.acao#" eq 'replicar'>
								<script>
									var frm = document.getElementById('formReplicar');
									<cfoutput>
										var verificacoes = '#qGruposItensAnoParaVerificacoes.recordcount#';
										var itensJaCadastrados = "#qGruposItensAnoPara.recordcount#";
										var quantItensSelecionados = "#qGruposItensSelecionados.recordcount#";
									</cfoutput>
										var tipoUnidade = frm.selTipoUnidade.options[frm.selTipoUnidade.selectedIndex].text;
										var modalidade = frm.selModalidade.options[frm.selModalidade.selectedIndex].text;
										var anoDe = frm.selAnoDe.value;
										var anoPara = frm.selAnoPara.value;
										msgFinal = 'Foram Replicados '+ quantItensSelecionados + ' Itens de ' + anoDe + ' para ' + anoPara + ', tipo de unidade "'+ tipoUnidade + '" e modalidade "'+ modalidade +'"!'
										
										alert(msgFinal);
										
										frm.selAnoDe.value = '';
										frm.selAnoPara.value = '';
										frm.selTipoUnidade.value = '';
										frm.selModalidade.value = '';
										frm.acao='';
									
								</script>
							</cfif>
						<cfelse>
							<cfif qGruposItensSelecionados.recordCount neq 0>
									<div id="form_container"	style="width:360px;height:221px;overflow-y:auto;position:relative;left:100px">
										<table align="left" id="tabInspecao" >
											<tr>
												<td colspan="7" align="center" class="titulos" style="border:none">
												
													<h1 style="font-size:10px;background:red">REPLICAÇÃO: GRUPO E ITENS SELECIONADOS (<cfoutput>#qGruposItensSelecionados.recordcount#</cfoutput> itens)</h1>
												
												</td>
											</tr>

											<tr bgcolor="<cfif "#form.acao#" eq 'replicar'>#003366<cfelse>red</cfif>" class="exibir" align="center" style="color:#fff">
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
												<cfoutput query="qGruposItensSelecionados">
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
						
					<!---Fim da tabela com a apresenta��o dos itens selecionados--->
					</form>


	</div>			

</body>

</html>