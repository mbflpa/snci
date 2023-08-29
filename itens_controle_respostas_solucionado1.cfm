<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif>
<cfset area = 'sins'>
<cfset evento = 'document.form1.observacao.focus();'>

<cfparam name="URL.Unid" default="0">
<cfparam name="URL.Ninsp" default="">
<cfparam name="URL.Ngrup" default="">
<cfparam name="URL.Nitem" default="">
<cfparam name="URL.Desc" default="">
<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>
<cfparam name="URL.DGrup" default="0">
<cfparam name="URL.numpag" default="0">
<cfparam name="URL.dtFinal" default="0">
<cfparam name="URL.DtInic" default="0">

<cfquery name="qUsuario" datasource="#dsn_inspecao#">
 SELECT DISTINCT Usu_Apelido, Usu_Lotacao
 FROM Usuarios
 WHERE Usu_Login = '#CGI.REMOTE_USER#'
 GROUP BY Usu_Apelido, Usu_Lotacao 
</cfquery>  

<cfquery name="qResposta" datasource="#dsn_inspecao#">
SELECT Pos_Situacao_Resp, Pos_Parecer, Ars_Sigla, Pos_Area
FROM ParecerUnidade INNER JOIN Areas ON Pos_Area = Ars_CodGerencia or Pos_Area is null
WHERE Pos_Unidade='#URL.unid#' AND Pos_Inspecao='#URL.ninsp#' AND Pos_NumGrupo=#URL.ngrup# AND Pos_NumItem=#URL.nitem#
</cfquery>

<cfquery name="qAnexos" datasource="#dsn_inspecao#">
  SELECT Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Codigo, Ane_Caminho
  FROM Anexos
  WHERE  Ane_NumInspecao = '#ninsp#' AND Ane_Unidade = '#unid#' AND Ane_NumGrupo = #ngrup# AND Ane_NumItem = #nitem# 
  order by Ane_Codigo
</cfquery>

<cfquery name="rsItem" datasource="#dsn_inspecao#">
SELECT RIP_NumInspecao, RIP_Unidade, Und_Descricao, RIP_NumGrupo, RIP_NumItem, RIP_Comentario, RIP_Recomendacoes, INP_DtInicInspecao, INP_Responsavel, RIP_Melhoria
FROM (Inspecao INNER JOIN 
(Resultado_Inspecao 
INNER JOIN Unidades 
ON RIP_Unidade = Und_Codigo) 
ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade)) 
INNER JOIN (Itens_Verificacao 
INNER JOIN Grupos_Verificacao 
ON (Itn_Ano = Grp_Ano) AND (Itn_NumGrupo = Grp_Codigo)) 
ON (RIP_NumItem = Itn_NumItem) AND (RIP_NumGrupo = Itn_NumGrupo) AND (Und_TipoUnidade = Itn_TipoUnidade) 
AND (convert(char(4),RIP_Ano) = Itn_Ano) AND (INP_Modalidade = Itn_Modalidade)
WHERE RIP_NumInspecao='#ninsp#' AND RIP_Unidade='#unid#' AND RIP_NumGrupo= #ngrup# AND RIP_NumItem=#nitem#
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
                      Funcionarios ON Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric AND 
                      Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric
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
	  , Pos_Situacao = 'PE'
	</cfcase>	
	<cfcase value="3">
	  , Pos_Situacao = 'SO'
	</cfcase>
	<cfcase value="4">
	  , Pos_Situacao = 'AN'
	</cfcase>
	<cfcase value="5">
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
     <cfset pos_obs = Form.H_obs & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & Trim(Encaminhamento) & '  ' & '-' & '  ' & #aux_obs# & CHR(13) & CHR(13) & 'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_Lotacao) & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
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
  <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & Trim(Encaminhamento) & '  ' & '-' & '  ' & #aux_obs# & CHR(13) & CHR(13) & 'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_Lotacao) & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>

 <cfquery datasource="#dsn_inspecao#">
    insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Orgao_Solucao, And_Parecer) values ('#FORM.ninsp#', '#FORM.unid#', '#FORM.ngrup#', '#FORM.nitem#', convert(char, getdate(), 102), '#CGI.REMOTE_USER#', '#FORM.frmResp#', convert(char, getdate(), 108), '#FORM.unid#', '#and_obs#')  
 </cfquery>  
  <cflocation url="itens_controle_respostas_solucionados.cfm?#CGI.QUERY_STRING#">
