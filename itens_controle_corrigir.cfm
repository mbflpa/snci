<cfprocessingdirective pageEncoding ="utf-8"> 
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif>             
<cfif isDefined("Form.acao")>
  <cfparam name="url.pg" default="#form.pg#"> 
<cfelse>
  <cfparam name="url.pg" default="">
</cfif>
<cfif isDefined("Form.acao")>

	<cfif "#url.pg#" neq 'pt'>
		<script>
			alert('Prezado Gestor, utilize o Papel de Trabalho para acessar esta página.');
		    history.go(-1);
		</script>
		
	</cfif>
<cfelse>
    <cfif isDefined("url.pg")>
		<cfif "#url.pg#" neq 'pt'>
			<script>
				alert('Prezado Gestor, utilize o Papel de Trabalho para acessar esta página.');
				history.go(-1);
			</script>
			
		</cfif>
	<cfelse>
		<script>
				alert('Prezado Gestor, utilize o Papel de Trabalho para acessar esta página.');
				history.go(-1);
		</script>
		
	</cfif>

</cfif>

<cfset anoinsp = right(ninsp,4)>	
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Matricula, Usu_Email from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT DISTINCT Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome, Usu_DR, Usu_Email
  FROM Usuarios
  WHERE Usu_Login = '#CGI.REMOTE_USER#'
  GROUP BY Usu_DR, Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome, Usu_Email
</cfquery>

<cfset grpacesso = ucase(Trim(qAcesso.Usu_GrupoAcesso))>

 <cfif (grpacesso neq 'GESTORES') and (grpacesso neq 'DESENVOLVEDORES') and (grpacesso neq 'GESTORMASTER') and (grpacesso neq 'INSPETORES')>
	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif>        

<cfquery name="rsRelev" datasource="#dsn_inspecao#">
	SELECT VLR_Fator, VLR_FaixaInicial, VLR_FaixaFinal
	FROM ValorRelevancia
	WHERE VLR_Ano = '#right(ninsp,4)#'
</cfquery>
<cfif (grpacesso eq 'GESTORES') or (grpacesso eq 'DESENVOLVEDORES') or (grpacesso eq 'GESTORMASTER') or (grpacesso eq 'INSPETORES')>
<!---  <cftry>  --->
  <cfif isDefined("Form.acao") And (Form.acao is 'alter_reincidencia' Or Form.acao is 'alter_valores' Or Form.acao is 'Anexar' Or Form.acao is 'Excluir_Anexo')>
	<cfif isDefined("Form.abertura")><cfset Session.E01.abertura = Form.abertura><cfelse><cfset Session.E01.abertura = 'Não'></cfif>
	<cfif isDefined("Form.processo")><cfset Session.E01.processo = Form.proc_se & Form.proc_num & Form.proc_ano><cfelse><cfset Session.E01.processo = ''></cfif>
	<cfif isDefined("Form.causaprovavel")><cfset Session.E01.causaprovavel = Form.causaprovavel><cfelse><cfset Session.E01.causaprovavel = ''></cfif>
	<cfif isDefined("Form.cbarea")><cfset Session.E01.cbarea = Form.cbarea><cfelse><cfset Session.E01.cbarea = ''></cfif>
	<cfif isDefined("Form.cbdata")><cfset Session.E01.cbdata = Form.cbdata><cfelse><cfset Session.E01.cbdata = ''></cfif>
	<cfif isDefined("Form.cbunid")><cfset Session.E01.cbunid = Form.cbunid><cfelse><cfset Session.E01.cbunid = ''></cfif>
	<cfif isDefined("Form.frmresp")><cfset Session.E01.frmresp = Form.frmresp><cfelse><cfset Session.E01.frmresp = ''></cfif>
	<cfif isDefined("Form.cborgao")><cfset Session.E01.cborgao = Form.cborgao><cfelse><cfset Session.E01.cborgao = ''></cfif>
	<cfif isDefined("Form.cktipo")><cfset Session.E01.cktipo = Form.cktipo><cfelse><cfset Session.E01.cktipo = ''></cfif>
	<cfif isDefined("Form.dtfinal")><cfset Session.E01.dtfinal = Form.dtfinal><cfelse><cfset Session.E01.dtfinal = ''></cfif>
	<cfif isDefined("Form.dtinicio")><cfset Session.E01.dtinicio = Form.dtinicio><cfelse><cfset Session.E01.dtinicio = ''></cfif>
	<cfif isDefined("Form.hreop")><cfset Session.E01.hreop = Form.hreop><cfelse><cfset Session.E01.hreop = ''></cfif>
	<cfif isDefined("Form.hunidade")><cfset Session.E01.hunidade = Form.hunidade><cfelse><cfset Session.E01.hunidade = ''></cfif>
	<cfif isDefined("Form.h_obs")><cfset Session.E01.h_obs = Form.h_obs><cfelse><cfset Session.E01.h_obs = ''></cfif>
	<cfif isDefined("Form.melhoria")><cfset Session.E01.melhoria = Form.melhoria><cfelse><cfset Session.E01.melhoria = ''></cfif>
	<cfif isDefined("Form.ngrup")><cfset Session.E01.ngrup = Form.ngrup><cfelse><cfset Session.E01.ngrup = ''></cfif>
	<cfif isDefined("Form.ninsp")><cfset Session.E01.ninsp = Form.ninsp><cfelse><cfset Session.E01.ninsp = ''></cfif>
	<cfif isDefined("Form.nitem")><cfset Session.E01.nitem = Form.nitem><cfelse><cfset Session.E01.nitem = ''></cfif>
	<cfif isDefined("Form.frmmotivo")><cfset Session.E01.frmmotivo = Form.frmmotivo><cfelse><cfset Session.E01.frmmotivo = ''></cfif>
	<cfif isDefined("Form.cbdata")><cfset Session.E01.cbdata = Form.cbdata><cfelse><cfset Session.E01.cbdata = ''></cfif>
	<cfif isDefined("Form.observacao")><cfset Session.E01.observacao = Form.observacao><cfelse><cfset Session.E01.observacao = ''></cfif>
	<cfif isDefined("Form.recomendacao")><cfset Session.E01.recomendacao = Form.recomendacao><cfelse><cfset Session.E01.recomendacao = ''></cfif>
	<cfif isDefined("Form.reop")><cfset Session.E01.reop = Form.reop><cfelse><cfset Session.E01.reop = ''></cfif>
	<cfif isDefined("Form.unid")><cfset Session.E01.unid = Form.unid><cfelse><cfset Session.E01.unid = ''></cfif>
	<cfif isDefined("Form.modalidade")><cfset Session.E01.modalidade = Form.modalidade><cfelse><cfset Session.E01.modalidade = ''></cfif>
	<cfif isDefined("Form.valor")><cfset Session.E01.valor = Form.valor><cfelse><cfset Session.E01.valor = ''></cfif>
	<cfif isDefined("Form.SE")><cfset Session.E01.SE = Form.SE><cfelse><cfset Session.E01.SE = ''></cfif>
	<cfif isDefined("Form.VLRecuperado")><cfset Session.E01.VLRecuperado = Form.VLRecuperado><cfelse><cfset Session.E01.VLRecuperado = ''></cfif>
	<cfif isDefined("Form.cbareaCS")><cfset Session.E01.cbareaCS = Form.cbareaCS><cfelse><cfset Session.E01.cbareaCS = ''></cfif>
	<cfif isDefined("Form.dbfrmnumsei")><cfset Session.E01.dbfrmnumsei = Form.dbfrmnumsei><cfelse><cfset Session.E01.dbfrmnumsei = ''></cfif>
	<cfif isDefined("Form.modal")><cfset Session.E01.modal = Form.modal><cfelse><cfset Session.E01.modal = ''></cfif>
