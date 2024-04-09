<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="permissao_negada.htm">
  <cfabort>
</cfif>

<!--- <cfdump var="#url#">

<cfabort> --->

<!--- Nova consulta para verificar respostas das unidades --->
<cfquery name="qSituacaoResp" datasource="#dsn_inspecao#">
SELECT Pos_Situacao_Resp
FROM ParecerUnidade
WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem#
</cfquery>

<cfquery name="qResponsavel" datasource="#dsn_inspecao#">
    SELECT  INP_Responsavel
    FROM  Inspecao
    WHERE  (INP_NumInspecao = '#ninsp#')
</cfquery>

<!--- Visualização de anexos --->
<cfquery name="qAnexos" datasource="#dsn_inspecao#">
SELECT     Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Codigo, Ane_Caminho
FROM Anexos
WHERE  Ane_NumInspecao = '#ninsp#' AND Ane_Unidade = '#unid#' AND Ane_NumGrupo = #ngrup# AND Ane_NumItem = #nitem#
</cfquery>

<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>
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

<cfif qSituacaoResp.recordCount Neq 0>
	<cfparam name="FORM.frmResp" default="#qSituacaoResp.Pos_Situacao_Resp#">
<cfelse>
	<cfparam name="Form.frmResp" default="0">
</cfif>
<!--- <cfdump var="#qSituacaoResp#"> --->


<cfquery name="qUsuario" datasource="#dsn_inspecao#">
 SELECT DISTINCT Usu_Apelido, Usu_Lotacao
 FROM Usuarios
 WHERE Usu_Login = '#CGI.REMOTE_USER#'
 GROUP BY Usu_Apelido, Usu_Lotacao
</cfquery>

<cfquery name="rsMod" datasource="#dsn_inspecao#">
SELECT Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria
FROM Unidades
WHERE Und_Codigo = '#URL.Unid#'
</cfquery>