</cfif>
<cfquery name="rsMOd" datasource="#dsn_inspecao#">
SELECT Unidades.Und_Descricao, Unidades.Und_CodReop
FROM Unidades
WHERE Unidades.Und_Codigo = '#URL.Unid#' 
</cfquery>

<cfquery name="qArea" datasource="#dsn_inspecao#">
SELECT DISTINCT Ars_CodGerencia, Ars_Sigla
FROM Areas WHERE Ars_Status = 'A'
ORDER BY Ars_Sigla
</cfquery>

<script type="text/javascript">
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

//Validação de campos vazios em formulário
function valida_form(form) {
 var frm = document.forms[form];
 var quant = frm.elements.length;
 for (var i=0; i<quant; i++) {
   var elemento = document.forms[form].elements[i];
   if (elemento.getAttribute('vazio') == 'false') {
	 if (Trim(elemento.value) == '') {
	   var nome = elemento.getAttribute('nome');
	   alert('O campo Manifestar-se deve ser preenchido!');
	   elemento.focus();
	   return false;
	   break;
	 }
   }
 }
}

//Função que abre uma página em Popup
function popupPage(){
<cfoutput>  //página chamada, seguida dos parâmetros número, unidade, grupo e item
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
//permite digitaçao apenas de valores numéricos
function numericos() {
var tecla = window.event.keyCode;
//permite digitação das teclas numéricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)
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
		      alert('Valor para o dia inválido!');
			  data.value = '';
		      event.returnValue = false;
			  break;
		    } else {
			  data.value += "/";
				break;
			}
		case 5:
			if (data.value.substring(3,5) < 1 || data.value.substring(3,5) > 12) {
		      alert('Valor para o Mês inválido!');
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
      alert('Sr. Analista, informe a Área e a Data de previsão para a solução da Situação Encontrada!');
	  return false;
	}  
  }  
  if ((document.form1.frmResp[4].checked) || (document.form1.frmResp[5].checked) || (document.form1.frmResp[6].checked)){
    if(document.form1.cbArea.value == ''){
       alert('Sr. Analista, informe a Área para encaminhamento!');
	   return false;
	}  
  }
  if (document.form1.frmResp[1].checked){    
	 if ((document.form1.cbunid[0].checked=='') && (document.form1.cbunid[1].checked=='') && (document.form1.cbOrgao.value=='')){ 
      alert('Sr. Analista, informe o Órgão solucionador da Situação Encontrada!');
	  return false;
	 }   
  }
  if (document.form1.frmResp[0].checked){    
	 if ((document.form1.frmResp[2].checked==0) && (document.form1.frmResp[3].checked==0) && (document.form1.frmResp[4].checked==0) && (document.form1.frmResp[5].checked==0) && (document.form1.frmResp[6].checked==0)){ 
      alert('Sr. Analista, Escolha o órgão Pendente!');
	  return false;
	 }   
  }     
</script>

<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body onLoad="exibirArea(0);exibirData(0)">
<cfinclude template="cabecalho.cfm">
<table width="95%" height="450">
<tr>
	  <td width="96%" valign="top">
<!--- Área de conteúdo   --->
<form name="form1" method="post" onSubmit="return valida_form(this.value)" action="<cfoutput>#CurrentPage#?#CGI.QUERY_STRING#</cfoutput>">  
  <table width="78%" align="center">
    <tr>
      <td colspan="7"><p align="center" class="titulo1">&nbsp;</p>
        <p align="center" class="titulo1">Ponto solucionado </p>
        <p>            
            <input name="unid" type="hidden" id="unid" value="<cfoutput>#URL.Unid#</cfoutput>">
            <input name="ninsp" type="hidden" id="ninsp" value="<cfoutput>#URL.Ninsp#</cfoutput>">
            <input name="ngrup" type="hidden" id="ngrup" value="<cfoutput>#URL.Ngrup#</cfoutput>">
            <input name="nitem" type="hidden" id="nitem" value="<cfoutput>#URL.Nitem#</cfoutput>">
            <input name="dtinicio" type="hidden" id="dtinicio" value="<cfoutput>#URL.DtInic#</cfoutput>">