</cfif>

 <cfquery name="qUnidade" datasource="#dsn_inspecao#">
		SELECT Und_descricao FROM Unidades
		WHERE UND_codigo='#unid#'
 </cfquery>

<cfif IsDefined("FORM.submit") AND IsDefined("FORM.acao") And Form.acao is "corrigir">
	<cfquery datasource="#dsn_inspecao#" name="rsRevis">
		SELECT INP_RevisorLogin
		FROM Inspecao
		WHERE INP_NumInspecao='#FORM.ninsp#'
	</cfquery>	
	<cfif trim(rsRevis.INP_RevisorLogin) lte 0 and grpacesso eq 'GESTORES'>
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Inspecao SET INP_RevisorLogin = '#CGI.REMOTE_USER#', INP_RevisorDTInic = CONVERT(varchar, getdate(), 120)
			WHERE INP_NumInspecao ='#FORM.ninsp#'
		</cfquery>
	</cfif>
	<cfset aux_mel = CHR(13) & Form.Melhoria>
	<cfquery datasource="#dsn_inspecao#">
		UPDATE Resultado_Inspecao SET RIP_Comentario='#aux_mel#',RIP_Correcao_Revisor = '1'
		WHERE RIP_Unidade='#FORM.unid#' AND RIP_NumInspecao='#FORM.ninsp#' AND RIP_NumGrupo=#FORM.ngrup# AND RIP_NumItem=#FORM.nitem#
	</cfquery>
	<cfset grpitm = '###FORM.ngrup#' & '.#FORM.nitem#'>
	<cflocation url = "GeraRelatorio/gerador/dsp/papeltrabalho.cfm?pg=controle&Form.id=#form.Ninsp##grpitm#" addToken = "no">
</cfif>

<cfquery name="qResponsavel" datasource="#dsn_inspecao#">
    SELECT INP_Responsavel
    FROM Inspecao
    WHERE (INP_NumInspecao = '#ninsp#')
</cfquery>