<cfif IsDefined("FORM.MM_UpdateRecord") AND FORM.MM_UpdateRecord EQ "form1">
  <cfquery datasource="#dsn_inspecao#">
  UPDATE ParecerUnidade SET
  <cfif IsDefined("FORM.frmResp") AND FORM.frmResp NEQ "">
  Pos_Situacao_Resp='#FORM.frmResp#'
  </cfif>
  <cfswitch expression="#Form.frmResp#">
    <cfcase value="0"><cfset Encaminhamento = ''>
	  , Pos_Situacao = 'RE'
	</cfcase>
	<cfcase value="2"> <cfset Encaminhamento = 'À(O) ' & Form.hUnidade>
	  , Pos_Situacao = 'PE'
	</cfcase>
	<cfcase value="3"><cfset Encaminhamento = ''>
	  , Pos_Situacao = 'SO'
	</cfcase>
	<cfcase value="8"><cfset Encaminhamento = ''>
	  , Pos_Situacao = 'CR'
	</cfcase>
	<cfcase value="9"><cfset Encaminhamento = ''>
	  , Pos_Situacao = 'CA'
	</cfcase>
	<cfcase value="4">
	<cfquery name="qReop" datasource="#dsn_inspecao#">
		SELECT Rep_Nome
		FROM Reops
		WHERE Rep_Codigo = '#form.reop#'
	</cfquery>
	<cfset Encaminhamento = 'À(O) ' & qReop.Rep_Nome>
	  , Pos_Situacao = 'AN'
	</cfcase>
	<cfcase value="5">
	<cfquery name="qArea2" datasource="#dsn_inspecao#">
		SELECT Ars_Sigla
		FROM Areas
		WHERE Ars_CodGerencia = '#Form.cbArea#'
	</cfquery>
	<cfset Encaminhamento = 'À(O) ' & qArea2.Ars_Sigla>
	  , Pos_Situacao = 'AN'
	</cfcase>
	<cfdefaultcase><cfset Encaminhamento = ''>
	  , Pos_Situacao = 'AN'
	</cfdefaultcase>
  </cfswitch>
  <cfif IsDefined("FORM.observacao") AND FORM.observacao NEQ "">
  , Pos_Parecer=
    <cfset aux_obs = Form.obs & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & Trim(Encaminhamento) & '  ' & '-' & '  ' & Trim(FORM.observacao) & CHR(13) & CHR(13) & 'Responsável: ' & CGI.REMOTE_USER & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_Lotacao) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
	<!--- As linhas abaixo servem para substituir o uso de aspas simples e duplas, a fim de evitar erros em instruções SQL --->
	 <cfset aux_obs = Replace(aux_obs,'"','','All')>
	 <cfset aux_obs = Replace(aux_obs,"'","","All")>
	 <cfset aux_obs = Replace(aux_obs,'&','','All')>
	 <cfset aux_obs = Replace(aux_obs,'*','','All')>
	 <cfset aux_obs = Replace(aux_obs,'%','','All')>
	'#aux_obs#'
    </cfif>
	<cfif IsDefined("FORM.cbData") AND FORM.cbData NEQ "">
    , Pos_DtPrev_Solucao =
    <cfset dia_data = Left(FORM.cbData,2)>
    <cfset mes_data = Mid(FORM.cbData,4,2)>
    <cfset ano_data = Right(FORM.cbData,2)>
    <cfset data = CreateDate(ano_data,mes_data,dia_data)>
    #data#
    </cfif>
	<cfif IsDefined("FORM.cbArea") AND FORM.cbArea NEQ "">
    , Pos_Area='#FORM.cbArea#'
    </cfif>
	, Pos_Relevancia=
   <cfif IsDefined("FORM.relevancia") AND FORM.relevancia NEQ "">
    '#FORM.relevancia#'
      <cfelse>
	  NULL
   </cfif>
    , Pos_DtPosic = CONVERT(char, GETDATE(), 102)
      WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
 </cfquery>

   <!--- Dados no campo Recomendações --->




 <cfif IsDefined("FORM.MM_UpdateRecord") AND FORM.MM_UpdateRecord EQ "form1">
 <cfquery datasource="#dsn_inspecao#">
   UPDATE Resultado_Inspecao SET
   <cfif IsDefined("FORM.recomendacao") AND FORM.recomendacao NEQ "">
   RIP_Recomendacoes=
	  <cfset aux_recom = FORM.recom & CHR(13) & FORM.recomendacao & CHR(13) & CHR(13)>
	  <!--- As linhas abaixo servem para substituir o uso de aspas simples e duplas, a fim de evitar erros em instruções SQL --->
	  <cfset aux_recom = Replace(aux_recom,'"','','All')>
	  <cfset aux_recom = Replace(aux_recom,"'","","All")>
	  <cfset aux_recom = Replace(aux_recom,'&','','All')>
	  <cfset aux_recom = Replace(aux_recom,'*','','All')>
	  <cfset aux_recom = Replace(aux_recom,'%','','All')>
	  '#aux_recom#',
   </cfif>
   <cfif IsDefined("FORM.Melhoria") AND FORM.Melhoria NEQ "">
   RIP_Comentario=
	  <cfset aux_mel = CHR(13) & Form.Melhoria>
	  <!--- As linhas abaixo servem para substituir o uso de aspas simples e duplas, a fim de evitar erros em instruções SQL --->
	  <cfset aux_mel = Replace(aux_mel,'"','','All')>
	  <cfset aux_mel = Replace(aux_mel,"'","","All")>
	  <cfset aux_mel = Replace(aux_mel,'&','','All')>
	  <cfset aux_mel = Replace(aux_mel,'*','','All')>
	  <cfset aux_mel = Replace(aux_mel,'%','','All')>
	  '#aux_mel#'
	  , RIP_UserName = '#CGI.REMOTE_USER#'
	  WHERE RIP_Unidade='#FORM.unid#' AND RIP_NumInspecao='#FORM.ninsp#' AND RIP_NumGrupo=#FORM.ngrup# AND RIP_NumItem=#FORM.nitem#
	</cfif>
  </cfquery>
 </cfif>

 <cfif IsDefined("FORM.MM_UpdateRecord") AND FORM.MM_UpdateRecord EQ "form1">
   <cfquery datasource="#dsn_inspecao#">
   INSERT Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_Orgao_Solucao, And_HrPosic )
   VALUES (
   <cfif IsDefined("form.Ninsp") AND form.Ninsp NEQ "">
   '#form.ninsp#'
      <cfelse>
      NULL
   </cfif>
   ,
   <cfif IsDefined("form.Unid") AND form.Unid NEQ "">
   '#form.unid#'
      <cfelse>
      NULL
   </cfif>
   ,
   <cfif IsDefined("form.Ngrup") AND form.Ngrup NEQ "">
   #form.Ngrup#
      <cfelse>
      NULL
   </cfif>
   ,
   <cfif IsDefined("form.Nitem") AND form.Nitem NEQ "">
   #form.Nitem#
      <cfelse>
      NULL
   </cfif>
   ,
   convert(char, getdate(), 102),
   '#CGI.REMOTE_USER#',

   <cfif IsDefined("FORM.frmResp") AND FORM.frmResp NEQ "">
   '#FORM.frmResp#'
      <cfelse>
      NULL
   </cfif>
   ,
   <cfswitch expression="#Form.frmResp#">
     <cfcase value="2">
	   '#form.unid#'
	 </cfcase>
	 <cfcase value="3">
	     <!--- Tratamento da área solucionadora--->
       <cfif IsDefined("FORM.cbunid") AND FORM.cbunid NEQ "">
         '#Form.cbunid#'
       <cfelse>
          <cfif IsDefined("FORM.cbOrgao") AND FORM.cbOrgao NEQ "---">
            '#Form.cbOrgao#'
          <cfelse>
            NULL
          </cfif>
       </cfif>
       <!--- --->
	 </cfcase>
	 <cfcase value="0">
	 	NULL
	 </cfcase>
	 <cfcase value="4">
	   '#form.reop#'
	 </cfcase>
	 <cfcase value="5">
	   '#FORM.cbArea#'
	 </cfcase>
	 <cfcase value="8">
	  '#FORM.cbArea#'
	 </cfcase>
	 <cfcase value="9">
	  '#FORM.cbArea#'
	 </cfcase>
	 <cfcase value="1">
	  '#FORM.unid#'
	 </cfcase>
   </cfswitch>
   ,
  CONVERT(char, GETDATE(), 108)
  )
 </cfquery>
  WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