</p>  </td>
    </tr>
    <tr bgcolor="#FFFFFF" class="exibir">
      <td colspan="7">&nbsp;</td>
      </tr>
    <tr class="exibir">
      <td width="113" bgcolor="eeeeee">Unidade      </td>
      <td width="139" colspan="2" bgcolor="f7f7f7"><cfoutput><strong>#rsMOd.Und_Descricao#</strong></cfoutput></td>
      <td width="71" bgcolor="f7f7f7"><cfoutput>Respons&aacute;vel</cfoutput></td>
      <td width="407" colspan="3" bgcolor="f7f7f7"><cfoutput><strong>#qResponsavel.INP_Responsavel#</strong></cfoutput></td>
      </tr>
	<tr class="exibir">
      <cfif qInspetor.RecordCount lt 2>
	    <td bgcolor="eeeeee">Analista</td>
	  <cfelse>
	    <td bgcolor="eeeeee">Analistas</td>
	    <td colspan="6" bgcolor="eeeeee">-&nbsp;<cfoutput query="qInspetor"><strong>#qInspetor.Fun_Nome#</strong>&nbsp;<cfif qInspetor.currentrow neq qInspetor.recordcount><br>-</cfif></cfoutput></td>
	  </cfif>
	  <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
      </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">Auditoria </td>
	  <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
      <td colspan="6" bgcolor="f7f7f7"><cfoutput><strong>#Num_Insp#</strong></cfoutput><cfoutput></cfoutput></td>
      </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">Objetivo </td>
      <td bgcolor="f7f7f7"><cfoutput>#URL.Ngrup#</cfoutput></td>
      <td colspan="5" bgcolor="f7f7f7"><cfoutput><strong>#URL.DGrup#</strong></cfoutput><cfoutput></cfoutput></td>
      </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee"> Item </td>
      <td bgcolor="f7f7f7"><cfoutput>#URL.Nitem#</cfoutput></td>
      <td bgcolor="f7f7f7"><cfoutput><strong>#URL.Desc#</strong></cfoutput></td>
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
        <input name="frmResp" type="radio" value="1"  onClick="exibirArea(this.value);exibirData(this.value)" checked>
N&atilde;o</span></label>
     <!--- <strong>
        <label> <strong><strong><strong>
        <input type="radio" name="frmResp" value="3" onClick="exibirArea(this.value);exibirData(this.value)" >
        </strong></strong></strong>Sim</label>
        </strong>--->
		</td>
      </tr>
    <tr class="exibir">
      <td colspan="7" bgcolor="eeeeee">A situa&ccedil;&atilde;o est&aacute; pendente da ? <span class="style4">
      <input name="frmResp" type="radio" value="2" onClick="exibirArea(this.value);exibirData(this.value)">