<cfquery name="qCausa" datasource="#dsn_inspecao#">
  SELECT Cpr_Codigo, Cpr_Descricao FROM CausaProvavel WHERE Cpr_Codigo not in (select PCP_CodCausaProvavel from ParecerCausaProvavel
  WHERE PCP_Unidade='#unid#' AND PCP_Inspecao='#ninsp#' AND PCP_NumGrupo=#ngrup# AND PCP_NumItem=#nitem#)
  ORDER BY Cpr_Descricao
</cfquery>
<cfquery name="qSeiApur" datasource="#dsn_inspecao#">
	SELECT SEI_NumSEI FROM Inspecao_SEI 
	WHERE SEI_Unidade='#unid#' AND SEI_Inspecao='#ninsp#' AND SEI_Grupo=#ngrup# AND SEI_Item=#nitem#
	ORDER BY SEI_NumSEI
</cfquery>
<cfquery name="qProcSei" datasource="#dsn_inspecao#">
	SELECT PDC_ProcSEI, PDC_Processo, PDC_Modalidade FROM Inspecao_ProcDisciplinar
	WHERE PDC_Unidade='#unid#' AND PDC_Inspecao='#ninsp#' AND PDC_Grupo=#ngrup# AND PDC_Item=#nitem#
	ORDER BY PDC_ProcSEI
</cfquery>

<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

<cfif isDefined("Form.Ninsp") and form.Ninsp neq "">

	<cfparam name="URL.Unid" default="#Form.Unid#">
	<cfparam name="URL.Ninsp" default="#Form.Ninsp#">
	<cfparam name="URL.Ngrup" default="#Form.Ngrup#">
	<cfparam name="URL.Nitem" default="#Form.Nitem#">
	<cfparam name="URL.Desc" default="">
	<cfparam name="URL.DGrup" default="">
	<cfparam name="URL.numpag" default="0">
	<cfparam name="URL.dtFinal" default="#form.dtfinal#">
	<cfparam name="URL.DtInic" default="#form.dtinicio#">
	<cfparam name="URL.dtFim" default="#form.dtfinal#">
	<cfparam name="URL.Reop" default="#Form.Reop#">
	<cfparam name="URL.ckTipo" default="#form.ckTipo#">
	<cfparam name="URL.SE" default="#Form.SE#">
	<cfparam name="URL.selstatus" default="#form.selstatus#">
	<cfparam name="URL.statusse" default="#Form.statusse#">
	<cfparam name="URL.sfrmPosArea" default="#Form.sfrmPosArea#">
	<cfparam name="URL.sfrmPosNomeArea" default="#form.sfrmPosNomeArea#">
	<cfparam name="URL.sfrmTipoUnidade" default="#Form.sfrmTipoUnidade#">
	<cfparam name="URL.VLRDEC" default="#Form.sVLRDEC#">
	<cfparam name="URL.situacao" default="#Form.situacao#">
	<cfparam name="URL.modal" default="#Form.modal#">
	<cfparam name="URL.tpunid" default="#Form.tpunid#">
<cfelse>
	<cfparam name="URL.Unid" default="0">
	<cfparam name="URL.Ninsp" default="">
	<cfparam name="URL.Ngrup" default="">
	<cfparam name="URL.Nitem" default="">
	<cfparam name="URL.Desc" default="">
	<cfparam name="URL.DGrup" default="0">
	<cfparam name="URL.numpag" default="0">
	<cfparam name="URL.dtFinal" default="0">
	<cfparam name="URL.DtInic" default="0">
	<cfparam name="URL.dtFim" default="0">
	<cfparam name="URL.Reop" default="">
	<cfparam name="URL.ckTipo" default="">
	<cfparam name="URL.SE" default="">
	<cfparam name="URL.selstatus" default="">
	<cfparam name="URL.statusse" default="">
	<cfparam name="URL.sfrmPosArea" default="">
    <cfparam name="URL.sfrmPosNomeArea" default="">
    <cfparam name="URL.sfrmTipoUnidade" default="">
	<cfparam name="URL.modal" default="">
</cfif>

<cfquery name="rsMod" datasource="#dsn_inspecao#">
  SELECT Und_Centraliza, Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Und_Centraliza, Und_Email, Dir_Descricao, Dir_Codigo, Dir_Sigla, Dir_Sto, Dir_Email
  FROM Unidades INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
  WHERE Und_Codigo = '#URL.Unid#'
</cfquery>

<!--- Nova consulta para verificar respostas das unidades --->
<cfquery name="qResposta" datasource="#dsn_inspecao#">
	SELECT  RIP_Recomendacoes, RIP_Recomendacao, RIP_Comentario, RIP_Caractvlr, RIP_Falta, RIP_Sobra, RIP_EmRisco, RIP_Valor, RIP_ReincInspecao, RIP_ReincGrupo, RIP_ReincItem, Dir_Descricao, Dir_Codigo, INP_DtInicInspecao, Grp_Descricao, Und_TipoUnidade, INP_Modalidade, Itn_Descricao, Itn_TipoUnidade, Itn_PTC_Seq, Itn_ImpactarTipos, TNC_ClassifInicio, TNC_ClassifAtual
	FROM  Inspecao 
	INNER JOIN (Diretoria 
	INNER JOIN ((Resultado_Inspecao 
	left JOIN ParecerUnidade ON (RIP_NumItem = Pos_NumItem) AND (RIP_NumGrupo = Pos_NumGrupo) AND (RIP_NumInspecao = Pos_Inspecao) AND (RIP_Unidade = Pos_Unidade)) 
	INNER JOIN (Itens_Verificacao 
	INNER JOIN Grupos_Verificacao ON Itn_Ano = Grp_Ano and Itn_NumGrupo = Grp_Codigo) ON (convert(char(4),RIP_Ano) = Grp_Ano) and (RIP_NumGrupo = Itn_NumGrupo) AND (RIP_NumItem = Itn_NumItem)) 
	ON Dir_Codigo = RIP_CodDiretoria) ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade) and (inp_modalidade=itn_modalidade)
	INNER JOIN Unidades ON Und_Codigo = INP_Unidade and (Itn_TipoUnidade = Und_TipoUnidade)
    left JOIN TNC_Classificacao ON (RIP_NumInspecao = TNC_Avaliacao) AND (RIP_Unidade = TNC_Unidade)
	WHERE RIP_Unidade='#URL.unid#' AND RIP_NumInspecao='#URL.ninsp#' AND RIP_NumGrupo=#URL.ngrup# AND RIP_NumItem=#URL.nitem#