</cfif>

  <!--- Encerramento do processo --->
  <cfif IsDefined("FORM.frmResp") AND FORM.frmResp EQ "3">
    <cfquery name="qVerificaEncerramento" datasource="#dsn_inspecao#">
      SELECT COUNT(Pos_Inspecao) AS vTotal
      FROM ParecerUnidade
      WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_Situacao_Resp <> '3'
    </cfquery>
    <cfif qVerificaEncerramento.vTotal is 0>
      <cfquery datasource="#dsn_inspecao#">
        UPDATE ProcessoParecerUnidade SET Pro_Situacao = 'EN', Pro_DtEncerr = CONVERT(char, GETDATE(), 102)
        WHERE Pro_Unidade='#FORM.unid#' AND Pro_Inspecao='#FORM.ninsp#'
      </cfquery>
    </cfif>
  </cfif>

  <!--- <cfif form.sacao eq "alt">
     <cfquery datasource="#dsn_inspecao#">
      update Analise SET Ana_Col01='#FORM.cb01#', Ana_Col02='#FORM.cb02#', Ana_Col03='#FORM.cb03#', Ana_Col04='#FORM.cb04#', Ana_Col05='#FORM.cb05#', Ana_Col06='#FORM.cb06#', Ana_Col07='#FORM.cb07#', Ana_Col08='#FORM.cb08#', Ana_Col09='#FORM.cb09#' where (Ana_NumInspecao='#FORM.ninsp#' and Ana_Unidade='#FORM.unid#') and (Ana_NumGrupo=#FORM.ngrup# and Ana_NumItem=#FORM.nitem#)
     </cfquery>
  </cfif> --->

  <cfif form.salvar_anexar is "anexar">
    <cflocation url="itens_controle_transmitir_anexo.cfm?ninsp=#form.Ninsp#&unid=#form.Unid#&ngrup=#form.Ngrup#&nitem=#form.Nitem#&cktipo=#form.cktipo#&dtfim=#form.dtfinal#&dtinic=#form.dtinicio#&reop=#form.reop#">
  </cfif>
  <cfif ckTipo eq "inspecao">
    <cflocation url="itens_controle_respostas.cfm?txtNum_Inspecao=#FORM.ninsp#&ckTipo=inspecao">
  <cfelse>
    <cflocation url="itens_controle_respostas.cfm?Dtinic=#form.dtinicio#&dtfim=#form.dtfinal#&ckTipo=#ckTipo#">
  </cfif>
</cfif>


<!--- Nova consulta para verificar respostas das unidades --->
<cfquery name="qResposta" datasource="#dsn_inspecao#">
SELECT Pos_Situacao_Resp, Pos_Parecer, Pos_Relevancia, RIP_Recomendacoes, RIP_Comentario
FROM  Resultado_Inspecao INNER JOIN ParecerUnidade ON Resultado_Inspecao.RIP_Unidade = ParecerUnidade.Pos_Unidade AND Resultado_Inspecao.RIP_NumInspecao = ParecerUnidade.Pos_Inspecao AND Resultado_Inspecao.RIP_NumGrupo = ParecerUnidade.Pos_NumGrupo AND Resultado_Inspecao.RIP_NumItem = ParecerUnidade.Pos_NumItem
WHERE Pos_Unidade='#URL.unid#' AND Pos_Inspecao='#URL.ninsp#' AND Pos_NumGrupo=#URL.ngrup# AND Pos_NumItem=#URL.nitem#
</cfquery>

<cfquery name="qInspetor" datasource="#dsn_inspecao#">
SELECT     Inspetor_Inspecao.IPT_MatricInspetor, Funcionarios.Fun_Nome
FROM         Inspetor_Inspecao INNER JOIN
                      Funcionarios ON Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric AND
                      Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric
WHERE     IPT_NumInspecao = '#URL.Ninsp#'
</cfquery>

<cfquery name="qArea" datasource="#dsn_inspecao#">
SELECT DISTINCT Ars_CodGerencia, Ars_Sigla
FROM Areas WHERE Ars_Status = 'A'
ORDER BY Ars_Sigla
</cfquery>

<!--- <cfquery name="qData" datasource="#dsn_inspecao#">
UPDATE ParecerUnidade SET Pos_Situacao_Resp = '5', Pos_Situacao = 'AN'
WHERE Pos_Situacao_Resp = '8' AND Pos_DtPrev_Solucao <= GETDATE()
</cfquery> --->

<cfset vRecom = 0>
<cfset vRecomendacao = Trim(qResposta.RIP_Recomendacoes)>

<cfif vRecomendacao is ''>
   <cfset vRecom = 1>
</cfif>

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script>
function anexar(){
   if((document.form1.frmResp[2].checked==0) && (document.form1.frmResp[3].checked==0) && (document.form1.frmResp[4].checked==0) && (document.form1.frmResp[5].checked==0) && (document.form1.frmResp[6].checked==0) && (document.form1.frmResp[1].checked==0)){
		     alert('Sr. Analista, Escolha o Órgão Pendente da Oportunidade de Aprimoramento(Unidade, Área, Órgão Subordinador, Corporativos DR ou AC)!');
		     return false;
	     }

  	 if (<cfoutput>#vRecom#</cfoutput> == 1){
	   if((document.form1.frmResp[0].checked==0) && (document.form1.recomendacao.value == '')){
		       alert('Sr. Analista, está faltando a Recomendação!');
		       return false;
	         }
         }

     if (document.form1.frmResp[1].checked){
	 if ((document.form1.cbunid[0].checked=='') && (document.form1.cbunid[1].checked=='') && (document.form1.cbOrgao.value=='')){
      alert('Sr. Analista, informe o Órgão Solucionador da Oportunidade de Aprimoramento(Área, Unidade ou Órgão Subordinador)!');
	  return false;
	   }
      }

	  if ((document.form1.observacao.value == '') && (document.form1.frmResp[0].checked==0) && (<cfoutput>#vRecom#</cfoutput> == 0) && (document.form1.frmResp[1].checked==0) && (document.form1.recomendacao.value == '')){
		 alert('Sr. Analista, está faltando sua Análise no campo Opinião da Auditoria!');
		 return false;
	    }

      if ((document.form1.observacao.value == '') && (document.form1.frmResp[1].checked)){
         alert('Sr. Analista, está faltando sua Análise Final no campo Opinião da Auditoria!');
	     return false;
         }
    document.form1.salvar_anexar.value = 'anexar';
	document.form1.submit();
 }

function Mascara_Data(data)
{
	switch (data.value.length)
	{
		case 2:
			data.value += "/";
			break;
		case 5:
			data.value += "/";
			break;
	}
}
var org;
function exibirOrgao(org){
  if (org==3){
    window.dOrgao.style.visibility = 'visible';
  } else {
    window.dOrgao.style.visibility = 'hidden';
	document.form1.cbArea.value = '';
  }
}

var ind;
function exibirArea(ind){
  if (ind==5 || ind==8 || ind==9){
    window.dArea.style.visibility = 'visible';
  } else {
    window.dArea.style.visibility = 'hidden';
	document.form1.cbArea.value = '';
  }
}
var dat;
function exibirData(dat){
  if (dat==8 || dat==2 || dat==4 || dat==5 || dat==9){
    window.dData.style.visibility = 'visible';
  } else {
    window.dData.style.visibility = 'hidden';
	document.form1.cbData.value = '';
  }
}
function validaForm(){
 if (document.form1.frmResp[5].checked){
    if(document.form1.cbData.value == ''){
      alert('Sr. Inspetor, informe a Área e a Data de previsão para a solução da Oportunidade de Aprimoramento!');
	  return false;
	}
  }
  if ((document.form1.frmResp[4].checked) || (document.form1.frmResp[5].checked) || (document.form1.frmResp[6].checked)){
    if(document.form1.cbArea.value == ''){
       alert('Sr. Inspetor, informe a Área para encaminhamento!');
	   return false;
	}
  }
   if((document.form1.frmResp[2].checked==0) && (document.form1.frmResp[3].checked==0) && (document.form1.frmResp[4].checked==0) && (document.form1.frmResp[5].checked==0) && (document.form1.frmResp[6].checked==0) && (document.form1.frmResp[1].checked==0)){
		     alert('Sr. Inspetor, Escolha o Órgão Pendente da Oportunidade de Aprimoramento(Unidade, Área, Órgão Subordinador, Corporativos DR ou AC)!');
		     return false;
	     }

     if (document.form1.frmResp[1].checked){
	 if ((document.form1.cbunid[0].checked=='') && (document.form1.cbunid[1].checked=='') && (document.form1.cbOrgao.value=='')){
      alert('Sr. Inspetor, informe o Órgão Solucionador da Oportunidade de Aprimoramento(Área, Unidade ou Órgão Subordinador)!');
	  return false;
	   }
      }

	  if ((document.form1.observacao.value == '') && (document.form1.frmResp[0].checked==0) && (<cfoutput>#vRecom#</cfoutput> == 0) && (document.form1.frmResp[1].checked==0) && (document.form1.recomendacao.value == '')){
		 alert('Sr. Inspetor, está faltando sua Análise no campo Opinião da Inspeção!');
		 return false;
	    }

      if ((document.form1.observacao.value == '') && (document.form1.frmResp[1].checked)){
         alert('Sr. Inspetor, está faltando sua Análise Final no campo Opinião da Inspeção!');
	     return false;
         }
  return true;
}


//Função que abre uma página em Popup
function popupPage() {
<cfoutput>  //página chamada, seguida dos parâmetros número, unidade, grupo e item
var page = "itens_controle_respostas1_comentarios.cfm?numero=#ninsp#&unidade=#unid#&numgrupo=#ngrup#&numitem=#nitem#";
</cfoutput>
windowprops = "location=no,"
+ "scrollbars=yes,width=750,height=500,top=100,left=200,menubars=no,toolbars=no,resizable=yes";
window.open(page, "Popup", windowprops);
}
function desabilita_campos_unidade(){
  var frm = document.forms[0];
  if (frm.cbunid[0].checked=='1'){
	frm.cbOrgao.disabled=true;
	frm.cbunid[1].disabled=true;
	frm.cbunid[0].focus();
	 return false;
   } else {
   if (frm.cbunid[0].checked==''){
	frm.cbOrgao.disabled=false;
	frm.cbunid[1].disabled=false;
	frm.cbunid[0].focus();
	 return false;
    }
  }
}

function desabilita_campos_subordinador(){
  var frm = document.forms[0];
  if (frm.cbunid[1].checked=='1'){
	frm.cbOrgao.disabled=true;
	frm.cbunid[0].disabled=true;
	frm.cbunid[1].focus();
	 return false;
   } else {
   if (frm.cbunid[1].checked==''){
	frm.cbOrgao.disabled=false;
	frm.cbunid[0].disabled=false;
	frm.cbunid[1].focus();
	 return false;
    }
  }
}

function desabilita_campos_area(){
  var frm = document.forms[0];
  if (frm.cbOrgao.value !=''){
	frm.cbunid[0].disabled=true;
	frm.cbunid[1].disabled=true;
	frm.cbOrgao.focus();
	 return false;
   } else {
   if (frm.cbOrgao.value==''){
	frm.cbunid[0].disabled=false;
	frm.cbunid[1].disabled=false;
	frm.cbOrgao.focus();
	 return false;
    }
  }
}



</script>
</head>
<body onLoad="exibirArea(0);atribuir();exibirOrgao(0);exibirData(0)">

<cfinclude template="cabecalho.cfm">

<table width="700" height="350" align="center">
<tr>
<td valign="top" width="26%" class="link1">
<table width="100%" border="0" cellpadding="0" cellspacing="0" align="center">
      <tr align="left" valign="top">
	  <td width="5%" height="10">&nbsp; </td>
        <td width="90%" height="4" background="../../menu/fundo.gif">
        </td>
      </tr>
</table>
      <!--- <table width="90%" border="0" cellpadding="0" cellspacing="0">
        <tr align="left" valign="top">
          <td width="90%" height="4" background="../../menu/fundo.gif"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="#" class="titulos"></a><cfinclude template="menu_sins.cfm"></font></strong></td>
        </tr>
      </table>
    </td>
	  <td valign="top"> --->
<!--- Área de conteúdo   --->
<!--- <form name="form1" method="post" onSubmit="return validaForm()" action="<cfoutput>#CurrentPage#?#CGI.QUERY_STRING#</cfoutput>"> --->
<form name="form1" method="post" onSubmit="return validaForm()" action="itens_controle_respostas1.cfm">
  <table width="100%" align="center">
    <tr>
        <td colspan="5"><p class="titulo1">
        <input name="unid" type="hidden" id="unid" value="<cfoutput>#URL.Unid#</cfoutput>">
          <input name="ninsp" type="hidden" id="ninsp" value="<cfoutput>#URL.Ninsp#</cfoutput>">
          <input name="ngrup" type="hidden" id="ngrup" value="<cfoutput>#URL.Ngrup#</cfoutput>">
          <input name="nitem" type="hidden" id="nitem" value="<cfoutput>#URL.Nitem#</cfoutput>">
          <input name="dtinicio" type="hidden" id="dtinicio" value="<cfoutput>#URL.DtInic#</cfoutput>">
          <input name="dtfinal" type="hidden" id="dtfinal" value="<cfoutput>#URL.dtfim#</cfoutput>">
		  <input name="cktipo" type="hidden" id="cktipo" value="<cfoutput>#ckTipo#</cfoutput>">
		  <input name="reop" type="hidden" id="reop" value="<cfoutput>#URL.reop#</cfoutput>">
          <input type="hidden" name="hUnidade" value="<cfoutput>#rsMOd.Und_Descricao#</cfoutput>">
          <input type="hidden" name="hReop" value="<cfoutput>#URL.reop#</cfoutput>">
        </p>
        </td>
   </tr>
    <tr class="exibir">
      <td width="128" bgcolor="eeeeee">Unidade</td>
      <td width="73" bgcolor="f7f7f7"><cfoutput>#URL.Unid#</cfoutput></td>
      <td width="215" bgcolor="f7f7f7"><cfoutput><strong>#rsMOd.Und_Descricao#</strong></cfoutput></td>
      <td width="71" bgcolor="eeeeee">Respons&aacute;vel</td>
      <td width="244" bgcolor="f7f7f7"><cfoutput><strong>#qResponsavel.INP_Responsavel#</strong></cfoutput></td>
    </tr>
	<tr class="exibir">
      <cfif qInspetor.RecordCount lt 2>
	    <td bgcolor="eeeeee">Inspetor</td>
	    <cfelse>
	    <td bgcolor="eeeeee">Inspetores</td>
	  </cfif>
      <td colspan="4" bgcolor="f7f7f7">-&nbsp;<cfoutput query="qInspetor"><strong>#qInspetor.Fun_Nome#</strong>&nbsp;<cfif qInspetor.currentrow neq qInspetor.recordcount><br>-&nbsp;</cfif></cfoutput></td>
    </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">Nº Relatório</td>
      <td colspan="4" bgcolor="f7f7f7"><cfoutput>#URL.Ninsp#</cfoutput></td>
    </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">Grupo</td>
      <td bgcolor="f7f7f7"><cfoutput>#URL.Ngrup#</cfoutput></td>
      <td colspan="3" bgcolor="f7f7f7"><cfoutput><strong>#URL.DGrup#</strong></cfoutput></td>
    </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">Item</td>
      <td bgcolor="f7f7f7"><cfoutput>#URL.Nitem#</cfoutput></td>
      <td colspan="3" bgcolor="f7f7f7"><cfoutput><strong>#URL.Desc#</strong></cfoutput></td>
    </tr>
	 <tr>
	 <td height="38" bgcolor="#eeeeee"><span class="titulos">Oportunidade de Aprimoramento:</span></td>
	   <cfif qResposta.Pos_Situacao_Resp is 0>
	     <td colspan="4" bgcolor="f7f7f7"><textarea name="Melhoria" cols="200" rows="20" wrap="VIRTUAL" class="form"><cfoutput>#qResposta.RIP_Comentario#</cfoutput></textarea></td>
	     <div align="center">
	         <input type="button" class="botao"  onClick="history.back()" value="Cancelar">
	       &nbsp;&nbsp;&nbsp;&nbsp;
	         <input name="Submit" type="submit" class="botao" value="Salvar">
	       </div>
	   <cfabort>

	   <cfelse>
	     <td width="615" colspan="4" bgcolor="f7f7f7"><textarea name="Melhoria" cols="200" rows="20" wrap="VIRTUAL" class="form" readonly><cfoutput>#qResposta.RIP_Comentario#</cfoutput></textarea></td>
	   </cfif>
	 </tr>
	  <input type="hidden" name="recom" value="<cfoutput>#qResposta.RIP_Recomendacoes#</cfoutput>">
    <tr>
      <td height="38"  bgcolor="eeeeee"><span class="titulos">Orientações:</span></td>
      <td colspan="4" bgcolor="f7f7f7"><cfif Not IsDefined("FORM.MM_UpdateRecord") And Trim(qResposta.RIP_Recomendacoes) neq ''>
        <textarea name="H_recom" cols="200" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#qResposta.RIP_Recomendacoes#</cfoutput></textarea>
      </cfif>
    </tr>
	 <input type="hidden" name="obs" value="<cfoutput>#qResposta.Pos_Parecer#</cfoutput>">
	<tr>
      <td valign="middle" bgcolor="eeeeee"><span class="titulos">Hist&oacute;rico:</span>
        <span class="titulos">Manifestação e Plano de Ação/An&aacute;lise do Controle Interno</span><span class="titulos">:</span></td>
      <td colspan="4" bgcolor="f7f7f7"><cfif Not IsDefined("FORM.MM_UpdateRecord") And Trim(qResposta.Pos_Parecer) neq ''><textarea name="H_obs" cols="200" rows="40" wrap="VIRTUAL" class="form" readonly><cfoutput>#qResposta.Pos_parecer#</cfoutput></textarea></cfif></td>
	</tr>
	<tr>
      <td colspan="4">&nbsp;</td>
    </tr>
	<tr bgcolor="f7f7f7">
      <td height="22" colspan="2" valign="top" class="exibir">Foi aberto processo disciplinar? </td>
      <td height="22" valign="top" class="exibir"><span class="style4">&nbsp;&nbsp;
        <input name="relevancia" type="checkbox" class="form" size="8" value="1" <cfif qResposta.Pos_Relevancia eq 1> checked </cfif>>
      </span></td>
      <td height="22" align="center" colspan="2" valign="top" class="red_titulo"><cfif qResposta.Pos_Relevancia eq 1>
        Item compromete o processo!
      </cfif> </td>
      </tr>
	 <tr>
	  <td colspan="3" class="exibir" bgcolor="#eeeeee"><strong>ANEXOS</strong></td>
	  <td height="22" colspan="2" bgcolor="#eeeeee" class="exibir"><input type="button" value="Salvar e Anexar arquivos" class="botao" onClick="anexar()"></td>
    </tr>
	<tr>
	<cfloop query="qAnexos">
	  	<cfif FileExists(qAnexos.Ane_Caminho)>
	       <tr>
      		<td colspan="2" bgcolor="eeeeee">
				<a target="_blank" href="<cfoutput>#qAnexos.Ane_Caminho#</cfoutput>">
				<span class="link1"><cfoutput>#ListLast(qAnexos.Ane_Caminho,'\')#</cfoutput></span></a></td>
			<cfoutput>
			  <td colspan="3" bgcolor="eeeeee">
			    <input type="button" class="botao" value="Excluir" onClick="window.open('excluir_controle_anexo.cfm?ninsp=#URL.Ninsp#&unid=#URL.Unid#&ngrup=#URL.Ngrup#&nitem=#URL.Nitem#&Ane_codigo=#qAnexos.Ane_Codigo#&cktipo=#url.cktipo#&dtfim=#url.dtfim#&dtinic=#url.dtinic#&reop=#url.reop#','_self')">
			  </td>
			  </cfoutput>
			</tr>
		 </cfif>
	  </cfloop>
	 </tr>
	<tr>
      <td colspan="4">&nbsp;</td>
    </tr>
	<tr bgcolor="f7f7f7">
    <td height="22" colspan="5" valign="top" class="exibir">Situa&ccedil;&atilde;o:&nbsp;&nbsp;
        <label><span class="style4">
        <input name="frmResp" type="radio" value="2" onClick="exibirArea(this.value);exibirOrgao(this.value);exibirData(this.value)">
          Pendente Unidade</span></label>
        <label><span class="style4">
        <input name="frmResp" type="radio" value="4" onClick="exibirArea(this.value);exibirOrgao(this.value);exibirData(this.value)">
          Pendente de Órgão Subordinador</span></label>
		<label><span class="style4">
        <input type="radio" name="frmResp" value="5" onClick="exibirArea(this.value);exibirOrgao(this.value);exibirData(this.value)">
          Pendente de Área</span></label>
        <label><span class="style4">
        <input type="radio" name="frmResp" value="8" onClick="exibirArea(this.value);exibirOrgao(this.value);exibirData(this.value)">
          Corporativo SE</span></label>
	    <label><span class="style4">
        <input type="radio" name="frmResp" value="9" onClick="exibirArea(this.value);exibirOrgao(this.value);exibirData(this.value)">
          Corporativo CS</span></label>
	 </td>
  </tr>
  <tr bgcolor="f7f7f7">
    <td height="25" colspan="5" valign="top" class="exibir">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
         <label><span class="style4">
         <input type="radio" name="frmResp" value="3" onClick="exibirArea(this.value);exibirOrgao(this.value);exibirData(this.value)">
          Solucionado</span></label>
        <label><span class="style4">
        <input type="radio" name="frmResp" value="10" onClick="exibirArea(this.value)">
          Ponto Suspenso</span></label>
        <label><span class="style4">
        <input type="radio" name="frmResp" value="11" onClick="solucao(this.value)">
          Orientação Cancelada</span></label>
	    <label><span class="style4">
        <input type="radio" name="frmResp" value="12" onClick="solucao(this.value)">
		Ponto Improcedente</span></label></td>
  </tr>
  <tr>
      <td colspan="4">&nbsp;</td>
  </tr>

   <!---  <tr bgcolor="f7f7f7">
      <td height="22" colspan="4" valign="top" class="exibir">Situação:
        <label><strong><span class="style4"><input name="frmResp" type="radio" value="1" onClick="exibirArea(this.value);exibirOrgao(this.value);exibirData(this.value)" checked>N&atilde;o</span></strong></label>
        <label><strong><span class="style4"><input type="radio" name="frmResp" value="3" >Sim</span></strong></label>
        <label><strong><span class="style4"><input type="radio" name="frmResp" value="6" onClick="exibirArea(this.value);exibirOrgao(this.value);exibirData(this.value)">Outros</span></strong></label></td>
      <td height="22" valign="top" class="exibir">&nbsp;</td>
	</tr>
    <tr bgcolor="f7f7f7">
      <td height="22" colspan="5" valign="top" class="exibir">A situa&ccedil;&atilde;o est&aacute; pendente da ?
	 <span class="style4"><input name="frmResp" type="radio" value="2" >Pendente Unidade</span>&nbsp;&nbsp;
        <strong><label><input type="radio" name="frmResp" value="4" ></strong>Órgão Subordinador</label>

<label>
<input type="radio" name="frmResp" value="5" >
</label>
</strong></strong>
<label>Pendente &Aacute;rea <strong><strong>
 <input type="radio" name="frmResp" value="8" >
   </strong></strong>Corporativo SE </strong></strong></label>
   <input type="radio" name="frmResp" value="9" >
   </strong></strong>Corporativo CS </td>
      </tr> --->
	  <tr bgcolor="f7f7f7">
	    <td colspan="2" valign="top" class="exibir">
		    <div id="dArea">
		    Selecione a &aacute;rea:
                <select name="cbArea" class="form">
                  <option selected="selected" value="">---</option>
                  <cfoutput query="qArea">
                    <option value="#Ars_CodGerencia#">#Ars_Sigla#</option>
                  </cfoutput>
                </select></div></td>
		&nbsp;&nbsp;&nbsp;
	     <td colspan="3" class="exibir" align="left">
		 <div id="dData">
		  Data de Previs&atilde;o da Solu&ccedil;&atilde;o:
	      <input name="cbData" class="form" type="text" size="12" onKeyDown="Mascara_Data(this)">
		    </div></td>
	    </tr>
   <tr bgcolor="f7f7f7">
      <td height="22" colspan="5" class="exibir">
	     <div id="dOrgao">
	    Solucionado pela: &nbsp;&nbsp;&nbsp; &Aacute;rea
         <select name="cbOrgao" class="form"  onChange="desabilita_campos_area()">
            <option selected="selected" value="">---</option>
            <cfoutput query="qArea">
              <option value="#Ars_CodGerencia#">#Ars_Sigla#</option>
            </cfoutput>
          </select>
        <span class="style4"></span><span class="style4">&nbsp;&nbsp;&nbsp;
        <input name="cbunid" type="checkbox" onClick="desabilita_campos_unidade()" class="form" size="8" value="<cfoutput>#rsMOd.Und_Codigo#</cfoutput>">
        Unidade</span>  &nbsp;&nbsp;&nbsp;
        <label><span class="style4"> </span></label>
        <strong>
        <label>
        <input type="checkbox" onclick ="desabilita_campos_subordinador()" class="form" name="cbunid" size="8" value="<cfoutput>#rsMOd.Und_CodReop#</cfoutput>">
        </label>
                </strong>
        <label>&Oacute;rg&atilde;o Subordinador</label></div></td>
      </tr>
	  <tr>
	    <td valign="middle" bgcolor="eeeeee" class="exibir">&nbsp;</td>
	    <td colspan="4" bgcolor="eeeeee" class="exibir">&nbsp;</td>
	  </tr>
	  <tr>
         <td colspan="4">&nbsp;</td>
      </tr>
    <!--- <tr>
      <td height="38" bgcolor="eeeeee"><span class="titulos">Orientar:</span></td>
	  <td colspan="4" bgcolor="f7f7f7"><textarea name="recomendacao" cols="200" rows="4" nome="recomendação" vazio="false" wrap="VIRTUAL" class="form" id="recomendacao"></textarea></td>
    </tr> --->
	<tr>
	 <td height="38"  bgcolor="eeeeee"><span class="titulos">Opini&atilde;o da Equipe de Controle Interno:</span></td>
	 <td colspan="4" bgcolor="f7f7f7"><textarea name="observacao" cols="200" rows="25" nome="Observação" vazio="false" wrap="VIRTUAL" class="form" id="observacao"></textarea></td>
	</tr>
	<tr>
      <td colspan="4">&nbsp;</td>
    </tr>
	<tr>
	  <td colspan="2" bgcolor="eeeeee">&nbsp;</td>
	   <td colspan="3" align="center" bgcolor="eeeeee"><!---<input type="hidden" name="Matricula" value="<cfoutput>#Matricula#</cfoutput>">--->
	     <div align="left">
	         <input type="button" class="botao"  onClick="history.back()" value="Cancelar">
	       &nbsp;&nbsp;&nbsp;&nbsp;
	         <input name="Submit" type="submit" class="botao" value="Salvar">
	       </div><!---<cfoutput>
	       <input name="comentarios" type="button" class="botao" onClick="window.open('itens_controle_respostas_comentarios.cfm?numero=<cfoutput>#URL.ninsp#</cfoutput>&unidade=<cfoutput>#URL.unid#</cfoutput>&numgrupo=<cfoutput>#URL.ngrup#</cfoutput>&numitem=<cfoutput>#URL.nitem#</cfoutput>','','scrollbars=yes, resizable=yes, width=600, height=460, left=120, top=100')" value="Corrigir">
	       </cfoutput>---></td>
	   </tr>
	<tr>
      <td colspan="2" bgcolor="eeeeee">&nbsp;</td>
      <td colspan="3" bgcolor="eeeeee">
        <div align="center">&nbsp;&nbsp;&nbsp;</div></td>
    </tr>
  </table>
  <input type="hidden" name="MM_UpdateRecord" value="form1">
  <input type="hidden" name="salvar_anexar" value="">
</form>
<!--- Fim Área de conteúdo --->
    </td>
  </tr>
</table>
</body>
</html>