Unidade</span>&nbsp;&nbsp;
<label><span class="style4"> </span></label>
<strong>
<label>
<input type="radio" name="frmResp" value="4" onClick="exibirArea(this.value);exibirData(this.value)">
</label>
</strong>
<label>&Oacute;rg&atilde;o Subordinador</label>
<strong><strong>
<label>
<input type="radio" name="frmResp" value="5" onClick="exibirArea(this.value);exibirData(this.value)">
</label>
</strong></strong>
<label>&Aacute;rea </label>
<strong><strong>
<input type="radio" name="frmResp" value="8" onClick="exibirArea(this.value);exibirData(this.value)">
</strong></strong>Corporativo DR <strong><strong>
<input type="radio" name="frmResp" value="9" onClick="exibirArea(this.value);exibirData(this.value)">
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
      <td colspan="4" valign="top" bgcolor="f7f7f7"><div id="dData"> Data de Previs&atilde;o da Solu&ccedil;&atilde;o:
              <input name="cbData" class="form" type="text" size="12"  onKeyPress="numericos()"  onKeyDown="Mascara_Data(this)" value="#dateformat(now(),"dd/mm/yyyy")#">
      </div></td>
      </tr>
    <tr class="exibir">
      <td colspan="7" bgcolor="eeeeee">&nbsp;</td>
      </tr>
    <!---<tr class="exibir">
      <td colspan="7" bgcolor="eeeeee"><div align="center">
        <input name="comentarios" type="button" class="botao" onClick="window.open('itens_unidades_controle_respostas_comentarios.cfm?numero=<cfoutput>#URL.ninsp#</cfoutput>&unidade=<cfoutput>#URL.unid#</cfoutput>&numgrupo=<cfoutput>#URL.ngrup#</cfoutput>&numitem=<cfoutput>#URL.nitem#</cfoutput>','','scrollbars=yes, resizable=yes, width=600, height=460, left=120, top=100')" value="Situação Encontrada">
      </div></td>
      </tr>--->    
	 <!--- <input type="hidden" name="frmResp" value="5">--->
	 <!--- <input type="hidden" name="obs" value="<cfoutput>#qResposta.Pos_Parecer#</cfoutput>"> --->
     <tr>
       <td valign="middle" bgcolor="eeeeee" class="exibir"><span class="titulos">Situação Encontrada:</span></td>
       <td colspan="4" bgcolor="f7f7f7"><textarea name="Melhoria" cols="120" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#rsItem.RIP_Comentario#</cfoutput></textarea></td>
     </tr>
     <tr>
      <td valign="middle" bgcolor="eeeeee" class="exibir"><p><span class="titulos">Hist&oacute;rico: Manifesta&ccedil;&atilde;o da &Aacute;rea/An&aacute;lise da Auditoria:</span></p>
        </td>
      <td colspan="4" bgcolor="f7f7f7">
	  <cfif Not IsDefined("FORM.MM_UpdateRecord") And Trim(qResposta.Pos_Parecer) neq ''><textarea name="H_obs" cols="120" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#qResposta.Pos_Parecer#</cfoutput></textarea></cfif></td>
    </tr>
     <tr>
       <td bgcolor="eeeeee"><span class="titulos">Recomenda&ccedil;&otilde;es:</span></td>
       <td colspan="6"><textarea name="H_recom" cols="120" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#rsItem.RIP_Recomendacoes#</cfoutput></textarea></td>
     </tr>
     <tr>
       <td bgcolor="eeeeee"><span class="titulos">Manifestar-se:</span></td>
       <td colspan="6"><textarea name="observacao" cols="120" rows="6" nome="Observa&ccedil;&atilde;o" vazio="false" wrap="VIRTUAL" class="form" id="observacao"></textarea></td>
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
      <td colspan="3">&nbsp;</td>
      <td colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="3">
        <div align="right">
          <input name="Cancelar" type="button" class="botao" value="Cancelar" onClick="history.back()">
        </div></td>
      <td colspan="4">             
                  <div align="left"></div>
             
            <input name="Submit" type="submit" class="botao" value="Confirmar" onClick="troca(dtinic.value,dtfinal.value);">    	  	      	  
                     </td>
      </tr>
  </table>
  <input type="hidden" name="MM_UpdateRecord" value="form1">  
  <input type="hidden" name="scodresp" id="scodresp" value="<cfoutput>#qResposta.Pos_Situacao_Resp#</cfoutput>">
</form>

<!--- Fim Área de conteúdo --->
	  </td>
  </tr>
</table>
<form name="formx"  method="post" action="itens_controle_respostas_solucionados.cfm">  
  <input name="dtinic" type="hidden" id="#form.dtinic#">
  <input name="dtfinal" type="hidden" id="#form.dtfinal#">
</form>
</body>
</html>