</cfquery>
		  
<cfquery name="qInspetor" datasource="#dsn_inspecao#">
	SELECT IPT_MatricInspetor, Fun_Nome
	FROM Inspetor_Inspecao INNER JOIN Funcionarios ON IPT_MatricInspetor = Fun_Matric AND IPT_MatricInspetor =
	Fun_Matric WHERE IPT_NumInspecao = '#URL.Ninsp#'
</cfquery>

	  
<cfquery name="qAreaDaUnidade" datasource="#dsn_inspecao#">  
      SELECT Areas.Ars_Codigo, Areas.Ars_Sigla, Areas.Ars_Descricao
      FROM Unidades INNER JOIN Reops ON Unidades.Und_CodReop = Reops.Rep_Codigo INNER JOIN Areas ON Reops.Rep_CodArea = Areas.Ars_Codigo
      WHERE Areas.Ars_Status = 'A' AND Unidades.Und_Codigo=#URL.unid#
</cfquery>		
<cfset areaDaUnidade = 	'#qAreaDaUnidade.Ars_Descricao#'/>	  

<cfquery name="qCausaProcesso" datasource="#dsn_inspecao#">
	SELECT Cpr_Codigo, Cpr_Descricao, PCP_Unidade, PCP_CodCausaProvavel  FROM ParecerCausaProvavel INNER JOIN CausaProvavel ON PCP_CodCausaProvavel =
	Cpr_Codigo WHERE PCP_Unidade='#URL.unid#' AND PCP_Inspecao='#URL.ninsp#' AND PCP_NumGrupo=#URL.ngrup# AND PCP_NumItem=#URL.nitem#
</cfquery>
<cfset PrzVencSN = 'no'>
<cfquery name="rsTPUnid" datasource="#dsn_inspecao#">
     SELECT Und_Codigo, Und_Descricao, Und_TipoUnidade FROM Unidades WHERE Und_Codigo = '#URL.unid#'
</cfquery>


<cfset vRecom = 0>
<cfset vRecomendacao = Trim(qResposta.RIP_Recomendacoes)>

<cfif vRecomendacao is ''>
   <cfset vRecom = 1>
</cfif>

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<script type="text/javascript" src="ckeditor/ckeditor.js"></script>


<script type="text/javascript">
<cfinclude template="mm_menu.js">

//reinicia o ckeditor para inibir o erro de retornar conteúdo vazio no textarea
// function CKupdate(){
//     for ( instance in CKEDITOR.instances )
//     CKEDITOR.instances[instance].updateElement();
// }
//*********************************************************************
	//==================================
	function exibirvalores() {
		window.impactofalta.style.visibility = 'hidden';
		window.impactosobra.style.visibility = 'hidden';
		window.impactoemrisco.style.visibility = 'hidden';
		window.impactofin.style.visibility = 'hidden';	

		var impfin = document.form1.frmimpactofin.value;
		var impfalta=document.form1.frmimpactofalta.value;
		var impsobra=document.form1.frmimpactosobra.value;
		var impemrisco=document.form1.frmimpactoemrisco.value;

	//	alert('Tem Impacto? ' + impfin + '  Tem falta? ' + impfalta + '  Tem Sobra? ' + impsobra + '  Tem em Risco? ' + impemrisco);
		if (impfin == 'S') 
		{
			document.form1.frmfalta.value = document.form1.sfrmfalta.value;
			document.form1.frmsobra.value = document.form1.sfrmsobra.value;
			document.form1.frmemrisco.value = document.form1.sfrmemrisco.value;
			window.impactofin.style.visibility = 'visible';
			if (impfalta == 'F') {window.impactofalta.style.visibility = 'visible';}
			if (impsobra == 'S') {window.impactosobra.style.visibility = 'visible';}
			if (impemrisco == 'R') {window.impactoemrisco.style.visibility = 'visible';}
		} 
	}
