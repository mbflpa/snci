<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif> 
<cfset area = 'sins'>
<cfset evento = 'document.form1.observacao.focus();'>

<cfquery name="rsItem" datasource="#dsn_inspecao#">
SELECT RIP_NumInspecao, RIP_Unidade, Und_Descricao, RIP_NumGrupo, RIP_NumItem, RIP_Comentario, RIP_Recomendacoes, INP_DtInicInspecao, INP_Responsavel, RIP_Melhoria
FROM (Inspecao INNER JOIN (Resultado_Inspecao 
INNER JOIN Unidades ON RIP_Unidade = Und_Codigo) ON 
(INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade)) 
INNER JOIN Itens_Verificacao ON (convert(char(4), RIP_Ano) = Itn_Ano and INP_Modalidade = Itn_Modalidade) 
AND (RIP_NumItem = Itn_NumItem) AND (RIP_NumGrupo = Itn_NumGrupo) AND (Und_TipoUnidade = Itn_TipoUnidade)
WHERE RIP_NumInspecao='#ninsp#' AND RIP_Unidade='#unid#' AND RIP_NumGrupo= #ngrup# AND RIP_NumItem=#nitem#
</cfquery> 

<cfquery name="qAnexos" datasource="#dsn_inspecao#">
  SELECT Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Codigo, Ane_Caminho
  FROM Anexos
  WHERE  Ane_NumInspecao = '#ninsp#' AND Ane_Unidade = '#unid#' AND Ane_NumGrupo = #ngrup# AND Ane_NumItem = #nitem# 
  order by Ane_Codigo
</cfquery>

<cfquery name="qSituacaoResp" datasource="#dsn_inspecao#">
SELECT Pos_Situacao_Resp 
FROM ParecerUnidade
WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem#
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
<cfparam name="URL.Reop" default="">

<cfquery name="qUsuario" datasource="#dsn_inspecao#">
 SELECT DISTINCT Usu_Apelido, Usu_Lotacao
 FROM Usuarios
 WHERE Usu_Login = '#CGI.REMOTE_USER#'
 GROUP BY Usu_Apelido, Usu_Lotacao 
</cfquery> 

<cfquery name="rsMod" datasource="#dsn_inspecao#">
 SELECT Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria
 FROM Unidades
 WHERE Und_Codigo = '#URL.unid#' 
</cfquery>
  

<!--- Nova consulta para verificar respostas das unidades --->
<cfquery name="qResposta" datasource="#dsn_inspecao#">
SELECT Pos_Situacao_Resp, Pos_Parecer, Ars_Sigla, Pos_Situacao_Resp
FROM ParecerUnidade INNER JOIN Areas ON Pos_Area = Ars_CodGerencia
WHERE Pos_Unidade='#URL.unid#' AND Pos_Inspecao='#URL.ninsp#' AND Pos_NumGrupo=#URL.ngrup# AND Pos_NumItem=#URL.nitem#
</cfquery>

