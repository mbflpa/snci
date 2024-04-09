<cfprocessingdirective pageEncoding ="utf-8"/> 
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif>

<!--- Nova consulta para verificar respostas das unidades --->
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
	 , Pos_Sit_Resp_Antes = #qSituacaoResp.Pos_Situacao_Resp#
      <cfelse>
      NULL
  </cfif> 
  
  <cfswitch expression="#Form.frmResp#">
    <cfcase value="0"> <cfset Encaminhamento = ''> 
	  , Pos_Situacao = 'PE' 
	</cfcase>
	<cfcase value="2"> <cfset Encaminhamento = 'A(O) ' & Form.hUnidade>
	  , Pos_Situacao = 'PE' 
	</cfcase>
	<cfcase value="3"> <cfset Encaminhamento = ''>
	  , Pos_Situacao = 'SO'	  
	</cfcase>
	<cfcase value="8"> <cfset Encaminhamento = ''>
	  , Pos_Situacao = 'CR'
	</cfcase>
	<cfcase value="9"> <cfset Encaminhamento = ''>
	  , Pos_Situacao = 'CA'
	</cfcase>
	<cfcase value="4">
	<cfquery name="qReop" datasource="#dsn_inspecao#">
		SELECT Rep_Nome
		FROM Reops
		WHERE Rep_Codigo = '#form.reop#'
	</cfquery>
	<cfset Encaminhamento = 'A(O) ' & qReop.Rep_Nome>
	  , Pos_Situacao = 'AN'
	</cfcase>
	<cfcase value="5"> 
	<cfquery name="qArea2" datasource="#dsn_inspecao#">
		SELECT Ars_Sigla
		FROM Areas
		WHERE Ars_CodGerencia = '#Form.cbArea#'
	</cfquery>
	<cfset Encaminhamento = '�(O) ' & qArea2.Ars_Sigla>
	  , Pos_Situacao = 'AN'
	</cfcase>
	<cfdefaultcase> <cfset Encaminhamento = ''>
	  , Pos_Situacao = 'AN'
	</cfdefaultcase>
  </cfswitch> 
  <cfif IsDefined("FORM.observacao") AND FORM.observacao NEQ "">
  , Pos_Parecer=
         <cfset aux_obs = Form.H_obs & CHR(13) & CHR(13) & Trim(Encaminhamento) & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & Trim(FORM.observacao) & CHR(13) & 'Respons�vel: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_Lotacao) & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
	     <cfset aux_obs = Replace(aux_obs,'"','','All')>
	     <cfset aux_obs = Replace(aux_obs,"'","","All")>
		 <cfset aux_obs = Replace(aux_obs,'*','','All')>
		  <!--- <cfset aux_obs = Replace(aux_obs,'&','','All')>
		  <cfset aux_obs = Replace(aux_obs,'%','','All')> --->		
	'#aux_obs#'
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
    , Pos_Relevancia=
   <cfif IsDefined("FORM.relevancia") AND FORM.relevancia NEQ "">
    '#FORM.relevancia#'
      <cfelse>
	  NULL     	   
    </cfif> 
    , Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
	, Pos_username = '#CGI.REMOTE_USER#'
	, Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
      WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
  </cfquery>  
 
  

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
   INSERT Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_Orgao_Solucao, And_HrPosic, And_Parecer)
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
     <cfset and_obs = trim(Encaminhamento) & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & Trim(FORM.observacao) & CHR(13) & 'Respons�vel: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_Lotacao) & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
	      <cfset and_obs = Replace(and_obs,'"','','All')>
		  <cfset and_obs = Replace(and_obs,"'","","All")>
		  <cfset and_obs = Replace(and_obs,'*','','All')>
		  <!--- <cfset and_obs = Replace(and_obs,'&','','All')>
		  <cfset and_obs = Replace(and_obs,'%','','All')> --->
	'#and_obs#'
  <cfelse>
   NULL
  </cfif>
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
        UPDATE ProcessoParecerUnidade SET Pro_Situacao = 'EN', Pro_DtEncerr = GETDATE()
        WHERE Pro_Unidade='#FORM.unid#' AND Pro_Inspecao='#FORM.ninsp#'
      </cfquery>
    </cfif>
  </cfif>  
 
  <cfif form.sacao eq "alt">     
     <cfquery datasource="#dsn_inspecao#">
      update Analise SET Ana_Col01='#FORM.cb01#', Ana_Col02='#FORM.cb02#', Ana_Col03='#FORM.cb03#', Ana_Col04='#FORM.cb04#', Ana_Col05='#FORM.cb05#', Ana_Col06='#FORM.cb06#', Ana_Col07='#FORM.cb07#', Ana_Col08='#FORM.cb08#', Ana_Col09='#FORM.cb09#' where (Ana_NumInspecao='#FORM.ninsp#' and Ana_Unidade='#FORM.unid#') and (Ana_NumGrupo=#FORM.ngrup# and Ana_NumItem=#FORM.nitem#)
     </cfquery>
<!---  <cfelse>
    <cfquery datasource="#dsn_inspecao#">
      insert into Analise (Ana_NumInspecao, Ana_Unidade, Ana_NumGrupo, Ana_NumItem, Ana_Col01, Ana_Col02, Ana_Col03, Ana_Col04, Ana_Col05, Ana_Col06, Ana_Col07, Ana_Col08, Ana_Col09) values ('#FORM.ninsp#', '#FORM.unid#', #FORM.ngrup#, #FORM.nitem#, '#FORM.cb01#', '#FORM.cb02#', '#FORM.cb03#', '#FORM.cb04#', '#FORM.cb05#', '#FORM.cb06#', '#FORM.cb07#', '#FORM.cb08#', '#FORM.cb09#')
   	</cfquery> --->
  </cfif> 
  <cfif ckTipo eq "inspecao">
    <cflocation url="itens_controle_respostas.cfm?txtNum_Inspecao=#FORM.ninsp#&ckTipo=inspecao">
  <cfelse>
    <cflocation url="itens_controle_respostas.cfm?Dtinic=#form.dtinicio#&dtfim=#form.dtfinal#&ckTipo=#ckTipo#">
  </cfif>
</cfif>
    
<!--- Nova consulta para verificar respostas das unidades --->
<cfquery name="qResposta" datasource="#dsn_inspecao#">
SELECT Pos_Situacao_Resp, Pos_Parecer, Pos_Relevancia
FROM ParecerUnidade
WHERE Pos_Unidade='#URL.unid#' AND Pos_Inspecao='#URL.ninsp#' AND Pos_NumGrupo=#URL.ngrup# AND Pos_NumItem=#URL.nitem#
</cfquery>

<cfquery name="qInspetor" datasource="#dsn_inspecao#">
SELECT     Inspetor_Inspecao.IPT_MatricInspetor, Funcionarios.Fun_Nome
FROM         Inspetor_Inspecao INNER JOIN
                      Funcionarios ON Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric AND 
                      Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric
WHERE     IPT_NumInspecao = '#URL.Ninsp#'
</cfquery>

<cfquery name="rsMod" datasource="#dsn_inspecao#">
SELECT Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria
FROM Unidades
WHERE Und_Codigo = '#URL.Unid#' 
</cfquery>

<cfquery name="qArea" datasource="#dsn_inspecao#">
SELECT DISTINCT Ars_CodGerencia, Ars_Sigla
FROM Areas
ORDER BY Ars_Sigla
</cfquery>

<cfquery name="qData" datasource="#dsn_inspecao#">
<!--- UPDATE ParecerUnidade SET Pos_Situacao_Resp = '5', Pos_Situacao = 'AN', Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
WHERE Pos_Situacao_Resp = '8' 
AND Pos_DtPrev_Solucao <= GETDATE() --->
</cfquery>
<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspe��es</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script>
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
  if (dat==8){
    window.dData.style.visibility = 'visible';
  } else {
    window.dData.style.visibility = 'hidden';
	document.form1.cbData.value = '';
  }
}
function validaForm(){
 if (document.form1.frmResp[5].checked){
    if(document.form1.cbData.value == ''){
      alert('Sr. Inspetor(a), informe a �rea e a Data de previs�o para a solu��o da n�o-conformidade!');
	  return false;
	}  
  } 
  if ((document.form1.frmResp[4].checked) || (document.form1.frmResp[5].checked) || (document.form1.frmResp[6].checked)){
    if(document.form1.cbArea.value == ''){
       alert('Sr. Inspetor(a), informe a �rea para encaminhamento!');
	   return false;
	}  
  }
  if (document.form1.frmResp[1].checked){    
	 if ((document.form1.cbunid[0].checked=='') && (document.form1.cbunid[1].checked=='') && (document.form1.cbOrgao.value=='')){ 
      alert('Sr. Inspetor(a), informe o �rg�o solucionador da n�o-conformidade!');
	  return false;
	 }   
  } 
   
 /* if (document.form1.observacao.value == ''){
     alert('Sr. Inspetor(a), informe o seu parecer sobre a resposta da unidade!');
	 return false;
  }*/
  if (document.form1.tipoUrg.value == ''){
     alert('Sr. Inspetor(a), falta informar An�lise do Impacto da n�o Conformidade!');
	return false;
  }
  return true;
}
function mostra(a,b,c)
{
 if (b == true)
 {
   if (c == 'cbox01'){document.form1.cb01.value = 1}
   if (c == 'cbox02'){document.form1.cb02.value = 1}
   if (c == 'cbox03'){document.form1.cb03.value = 1}
   if (c == 'cbox04'){document.form1.cb04.value = 1}
   if (c == 'cbox05'){document.form1.cb05.value = 1}
   if (c == 'cbox06'){document.form1.cb06.value = 1}
   if (c == 'cbox07'){document.form1.cb07.value = 1}
   if (c == 'cbox08'){document.form1.cb08.value = 1}
   if (c == 'cbox09'){document.form1.cb09.value = 1}
  //alert('valor do hidden cb01: '+document.form1.cb01.value); 
  document.form1.frmsoma.value = parseInt(document.form1.frmsoma.value) + parseInt(a);
 if (parseInt(document.form1.frmsoma.value) == 0) 
  {
	 document.form1.frmurgencia.value = 0;
	 document.form1.tipoUrg.value=''
  }
  if (parseInt(document.form1.frmsoma.value) > 0 && parseInt(document.form1.frmsoma.value) <= 15) 
  {
	 document.form1.frmurgencia.value = 1;
	 document.form1.tipoUrg.value='Baixo'
  }
  if (parseInt(document.form1.frmsoma.value) > 15 && parseInt(document.form1.frmsoma.value) <= 31)
  {
     document.form1.frmurgencia.value = 2;
	 document.form1.tipoUrg.value='M�dio'
  }
  if (parseInt(document.form1.frmsoma.value) > 31 && parseInt(document.form1.frmsoma.value) <= 46)
  {
     document.form1.frmurgencia.value = 3;
	 document.form1.tipoUrg.value='Alto'
  }
  if (parseInt(document.form1.frmsoma.value) > 46)
  {
     document.form1.frmurgencia.value = 4;
	 document.form1.tipoUrg.value='Muito Alto'
  }
  document.form1.frmprioridade.value = parseInt(document.form1.frmsoma.value) * parseInt(document.form1.frmurgencia.value)
 } 
 else 
 { 
   if (c == 'cbox01'){document.form1.cb01.value = 0}
   if (c == 'cbox02'){document.form1.cb02.value = 0}
   if (c == 'cbox03'){document.form1.cb03.value = 0}
   if (c == 'cbox04'){document.form1.cb04.value = 0}
   if (c == 'cbox05'){document.form1.cb05.value = 0}
   if (c == 'cbox06'){document.form1.cb06.value = 0}
   if (c == 'cbox07'){document.form1.cb07.value = 0}
   if (c == 'cbox08'){document.form1.cb08.value = 0}
   if (c == 'cbox09'){document.form1.cb09.value = 0}
  document.form1.frmsoma.value = parseInt(document.form1.frmsoma.value) - parseInt(a);
 if (parseInt(document.form1.frmsoma.value) == 0) 
  {
	 document.form1.frmurgencia.value = 0;
	 document.form1.tipoUrg.value=''
  }
  if (parseInt(document.form1.frmsoma.value) > 0 && parseInt(document.form1.frmsoma.value) <= 15) 
  {
	 document.form1.frmurgencia.value = 1;
	 document.form1.tipoUrg.value='Baixo'
  }
  if (parseInt(document.form1.frmsoma.value) > 15 && parseInt(document.form1.frmsoma.value) <= 31)
  {
     document.form1.frmurgencia.value = 2;
	 document.form1.tipoUrg.value='M�dio'
  }
  if (parseInt(document.form1.frmsoma.value) > 31 && parseInt(document.form1.frmsoma.value) <= 46)
  {
     document.form1.frmurgencia.value = 3;
	 document.form1.tipoUrg.value='Alto'
  }
  if (parseInt(document.form1.frmsoma.value) > 46)
  {
     document.form1.frmurgencia.value = 4;
	 document.form1.tipoUrg.value='Muito Alto'
  }
 document.form1.frmprioridade.value = parseInt(document.form1.frmsoma.value) * parseInt(document.form1.frmurgencia.value)
}
}
//Fun��o que abre uma p�gina em Popup
function popupPage() {
<cfoutput>  //p�gina chamada, seguida dos par�metros n�mero, unidade, grupo e item
var page = "itens_controle_respostas_comentarios.cfm?numero=#ninsp#&unidade=#unid#&numgrupo=#ngrup#&numitem=#nitem#";
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
<body onLoad="exibirArea(0);atribuir();popupPage();exibirOrgao(0);exibirData(0)">

<cfinclude template="cabecalho.cfm">
<!--- Buscando dados da Gravidade --->
<cfquery name="qGrav" datasource="#dsn_inspecao#">
SELECT Ana_Col01, Ana_Col02, Ana_Col03, Ana_Col04, Ana_Col05, Ana_Col06, Ana_Col07, Ana_Col08, Ana_Col09  FROM Analise WHERE Ana_NumInspecao='#URL.Ninsp#' AND Ana_Unidade='#URL.Unid#' AND Ana_NumGrupo=#URL.Ngrup# AND Ana_NumItem=#URL.Nitem#
</cfquery>

<table width="800" height="450">
<tr>
<td valign="top" width="26%" class="link1"> 
<table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr align="left" valign="top">
        <td width="95%" height="4" background="../../menu/fundo.gif">
		   
        </td>
      </tr>
</table>
      <table width="93%" border="0" cellpadding="0" cellspacing="0">
        <tr align="left" valign="top">
          <td width="5%" height="10">&nbsp; </td>
          <td width="95%" height="4" background="../../menu/fundo.gif"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="#" class="titulos"></a><cfinclude template="menu_sins.cfm"></font></strong></td>
        </tr>
      </table>
    </td>
	  <td valign="top">
<!--- �rea de conte�do   --->
<!--- <form name="form1" method="post" onSubmit="return validaForm()" action="<cfoutput>#CurrentPage#?#CGI.QUERY_STRING#</cfoutput>"> --->
<form name="form1" method="post" onSubmit="return validaForm()" action="itens_controle_respostas_solucionados.cfm"> 
  <table width="100%" align="center">
    <tr>
      <td colspan="5"><p class="titulo1">Relat&Oacute;rio de Inspe&Ccedil;&Atilde;o </p>
        <p>
          <input name="unid" type="hidden" id="unid" value="<cfoutput>#URL.Unid#</cfoutput>">
          <input name="ninsp" type="hidden" id="ninsp" value="<cfoutput>#URL.Ninsp#</cfoutput>">
         <input name="ngrup" type="hidden" id="ngrup" value="<cfoutput>#URL.Ngrup#</cfoutput>">
         <input name="nitem" type="hidden" id="nitem" value="<cfoutput>#URL.Nitem#</cfoutput>">
         <input name="dtinicio" type="hidden" id="dtinicio" value="<cfoutput>#URL.DtInic#</cfoutput>">
         <input name="dtfinal" type="hidden" id="dtfinal" value="<cfoutput>#URL.dtfim#</cfoutput>"> 
		  input name="cktipo" type="hidden" id="cktipo" value="<cfoutput>#ckTipo#</cfoutput>"
		 <input name="reop" type="hidden" id="reop" value="<cfoutput>#URL.reop#</cfoutput>">
        </p>	</td>
   </tr>
   <tr><td colspan="5">&nbsp;</td></tr>
	<tr bgcolor="#FFFFFF" class="exibir">
      <td>&nbsp;</td>
	  <td>
      <td><input name="comentarios" type="button" class="botao" onClick="window.open('itens_controle_respostas_comentarios.cfm?numero=<cfoutput>#URL.ninsp#</cfoutput>&unidade=<cfoutput>#URL.unid#</cfoutput>&numgrupo=<cfoutput>#URL.ngrup#</cfoutput>&numitem=<cfoutput>#URL.nitem#</cfoutput>','','scrollbars=yes, resizable=yes, width=800, height=560, left=300, top=250')" value="N&atilde;o-Conformidade"></td> 
      <td></td>
      <td>&nbsp;</td>
    </tr>
	<tr><td colspan="5">&nbsp;</td></tr>
    <tr class="exibir">
      <td width="84" bgcolor="eeeeee">Unidade      </td>
      <td width="241" bgcolor="f7f7f7"><cfoutput>#URL.Unid#</cfoutput><input type="hidden" name="hUnidade" value="<cfoutput>#rsMOd.Und_Descricao#</cfoutput>"></td>
      <td width="143" bgcolor="f7f7f7"><cfoutput><strong>#rsMOd.Und_Descricao#</strong></cfoutput></td>
      <td width="74" bgcolor="eeeeee">�rg�o Subordinador</td>
      <td width="151" bgcolor="f7f7f7"><cfoutput>#URL.reop#</cfoutput><input type="hidden" name="hReop" value="<cfoutput>#URL.reop#</cfoutput>"></td>	  
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
      <td bgcolor="eeeeee">N&ordm; Relat&oacute;rio </td>
      <td colspan="4" bgcolor="f7f7f7"><cfoutput>#URL.Ninsp#</cfoutput></td>
    </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">N&ordm; Grupo </td>
      <td bgcolor="f7f7f7"><cfoutput>#URL.Ngrup#</cfoutput></td>	  
      <td colspan="3" bgcolor="f7f7f7"><cfoutput><strong>#URL.DGrup#</strong></cfoutput></td>
    </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">N&ordm; Item </td>
      <td bgcolor="f7f7f7"><cfoutput>#URL.Nitem#</cfoutput></td>
      <td colspan="3" bgcolor="f7f7f7"><cfoutput><strong>#URL.Desc#</strong></cfoutput></td>
    </tr>
    <tr bgcolor="f7f7f7">
      <td height="22" colspan="5" valign="top" class="exibir"><table width="709" border="1">
    <tr bgcolor="f7f7f7">
            <td height="4" colspan="4" valign="top" class="exibir"><div align="center"><strong>An&aacute;lise do Impacto de N&atilde;o-conformidade</strong>                
              <input name="cb01" type="hidden" id="cb01" value="0">
              <input name="cb02" type="hidden" id="cb02" value="0">
              <input name="cb03" type="hidden" id="cb03" value="0">
              <input name="cb04" type="hidden" id="cb04" value="0">
              <input name="cb05" type="hidden" id="cb05" value="0">
              <input name="cb06" type="hidden" id="cb06" value="0">
              <input name="cb07" type="hidden" id="cb07" value="0">
              <input name="cb08" type="hidden" id="cb08" value="0">
              <input name="cb09" type="hidden" id="cb09" value="0">          
              <input name="sacao" type="hidden" id="sacao" value="inc">
           </div></td>
        </tr>
        <tr bgcolor="f7f7f7">
          <td height="1" valign="top" class="exibir"><div align="center"><strong>Efeitos n&atilde;o desejados </strong></div></td>
          <td width="93" height="1" valign="top" class="exibir"><div align="center"><strong>Pontua&ccedil;&atilde;o</strong></div></td>
          <td width="300" height="1" valign="top" class="exibir"><div align="left"><strong> Consequ&ecirc;ncias identificadas </strong></div></td>
		  <td height="1" valign="top" class="exibir"><div align="left"><strong> Ajuda </strong></div></td>
        </tr>
        <tr bgcolor="f7f7f7">
          <td height="1" valign="top" class="exibir">N&atilde;o Presta&ccedil;&atilde;o do Servi&ccedil;o </td>
          <td height="1" valign="middle" class="exibir"><div align="center">10</div></td>
          <td height="1" valign="top" class="exibir"><label>
            <input name="cbox01" type="checkbox" id="cbox01" value="10"  onClick="mostra(this.value, this.checked, this.name)">
          </label></td>
		  <td align="center"><a href="Ajuda/nao_prestacao_de_servico.cfm" target="_blank" class="exibir"><img border="0" src="interro.jpg"></a></td>
        </tr>
        <tr bgcolor="f7f7f7">
          <td height="1" valign="top" class="exibir">N&atilde;o Cumprimento dos Prazos </td>
          <td height="1" valign="middle" class="exibir"><div align="center">05</div></td>
          <td height="1" valign="top" class="exibir">
		  <input name="cbox02" type="checkbox" id="cbox02" value="5" onClick="mostra(this.value, this.checked, this.name)"></td>
		  <td align="center"><a href="Ajuda/nao_cumprimento_dos_prazos.cfm" target="_blank" class="exibir"><img border="0" src="interro.jpg"></a></td>
        </tr>
        <tr bgcolor="f7f7f7">
          <td height="1" valign="top" class="exibir">Perda no Processo Produtivo </td>
          <td height="1" valign="middle" class="exibir"><div align="center">07</div></td>
          <td height="1" valign="top" class="exibir">
		  <input name="cbox03" type="checkbox" id="cbox03" value="7" onClick="mostra(this.value, this.checked, this.name)"></td>
		  <td align="center"><a href="Ajuda/perda_no_processo_produtivo.cfm" target="_blank" class="exibir"><img border="0" src="interro.jpg"></a></td>
        </tr>
        <tr bgcolor="f7f7f7">
          <td height="1" valign="top" class="exibir">Preju&iacute;zo Financeiro &agrave; ECT  </td>
          <td height="1" valign="middle" class="exibir"><div align="center">10</div></td>
          <td height="1" valign="top" class="exibir">
		  <input name="cbox04" type="checkbox" id="cbox04" value="10" onClick="mostra(this.value, this.checked, this.name)"></td>
		  <td align="center"><a href="Ajuda/prejuizo_financeiro_a_ECT.cfm" target="_blank" class="exibir"><img border="0" src="interro.jpg"></a></td>
        </tr>
        <tr bgcolor="f7f7f7">
          <td height="1" valign="top" class="exibir">Descumprimento de Norma Legal(Lei) </td>
          <td height="1" valign="middle" class="exibir"><div align="center">05</div></td>
          <td height="1" valign="top" class="exibir">
		  <input name="cbox05" type="checkbox" id="cbox05" value="5" onClick="mostra(this.value, this.checked, this.name)"></td>
		  <td align="center"><a href="Ajuda/descumprimento_de_lei.cfm" target="_blank" class="exibir"><img border="0" src="interro.jpg"></a></td>
        </tr>
        <tr bgcolor="f7f7f7">
          <td height="1" valign="top" class="exibir">Sobrecarga de Trabalho </td>
          <td height="1" valign="middle" class="exibir"><div align="center">02</div></td>
          <td height="1" valign="top" class="exibir">
		  <input name="cbox06" type="checkbox" id="cbox06" value="2" onClick="mostra(this.value, this.checked, this.name)"></td>
          <td align="center"><a href="Ajuda/sobrecarga_de_trabalho.cfm" target="_blank" class="exibir"><img border="0" src="interro.jpg"></a></td>
		</tr>
        <tr bgcolor="f7f7f7">
          <td height="1" valign="top" class="exibir">Falha no Controle Interno </td>
          <td height="1" valign="middle" class="exibir"><div align="center">07</div></td>
          <td height="1" valign="top" class="exibir">
		  <input name="cbox07" type="checkbox" id="cbox07" value="7" onClick="mostra(this.value, this.checked, this.name)"></td>
		  <td align="center"><a href="Ajuda/falha_no_controle_interno.cfm" target="_blank" class="exibir"><img border="0" src="interro.jpg"></a></td>
        </tr>
		<tr bgcolor="f7f7f7">
          <td height="1" valign="top" class="exibir">Descumprimento de Norma Interna </td>
          <td height="1" valign="middle" class="exibir"><div align="center">05</div></td>
          <td height="1" valign="top" class="exibir">
		  <input name="cbox08" type="checkbox" id="cbox08" value="5" onClick="mostra(this.value, this.checked, this.name)"></td>
		  <td align="center"><a href="Ajuda/descumprimento_de_norma_interna.cfm" target="_blank" class="exibir"><img border="0" src="interro.jpg"></a></td>
        </tr>
        <tr bgcolor="f7f7f7">
          <td height="1" valign="top" class="exibir">Reincid�ncia </td>
          <td height="1" valign="middle" class="exibir"><div align="center">10</div></td>
          <td height="1" valign="top" class="exibir">
		  <input name="cbox09" type="checkbox" id="cbox09" value="10" onClick="mostra(this.value, this.checked, this.name)"></td>
		  <td align="center"><a href="Ajuda/reincidencia.cfm" target="_blank" class="exibir"><img border="0" src="interro.jpg"></a></td>
        </tr>
        <tr bgcolor="f7f7f7">
          <td height="1" valign="top" class="exibir">Somat&oacute;rio</td>
          <td height="1" colspan="3" valign="top" bgcolor="f7f7f7" class="exibir"><input name="frmsoma" type="text" class="form" id="frmsoma" value="0" size="6" maxlength="3" readonly=""></td>
		  </tr>
        <tr bgcolor="f7f7f7">
          <td height="1" valign="top" class="exibir">Tipo Urg&ecirc;ncia </td>
          <td height="1" colspan="3" valign="top" bgcolor="f7f7f7" class="exibir"><label>
            <input name="frmurgencia" type="text" class="form" id="frmurgencia" value="0" size="6" maxlength="3" readonly="">
           
            <input name="tipoUrg" type="text" class="form" id="tipoUrg" size="15" maxlength="10" readonly="">
          </label></td>
		  </tr>
        <tr bgcolor="f7f7f7">
          <td height="1" valign="top" class="exibir">Prioridade</td>
          <td height="1" colspan="3" valign="top" bgcolor="f7f7f7" class="exibir"><input name="frmprioridade" type="text" class="form" id="frmprioridade" size="6" maxlength="4" readonly=""><a href="itens_controle_respostas1.cfm">itens_controle_respostas1</a></td> 
		  </tr>
      </table></td>
    </tr>
  <!--- <tr bgcolor="f7f7f7">
      <td height="22" colspan="4" valign="top" class="exibir">Marque se a n�o-conformidade compromete todo o processo auditado <span class="style4">&nbsp;&nbsp;
        <input name="relevancia" type="checkbox" class="form" size="8" value="1" <cfif qResposta.Pos_Relevancia eq 1> checked </cfif>>
      </span></td>
      <td height="22" align="center" colspan="1" valign="top" class="red_titulo"><cfif qResposta.Pos_Relevancia eq 1>Item compromete o processo!</cfif> </td>
      </tr>
    <tr bgcolor="f7f7f7">
      <td height="22" colspan="4" valign="top" class="exibir">A situa&ccedil;&atilde;o do item foi regularizada por definitivo ? &nbsp;&nbsp;
        <label><span class="style4">
<input name="frmResp" type="radio" value="1"  onClick="exibirArea(this.value);exibirOrgao(this.value);exibirData(this.value)">
N&atilde;o</span></label>
        <strong>
        <label>
<strong><strong><strong>
<input type="radio" name="frmResp" value="3" onClick="exibirArea(this.value);exibirOrgao(this.value);exibirData(this.value)">
</strong></strong></strong>Sim</label>
        </strong></td>--->
		<td height="22" valign="top" class="exibir"><!--- <cfoutput>
		  <input type="button" value="Anexar arquivos" class="botao" onClick="window.open('itens_inspetores_transmitir_anexo.cfm?ninsp=#url.ninsp#&unid=#url.unid#&ngrup=#url.ngrup#&nitem=#url.nitem#&cktipo=#url.cktipo#&dtfim=#url.dtfim#&dtinic=#url.dtinic#&reop=#url.reop#','_self')">
		  </cfoutput> --->
		<!--- </td> 	
    </tr>--->
    <tr bgcolor="f7f7f7">
      <td height="22" colspan="5" valign="top" class="exibir">A situa&ccedil;&atilde;o est&aacute; pendente da ? <span class="style4">
<input name="frmResp" type="radio" value="2" onClick="exibirArea(this.value);exibirOrgao(this.value);exibirData(this.value)">
Unidade</span>&nbsp;&nbsp;
        <label><span class="style4">
</span></label>
        <strong><label><input type="radio" name="frmResp" value="4" onClick="exibirArea(this.value);exibirOrgao(this.value);exibirData(this.value)">
  </label>
</strong>
<label>�rg�o Subordinador</label>
<strong><strong>
<label>
<input type="radio" name="frmResp" value="5" onClick="exibirArea(this.value);exibirOrgao(this.value);exibirData(this.value)">
</label>
</strong></strong>
<label>&Aacute;rea </label><strong><strong>
 <input type="radio" name="frmResp" value="8" onClick="exibirArea(this.value);exibirOrgao(this.value);exibirData(this.value)">
   </strong></strong>Corporativo DR <strong><strong>
 <input type="radio" name="frmResp" value="9" onClick="exibirArea(this.value);exibirOrgao(this.value);exibirData(this.value)">
   </strong></strong>Corporativo AC<strong>   
   </label>
   </strong></td>
      </tr>	  
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
	    <td colspan="3" valign="top" class="exibir">
		  <div id="dData">	
		  Data de Previs&atilde;o da Solu&ccedil;&atilde;o:		 
	      <input name="cbData" class="form" type="text" size="10"  onKeyPress="numericos()"  onKeyDown="Mascara_Data(this)" value="#dateformat(now(),"dd/mm/yyyy")#">
		    </div></td>
	    </tr>
   <tr bgcolor="f7f7f7">
      <td height="22" colspan="5" valign="top" class="exibir">
	     <div id="dOrgao">
	    Solucionado pela: &nbsp;&nbsp;&nbsp; &Aacute;rea	
         <select name="cbOrgao" class="form"  onChange="desabilita_campos_area()">
            <option selected="selected" value="">---</option>
            <cfoutput query="qArea">
              <option value="#Ars_CodGerencia#">#Ars_Sigla#</option>
            </cfoutput>
          </select>
        <span class="style4">        </span><span class="style4">&nbsp;&nbsp;&nbsp;
        <input name="cbunid" type="checkbox" onClick="desabilita_campos_unidade()" class="form" size="8" value="<cfoutput>#rsMOd.Und_Codigo#</cfoutput>">
        Unidade</span>  &nbsp;&nbsp;&nbsp;
        <label><span class="style4"> </span></label>
        <strong>
        <label>
        <input type="checkbox"  onclick ="desabilita_campos_subordinador()" class="form" name="cbunid" size="8" value="<cfoutput>#rsMOd.Und_CodReop#</cfoutput>">
        </label>
                </strong>
        <label>&Oacute;rg&atilde;o Subordinador</label></div></td>	  	     
      </tr>	
	  <!--- Visualiza��o de anexos --->
	  <cfquery name="qAnexos" datasource="#dsn_inspecao#">
		SELECT     Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Codigo, Ane_Caminho
		FROM       Anexos
		WHERE  Ane_NumInspecao = #url.ninsp# AND Ane_Unidade = #url.unid# AND Ane_NumGrupo = #url.ngrup# AND Ane_NumItem = #url.nitem# order by Ane_Codigo
		order by Ane_Codigo
	  </cfquery>
<!--- <cfdirectory action="list" name="qAnexos" directory="#diretorio_anexos#"> 
	  	
      		<td valign="middle" bgcolor="eeeeee" class="exibir">&nbsp;</td>
      		<td colspan="4" bgcolor="f7f7f7" class="titulo2"></td>
    	</tr>
		
	  <cfloop query="qAnexos">
	  	<cfif FileExists(qAnexos.Ane_Caminho)>
		<tr>
      		<td valign="middle" bgcolor="eeeeee" class="exibir">&nbsp;</td>
      		<td colspan="3" bgcolor="f7f7f7">
				<a target="_blank" href="<cfoutput>#qAnexos.Ane_Caminho#</cfoutput>">
				<span class="link1"><cfoutput>#ListLast(qAnexos.Ane_Caminho,'\')#</cfoutput></span></a> 
			</td>
			<cfoutput>
			<td bgcolor="f7f7f7"><input type="button" class="botao" value="Excluir" onClick="window.open('excluir_anexo.cfm?ninsp=#url.ninsp#&unid=#url.unid#&ngrup=#url.ngrup#&nitem=#url.nitem#&Ane_codigo=#qAnexos.Ane_Codigo#&cktipo=#url.cktipo#&dtfim=#url.dtfim#&dtinic=#url.dtinic#&reop=#url.reop#')"> </td>
			</cfoutput>
    	</tr>
		</cfif>
	  </cfloop> --->
	   <tr>
      		<td valign="middle" bgcolor="eeeeee" class="exibir">&nbsp;</td>
      		<td colspan="4" bgcolor="f7f7f7" class="exibir">&nbsp;</td>
    	</tr>
	  <!--- --->  
	  <!--- <input type="hidden" name="obs" value="<cfoutput>#qResposta.Pos_Parecer#</cfoutput>"> --->
    <tr>
      <td height="38" valign="middle" bgcolor="eeeeee" class="exibir">&nbsp;</td>
      <td colspan="4" rowspan="2" bgcolor="f7f7f7"><cfif Not IsDefined("FORM.MM_UpdateRecord") And Trim(qResposta.Pos_Parecer) neq ''><textarea name="H_obs" cols="120" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#qResposta.Pos_Parecer#</cfoutput></textarea></cfif>
	  <textarea name="observacao" cols="120" rows="5" nome="Observa��o" vazio="false" wrap="VIRTUAL" class="form" id="observacao"></textarea></td>
    </tr>
    <tr>
      <td valign="middle" bgcolor="eeeeee" class="exibir">An&aacute;lise do Inspetor:</td>
    </tr>    
    <tr>
      <td colspan="2">&nbsp;</td>
      <td colspan="3">
        <div align="center">
          <input type="button" class="botao"  onClick="history.back()" value="Voltar">&nbsp;&nbsp;&nbsp;
          <input name="Submit" type="submit" class="botao" value="Confirmar">
        </div></td>
    </tr>
  </table>
  <input type="hidden" name="MM_UpdateRecord" value="form1">
</form>
<!---<script>
function atribuir()
{
 
<cfif qGrav.RecordCount gt 0>
 document.form1.sacao.value='alt';
 <cfoutput query="qGrav">
 <cfif qGrav.Ana_Col01 eq '1'> document.form1.cbox01.checked=true; mostra('10', true, 'cbox01');</cfif>
 <cfif qGrav.Ana_Col02 eq '1'> document.form1.cbox02.checked=true; mostra('5', true, 'cbox02');</cfif>
 <cfif qGrav.Ana_Col03 eq '1'> document.form1.cbox03.checked=true; mostra('7', true, 'cbox03');</cfif>
 <cfif qGrav.Ana_Col04 eq '1'> document.form1.cbox04.checked=true; mostra('10', true, 'cbox04');</cfif>
 <cfif qGrav.Ana_Col05 eq '1'> document.form1.cbox05.checked=true; mostra('5', true, 'cbox05');</cfif>
 <cfif qGrav.Ana_Col06 eq '1'> document.form1.cbox06.checked=true; mostra('2', true, 'cbox06');</cfif>
 <cfif qGrav.Ana_Col07 eq '1'> document.form1.cbox07.checked=true; mostra('7', true, 'cbox07');</cfif>
 <cfif qGrav.Ana_Col08 eq '1'> document.form1.cbox08.checked=true; mostra('5', true, 'cbox08');</cfif>
 <cfif qGrav.Ana_Col09 eq '1'> document.form1.cbox09.checked=true; mostra('10', true, 'cbox09');</cfif>
 
 </cfoutput>
 </cfif>
}
</script>--->
<!--- Fim �rea de conte�do --->
    </td>
  </tr>
</table>

</body>
</html>