//=========================================
function dtprazo(k){
	document.form1.cbdata.disabled = true;
	document.form1.cbdata.value = document.form1.frmdtprevsol.value;
	//alert('dtprazo: ' + k);
	if (k == 3 || k == 10 || k == 12 || k == 13 || k == 25 || k == 26)
	{
	document.form1.cbdata.value = document.form1.dtdehoje.value;
	document.form1.cbdata.disabled = true;
	}
	if (k == 2 || k == 4 || k == 5 || k == 8  || k == 20 )
	{
	document.form1.cbdata.value = document.form1.dtdehoje.value;
	document.form1.cbdata.disabled = true;
	}
	if (k == 15 || k == 16 || k == 18 || k == 19 || k == 21 || k == 23)
	{
	//alert('dtprazo: ' + k);
	document.form1.cbdata.disabled = false;
	}
}
// travar o combobox em um determinado valor
function travarcombo(a,b) {
	//alert('travar combo Valor de A: ' + a + 'Valor de B: ' + b);
   var opt_sn = 'N';
   var comboitem = document.getElementById(b);
   comboitem.disabled=false
   for (i = 1; i < comboitem.length; i++) {
       // comparando o valor do label
//       if (comboitem.options[i].text.substring(comboitem.options[i].text.indexOf("/") + 1,comboitem.options[i].text.length) ==  a)
      if (comboitem.options[i].text ==  a)
	   {
       //     alert(i);
		  opt_sn = 'S'
          comboitem.selectedIndex = i;
          comboitem.disabled=true;
          i = comboitem.length;
         }
    }
	if (opt_sn == "N")
	{
       //    alert(i);
       comboitem.selectedIndex = 0;
       comboitem.disabled=false;
    }
}
//=======================
// travar o combobox(cbarea) em um determinado valor
function buscaopt(a) {
	//alert(a);
   var opt_sn = 'N';
   var comboitem = document.getElementById("cbarea");
   for (i = 1; i < comboitem.length; i++) {
   
   // if (comboitem.options[i].text ==  a) {alert(comboitem.options[i].text);}
       // comparando o valor do label
     //  if (comboitem.options[i].text.substring(comboitem.options[i].text.indexOf("/") + 1,comboitem.options[i].text.length) ==  a)
	 if (comboitem.options[i].text ==  a)
	   {

		  opt_sn = 'S'
          comboitem.selectedIndex = i;
          comboitem.disabled=true;
          i = comboitem.length;
         }
    }
	if (opt_sn == "N")
	{
       //    alert(i);
       comboitem.selectedIndex = 0;
       comboitem.disabled=false;
    }
}
//=================
function reincidencia(a){
 //alert(a);
 if (a == 'N')
  {
   document.form1.frmreincInsp.value = '';
   document.form1.frmreincGrup.value = 0;
   document.form1.frmreincItem.value = 0;
   document.form1.frmreincInsp.disabled = true;
   document.form1.frmreincGrup.disabled = true;
   document.form1.frmreincItem.disabled = true;
   document.form1.alter_reincidencia.disabled = true;
  }
  else
  {
   document.form1.frmreincInsp.disabled = false;
   document.form1.frmreincGrup.disabled = false;
   document.form1.frmreincItem.disabled = false;
   document.form1.alter_reincidencia.disabled = false;
   document.form1.frmreincInsp.value = document.form1.dbreincInsp.value;
   document.form1.frmreincGrup.value = document.form1.dbreincGrup.value;
   document.form1.frmreincItem.value = document.form1.dbreincItem.value;
   
  }
 }
//===================
function controleNCI()
{
//alert(document.form1.nci.value);
//alert(document.form1.frmnumseinci.value);
 document.form1.pontocentlzSN.value = 'N'
var x=document.form1.nci.value;
 var k=document.form1.frmnumseinci.value;
	if (x == 'Sim' && k.length == 20)
    {
	document.form1.nseincirel.value = k;
	document.form1.pontocentlzSN.value = 'S'
	document.form1.frmcbarea.selectedIndex = 0;
	document.form1.frmcbarea.disabled=true;
	}
}
//===================
function mensagemNCI(){
  var x=document.form1.nci.value;
	if (x == 'Sim')
    {
	   alert('Gestor(a), será necessário registrar o N° SEI e anexar a NCI.');
	   document.form1.frmnumseinci.focus();
	   document.form1.frmcbarea.selectedIndex = 0;
 	   document.form1.frmcbarea.disabled=true;
	}else{
		document.form1.frmcbarea.disabled=false;	
	}
}
//===================
function hanci()
{
// alert(document.form1.nseincirel.value);
 var x=document.form1.nci.value;
 var k=document.form1.nseincirel.value;
 window.ncisei.style.visibility = 'hidden';
  if (x=='Sim'){
    window.ncisei.style.visibility = 'visible';
    document.form1.frmnumseinci.value = document.form1.nseincirel.value;
    if (k.length != 20)
    {
	 // document.form1.frmnumseinci.disabled=true;
	}
  }
}