<cfquery name="qResponsavel" datasource="#dsn_inspecao#">
    SELECT  INP_Responsavel
    FROM  Inspecao
    WHERE  (INP_NumInspecao = #URL.Ninsp#)
</cfquery>
<cfset encaminhamento = qResposta.Ars_Sigla>
<cfquery name="qInspetor" datasource="#dsn_inspecao#">
    SELECT     Inspetor_Inspecao.IPT_MatricInspetor, Funcionarios.Fun_Nome
    FROM         Inspetor_Inspecao INNER JOIN
                      Funcionarios ON IPT_MatricInspetor = Fun_Matric AND 
                      IPT_MatricInspetor = Fun_Matric
    WHERE     (IPT_NumInspecao = '#URL.Ninsp#')
</cfquery>


 <cfif IsDefined("FORM.MM_UpdateRecord") AND FORM.MM_UpdateRecord EQ "form1">
	<cfset maskcgiusu = ucase(trim(CGI.REMOTE_USER))>
	<cfif left(maskcgiusu,8) eq 'EXTRANET'>
		<cfset maskcgiusu = left(maskcgiusu,9) & '***' &  mid(maskcgiusu,13,8)>
	<cfelse>
		<cfset maskcgiusu = left(maskcgiusu,12) & mid(maskcgiusu,13,4) & '***' & right(maskcgiusu,1)>	
	</cfif> 
  <cfquery datasource="#dsn_inspecao#">
  UPDATE ParecerUnidade SET Pos_Situacao_Resp=
  <cfif IsDefined("FORM.frmResp") AND FORM.frmResp NEQ "">
    '#FORM.frmResp#'
	, Pos_Sit_Resp_Antes = #form.scodresp#
      <cfelse>
      NULL
  </cfif>
  <cfswitch expression="#Form.frmResp#">
    <cfcase value="0">
	  , Pos_Situacao = 'PE'
	</cfcase>
	<cfcase value="2">
	  , Pos_Situacao = 'PE'<cfset Encaminhamento = Form.hUnidade>
	</cfcase>	
	<cfcase value="3">
	  , Pos_Situacao = 'SO'
	</cfcase>
	<cfcase value="4">
	 <cfquery name="qReop" datasource="#dsn_inspecao#">
		SELECT Rep_Nome
		FROM Reops
		WHERE Rep_Codigo = '#form.reop#'
	 </cfquery>
	 <cfset Encaminhamento = qReop.Rep_Nome>	
	  , Pos_Situacao = 'AN'
	</cfcase>
	<cfcase value="5">
	 <cfquery name="qArea2" datasource="#dsn_inspecao#">
		SELECT Ars_Sigla
		FROM Areas
		WHERE Ars_CodGerencia = '#Form.cbArea#'
	 </cfquery>
	 <cfset Encaminhamento = qArea2.Ars_Sigla>
	  , Pos_Situacao = 'AN'
	</cfcase>
	<cfcase value="8">
	  , Pos_Situacao = 'CR'
	</cfcase>
	<cfcase value="9">
	  , Pos_Situacao = 'CA'
	</cfcase>	
  </cfswitch> 
    <cfset aux_obs = "">
  <cfif IsDefined("FORM.observacao") AND FORM.observacao NEQ "">
  , Pos_Parecer=
    <cfset aux_obs = Trim(FORM.observacao)>
	<cfset aux_obs = Replace(aux_obs,'"','','All')>
    <cfset aux_obs = Replace(aux_obs,"'","","All")>
	<cfset aux_obs = Replace(aux_obs,'*','','All')>
    <cfset aux_obs = Replace(aux_obs,'>','','All')>		
	<!---	 <cfset aux_obs = Replace(aux_obs,'&','','All')>
		     <cfset aux_obs = Replace(aux_obs,'%','','All')> --->
    <cfset pos_obs = Form.H_obs & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & Trim(Encaminhamento) & '  ' & '-' & '  ' & #aux_obs# & CHR(13) & CHR(13) & 'Respons�vel: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_Lotacao) & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
	'#pos_obs#'
   </cfif>
   , Pos_DtPrev_Solucao = 
    <cfif IsDefined("FORM.cbData") AND FORM.cbData NEQ "">
    <cfset dia_data = Left(FORM.cbData,2)>
    <cfset mes_data = Mid(FORM.cbData,4,2)>
    <cfset ano_data = Right(FORM.cbData,2)>
    <cfset data = CreateDate(ano_data,mes_data,dia_data)>
     #data#
    <cfelse>
     NULL
    </cfif>
   , Pos_Area=
   <cfif IsDefined("FORM.cbArea") AND FORM.cbArea NEQ "">
    '#FORM.cbArea#'
      <cfelse>
	  NULL     	   
   </cfif>
  , Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
  , Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
  , Pos_NomeResp='#CGI.REMOTE_USER#'
  , Pos_username = '#CGI.REMOTE_USER#'
  WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
  </cfquery>  
  
 <!--- Inserindo dados dados na tabela Andamento --->
 <cfif IsDefined("FORM.MM_UpdateRecord") AND FORM.MM_UpdateRecord EQ "form1">
 	<cfset maskcgiusu = ucase(trim(CGI.REMOTE_USER))>
	<cfif left(maskcgiusu,8) eq 'EXTRANET'>
		<cfset maskcgiusu = left(maskcgiusu,9) & '***' &  mid(maskcgiusu,13,8)>
	<cfelse>
		<cfset maskcgiusu = left(maskcgiusu,12) & mid(maskcgiusu,13,4) & '***' & right(maskcgiusu,1)>	
	</cfif>
  <cfset hhmmssdc = timeFormat(now(), "HH:MM:ssl")>
  <cfset hhmmssdc = Replace(hhmmssdc,':','',"All")>
  <cfset hhmmssdc = Replace(hhmmssdc,'.','',"All")>	
   <cfquery datasource="#dsn_inspecao#">
   INSERT Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_Orgao_Solucao, And_HrPosic, and_Parecer)
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
  #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
   ,
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
	     <!--- Tratamento da �rea solucionadora--->
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
  '#hhmmssdc#'
  ,
   <cfif IsDefined("FORM.observacao") AND FORM.observacao NEQ "">
      <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & Trim(Encaminhamento) & '  ' & '-' & '  ' & #aux_obs# & CHR(13) & CHR(13) & 'Respons�vel: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_Lotacao) & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
 '#and_obs#'
  <cfelse>
   NULL
  </cfif>
  )
 </cfquery>          
  WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
