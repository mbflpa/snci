<cfprocessingdirective pageEncoding ="utf-8"/> 
<cfparam name = "numinsp" default = ''> 
<cfset msg=''>
<!---
<cfparam name = "grpitem" default = ''> 
<cfparam name = "acao" default = ''> 
--->
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>  
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_Matricula,Usu_GrupoAcesso 
	from usuarios 
	where Usu_login = '#cgi.REMOTE_USER#'
</cfquery>
<cfset grpacesso = ucase(Trim(qAcesso.Usu_GrupoAcesso))>
<cfoutput>
	<cfif isDefined("url.acao") And (url.acao is 'buscar') and len(trim(url.numinsp)) neq 10>
		<cfset msg='Nº de Avaliação Inválido!'>
	</cfif>
	<!--- ================= --->
	<cfif isDefined("url.acao") And (url.acao is 'buscar') and len(trim(url.numinsp)) eq 10>
		<cfset somenteavaliarmeta3='N'>		
		<cfquery datasource="#dsn_inspecao#" name="rsInsp">
			SELECT INP_DTConcluirRevisao
			FROM Inspecao
			WHERE INP_NumInspecao='#url.numinsp#'
		</cfquery>
		<cfif trim(rsInsp.INP_DTConcluirRevisao) eq ''>
			<cfset msg='Nº avaliação inexistente ou em fase de revisão!'>
		</cfif>
		<cfif grpacesso eq 'INSPETORES' and msg eq ''>
			<cfquery datasource="#dsn_inspecao#" name="rsInspetor">
				SELECT IPT_NumInspecao
				FROM Inspetor_Inspecao
				WHERE IPT_NumInspecao='#url.numinsp#' AND IPT_MatricInspetor='#qAcesso.Usu_Matricula#'
			</cfquery>
			<cfif rsInspetor.recordcount lte 0>
				<cfset msg='Inspetor(a), você não participou desta avaliação!'>
			</cfif>
		</cfif>
		<cfquery datasource="#dsn_inspecao#" name="rsIncluir">
			SELECT  RIP_NumGrupo,RIP_NumItem,Fun_Nome
			FROM Resultado_Inspecao 
			INNER JOIN Inspecao ON (RIP_Unidade = INP_Unidade) AND (RIP_NumInspecao = INP_NumInspecao) 
			INNER JOIN Funcionarios ON RIP_MatricAvaliador = Fun_Matric
			left JOIN UN_Ficha_Facin_Avaliador ON (RIP_Unidade = FACA_Unidade) AND (RIP_NumInspecao = FACA_Avaliacao) and (RIP_NumGrupo=FACA_grupo) and (RIP_NumItem=FACA_Item)
			WHERE RIP_NumInspecao = convert(varchar,'#url.numinsp#') and (RIP_Recomendacao_Inspetor is not null or RIP_Correcao_Revisor = '1') and FACA_Avaliacao is null and INP_DTConcluirRevisao is not null
			<cfif grpacesso eq 'INSPETORES'>
				AND RIP_MatricAvaliador = '#qAcesso.Usu_Matricula#'
			</cfif>
			order by RIP_NumGrupo, RIP_NumItem
		</cfquery>	

		<cfquery datasource="#dsn_inspecao#" name="rsalter">
			SELECT RIP_Unidade, RIP_NumGrupo,RIP_NumItem,Fun_Nome
			FROM Resultado_Inspecao 
			INNER JOIN Inspecao ON (RIP_Unidade = INP_Unidade) AND (RIP_NumInspecao = INP_NumInspecao) 
			INNER JOIN Funcionarios ON RIP_MatricAvaliador = Fun_Matric
			INNER JOIN UN_Ficha_Facin_Avaliador ON (RIP_Unidade = FACA_Unidade) AND (RIP_NumInspecao = FACA_Avaliacao) and (RIP_NumGrupo=FACA_grupo) and (RIP_NumItem=FACA_Item)
			WHERE RIP_NumInspecao = convert(varchar,'#url.numinsp#') and INP_DTConcluirRevisao is not null
			<cfif grpacesso eq 'INSPETORES'>
				AND RIP_MatricAvaliador = '#qAcesso.Usu_Matricula#'
			</cfif>
			order by RIP_NumGrupo, RIP_NumItem
		</cfquery>
		<cfif rsIncluir.recordcount lte 0 and rsalter.recordcount lte 0>
			<cfquery datasource="#dsn_inspecao#" name="rsIncluir">
				SELECT top 1 RIP_NumGrupo,RIP_NumItem,Fun_Nome
				FROM Resultado_Inspecao 
				INNER JOIN Inspecao ON (RIP_Unidade = INP_Unidade) AND (RIP_NumInspecao = INP_NumInspecao) 
				INNER JOIN Funcionarios ON RIP_MatricAvaliador = Fun_Matric
				left JOIN UN_Ficha_Facin_Avaliador ON (RIP_Unidade = FACA_Unidade) AND (RIP_NumInspecao = FACA_Avaliacao) and (RIP_NumGrupo=FACA_grupo) and (RIP_NumItem=FACA_Item)
				WHERE RIP_NumInspecao = convert(varchar,'#url.numinsp#') and FACA_Avaliacao is null and INP_DTConcluirRevisao is not null
				<cfif grpacesso eq 'INSPETORES'>
					AND RIP_MatricAvaliador = '#qAcesso.Usu_Matricula#'
				</cfif>
				order by RIP_NumGrupo, RIP_NumItem
			</cfquery>	
			
		</cfif>
		<cfquery datasource="#dsn_inspecao#" name="rsBase">
			SELECT RIP_NumInspecao, RIP_NumGrupo, RIP_NumItem, RIP_Resposta, RIP_MatricAvaliador, RIP_Recomendacao_Inspetor, RIP_Data_Avaliador, RIP_Matricula_Reanalise, RIP_Correcao_Revisor, RIP_DtUltAtu_Revisor, RIP_UserName_Revisor,Fun_Nome,Usu_Apelido,INP_DTConcluirAvaliacao,INP_DTConcluirRevisao
			FROM Resultado_Inspecao 
			INNER JOIN Inspecao ON (RIP_Unidade = INP_Unidade) AND (RIP_NumInspecao = INP_NumInspecao) 
			INNER JOIN Funcionarios ON RIP_MatricAvaliador = Fun_Matric
			INNER JOIN Usuarios ON INP_RevisorLogin = Usu_Login
			WHERE RIP_NumInspecao = convert(varchar,'#url.numinsp#') and (RIP_Recomendacao_Inspetor is not null or RIP_Correcao_Revisor = '1') and INP_DTConcluirRevisao is not null
			<cfif grpacesso eq 'INSPETORES'>
				AND RIP_MatricAvaliador = '#qAcesso.Usu_Matricula#'
			</cfif>
		</cfquery>
		<cfif rsBase.recordcount lte 0>
			<cfquery datasource="#dsn_inspecao#" name="rsBase">
				SELECT top 1 RIP_NumInspecao, RIP_NumGrupo, RIP_NumItem, RIP_Resposta, RIP_MatricAvaliador, RIP_Recomendacao_Inspetor, RIP_Data_Avaliador, RIP_Matricula_Reanalise, RIP_Correcao_Revisor, RIP_DtUltAtu_Revisor, RIP_UserName_Revisor,Fun_Nome,Usu_Apelido,INP_DTConcluirAvaliacao,INP_DTConcluirRevisao
				FROM Resultado_Inspecao 
				INNER JOIN Inspecao ON (RIP_Unidade = INP_Unidade) AND (RIP_NumInspecao = INP_NumInspecao) 
				INNER JOIN Funcionarios ON RIP_MatricAvaliador = Fun_Matric
				INNER JOIN Usuarios ON INP_RevisorLogin = Usu_Login
				WHERE RIP_NumInspecao = convert(varchar,'#url.numinsp#') and INP_DTConcluirRevisao is not null
				<cfif grpacesso eq 'INSPETORES'>
				 AND RIP_MatricAvaliador = '#qAcesso.Usu_Matricula#'
				</cfif>
			</cfquery>
		</cfif>
		<cfif rsBase.recordcount eq 1><cfset somenteavaliarmeta3='S'></cfif>
		<cfquery datasource="#dsn_inspecao#" name="rsFacin">
			select FAC_DtConcluirFacin,Usu_Apelido,FAC_Matricula
			from UN_Ficha_Facin 
			INNER JOIN Usuarios ON FAC_Matricula = Usu_Matricula
			WHERE FAC_Avaliacao = convert(varchar,'#url.numinsp#') 
		</cfquery>
		
		<!---
			<cfquery datasource="#dsn_inspecao#" name="rsFacin">
			select FAC_DtConcluirFacin,Usu_Apelido
			from UN_Ficha_Facin 
			INNER JOIN Usuarios ON FAC_Matricula = Usu_Matricula
			WHERE FAC_Avaliacao = convert(varchar,'#url.numinsp#') and
			FAC_Matricula = '#qAcesso.Usu_Matricula#'
		</cfquery>
		--->
	</cfif>


	<!--- =================== --->