//=================
function exibe(a)
{
//  alert('exibe: ' + a);
  exibirArea(a);
 exibirAreaCS(a);
  exibirValor(a);
 dtprazo(a);
}
//==============
function exibir_Area011(x)
{
  document.form1.frmcbarea.selectedIndex = 0;
//  var x = document.form1.nci.value;
 // alert(x);
  if (x != "Sim"){
		document.form1.frmcbarea.disabled=false;
  }
  else
    {
      if (document.form1.pontocentlzSN.value == "S")
        {
         document.form1.frmcbarea.disabled=true;
        }
    }
}
//============================
var ind
function exibirArea(ind)
{
  //alert('exibirArea: ' + ind);
  document.form1.observacao.disabled=false;
  document.form1.cbarea.disabled=false;
  if (ind==5 || ind==10 || ind==19 || ind==21|| ind==25 || ind==26)
  {
    window.dArea.style.visibility = 'visible';
    if(ind==21) {buscaopt('SEC AVAL CONT INTERNO/SGCIN')}
	<cfoutput>
		if(ind==25)
	    {
		    document.form1.observacao.value = ''
            <cfset sinformes = "Encaminhamos achado de Controle interno, constatado na agência terceirizada referenciada nesta Avaliação, para conhecimento, análise, acompanhamento da regularização (se for o caso) e aplicação das providências de competência desse órgão, conforme previsto no instrumento contratual regente. Após a ciência,  o controle da baixa desse  item passará a ser de responsabilidade dessa área e a efetividade e regularidade das ações adotadas poderão serem avaliadas em futuros trabalhos das áreas de Controle Interno da Empresa (2° e 3° linha) ou de Órgãos Externos.">
            var area = "#trim(areaDaUnidade)#"; 
            var parecer =  "#sinformes#"; 
            travarcombo(area,'cbarea');
            document.form1.observacao.value = parecer;
            document.form1.observacao.disabled=true;
		}
		if(ind==26)
	    {
		    document.form1.observacao.value = ''
            var area = "#trim(areaDaUnidade)#"; 
            travarcombo(area,'cbarea');
            document.form1.observacao.disabled=false;
		}		
    </cfoutput>
  } else {
    window.dArea.style.visibility = 'hidden';
	document.form1.cbarea.value = '';
  }
}
//====================
var idx
function exibirAreaCS(idx){
	//alert(idx);
	//alert(document.form1.houveProcSN.value);
	window.dAreaCS.style.visibility = 'visible';
  if (idx==24 || document.form1.houveProcSN.value == 'S')
    {
		if(document.form1.houveProcSN.value == 'S')
		{
			//alert(document.form1.houveProcSN.value);
			if(document.form1.mensSN.value == 'S')
			{
				alert('                            Atenção! \n\nGestor(a), favor informar a Situação: APURAÇÃO deste ponto.');
				document.form1.mensSN.value = 'N';
			}
				travarcombo('APURACAO','frmResp'); travarcombo('CORREGEDORIA/PRESI','cbareaCS')
			} else { exibe('N'); travarcombo('kkk','frmResp')}
  } else if (idx == 9){}
    else {
    window.dAreaCS.style.visibility = 'hidden';
	document.form1.cbareaCS.value = '';
  }
}
//===========================
function exibirValor(vlr){
	//alert('exibirValor: ' + vlr);
  //if ((vlr==3 || vlr==9) && document.form1.vlrdeclarado.value == 'S'){
  if (vlr==3 || vlr==9){
    window.dValor.style.visibility = 'visible';
   // alert('Sr. Gestor, informe o Valor Regularizado, Exemplos: 1185,40; 0,07');
	document.form1.VLRecuperado.value='0,00'
	if (document.form1.vlrdeclarado.value == 'N'){document.form1.VLRecuperado.value='0,0'}
  } else {
    document.form1.VLRecuperado.value='0,00'
    window.dValor.style.visibility = 'hidden';
  }
}
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
function validarform()
{
	
	
// ==== critica do botao corrigir ===
    if (document.form1.acao.value == 'corrigir')
	{
		document.form1.recomendacao.disabled = false;
		var melhor = document.form1.Melhoria.value;
		melhor = melhor.replace(/\s/g, '');
		if (melhor.length < 100)
		{
			alert('Gestor(a), os campos: Situação Encontrada deve conter no mínimo 100(cem) caracteres!');
			return false;
		}

	}
}

//Funcao que abre uma pagina em Popup
function popupPage() {
<cfoutput>  //pagina chamada, seguida dos parametros numero, unidade, grupo e item
var page = "itens_controle_respostas_comentarios.cfm?numero=#ninsp#&unidade=#unid#&numgrupo=#ngrup#&numitem=#nitem#";
</cfoutput>
windowprops = "location=no,"
+ "scrollbars=yes,width=750,height=500,top=100,left=200,menubars=no,toolbars=no,resizable=yes";
window.open(page, "Popup", windowprops);
}

function abrirPopup(url,w,h) 
{
	var newW = w + 100;
	var newH = h + 100;
	var left = (screen.width-newW)/2;
	var top = (screen.height-newH)/2;
	var newwindow = window.open(url, 'blank', 'width='+newW+',height='+newH+',left='+left+',top='+top+ ',scrollbars=no');
	newwindow.resizeTo(newW, newH);
	//posiciona o popup no centro da tela
	newwindow.moveTo(left, top);
	newwindow.focus();
	return false;
}

</script>

</head>

<body onLoad="exibirvalores();if(document.form1.houveProcSN.value != 'S') {exibe(document.form1.frmResp.value)} else {exibe(24)}; hanci(); controleNCI(); exibir_Area011(this.value);"> 
 <cfinclude template="cabecalho.cfm">
    <cfif '#qResposta.RIP_Recomendacao#' eq 'R'>
		<div align="right" style="position:absolute;top:163px;right:160px">
			<a  onClick="abrirPopup('itens_controle_revisliber_reanalise.cfm?<cfoutput>ninsp=#ninsp#&unid=#unid#&ngrup=#ngrup#&nitem=#nitem#&tpuni=#rsTPUnid.Und_TipoUnidade#</cfoutput>',800,600)" href="#"
			class="botaoCad" ><img   onmouseover="bigImg(this)" onMouseOut="normalImg(this)"   alt="Orientações p/ Reanálise do Inspetor" src="figuras/reavaliar.png" width="25"   border="0" style="position:absolute;left:0px;top:5px"></img></a>	
		</div>
	</cfif>
							
