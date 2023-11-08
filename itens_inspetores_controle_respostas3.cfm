<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="permissao_negada.htm">
  <cfabort>
</cfif> 

<!--- Nova consulta para verificar respostas das unidades --->
<cfquery name="qSituacaoResp" datasource="#dsn_inspecao#">
SELECT Pos_Situacao_Resp 
FROM ParecerUnidade
WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem#
</cfquery>

<cfquery name="qResponsavel" datasource="#dsn_inspecao#">
    SELECT  INP_Responsavel, INP_DtFimInspecao
    FROM  Inspecao
    WHERE  INP_NumInspecao = '#ninsp#'
</cfquery>
<!--- Visualiza��o de anexos --->
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
	  , Pos_Situacao = 'PE' 
	</cfcase>
	<cfcase value="2"> <cfset Encaminhamento = '�(O) ' & Form.hUnidade>
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
	<cfset Encaminhamento = '�(O) ' & qReop.Rep_Nome>
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
	<cfdefaultcase><cfset Encaminhamento = ''>
	  , Pos_Situacao = 'AN'
	</cfdefaultcase>
  </cfswitch> 
  <cfif IsDefined("FORM.observacao") AND FORM.observacao NEQ "">   
  , Pos_Parecer=      	  	  
    <cfset aux_obs = Form.H_obs & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & Trim(Encaminhamento) & '  ' & '-' & '  ' & Trim(FORM.observacao) & CHR(13) & CHR(13) & 'Respons�vel: ' & CGI.REMOTE_USER & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_Lotacao) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
	<!--- As linhas abaixo servem para substituir o uso de aspas simples e duplas, a fim de evitar erros em instru��es SQL --->
	 <cfset aux_obs = Replace(aux_obs,'"','','All')>
	 <cfset aux_obs = Replace(aux_obs,"'","","All")>	
	 <cfset aux_obs = Replace(aux_obs,'*','','All')>
	 <!--- <cfset aux_obs = Replace(aux_obs,'&','','All')>
	 <cfset aux_obs = Replace(aux_obs,'%','','All')> --->	 		
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
    , Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#	
	, Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
      WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
 </cfquery> 
 
   <!--- Dados no campo Recomenda��es ---> 
  
 <cfif IsDefined("FORM.MM_UpdateRecord") AND FORM.MM_UpdateRecord EQ "form1">
 <cfquery datasource="#dsn_inspecao#">
   UPDATE Resultado_Inspecao SET 
   <cfif IsDefined("FORM.recomendacao") AND FORM.recomendacao NEQ "">   
   RIP_Recomendacoes=	 
	  <cfset aux_recom = FORM.recom & CHR(13) & FORM.recomendacao & CHR(13) & CHR(13)>
	  <!--- As linhas abaixo servem para substituir o uso de aspas simples e duplas, a fim de evitar erros em instru��es SQL --->
	  <cfset aux_recom = Replace(aux_recom,'"','','All')>
	  <cfset aux_recom = Replace(aux_recom,"'","","All")>
	  <cfset aux_recom = Replace(aux_recom,'*','','All')>
	  <!--- <cfset aux_recom = Replace(aux_recom,'&','','All')>
	  <cfset aux_recom = Replace(aux_recom,'%','','All')>	 --->	
	  '#aux_recom#',
   </cfif>
   <cfif IsDefined("FORM.Melhoria") AND FORM.Melhoria NEQ "">   
   RIP_Comentario=	  	 
	  <cfset aux_mel = CHR(13) & Form.Melhoria>
	  <!--- As linhas abaixo servem para substituir o uso de aspas simples e duplas, a fim de evitar erros em instru��es SQL --->
	  <cfset aux_mel = Replace(aux_mel,'"','','All')>
	  <cfset aux_mel = Replace(aux_mel,"'","","All")>
	  <cfset aux_mel = Replace(aux_mel,'*','','All')>
	  <!--- <cfset aux_mel = Replace(aux_mel,'&','','All')>
	  <cfset aux_mel = Replace(aux_mel,'%','','All')> --->		
	  '#aux_mel#'
	  , RIP_UserName = '#CGI.REMOTE_USER#'	  	  	        
	  WHERE RIP_Unidade='#FORM.unid#' AND RIP_NumInspecao='#FORM.ninsp#' AND RIP_NumGrupo=#FORM.ngrup# AND RIP_NumItem=#FORM.nitem#
	</cfif>
  </cfquery> 
 </cfif>    
	<cfset hhmmss = timeFormat(now(), "HH:mm:ss")>
	<cfset hhmmss = left(hhmmss,2) & mid(hhmmss,4,2) & mid(hhmmss,7,2)>
 <cfif IsDefined("FORM.MM_UpdateRecord") AND FORM.MM_UpdateRecord EQ "form1">
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
  '#hhmmss#'
  ,
  <cfif IsDefined("FORM.observacao") AND FORM.observacao NEQ "">
    <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & Trim(Encaminhamento) & '  ' & '-' & '  ' & Trim(FORM.observacao) & CHR(13) & CHR(13) & 'Respons�vel: ' & CGI.REMOTE_USER & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_Lotacao) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
	<!--- As linhas abaixo servem para substituir o uso de aspas simples e duplas, a fim de evitar erros em instru��es SQL --->
          <cfset and_obs = Replace(and_obs,'"','','All')>
		  <cfset and_obs = Replace(and_obs,"'","","All")>
		  <cfset and_obs = Replace(and_obs,'&','','All')>
		  <cfset and_obs = Replace(and_obs,'*','','All')>
		  <!--- <cfset and_obs = Replace(and_obs,'%','','All')> --->
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
        UPDATE ProcessoParecerUnidade SET Pro_Situacao = 'EN', Pro_DtEncerr = CONVERT(char, GETDATE(), 102)
        WHERE Pro_Unidade='#FORM.unid#' AND Pro_Inspecao='#FORM.ninsp#'
      </cfquery>
    </cfif>
  </cfif>    
 
  <cfif form.sacao eq "alt">     
     <cfquery datasource="#dsn_inspecao#">
       update Analise SET Ana_Col01='#FORM.cb01#', Ana_Col02='#FORM.cb02#', Ana_Col03='#FORM.cb03#', Ana_Col04='#FORM.cb04#', Ana_Col05='#FORM.cb05#', Ana_Col06='#FORM.cb06#', Ana_Col07='#FORM.cb07#', Ana_Col08='#FORM.cb08#', Ana_Col09='#FORM.cb09#' where (Ana_NumInspecao='#FORM.ninsp#' and Ana_Unidade='#FORM.unid#') and (Ana_NumGrupo=#FORM.ngrup# and Ana_NumItem=#FORM.nitem#)
     </cfquery>
  </cfif> 
  <!--- <cfdump var="#form#">
  <cfabort>   --->
  
  <cfif form.salvar_anexar is "anexar">
    <cflocation url="itens_inspetores_transmitir_anexo.cfm?ninsp=#form.Ninsp#&unid=#form.Unid#&ngrup=#form.Ngrup#&nitem=#form.Nitem#&cktipo=#form.cktipo#&dtfim=#form.dtfinal#&dtinic=#form.dtinicio#&reop=#form.reop#&matricula=#form.matricula#">
  </cfif>
  
  <cfif ckTipo eq "inspecao">
    <cflocation url="itens_inspetores_controle_respostas.cfm?txtNum_Matricula=#Matricula#&ckTipo=inspecao">
  <cfelse>
    <cflocation url="itens_inspetores_controle_respostas.cfm?Dtinic=#form.dtinicio#&dtfim=#form.dtfinal#&ckTipo=#ckTipo#">
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

<cfquery name="qData" datasource="#dsn_inspecao#">
UPDATE ParecerUnidade SET Pos_Situacao_Resp = '5', Pos_Situacao = 'AN', Pos_DtUltAtu = CONVERT(char, GETDATE(), 120) 
WHERE Pos_Situacao_Resp = '8' AND Pos_DtPrev_Solucao <= GETDATE()
</cfquery>

<!--- Buscando dados da Gravidade --->
<cfquery name="qGrav" datasource="#dsn_inspecao#">
SELECT Ana_Col01, Ana_Col02, Ana_Col03, Ana_Col04, Ana_Col05, Ana_Col06, Ana_Col07, Ana_Col08, Ana_Col09  FROM Analise WHERE Ana_NumInspecao='#URL.Ninsp#' AND Ana_Unidade='#URL.Unid#' AND Ana_NumGrupo=#URL.Ngrup# AND Ana_NumItem=#URL.Nitem#
</cfquery>

<cfset vUrgencia = qGrav.Ana_Col01 + qGrav.Ana_Col02 + qGrav.Ana_Col03 + qGrav.Ana_Col04 + qGrav.Ana_Col05 + qGrav.Ana_Col06 + qGrav.Ana_Col07 + qGrav.Ana_Col08 + qGrav.Ana_Col09>
<cfset vRecom = 0>
<cfset vRecomendacao = Trim(qResposta.RIP_Recomendacoes)>

<cfif vRecomendacao is ''>
   <cfset vRecom = 1>
</cfif>
<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<script>
function anexar(){ 
    if (document.form1.tipoUrg.value == ''){    
       alert('Sr. Analista, falta fazer � An�lise do Impacto da Oportunidade de Aprimoramento!')
	   return false;  
   }
   if((document.form1.frmResp[2].checked==0) && (document.form1.frmResp[3].checked==0) && (document.form1.frmResp[4].checked==0) && (document.form1.frmResp[5].checked==0) && (document.form1.frmResp[6].checked==0) && (document.form1.frmResp[1].checked==0)){ 
		     alert('Sr. Analista, Escolha o �rg�o Pendente da Oportunidade de Aprimoramento(Unidade, �rea, �rg�o Subordinador, Corporativos DR ou AC)!');
		     return false;		   
	     }       
   
    if ((<cfoutput>#vUrgencia#</cfoutput> != 0) && (<cfoutput>#vRecom#</cfoutput> == 1)){
	   if((document.form1.frmResp[0].checked==0) && (document.form1.recomendacao.value == '')){ 	
		       alert('Sr. Analista, est� faltando a Recomenda��o!');
		       return false;		
	         }         
           }    
   
     if (document.form1.frmResp[1].checked){       
	 if ((document.form1.cbunid[0].checked=='') && (document.form1.cbunid[1].checked=='') && (document.form1.cbOrgao.value=='')){ 
      alert('Sr. Analista, informe o �rg�o Solucionador da Oportunidade de Aprimoramento(�rea, Unidade ou �rg�o Subordinador)!');
	  return false;
	   }    
      } 
	  	  
	  if ((document.form1.observacao.value == '') && (document.form1.frmResp[0].checked==0) && (<cfoutput>#vRecom#</cfoutput> == 0) && (document.form1.frmResp[1].checked==0) && (document.form1.recomendacao.value == '')){ 	
		 alert('Sr. Analista, est� faltando sua An�lise no campo Opini�o da Auditoria!');
		 return false;
	    }
		  
      if ((document.form1.observacao.value == '') && (document.form1.frmResp[1].checked)){
         alert('Sr. Analista, est� faltando sua An�lise Final no campo Opini�o da Auditoria!');
	     return false;
         }   
    document.form1.salvar_anexar.value = 'anexar';
	document.form1.submit();
 } 
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
      alert('Sr. Analista, informe a �rea e a Data de previs�o para a solu��o da Oportunidade de Aprimoramento!');
	  return false;
	}  
  } 
  if ((document.form1.frmResp[4].checked) || (document.form1.frmResp[5].checked) || (document.form1.frmResp[6].checked)){
    if(document.form1.cbArea.value == ''){
       alert('Sr. Analista, informe a �rea para Encaminhamento!');
	   return false;
	}  
  }
  
  if (document.form1.tipoUrg.value == ''){    
       alert('Sr. Analista, falta fazer � An�lise do Impacto da Oportunidade de Aprimoramento!')
	   return false;  
   } 	
   
   if((document.form1.frmResp[2].checked==0) && (document.form1.frmResp[3].checked==0) && (document.form1.frmResp[4].checked==0) && (document.form1.frmResp[5].checked==0) && (document.form1.frmResp[6].checked==0) && (document.form1.frmResp[1].checked==0)){ 
		     alert('Sr. Analista, Escolha o �rg�o Pendente da Oportunidade de Aprimoramento(Unidade, �rea, �rg�o Subordinador, Corporativos DR ou AC)!');
		     return false;		   
	     }       
   
    if ((<cfoutput>#vUrgencia#</cfoutput> != 0) && (<cfoutput>#vRecom#</cfoutput> == 1)){
	   if((document.form1.frmResp[0].checked==0) && (document.form1.recomendacao.value == '')){ 	
		       alert('Sr. Analista, est� faltando a Recomenda��o!');
		       return false;		
	         }         
           }    
   
     if (document.form1.frmResp[1].checked){       
	 if ((document.form1.cbunid[0].checked=='') && (document.form1.cbunid[1].checked=='') && (document.form1.cbOrgao.value=='')){ 
      alert('Sr. Analista, informe o �rg�o Solucionador da Oportunidade de Aprimoramento(�rea, Unidade ou �rg�o Subordinador)!');
	  return false;
	   }    
      } 
	  	  
	  if ((document.form1.observacao.value == '') && (document.form1.frmResp[0].checked==0) && (<cfoutput>#vRecom#</cfoutput> == 0) && (document.form1.frmResp[1].checked==0) && (document.form1.recomendacao.value == '')){ 	
		 alert('Sr. Analista, est� faltando sua An�lise no campo Opini�o da Auditoria!');
		 return false;
	    }
		  
      if ((document.form1.observacao.value == '') && (document.form1.frmResp[1].checked)){
         alert('Sr. Analista, est� faltando sua An�lise Final no campo Opini�o da Auditoria!');
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
var page = "itens_inspetores_controle_respostas1.cfm?numero=#ninsp#&unidade=#unid#&numgrupo=#ngrup#&numitem=#nitem#";
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

<table width="700" height="350">
<tr>
<td valign="top" width="26%" class="link1"> 
<table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr align="left" valign="top">
	  <td width="5%" height="10">&nbsp; </td>
      <!---  <td width="90%" height="4" background="../../menu/fundo.gif">		   
        </td>--->
      </tr>
</table>
      <table width="90%" border="0" cellpadding="0" cellspacing="0">
        <tr align="left" valign="top">         
       <!--- <td width="90%" height="4" background="../../menu/fundo.gif"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><a href="#" class="titulos"></a><cfinclude template="menu_sins.cfm"></font></strong></td>--->
        </tr>
      </table>
    </td>
	  <td valign="top">
<!--- �rea de conte�do   --->
<!--- <form name="form1" method="post" onSubmit="return validaForm()" action="<cfoutput>#CurrentPage#?#CGI.QUERY_STRING#</cfoutput>"> --->
<form name="form1" method="post" onSubmit="return validaForm()" action="itens_inspetores_controle_respostas1.cfm"> 
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
      <td width="213" bgcolor="f7f7f7"><cfoutput><strong>#rsMOd.Und_Descricao#</strong></cfoutput></td>
      <td width="118" bgcolor="eeeeee">Respons&aacute;vel</td>
      <td width="199" bgcolor="f7f7f7"><cfoutput><strong>#qResponsavel.INP_Responsavel#</strong></cfoutput></td>	  
    </tr>
	<tr class="exibir">
      <cfif qInspetor.RecordCount lt 2>
	    <td bgcolor="eeeeee">Analista</td>
	    <cfelse>
	    <td bgcolor="eeeeee">Analistas</td>
	  </cfif>
      <td colspan="4" bgcolor="f7f7f7">-&nbsp;<cfoutput query="qInspetor"><strong>#qInspetor.Fun_Nome#</strong>&nbsp;<cfif qInspetor.currentrow neq qInspetor.recordcount><br>-&nbsp;</cfif></cfoutput></td>
    </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">Auditoria</td>
      <td colspan="4" bgcolor="f7f7f7"><cfoutput>#URL.Ninsp#</cfoutput></td>
    </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">Objetivo</td>
      <td bgcolor="f7f7f7"><cfoutput>#URL.Ngrup#</cfoutput></td>	  
      <td colspan="3" bgcolor="f7f7f7"><cfoutput><strong>#URL.DGrup#</strong></cfoutput></td>
    </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">Item</td>
      <td bgcolor="f7f7f7"><cfoutput>#URL.Nitem#</cfoutput></td>
      <td colspan="3" bgcolor="f7f7f7"><cfoutput><strong>#URL.Desc#</strong></cfoutput></td>
    </tr>
    <tr bgcolor="f7f7f7">
      <td height="22" colspan="5" valign="top" class="exibir"><table width="709" border="1">
      <tr bgcolor="f7f7f7">
            <td height="4" colspan="5" valign="top" class="exibir"><div align="center"><strong>An&aacute;lise do Impacto da Oportunidade de Aprimoramento</strong>                
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
          <td height="1" colspan="1" valign="top" class="exibir"><div align="center"><strong>Efeitos n&atilde;o desejados </strong></div></td>
          <td width="93" height="1" valign="top" class="exibir"><div align="center"><strong>Pontua&ccedil;&atilde;o</strong></div></td>
          <td width="313" height="1" valign="top" class="exibir"><div align="left"><strong> Consequ&ecirc;ncias identificadas </strong></div></td>
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
          <td height="1" colspan="3" valign="top" bgcolor="f7f7f7" class="exibir"><input name="frmprioridade" type="text" class="form" id="frmprioridade" size="6" maxlength="4" readonly=""></td> 
		  </tr>
      </table></td>
    </tr>
	<tr bgcolor="f7f7f7">
      <td height="22" colspan="2" valign="top" class="exibir">Marque se a oportunidade de aprimoramento compromete todo o processo auditado </td>
      <td height="22" valign="top" class="exibir"><span class="style4">&nbsp;&nbsp;
	  <!---<cfoutput>#Len(qResposta.Pos_Relevancia)#</cfoutput>--->
        <input name="relevancia" type="checkbox" align="left" class="form" size="8" value="1" <cfif qResposta.Pos_Relevancia eq 1> checked </cfif>>
      </span></td>
      <td height="22" align="center" colspan="2" valign="top" class="red_titulo"><cfif qResposta.Pos_Relevancia eq 1>
        Item compromete o processo!
      </cfif> </td>
      </tr>
    <tr bgcolor="f7f7f7">
      <td height="22" colspan="4" valign="top" class="exibir">A situa&ccedil;&atilde;o do item foi regularizada por definitivo ? &nbsp;&nbsp;
        <label><span class="style4">
<input name="frmResp" type="radio" value="0" onClick="exibirArea(this.value);exibirOrgao(this.value);exibirData(this.value)" checked>
N&atilde;o</span></label>
        <strong>
        <label>
<strong>
<input type="radio" name="frmResp" value="3" onClick="exibirArea(this.value);exibirOrgao(this.value);exibirData(this.value)">
</strong>Sim</label>
        </strong></td>

      <td height="22" valign="top" class="exibir">&nbsp;</td>
	</tr>
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
<label>&Aacute;rea <strong><strong>
 <input type="radio" name="frmResp" value="8" onClick="exibirArea(this.value);exibirOrgao(this.value);exibirData(this.value)">
   </strong></strong>Corporativo DR </strong></strong></label>
   <input type="radio" name="frmResp" value="9" onClick="exibirArea(this.value);exibirOrgao(this.value);exibirData(this.value)">
   </strong></strong>Corporativo AC </td>
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
	      <input name="cbData" class="form" type="text" size="12"  onKeyPress="numericos()"  onKeyDown="Mascara_Data(this)" value="#dateformat(now(),"dd/mm/yyyy")#">
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
        <input type="checkbox" onclick="desabilita_campos_subordinador()" class="form" name="cbunid" size="8" value="<cfoutput>#rsMOd.Und_CodReop#</cfoutput>">
        </label>
                </strong>
        <label>&Oacute;rg&atilde;o Subordinador</label>
	     <!--- </div><input type="button" value="teste" onClick="alert(document.form1.frmResp[7].value)"> ---></td>	  	     
      </tr>	  

	  <tr>
	    <td valign="middle" bgcolor="eeeeee" class="exibir">&nbsp;</td>
	    <td colspan="4" bgcolor="eeeeee" class="exibir">&nbsp;</td>
	  </tr>	  	
	 <tr>      		
	 <td height="38" valign="middle" bgcolor="#eeeeee"><span class="titulos">Oportunidade de Aprimoramento:</span></td>      
	   <cfif qResposta.Pos_Situacao_Resp is 0> 
	     <td colspan="4" bgcolor="f7f7f7"><textarea name="Melhoria" cols="120" rows="12" wrap="VIRTUAL" class="form"><cfoutput>#qResposta.RIP_Comentario#</cfoutput></textarea></td>
	   <cfelse> 
	     <td width="615" colspan="4" bgcolor="f7f7f7"><textarea name="Melhoria" cols="120" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#qResposta.RIP_Comentario#</cfoutput></textarea></td> 
	   </cfif>	
	 </tr>	
	 <!--- <input type="hidden" name="obs" value="<cfoutput>#qResposta.Pos_Parecer#</cfoutput>">	 --->   
    <tr>
      <td valign="middle" bgcolor="eeeeee"><span class="titulos">Hist&oacute;rico:</span>
        <span class="titulos">Manifesta��o/An&aacute;lise da Auditoria</span><span class="titulos">:</span></td>
      <td colspan="4" bgcolor="f7f7f7"><cfif Not IsDefined("FORM.MM_UpdateRecord") And Trim(qResposta.Pos_Parecer) neq ''><textarea name="H_obs" cols="120" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#qResposta.Pos_Parecer#</cfoutput></textarea></cfif></td>
	</tr>
      <input type="hidden" name="recom" value="<cfoutput>#qResposta.RIP_Recomendacoes#</cfoutput>">
    <tr>
      <td height="116" valign="middle" bgcolor="eeeeee"><span class="titulos">Recomenda&ccedil;&otilde;es:</span></td>
      <td colspan="4" rowspan="2" bgcolor="f7f7f7"><cfif Not IsDefined("FORM.MM_UpdateRecord") And Trim(qResposta.RIP_Recomendacoes) neq ''>
        <textarea name="H_recom" cols="120" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#qResposta.RIP_Recomendacoes#</cfoutput></textarea>
      </cfif>
	  <textarea name="recomendacao" cols="120" rows="5" nome="recomenda��o" vazio="false" wrap="VIRTUAL" class="form" id="recomendacao"></textarea></td>
    </tr>
    <tr>
      <td height="48" bgcolor="eeeeee"><span class="titulos">Recomendar:</span></td>
    </tr>
	<tr>
	 <td height="38"  bgcolor="eeeeee"><span class="titulos">Opini&atilde;o da Auditoria :</span></td>
	 <td colspan="4" bgcolor="f7f7f7"><textarea name="observacao" cols="120" rows="5" nome="Observa��o" vazio="false" wrap="VIRTUAL" class="form" id="observacao"></textarea></td>
	</tr>
	<tr>
	  <td colspan="3" bgcolor="#eeeeee" class="exibir"><strong>ANEXOS</strong></td>
	  <td height="22" colspan="2" bgcolor="#eeeeee" class="exibir"><input type="button" value="Salvar e Anexar arquivos" class="botao" onClick="anexar()"></td>  
  </tr>
	<cfloop query="qAnexos">
	  	<cfif FileExists(qAnexos.Ane_Caminho)>
	       <tr>
      		<td colspan="2" bgcolor="eeeeee">
				<a target="_blank" href="<cfoutput>#qAnexos.Ane_Caminho#</cfoutput>">
				<span class="link1"><cfoutput>#ListLast(qAnexos.Ane_Caminho,'\')#</cfoutput></span></a></td>
			<cfoutput>
			  <td colspan="3" bgcolor="eeeeee">
			    <input type="button" class="botao" value="Excluir" onClick="window.open('excluir_anexo.cfm?ninsp=#URL.Ninsp#&unid=#URL.Unid#&ngrup=#URL.Ngrup#&nitem=#URL.Nitem#&Ane_codigo=#qAnexos.Ane_Codigo#&cktipo=#url.cktipo#&dtfim=#url.dtfim#&dtinic=#url.dtinic#&reop=#url.reop#','_self')">
			  </td>
			</cfoutput>  
			</tr>
		 </cfif>
	  </cfloop>		
	<tr>
	  <td colspan="2" bgcolor="eeeeee">&nbsp;</td>
	  <td colspan="3" bgcolor="eeeeee" align="center"><div align="left">
	      <input type="hidden" name="Matricula" value="<cfoutput>#Matricula#</cfoutput>">
	      <input type="button" class="botao"  onClick="history.back()" value="Voltar">
	    &nbsp;&nbsp;&nbsp;
	      <input name="Submit" type="submit" class="botao" value="Salvar">
	    </div></td>
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
<script>
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
</script>
<!--- Fim �rea de conte�do --->
    </td>
  </tr>
</table>
</body>
</html>