</cfoutput>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="public/bootstrap/bootstrap.min.css">
<link href="css.css" rel="stylesheet" type="text/css">

</head>
<body onLoad="aviso();form1.dtinic.focus()"><br>
<cfif grpacesso eq 'INSPETORES'>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
	      <cfinclude template="cabecalho.cfm"> 
		</table>
		<table width="100%" height="30%" border="0" align="center" cellpadding="0" cellspacing="0">
	<tr valign="top">
	<td width="25%">
	 <!--- <cfinclude template="menu_sins.cfm"> --->
	</td>
	<td align="center" valign="top">
	<br><br><br>
</cfif> 
<cfif grpacesso neq 'INSPETORES'>
	<cfif isDefined("url.acao") and url.acao eq 'buscar'>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
	      <cfinclude template="cabecalho.cfm"> 
		</table>
		<table width="100%" height="30%" border="0" align="center" cellpadding="0" cellspacing="0">
	<tr valign="top">
	<td width="25%">
	 <cfinclude template="menu_sins.cfm">
	</td>
	<td align="center" valign="top">
	<br><br><br>
	</cfif> 
</cfif> 
<div class="row" align="center">
	<div class="col">
		<label style="color:#009;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:16px;"><strong>Ficha Avaliação do Controle Interno (FACIN)</label>
	</div>