</cfif>

  <cflocation url="itens_controle_respostas_corporativo.cfm?#CGI.QUERY_STRING#">
</cfif>

<cfquery name="qArea" datasource="#dsn_inspecao#">
SELECT DISTINCT Ars_CodGerencia, Ars_Sigla
FROM Areas WHERE Ars_Status = 'A'
ORDER BY Ars_Sigla
</cfquery>

<script type="text/javascript">
//permite digita�ao apenas de valores num�ricos
function numericos() {
var tecla = window.event.keyCode;
//permite digita��o das teclas num�ricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)
//if ((tecla != 8) && (tecla != 9) && (tecla != 27) && (tecla != 46)) {
	
	if ((tecla != 46) && ((tecla < 48) || (tecla > 57))) {
		//alert(tecla);
	//  if () {
		event.returnValue = false;
	 // }
	}
//}
}
function troca(b,c){ 
 document.formx.dtinic.value=b;
 document.formx.dtfinal.value=c;
 document.formx.submit();
}
</script>
<script>
function Trim(str)
{
while (str.charAt(0) == ' ')
str = str.substr(1,str.length -1);

while (str.charAt(str.length-1) == ' ')
str = str.substr(0,str.length-1);

return str;
} 

//Valida��o de campos vazios em formul�rio
/*function valida_form(form) {
 var frm = document.forms[form];
 var quant = frm.elements.length;
 for (var i=0; i<quant; i++) {
   var elemento = document.forms[form].elements[i];
   if (elemento.getAttribute('vazio') == 'false') {
	 if (Trim(elemento.value) == '') {
	   var nome = elemento.getAttribute('nome');
	   alert('Informe o campo ' + nome + '!');
	   elemento.focus();
	   return false;
	   break;
	 }
   }
 }
}
*/
//Fun��o que abre uma p�gina em Popup
function popupPage(){
<cfoutput>  //p�gina chamada, seguida dos par�metros n�mero, unidade, grupo e item
var page = "itens_unidades_controle_respostas_comentarios.cfm?numero=#ninsp#&unidade=#unid#&numgrupo=#ngrup#&numitem=#nitem#";
</cfoutput>
windowprops = "location=no,"
+ "scrollbars=yes,width=750,height=500,top=100,left=200,menubars=no,toolbars=no,resizable=yes";
window.open(page, "Popup", windowprops);
}
</script>
<html>
<head>
<script>
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
	
//================
function Mascara_Data(data)
{
	switch (data.value.length)
	{
		case 2:
		   if (data.value < 1 || data.value > 31) {
		      alert('Valor para o dia inv�lido!');
			  data.value = '';
		      event.returnValue = false;
			  break;
		    } else {
			  data.value += "/";
				break;
			}
		case 5:
			if (data.value.substring(3,5) < 1 || data.value.substring(3,5) > 12) {
		      alert('Valor para o M�s inv�lido!');
			  data.value = '';
		      event.returnValue = false;
			  break;
		    } else {
			  data.value += "/";
				break;
			}
	}
}
//=============================
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
  if (dat==8 || dat==9){   
    window.dData.style.visibility = 'visible';
  } else {
    window.dData.style.visibility = 'hidden';
	document.form1.cbData.value = '';
  }
}
</script>