<table width="70%"  align="center" bordercolor="f7f7f7">
  <tr>
    <td height="20" colspan="3" bgcolor="eeeeee"><div align="center"><strong class="titulo2"><cfoutput>#qResposta.Dir_Descricao#</cfoutput></strong></div></td>
  </tr>
  <tr bgcolor="eeeeee">
    <td height="20" colspan="3">&nbsp;</td>
  </tr>
  <tr bgcolor="eeeeee">
    <td height="10" colspan="3"><div align="center"><strong class="titulo1">CONTROLE DAS MANIFESTAÇÕES</strong></div></td>
  </tr>
  <tr bgcolor="eeeeee">
    <td height="20" colspan="3">&nbsp;</td>
  </tr>
  <form name="form1" method="post" onSubmit="return validarform()" enctype="multipart/form-data" action="itens_controle_corrigir.cfm">
  <cfoutput>
		<input type="hidden" name="sfrmTipoUnidade" id="sfrmTipoUnidade" value="#qResposta.Itn_TipoUnidade#">
	</cfoutput>
    <tr bgcolor="eeeeee">
      <td colspan="3"><p class="titulo1">
	    <input type="hidden" id="pg" name="pg" value="<cfoutput>#URL.pg#</cfoutput>"> 
        <input type="hidden" id="acao" name="acao" value="">
        <input type="hidden" id="anexo" name="anexo" value="">
        <input type="hidden" id="vCausaProvavel" name="vCausaProvavel" value="">
        <input type="hidden" id="vCodigo" name="vCodigo" value="">
		<cfset falta = lscurrencyformat(qResposta.RIP_Falta,'Local')>
		<cfset sobra = lscurrencyformat(qResposta.RIP_Sobra,'Local')>
		<cfset emrisco = lscurrencyformat(qResposta.RIP_EmRisco,'Local')>
        <input name="unid" type="hidden" id="unid" value="<cfoutput>#URL.Unid#</cfoutput>">
        <input name="ninsp" type="hidden" id="ninsp" value="<cfoutput>#URL.Ninsp#</cfoutput>">
        <input name="ngrup" type="hidden" id="ngrup" value="<cfoutput>#URL.Ngrup#</cfoutput>">
        <input name="nitem" type="hidden" id="nitem" value="<cfoutput>#URL.Nitem#</cfoutput>">
        <input name="dtinicio" type="hidden" id="dtinicio" value="<cfoutput>#URL.DtInic#</cfoutput>">
        <input name="dtfinal" type="hidden" id="dtfinal" value="<cfoutput>#URL.dtfim#</cfoutput>">
        <input name="cktipo" type="hidden" id="cktipo" value="<cfoutput>#ckTipo#</cfoutput>">
        <input name="reop" type="hidden" id="reop" value="<cfoutput>#URL.reop#</cfoutput>">
        <input type="hidden" id="hUnidade" name="hUnidade" value="<cfoutput>#rsMOd.Und_Descricao#</cfoutput>">
        <input type="hidden" id="hReop" name="hReop" value="<cfoutput>#URL.reop#</cfoutput>">
        <input type="hidden" id="SE" name="SE" value="<cfoutput>#URL.SE#</cfoutput>">
		<input type="hidden" id="selstatus" name="selstatus" value="<cfoutput>#URL.selstatus#</cfoutput>">
        <input type="hidden" id="statusse" name="statusse" value="<cfoutput>#URL.statusse#</cfoutput>">
		<input type="hidden" id="vlrdeclarado" name="vlrdeclarado" value="<cfoutput>#url.vlrdec#</cfoutput>">
		<input type="hidden" id="emailusu" name="emailusu" value="<cfoutput>#qAcesso.Usu_Email#</cfoutput>">
		<input type="hidden" id="modal" name="modal" value="<cfoutput>#URL.modal#</cfoutput>">
		<input type="hidden" id="tpunid" name="tpunid" value="<cfoutput>#URL.tpunid#</cfoutput>">
      </p></td>
    </tr>
	  <tr>
      <td width="95" bgcolor="eeeeee" class="exibir">Unidade</td>
      <td bgcolor="eeeeee"><cfoutput><strong class="exibir">#URL.Unid#</strong></cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput><strong class="exibir">#rsMOd.Und_Descricao#</strong></cfoutput></td>
      <td colspan="1" bgcolor="eeeeee"><span class="exibir">Responsável</span>&nbsp;&nbsp;<cfoutput><strong class="exibir">#qResponsavel.INP_Responsavel#</strong></cfoutput></td>
      </tr>
   <tr class="exibir">
            <cfif qInspetor.RecordCount lt 2>
              <td bgcolor="eeeeee">Inspetor</td>
              <cfelse>
              <td bgcolor="eeeeee">Inspetores</td>
            </cfif>
            <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
            <td colspan="3" bgcolor="eeeeee">-&nbsp;<cfoutput query="qInspetor"><strong class="exibir">#qInspetor.Fun_Nome#</strong>&nbsp;<cfif qInspetor.currentrow neq qInspetor.recordcount><br>-&nbsp;</cfif></cfoutput></td>
      </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">N° Relatório</td>
      <td colspan="3" bgcolor="eeeeee"><cfoutput><strong class="exibir">#URL.Ninsp#</strong></cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;In&iacute;cio Inspe&ccedil;&atilde;o &nbsp;<strong class="exibir"><cfoutput>#DateFormat(qResposta.INP_DtInicInspecao,"dd/mm/yyyy")#</cfoutput></strong></td>
      </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">Grupo</td>
      <td colspan="3" bgcolor="eeeeee"><cfoutput><strong class="exibir">#URL.Ngrup#</strong></cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput><strong class="exibir">#qResposta.Grp_Descricao#</strong></cfoutput></td>
    </tr>

    <tr class="exibir">
      <td bgcolor="eeeeee">Item</td>
      <td colspan="3" bgcolor="eeeeee"><cfoutput><strong class="exibir">#URL.Nitem#</strong></cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput><strong class="exibir">#qResposta.Itn_Descricao#</strong></cfoutput></td>
    </tr>