</div>
<br>

<form name="form1" id="form1" method="get" onSubmit="return valida_form()" action="ficha_facin_ref.cfm" target="_self">
  <table width="800" align="center">
	<tr align="center">
		<td>
			<span class="exibir"><strong>Nº Avaliação:</strong></span>
		</td>
	</tr>
    <tr align="center">
      <td>
		<input id="numinsp" name="numinsp" type="text" vazio="false" size="14" maxlength="10" class="form-control" onKeyPress="numericos()" value="<cfoutput>#numinsp#</cfoutput>" onChange="if (this != '') {document.form1.acao.value = 'buscar'; document.form1.submit()};">
	  </td>
	  <td>
		&nbsp;&nbsp;&nbsp;&nbsp;<input name="buscar" type="button" class="btn btn-info" value="Buscar Grupo/Item" align="center">
	 </td>
    </tr>

	<tr>

	</tr>
	<cfif isDefined("acao")>
		<tr>
			<td></td>
		</tr>
		<tr>
			<td></td>
		</tr>
		<tr>
			<td colspan="3"><hr></td>
		</tr>
		<tr>
			<td colspan="3" class="exibir" align="center"><strong>Grupo/Item</strong></td>
		</tr>
		<tr>
			<td colspan="3" class="exibir"></td>
		</tr>
		<tr>
			<td colspan="3" class="exibir"></td>
		</tr>

		<tr>
			<td class="exibir" align="center"><strong>Incluir</strong></td>
			<td></td>
			<td class="exibir" align="center"><strong>Alterar</strong></td>
		</tr>
		<tr>
			<td colspan="3"><hr></td>
		</tr>
		<tr>
			<td></td>
		</tr>
		<tr>
			<td></td>
		</tr>
		<tr>
			<td>
				<select name="grpitem" id="grpitem" class="form-select">
					<cfif isDefined("url.acao") And (url.acao is 'buscar') and len(trim(url.numinsp)) eq 10>
						<cfoutput query="rsIncluir">
							<cfset grpitm = RIP_NumGrupo & ',' & RIP_NumItem>
							<cfset nomegrpitm = RIP_NumGrupo & '_' & RIP_NumItem & ' - ' & trim(Fun_Nome)>
							<option value="#grpitm#">#nomegrpitm#</option>
						</cfoutput>
					</cfif>
				</select>
			</td>
			<td></td>
			<td>
				<select name="grpitem2" id="grpitem2" class="form-select">
					<cfif isDefined("url.acao") And (url.acao is 'buscar') and len(trim(url.numinsp)) eq 10>
						<cfoutput query="rsalter">
							<cfset grpitm = RIP_NumGrupo & ',' & RIP_NumItem>
							<cfset nomegrpitm = RIP_NumGrupo & '_' & RIP_NumItem& ' - ' & trim(Fun_Nome)>
							<option value="#grpitm#">#nomegrpitm#</option>
						</cfoutput>
					</cfif>
				</select>
			</td>
		</tr>	
			  