<script> 
function validaForm(){
 if (document.form1.frmResp[5].checked){
    if(document.form1.cbData.value == ''){
      alert('Sr. Analista, informe a �rea e a Data de previs�o para a solu��o da Situa��o Encontrada!');
	  return false;
	}  
  }  
  if ((document.form1.frmResp[4].checked) || (document.form1.frmResp[5].checked) || (document.form1.frmResp[6].checked)){
    if(document.form1.cbArea.value == ''){
       alert('Sr. Analista, informe a �rea para encaminhamento!');
	   return false;
	}  
  }
  if (document.form1.frmResp[1].checked){    
	 if ((document.form1.cbunid[0].checked=='') && (document.form1.cbunid[1].checked=='') && (document.form1.cbOrgao.value=='')){ 
      alert('Sr. Analista, informe o �rg�o solucionador da Situa��o Encontrada!');
	  return false;
	 }   
  } 
  if (document.form1.frmResp[0].checked){    
	 if ((document.form1.frmResp[2].checked==0) && (document.form1.frmResp[3].checked==0) && (document.form1.frmResp[4].checked==0) && (document.form1.frmResp[5].checked==0) && (document.form1.frmResp[6].checked==0)){ 
      alert('Sr. Analista, Escolha o �rg�o Pendente!');
	  return false;
	 }   
  }    
    
</script>

<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body onLoad="exibirArea(0); exibirData(0);exibirOrgao(0);">
<cfinclude template="cabecalho.cfm">
<table width="85%" height="30%">
<tr>
 <td width="86%" valign="top">
<!--- �rea de conte�do   --->
<form name="form1" method="post" onSubmit="return valida_form(this.value)" action="<cfoutput>#CurrentPage#?#CGI.QUERY_STRING#</cfoutput>">  
  <table width="76%" height="800" align="center">
    <tr>
      <td colspan="5"><p align="center" class="titulo1">&nbsp;</p>
        <p align="center" class="titulo1">Ponto Corporativo </p>
        <p>            
            <input name="unid" type="hidden" id="unid" value="<cfoutput>#URL.Unid#</cfoutput>">
            <input name="ninsp" type="hidden" id="ninsp" value="<cfoutput>#URL.Ninsp#</cfoutput>">
            <input name="ngrup" type="hidden" id="ngrup" value="<cfoutput>#URL.Ngrup#</cfoutput>">
            <input name="nitem" type="hidden" id="nitem" value="<cfoutput>#URL.Nitem#</cfoutput>">
            <input name="dtinicio" type="hidden" id="dtinicio" value="<cfoutput>#URL.DtInic#</cfoutput>">
			<input name="dtfinal" type="hidden" id="dtfinal" value="<cfoutput>#URL.dtfim#</cfoutput>"> 
			<input name="reop" type="hidden" id="reop" value="<cfoutput>#URL.reop#</cfoutput>">			
</p>  </td>
    </tr>
    <tr bgcolor="#FFFFFF" class="exibir">
      <td colspan="7">&nbsp;</td>
      </tr>
    <tr class="exibir">
      <td width="97" bgcolor="eeeeee">Unidade</td>
      <td colspan="2" bgcolor="f7f7f7"><cfoutput><strong>#rsMOd.Und_Descricao#</strong></cfoutput></td>
      <td width="71" bgcolor="f7f7f7"><cfoutput>Respons&aacute;vel</cfoutput></td>
      <td width="383" colspan="3" bgcolor="f7f7f7"><cfoutput><strong>#qResponsavel.INP_Responsavel#</strong></cfoutput></td>
      </tr>
	<tr class="exibir">      
	 <td bgcolor="eeeeee">Analista(as)</td>
	 <cfif qInspetor.RecordCount neq 0>
	 <td colspan="6" bgcolor="f7f7f7"><cfoutput query="qInspetor"><strong>#Fun_Nome#<br></strong></cfoutput>	  
	 <cfelse>
	   -	
	 </td>	 
	 </cfif>
	  <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
    </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">Auditoria </td>
	  <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
      <td colspan="6" bgcolor="f7f7f7"><cfoutput><strong>#Num_Insp#</strong></cfoutput></td>
      </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">Objetivo </td>
      <td width="74" bgcolor="f7f7f7"><cfoutput>#URL.Ngrup#</cfoutput></td>
      <td colspan="5" bgcolor="f7f7f7"><cfoutput><strong>#URL.DGrup#</strong></cfoutput></td>
      </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee"> Item </td>
      <td bgcolor="f7f7f7"><cfoutput>#URL.Nitem#</cfoutput></td>
      <td width="75" bgcolor="f7f7f7"><cfoutput><strong>#URL.Desc#</strong></cfoutput></td>
      <td colspan="4" bgcolor="f7f7f7"><cfoutput></cfoutput></td>
    </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">&nbsp;</td>
      <td colspan="2" bgcolor="f7f7f7">&nbsp;</td>
      <td colspan="4" bgcolor="f7f7f7">&nbsp;</td>
    </tr>
    <tr class="exibir">
      <td colspan="7" bgcolor="eeeeee">A situa&ccedil;&atilde;o do item foi regularizada por definitivo ? &nbsp;&nbsp;
        <label><span class="style4">
        <input name="frmResp" type="radio" value="1"  onClick="exibirArea(this.value);exibirData(this.value);exibirOrgao(this.value)" checked>
N&atilde;o</span></label>
        <strong>
        <label> <strong><strong><strong>
        <input type="radio" name="frmResp" value="3" onClick="exibirArea(this.value);exibirData(this.value);exibirOrgao(this.value)">
        </strong></strong></strong>Sim</label>
        </strong></td>
      </tr>
    <tr class="exibir">
      <td colspan="7" bgcolor="eeeeee">A situa&ccedil;&atilde;o est&aacute; pendente da ? <span class="style4">
      <input name="frmResp" type="radio" value="2" onClick="exibirArea(this.value);exibirData(this.value);exibirOrgao(this.value)">
Unidade</span>&nbsp;&nbsp;
<label><span class="style4"> </span></label>
<strong>
<label>
<input type="radio" name="frmResp" value="4" onClick="exibirArea(this.value);exibirData(this.value);exibirOrgao(this.value)">
</label>
</strong>
<label>&Oacute;rg&atilde;o Subordinador</label>
<strong><strong>
<label>
<input type="radio" name="frmResp" value="5" onClick="exibirArea(this.value);exibirData(this.value);exibirOrgao(this.value)">
</label>
</strong></strong>
<label>&Aacute;rea </label>
<strong><strong>
<input type="radio" name="frmResp" value="8" onClick="exibirArea(this.value);exibirData(this.value);exibirOrgao(this.value)">
</strong></strong>Corporativo DR <strong><strong>
<input type="radio" name="frmResp" value="9" onClick="exibirArea(this.value);exibirData(this.value);exibirOrgao(this.value)">
</strong></strong>Corporativo AC<strong></strong></td>
      </tr>
    <tr class="exibir">
      <td colspan="3" valign="top" bgcolor="f7f7f7"><div id="dArea"> Selecione a &aacute;rea:
          <select name="cbArea" class="form">
            <option selected="selected" value="">---</option>
            <cfoutput query="qArea">
              <option value="#Ars_CodGerencia#">#Ars_Sigla#</option>
            </cfoutput>
          </select>                        
      </div></td>
      <td colspan="4" valign="top" bgcolor="f7f7f7"><div id=dData> Data de Previs&atilde;o da Solu&ccedil;&atilde;o:
              <input name="cbData" class="form" type="text" size="12"  onKeyPress="numericos()"  onKeyDown="Mascara_Data(this)" value="#dateformat(now(),"dd/mm/yyyy")#">
      </div></td>
      </tr>
    <tr class="exibir">	 
      <td colspan="7" bgcolor="eeeeee"><div id="dOrgao">Solucionado pela: &nbsp;&nbsp;<span class="style4">&Aacute;rea &nbsp;</span>
        <select name="cbOrgao" class="form"  onChange="desabilita_campos_area()">
          <option selected="selected" value="">---</option>
          <cfoutput query="qArea">
            <option value="#Ars_CodGerencia#">#Ars_Sigla#</option>
          </cfoutput>
        </select>
        <span class="style4"></span><span class="style4"> &nbsp;&nbsp;
         <input name="cbunid" type="checkbox" onClick="desabilita_campos_unidade()" class="form" size="8" value="<cfoutput>#rsMod.Und_Codigo#</cfoutput>">
Unidade &nbsp;&nbsp;&nbsp;
<label> </label>
<strong>
<label>
     <input type="checkbox" onClick="desabilita_campos_subordinador()" class="form" name="cbunid" size="8" value="<cfoutput>#rsMOd.Und_CodReop#</cfoutput>">
</label>
</strong>
<label>&Oacute;rg&atilde;o Subordinador</label>
       </span></div></td>
      </tr>
    <tr class="exibir">
      <td colspan="4" bgcolor="f7f7f7"><div align="center">
       <!--- <input name="comentarios" type="button" class="botao" onClick="window.open('itens_unidades_controle_respostas_comentarios.cfm?numero=<cfoutput>#URL.ninsp#</cfoutput>&unidade=<cfoutput>#URL.unid#</cfoutput>&numgrupo=<cfoutput>#URL.ngrup#</cfoutput>&numitem=<cfoutput>#URL.nitem#</cfoutput>','','scrollbars=yes, resizable=yes, width=600, height=460, left=120, top=100')" value="Situa��o Encontrada">
      </div>---></td>
      <td colspan="4" bgcolor="f7f7f7">&nbsp;</td>
      </tr>
	 <!--- <input type="hidden" name="frmResp" value="5">--->
	 <!--- <input type="hidden" name="obs" value="<cfoutput>#qResposta.Pos_Parecer#</cfoutput>"> --->
     <tr>
       <td height="130" valign="middle" bgcolor="eeeeee" class="exibir"><span class="titulos">Situa��o Encontrada:</span></td>
       <td colspan="4" bgcolor="f7f7f7"><textarea name="Melhoria" cols="120" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#rsItem.RIP_Comentario#</cfoutput></textarea>
       </td>
     </tr>
     <tr>
      <td bgcolor="eeeeee"><span class="titulos">Hist&oacute;rico: Manifesta&ccedil;&atilde;o da &Aacute;rea/An&aacute;lise da Auditoria:</span></td>
      <td colspan="4" bgcolor="f7f7f7">
	  <cfif Not IsDefined("FORM.MM_UpdateRecord") And Trim(qResposta.Pos_Parecer) neq ''>
	    <textarea name="H_obs" cols="120" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#qResposta.Pos_Parecer#</cfoutput></textarea>
	  </cfif>
	  </td>
    </tr>
     <tr>
       <td height="150" bgcolor="eeeeee"><span class="titulos">Recomenda&ccedil;&otilde;es:</span></td>
       <td colspan="4"><textarea name="H_recom" cols="120" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#rsItem.RIP_Recomendacoes#</cfoutput></textarea></td>
     </tr>
     <tr>
       <td height="80" bgcolor="eeeeee"><span class="titulos">Manifestar-se:</span></td>
       <td colspan="4"><textarea name="observacao" cols="120" rows="6" nome="Observa��o" vazio="false" wrap="VIRTUAL" class="form" id="observacao"></textarea></td>
     </tr>
     <tr>
	 <td bgcolor="#eeeeee" class="exibir"><div align="left"><strong>ANEXOS</strong></div></td>
	 
	 <td colspan="4" bgcolor="f7f7f7" class="exibir"><cfoutput>	  
	     <div align="right">
	      <!--- <input type="button" value="Anexar arquivos" class="botao" onClick="window.open('itens_corporativo_transmitir_anexo.cfm?ninsp=#URL.Ninsp#&unid=#URL.Unid#&ngrup=#URL.Ngrup#&nitem=#URL.Nitem#&reop=#url.reop#','_self')">--->	     
	       </div>
	 </cfoutput></td>	  
     </tr>		  
	   <cfloop query="qAnexos">
        <cfif FileExists(qAnexos.Ane_Caminho)>
        <tr>
        <td colspan="4" bgcolor="eeeeee">				
		  <a target="_blank" href="<cfoutput>#qAnexos.Ane_Caminho#</cfoutput>"><span class="link1"><cfoutput>#ListLast(qAnexos.Ane_Caminho,'\')#</cfoutput></span></a></td>
		  <td colspan="6" bgcolor="eeeeee">
			  <!--- <input type="button" class="botao" value="Excluir" onClick="window.open('excluir_usuario_anexo.cfm?ninsp=#URL.Ninsp#&unid=#URL.Unid#&ngrup=#URL.Ngrup#&nitem=#URL.Nitem#&Ane_codigo=#qAnexos.Ane_Codigo#&area=#url.area#','_self')"> --->
	    </td>			 		     
	    </tr>
	    </cfif>
	  </cfloop>		  
        <tr>
          <td colspan="4">&nbsp;</td>
        </tr>	 
    <tr>
      <td colspan="4">
        <div align="right">
          <input name="Cancelar" type="button" class="botao" value="Cancelar" onClick="history.back()">
        </div></td>
      <td colspan="3">             
                  <div align="left"></div>
              <cfif Trim(qResposta.Pos_Situacao_Resp) gte 8>
            <input name="Submit" type="submit" class="botao" value="Confirmar" onClick="troca(dtinic.value,dtfinal.value);">    	  	      	  
              </cfif>
       </td>
      </tr>
  </table>
  <input type="hidden" name="MM_UpdateRecord" value="form1">  
  <input type="hidden" name="scodresp" id="scodresp" value="<cfoutput>#qResposta.Pos_Situacao_Resp#</cfoutput>">
</form>

<!--- Fim �rea de conte�do --->
	  </td>
  </tr>
</table>
<form name="formx"  method="post" action="itens_controle_respostas_corporativo.cfm">  
  <input name="dtinic" type="hidden" id="#form.dtinic#">
  <input name="dtfinal" type="hidden" id="#form.dtfinal#">
</form>
</body>
</html>