<cfoutput>	
	<cfset tipoimpacto = 'NÃO QUANTIFICADO'>
	<cfif listFind(#qResposta.Itn_PTC_Seq#,'10')>
		<cfset tipoimpacto = 'QUANTIFICADO'>
	</cfif>
	<cfset impactofin = 'N'>
	<cfset impactofalta = 'N'>
	<cfset impactosobra = 'N'>
	<cfset impactoemrisco = 'N'>
	<cfif listFind(#qResposta.Itn_ImpactarTipos#,'F')>
		  <cfset impactofin = 'S'>
		<cfset impactofalta = 'F'>
	</cfif>
	<cfif listFind(#qResposta.Itn_ImpactarTipos#,'S')>
		  <cfset impactofin = 'S'>
		<cfset impactosobra = 'S'>
	</cfif>	
	<cfif listFind(#qResposta.Itn_ImpactarTipos#,'R')>
		  <cfset impactofin = 'S'>
		<cfset impactoemrisco = 'R'>
	</cfif>		
<cfif tipoimpacto eq 'QUANTIFICADO'>
	 <tr class="exibir">
	  <td bgcolor="eeeeee"><div id="impactofin">Potencial Valor</div></td>
	  <td colspan="3" bgcolor="eeeeee">
		<table width="95%" border="0" cellspacing="0" bgcolor="eeeeee">
			<tr class="exibir"><strong>
				<td width="30%" bgcolor="eeeeee"><strong>Estimado a Recuperar (R$):&nbsp;</strong></td>
				<td width="35%" bgcolor="eeeeee"><strong>Estimado Não Planejado/Extrapolado/Sobra (R$):</strong></td>
				<td width="35%" bgcolor="eeeeee"><strong>Estimado em Risco ou Envolvido (R$):</strong></td>
			</tr>
			<tr class="exibir"><strong>
				<td width="30%" bgcolor="eeeeee"><input name="frmfalta" type="text" class="form" value="#falta#" size="22" maxlength="17" readonly></td>
				<td width="35%" bgcolor="eeeeee"><input name="frmsobra" type="text" class="form" value="#sobra#" size="22" maxlength="17" readonly></td>
				<td width="35%" bgcolor="eeeeee"><input name="frmemrisco" type="text" class="form" value="#emrisco#" size="22" maxlength="17" readonly></td>
			</tr>
		  </table>		  
	  </td>
	</tr> 
</cfif>	
</cfoutput>		
	<tr>
		<td bgcolor="#eeeeee" align="center"><span class="titulos">Situação Encontrada:</span></td>
		<td colspan="3" bgcolor="eeeeee"><textarea name="Melhoria" cols="200" rows="20" wrap="VIRTUAL" class="form"><cfoutput>#qResposta.RIP_Comentario#</cfoutput></textarea></td>
	</tr>

	<tr>
		<td bgcolor="eeeeee" align="center"><span class="titulos">Orientações:</span></td>
		<td colspan="3" bgcolor="eeeeee"><textarea name="recomendacao" cols="200" rows="12" wrap="VIRTUAL" class="form" disabled><cfoutput>#qResposta.RIP_Recomendacoes#</cfoutput></textarea></td>
	</tr> 

	<tr bgcolor="eeeeee">
      <td colspan="3">&nbsp;</td>
    </tr>
<cfoutput>

 	
	<tr bgcolor="eeeeee">
		<td colspan="3" align="center">
			<input name="button" type="button" class="botao" onClick="voltar();" value="Voltar">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input name="Submit" type="Submit" class="botao" value="Confirmar Correção Texto" onClick="document.form1.acao.value='corrigir';">
		</td>
	</tr>
	</cfoutput>  

	</form>
</table>

<script>
	
		CKEDITOR.replace('Melhoria', {
			width: '1020',
			height: 200,
			removePlugins: 'scayt',
			disableNativeSpellChecker: false,
			line_height:'1px',
			disableObjectResizing:true,
			toolbar: [
				['Preview', 'Print', '-' ],
				[ 'Cut', 'Copy', 'Paste', 'PasteText', 'RemoveFormat','-', 'Undo', 'Redo', '-','Find' ],
				['SelectAll', '-'],
				[ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ],
				[ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
				['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
				'/',
				['HorizontalRule','SpecialChar', '-','TextColor', 'BGColor','-','Imagem','-','Maximize','Table'  ]
			]
		});

		CKEDITOR.replace('recomendacao', {
			width: '1020',
			height: 200,
			removePlugins: 'scayt',
			disableNativeSpellChecker: false,
			toolbar: [
				['Preview', 'Print', '-' ],
				[ 'Cut', 'Copy', 'Paste', 'PasteText', 'RemoveFormat','-', 'Undo', 'Redo', '-','Find' ],
				['SelectAll', '-'],
				[ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ],
				[ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
				['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
				['HorizontalRule','SpecialChar', '-','TextColor', 'BGColor','Maximize','Table'  ]
			]
		});

		function voltar() {
			<cfoutput>
				var insp = '#URL.Ninsp#';
				var grpitm = '###URL.Ngrup#' + '.#URL.Nitem#';
			</cfoutput>
			var url = 'GeraRelatorio/gerador/dsp/papeltrabalho.cfm?pg=controle&Form.id=' + insp + grpitm;
			window.open(url, '_self');
		}
	
</script>

</body>
</html>

<cfif isDefined("Session.E01")>
	<cfset StructClear(Session.E01)>
</cfif>

<cfelse>
     <cfinclude template="permissao_negada.htm">
</cfif>