<cfset btninc = ''>
<cfset btnalt = ''>
<cfif isDefined("url.acao") And (url.acao is 'buscar') and len(trim(url.numinsp)) eq 10>
	<cfif rsIncluir.recordcount lte 0>
		<cfset btninc = 'disabled'>
	</cfif>
	<cfif rsalter.recordcount lte 0>
		<cfset btnalt = 'disabled'>
	</cfif>
</cfif>
<tr>
	<td></td>
</tr>
<tr>
	<td></td>
</tr>
<tr>
	<td></td>
</tr>
		<tr>
			<td><input name="inc" id="inc" type="button" class="btn btn-primary" value="Incluir (FACIN)" onClick="document.form1.acao.value = 'inc';document.formx.grpitem.value = document.form1.grpitem.value;valida_form();" <cfoutput>#btninc#</cfoutput>></td>
			<td></td>
			<td><input name="alt" id="alt" type="button" class="btn btn-warning" value="Alterar (FACIN)" onClick="document.form1.acao.value = 'alt';document.formx.grpitem.value = document.form1.grpitem2.value;valida_form();" <cfoutput>#btnalt#</cfoutput>></td>
		</tr>
	</cfif>
	<tr>
		<td></td>
	</tr>
	<tr>
		<td></td>
	</tr>
	<tr>
		<td></td>
	</tr>
	<tr>
		<td></td>
	</tr>
	<tr>
		<td></td>
	</tr>
	<tr>
		<td></td>
	</tr>
 </table>
 <div class="row"><br><br></div>
 <div id="aviso" class="noprint" align="center" style="margin-top:10px;float: left;margin-left:620px">
	<a style="cursor:pointer;" onClick="if(confirm('Confirma conclusão da FACIN?')){concluir();}">
	<div style="color:darkred;position:relative;font-size:25px">Confirmar conclusão da FACIN</div>
	</a> 
  </div>
  <div class="row"><br><br><br><br></div>
  
  <cfif (isDefined("acao") And (url.acao is 'buscar') and len(trim(url.numinsp)) eq 10 and (rsIncluir.recordcount gt 0 or rsalter.recordcount gt 0 or somenteavaliarmeta3 eq 'S'))>
	<div class="row">&nbsp;&nbsp;&nbsp;Qtd. de Itens:&nbsp;<cfoutput>#rsBase.recordcount#</cfoutput></div>
	<div id="tab">
	<table width="1400" class="table table-bordered table-striped table-hover table-active" style="background:#FFF">
		<thead style="background:#CCC" align="center">
			<th>Grupo</th>
			<th>Item</th>
			<th>Resposta</th>
			<th>Inspetor(a)</th>
			<th>Conclusão Avaliação: (<cfoutput>#dateformat(rsBase.INP_DTConcluirAvaliacao,"dd/mm/yyyy")#</cfoutput>)-Tempo(h)</th>
			<th>Últ. Ação do Inspetor(a)</th>
			<th>Últ. Ação do Revisor(a)</th>
			<th>Dif. Ações Tempo(h)</th>
			<th>Com Reanálise?</th>
			<th>Com Correção de texto?</th>			
			<th>Conclusão Revisão: (<cfoutput>#dateformat(rsBase.INP_DTConcluirRevisao,"dd/mm/yyyy")#</cfoutput>)-Tempo(h)</th>
			<th>Revisor</th>
		</thead>
		<cfoutput query="rsBase">
			<cfset reanalise = 'Não'>
			<cfset correcao = 'Não'>
			<cfif trim(rsBase.RIP_Recomendacao_Inspetor) neq ''><cfset reanalise = 'Sim'></cfif>
			<cfif trim(rsBase.RIP_Recomendacao_Inspetor) eq '' and rsBase.RIP_Correcao_Revisor eq '1'><cfset correcao = 'Sim'></cfif>
			<cfif trim(rsBase.RIP_DtUltAtu_Revisor) neq ''>
				<cfset h1 = DateDiff("h",rsBase.RIP_Data_Avaliador,rsBase.RIP_DtUltAtu_Revisor)>
			<cfelse>
				<cfset h1 = 0>
			</cfif>
			
			<cfset h2 = DateDiff("h",rsBase.RIP_Data_Avaliador,rsBase.INP_DTConcluirAvaliacao)>
			<cfset h3 = DateDiff("h",rsBase.INP_DTConcluirAvaliacao,rsBase.INP_DTConcluirRevisao)>
			<cfset ripresposta =  rsBase.RIP_Resposta>
			<cfif ripresposta eq 'C'><cfset ripresposta =  'Conforme'></cfif>
			<cfif ripresposta eq 'N'><cfset ripresposta =  'Não Conforme'></cfif>
			<cfif ripresposta eq 'V'><cfset ripresposta =  'Não Verificado'></cfif>
			<cfif ripresposta eq 'E'><cfset ripresposta =  'Não Executa'></cfif>
			<tbody>
				<tr class="table-active" align="center">
					<td>#rsBase.RIP_NumGrupo#</td>
					<td>#rsBase.RIP_NumItem#</td>
					<td>#ripresposta#</td>
					<td>#rsBase.Fun_Nome#</td>
					<th>#h2#</th>
					<td>#rsBase.RIP_Data_Avaliador#</td>
					<td>#rsBase.RIP_DtUltAtu_Revisor#</td>
					<td>#h1#</td>
					<td>#reanalise#</td>
					<td>#correcao#</td>				
					<th>#h3#</th>
					<td>#rsBase.Usu_Apelido#</td>
				</tr>
			</tbody>
		</cfoutput>
	</table>
	</div>	
 </cfif>
  <input type="hidden" id="acao" name="acao" value="">
  <input type="hidden" id="msg" name="msg" value="<cfoutput>#msg#</cfoutput>">
  
  <cfif isDefined("url.acao") And (url.acao is 'buscar') and len(trim(url.numinsp)) eq 10>
		<cfoutput>
			<input type="hidden" id="unid" name="unid" value="#rsalter.RIP_Unidade#">
			<input type="hidden" id="aval" name="aval" value="#url.numinsp#">
			<input type="hidden" id="matr" name="matr" value="#trim(qAcesso.Usu_Matricula)#">
			<input type="hidden" id="facmatricula" name="facmatricula" value="#trim(rsFacin.FAC_Matricula)#">
			<input type="hidden" id="concfacin" name="concfacin" value="#trim(dateformat(rsFacin.FAC_DtConcluirFacin,"dd-mm-yyyy"))#">
			<input type="hidden" id="concfacinnome" name="concfacinnome" value="#rsFacin.Usu_Apelido#">
			<input type="hidden" id="grpacesso" name="grpacesso" value="#grpacesso#">
		</cfoutput>
	</cfif>	
  </form>
<cfif isDefined("url.acao") And (url.acao is 'buscar') and len(trim(url.numinsp)) eq 10>
	<form name="formx" method="post" action="ficha_facin.cfm" target="_self">
		<input type="hidden" id="numinsp" name="numinsp" value="">
		<input type="hidden" id="grpitem" name="grpitem" value="">
		<input type="hidden" id="acao" name="acao" value="">
		<input type="hidden" id="somenteavaliarmeta3" name="somenteavaliarmeta3" value="<cfoutput>#somenteavaliarmeta3#</cfoutput>">
		<input type="hidden" id="salvarsn" name="salvarsn" value="S">
		<input type="hidden" id="grpacesso" name="grpacesso" value="<cfoutput>#grpacesso#</cfoutput>">
		<input type="hidden" id="matrusu" name="matrusu" value="<cfoutput>#trim(qAcesso.Usu_Matricula)#</cfoutput>">
	</form>
</cfif>
</body>
<script src="public/jquery-3.7.1.min.js"></script>
<script type="text/javascript" src="public/axios.min.js"></script>
<script>

	//================
	function aviso() {
		$('div#aviso').hide()
		//alert($('#msg').val())
		//alert($('#acao').val())
		if($('#msg').val() != '') {
			$('#aviso').html($('#msg').val())
			$('#aviso').show(500)
		} 
		//if($('#msg').val() == '' && $('#acao').val()=='buscar') {
		if($('#msg').val() == '') {
			//alert('aqui linha 410')
			if($('#grpacesso').val() == 'INSPETORES' && $('#concfacin').val() == '') {
				let prots = '<option value=""></option>'
				$('#grpitem2').html(prots)
				$('#aviso').html('Inspetor(a), FACIN não concluída pelo gestor!')
				$('#tab').hide()
				$('#aviso').show(500)
			}
			if($('#matr').val() == $('#facmatricula').val() && $('#facmatricula').val() != '') {
				$('#salvarsn').val('S')
				if($('#grpacesso').val() == 'GESTORES' && $('#concfacin').val() == '' && ($('#grpitem').val() == '' || $('#grpitem').val() == null) && $('#grpitem2').val() != null) {
					$('#aviso').show(500)
				}else{
					if ($('#acao').val()=='buscar'){
						$('#aviso').html('FACIN está em fase de conclusão por '+$('#concfacin').val()+' Gestor(a): '+$('#concfacinnome').val())
						$('#aviso').show(500)
					}
				}
								
				if($('#concfacin').val() != '' && $('#concfacin').val() != undefined && $('#concfacin').val() != null){
					$('#salvarsn').val('N')
					$('#aviso').html('Conclusão da FACIN realizada em '+$('#concfacin').val()+' Gestor(a): '+$('#concfacinnome').val())
					$('#aviso').show(500)
				}
				
			}		
			if($('#matr').val() != $('#facmatricula').val() && $('#facmatricula').val() != '') {
				$('#salvarsn').val('N')
				$('#aviso').html('FACIN está em fase de conclusão por '+$('#concfacin').val()+' Gestor(a): '+$('#concfacinnome').val())
				if($('#concfacin').val() != '' && $('#concfacin').val() != undefined && $('#concfacin').val() != null){
					$('#aviso').html('Conclusão da FACIN realizada em '+$('#concfacin').val()+' Gestor(a): '+$('#concfacinnome').val())
				}
				$('#aviso').show(500)
			}
		}		


		if($('#grpitem').val() == '' && $('#grpitem2').val() == '') {
			$('#aviso').html('Nº avaliação inexistente ou está na fase de Revisão!')
			$('#aviso').show(500)
		} 	
		if($('#somenteavaliarmeta3').val() == 'S' && $('#grpitem2').val() != null) {
			let prots = '<option value=""></option>';
            $('#grpitem').html(prots);
			$("#grpitem").attr('disabled', true);
			$("#inc").attr('disabled', true);
			if($('#concfacin').val() == ''){
				$('#aviso').show(500)
			}
		} 
   	}

	function concluir(){
		// submeter ao banco de dados
		let unid = $('#unid').val()
		unid = unid.toString()
		let aval = $('#aval').val()
		aval = aval.toString()
		let matr = $('#matr').val()
		matr = matr.toString()
		axios.get("CFC/fichafacin.cfc",{
			params: {
			method: "finalizarfacin",
			unid: unid,
			aval: aval,
			matr: matr
			}
		})
		.then(data =>{
			var vlr_ini = data.data.indexOf("<string>");
			var vlr_fin = data.data.length
			let dados = data.data.substring(vlr_ini,vlr_fin);
			$("#aviso").html(dados);
			$("#msgmacproc").show(500);
        })
      }

	//Validação de campos vazios em formulario
	function valida_form() {
		var numinsp = document.form1.numinsp.value;
		if (numinsp.length != 10) {
			document.form1.numinsp.focus();
			return false;
		}
	// inicio criticas para o botao Salvar manifestaçao
	if (document.form1.acao.value != '')
		{
			document.formx.numinsp.value = numinsp;
			//document.formx.grpitem.value = document.form1.grpitem.value;
			document.formx.acao.value = document.form1.acao.value;
			if(document.form1.grpacesso.value == 'INSPETORES') {
				 document.formx.salvarsn.value='S'
			}
			document.formx.submit();
		}	  
	}	
	function numericos() {
		var tecla = window.event.keyCode;
		//permite digitar das teclas numéricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)
		//if ((tecla != 8) && (tecla != 9) && (tecla != 27) && (tecla != 46)) {

			if ((tecla != 46) && ((tecla < 48) || (tecla > 57))) {
				//alert(tecla);
			//  if () {
				event.returnValue = false;
			// }
			}

		//}
	}
</script>
</html>