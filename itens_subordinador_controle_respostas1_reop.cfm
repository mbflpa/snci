<cfprocessingdirective pageEncoding ="utf-8"/>
<!--- <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif>   --->
<cfset area = 'sins'>
<cfset Encaminhamento = 'À SGCIN'>
 
<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

<cfif isDefined("Form.Ninsp") and form.Ninsp neq "">
<cfparam name="URL.Unid" default="#Form.Unid#">
<cfparam name="URL.Ninsp" default="#Form.Ninsp#">
<cfparam name="URL.Ngrup" default="#Form.Ngrup#">
<cfparam name="URL.Nitem" default="#Form.Nitem#">
<cfparam name="URL.Desc" default="">
<cfparam name="URL.DGrup" default="">
<cfparam name="URL.numpag" default="0">
<cfparam name="URL.dtFinal" default="">
<cfparam name="URL.DtInic" default="">
<cfparam name="URL.dtFim" default="">
<cfparam name="URL.Reop" default="">
<cfparam name="URL.ckTipo" default="">

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
</cfif>

                                                                  <!--- Teste 1 --->
<cfif IsDefined("FORM.submit") AND (FORM.submit EQ "Salvar" OR Form.submit eq "Salvar e Anexar arquivos")>
 <cfquery datasource="#dsn_inspecao#">
   UPDATE Resultado_Inspecao SET
  <cfif IsDefined("FORM.Melhoria") AND FORM.Melhoria NEQ "">
    RIP_Comentario=
	  <cfset aux_mel = CHR(13) & Form.Melhoria>
	  <!--- As linhas abaixo servem para substituir o uso de aspas simples e duplas, a fim de evitar erros em instruções SQL--->
	   <cfset aux_mel = Replace(aux_mel,'"','','All')>
	   <cfset aux_mel = Replace(aux_mel,"'","","All")>
	   <cfset aux_mel = Replace(aux_mel,'*','','All')>
	  <!--- <cfset aux_mel = Replace(aux_mel,'%','','All')> 
	        <cfset aux_mel = Replace(aux_mel,'&','','All')>
	  --->
	  '#aux_mel#'
   </cfif>
      ,
   <cfif IsDefined("FORM.recomendacao") AND FORM.recomendacao NEQ "">
     RIP_Recomendacoes=
	  <cfset aux_recom = CHR(13) & FORM.recomendacao>
	  <!--- As linhas abaixo servem para substituir o uso de aspas simples e duplas, a fim de evitar erros em instruções SQL--->
	  <cfset aux_recom = Replace(aux_recom,'"','','All')>
	  <cfset aux_recom = Replace(aux_recom,"'","","All")>
	  <cfset aux_recom = Replace(aux_recom,'*','','All')>
	  <!--- <cfset aux_recom = Replace(aux_recom,'%','','All')>
	        <cfset aux_recom = Replace(aux_recom,'&','','All')>
	   --->
	  '#aux_recom#'
    </cfif>
	<cfif IsDefined("FORM.valor") AND FORM.valor NEQ "">
      , RIP_Valor='#FORM.valor#'
    </cfif>
	  , RIP_UserName = '#CGI.REMOTE_USER#'
	  , RIP_DtUltAtu = CONVERT(char, GETDATE(), 120)
	  WHERE RIP_Unidade='#FORM.unid#' AND RIP_NumInspecao='#FORM.ninsp#' AND RIP_NumGrupo=#FORM.ngrup# AND RIP_NumItem=#FORM.nitem#
  </cfquery>
<!--- Teste 1 --->
	<cfif isDefined("Form.submit") and Form.Submit eq 'Salvar e Anexar arquivos'>
	  <cflocation url="itens_usuarios_unidades_transmitir_anexo.cfm?ninsp=#form.Ninsp#&unid=#form.Unid#&ngrup=#form.Ngrup#&nitem=#form.Nitem#">
	</cfif>
</cfif>

<cfquery name="rsItem" datasource="#dsn_inspecao#">
  SELECT RIP_NumInspecao, RIP_Unidade, Und_Descricao, RIP_NumGrupo, RIP_NumItem,Und_TipoUnidade,
  RIP_Comentario, RIP_Recomendacoes, INP_DtInicInspecao, INP_Responsavel, Rep_Codigo, RIP_Valor,Itn_PTC_Seq,
  Itn_Descricao, Itn_ImpactarTipos, INP_DtEncerramento, Grp_Descricao, RIP_ReincInspecao, RIP_ReincGrupo, RIP_ReincItem, RIP_Caractvlr, RIP_Falta, RIP_Sobra, RIP_EmRisco, TNC_ClassifInicio, 
  TNC_ClassifAtual
  FROM Reops 
  INNER JOIN Resultado_Inspecao 
  INNER JOIN Inspecao ON RIP_Unidade = INP_Unidade AND RIP_NumInspecao = INP_NumInspecao 
  INNER JOIN Unidades ON INP_Unidade = Und_Codigo ON Rep_Codigo = Unidades.Und_CodReop 
  INNER JOIN Grupos_Verificacao 
  INNER JOIN Itens_Verificacao 
  ON Grp_Codigo = Itn_NumGrupo and Grp_Ano = Itn_Ano
  ON RIP_NumGrupo = Itn_NumGrupo AND RIP_NumItem = Itn_NumItem AND convert(char(4), RIP_Ano) = Itn_Ano and Itn_TipoUnidade = Und_TipoUnidade AND (INP_Modalidade = Itn_Modalidade)
  left JOIN TNC_Classificacao ON (RIP_NumInspecao = TNC_Avaliacao) AND (RIP_Unidade = TNC_Unidade) 
  WHERE RIP_NumInspecao='#ninsp#' AND RIP_Unidade='#unid#' AND RIP_NumGrupo= #ngrup# AND RIP_NumItem=#nitem#
</cfquery>

<!--- <cfdump var="#rsItem#">
<cfabort> --->

<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT DISTINCT Usu_Apelido, Usu_Lotacao
  FROM Usuarios
  WHERE Usu_Login = '#CGI.REMOTE_USER#'
  GROUP BY Usu_Lotacao, Usu_Apelido
</cfquery>


<cfquery name="qAnexos" datasource="#dsn_inspecao#">
  SELECT Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Codigo, Ane_Caminho
  FROM Anexos
  WHERE  Ane_NumInspecao = '#ninsp#' AND Ane_Unidade = '#unid#' AND Ane_NumGrupo = #ngrup# AND Ane_NumItem = #nitem#
  order by Ane_Codigo
</cfquery>

<!--- Nova consulta para verificar respostas das unidades --->

<cfquery name="qResposta" datasource="#dsn_inspecao#">
  SELECT Pos_NumGrupo, Pos_NumItem, Pos_Unidade, Pos_Situacao_Resp, Pos_Parecer, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS Data
  FROM ParecerUnidade
  WHERE  Pos_NumGrupo = #ngrup# AND Pos_NumItem = #nitem# AND Pos_Unidade = '#unid#' AND Pos_Inspecao = '#ninsp#'
</cfquery>

<cfquery name="qResponsavel" datasource="#dsn_inspecao#">
  SELECT INP_Responsavel
  FROM Inspecao
  WHERE (INP_NumInspecao = '#URL.Ninsp#')
</cfquery>

<cfquery name="qInspetor" datasource="#dsn_inspecao#">
  SELECT Inspetor_Inspecao.IPT_MatricInspetor, Funcionarios.Fun_Nome
  FROM Inspetor_Inspecao INNER JOIN Funcionarios ON Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric AND Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric
  WHERE (IPT_NumInspecao = '#URL.Ninsp#')
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
   <cfif IsDefined("FORM.observacao") AND FORM.observacao NEQ "">
	, Pos_Parecer=
	  <!--- As linhas abaixo servem para substituir o uso de aspas simples e duplas, a fim de evitar erros em instruções SQL --->
	  <cfset aux_obs = Trim(FORM.observacao)>
	  <cfset aux_obs = Replace(aux_obs,'"','','All')>
	  <cfset aux_obs = Replace(aux_obs,"'","","All")>
	  <cfset aux_obs = Replace(aux_obs,'*','','All')>
      <cfset aux_obs = Replace(aux_obs,'>','','All')>				  
	<!---	 <cfset aux_obs = Replace(aux_obs,'&','','All')>
		     <cfset aux_obs = Replace(aux_obs,'%','','All')> --->
     <cfset pos_obs = Form.H_obs & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & Trim(Encaminhamento) & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & 'Situação: RESPOSTA DA UNIDADE' & CHR(13) & CHR(13) & 'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_Lotacao) & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
	'#pos_obs#'
  </cfif>
  , Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(now()),month(now()),day(now())))#
  , Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
  , Pos_NomeResp='#CGI.REMOTE_USER#'
  , Pos_username = '#CGI.REMOTE_USER#'
  , Pos_Situacao = 'RU'
  WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
  </cfquery>

 <!--- Inserindo dados dados na tabela Andamento --->
	<cfset hhmmssdc = timeFormat(now(), "HH:MM:ssl")>
	<cfset hhmmssdc = Replace(hhmmssdc,':','',"All")>
	<cfset hhmmssdc = Replace(hhmmssdc,'.','',"All")>
 <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>' & Trim(Encaminhamento) & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & 'Situação: RESPOSTA DA UNIDADE' & CHR(13) & CHR(13) & 'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_Lotacao) & CHR(13) & CHR(13) & '--------------------------------------------------------------------------------------------------------------'>
 <cfquery datasource="#dsn_inspecao#">
    insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Orgao_Solucao) 
    values ('#FORM.ninsp#', '#FORM.unid#', '#FORM.ngrup#', '#FORM.nitem#', #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#, '#CGI.REMOTE_USER#', '#FORM.frmResp#', '#hhmmssdc#', '#and_obs#', '#qUsuario.Usu_Lotacao#')
 </cfquery>

 <cfif form.salvar_anexar is "anexar">
    <cflocation url="itens_usuarios_unidades_transmitir_anexo.cfm?ninsp=#form.Ninsp#&unid=#form.Unid#&ngrup=#form.Ngrup#&nitem=#form.Nitem#">
  </cfif>

  <cflocation url="itens_unidades_controle_respostas.cfm?#CGI.QUERY_STRING#">

</cfif>
 <cfquery name="rsMOd" datasource="#dsn_inspecao#">
   SELECT Unidades.Und_Descricao, Unidades.Und_CodReop
   FROM Unidades
   WHERE Unidades.Und_Codigo = '#URL.Unid#'
</cfquery>

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="css.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
<cfinclude template="mm_menu.js">

//==================================
function anexar(){
    if(document.form1.observacao.value == ''){
		       alert('O campo Manifestar-se deve ser preenchido!');
		       return false;
	         }
    document.form1.salvar_anexar.value = 'anexar';
	document.form1.submit();
}

function salvar(){
    if(document.form1.observacao.value == ''){
		       alert('O campo Manifestar-se deve ser preenchido!');
		       return false;
    	     }
    document.form1.salvar_anexar.value = 'salvar';
   	document.form1.submit();
}

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
function popupPage() {
<cfoutput>  //página chamada, seguida dos parâmetros número, unidade, grupo e item
var page = "itens_unidades_controle_respostas_comentarios.cfm?numero=#ninsp#&unidade=#unid#&numgrupo=#ngrup#&numitem=#nitem#";
</cfoutput>
windowprops = "location=no,"
+ "scrollbars=yes,width=750,height=500,top=100,left=200,menubars=no,toolbars=no,resizable=yes";
window.open(page, "Popup", windowprops);
}

function mensagem(){
	alert('Sr. Inspetor, se necessário ajuste os campos Situação Encontrada e/ou Orientação');
	}
</script>
</head>

<cfquery name="qVerificaRevisao" datasource="#dsn_inspecao#">
  SELECT ParecerUnidade.Pos_Inspecao, ParecerUnidade.Pos_Situacao_Resp
  FROM ParecerUnidade
  WHERE ParecerUnidade.Pos_NumGrupo = #ngrup# AND ParecerUnidade.Pos_NumItem = #nitem# AND ParecerUnidade.Pos_Unidade = '#unid#' AND ParecerUnidade.Pos_Inspecao = '#ninsp#' AND ((ParecerUnidade.Pos_Situacao_Resp = 0) OR (ParecerUnidade.Pos_Situacao_Resp = 13))
</cfquery>

<cfset DataDia = DateFormat(now(),'DD/MM/YYYY')>

<cfset DtEncerramento = DateFormat(rsItem.INP_DtEncerramento,'DD/MM/YYYY')>

<cfif (qVerificaRevisao.recordcount neq 0 and DtEncerramento eq DataDia)>
  <body onLoad="mensagem()">
<cfelse>
  <body onLoad="">
</cfif>

 <cfinclude template="cabecalho.cfm">

       <!--- Área de conteúdo   --->

<table width="99%" height="60" align="center">
<tr>
	  <td width="74%" valign="top">
	<form name="form1" method="post" onSubmit="return valida_form(this.name)"  action="<cfoutput>#CurrentPage#?#CGI.QUERY_STRING#</cfoutput>">

        <table width="70%" align="center">
         <tr>
		    <br>
              <td colspan="7"><p align="center" class="titulo1"><strong>Ponto de Avaliação de Controle Interno</strong>
                      <input name="unid" type="hidden" id="unid" value="<cfoutput>#URL.Unid#</cfoutput>">
                      <input name="ninsp" type="hidden" id="ninsp" value="<cfoutput>#URL.Ninsp#</cfoutput>">
                      <input name="ngrup" type="hidden" id="ngrup" value="<cfoutput>#URL.Ngrup#</cfoutput>">
                      <input name="nitem" type="hidden" id="nitem" value="<cfoutput>#URL.Nitem#</cfoutput>">
					  <cfset caracvlr = #trim(rsItem.RIP_Caractvlr)#>

              </p></td>
          </tr>
          <tr bgcolor="#FFFFFF" class="exibir">
            <td colspan="8">&nbsp;</td>
          </tr>
          <tr class="exibir">
            <td width="97" bgcolor="eeeeee">Unidade </td>
            <td colspan="2" bgcolor="eeeeee"><cfoutput><strong>#rsMOd.Und_Descricao#</strong></cfoutput></td>
            <td bgcolor="eeeeee">Respons&aacute;vel</td>
            <td bgcolor="eeeeee"><cfoutput><strong>#qResponsavel.INP_Responsavel#</strong></cfoutput></td>
          </tr>
          <tr class="exibir">
            <cfif qInspetor.RecordCount lt 2>
              <td bgcolor="eeeeee">Inspetor</td>
              <cfelse>
              <td width="192" bgcolor="eeeeee">Inspetores</td>
            </cfif>
            <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
            <td colspan="7" bgcolor="eeeeee">-&nbsp;<cfoutput query="qInspetor"><strong>#qInspetor.Fun_Nome#</strong>&nbsp;<cfif qInspetor.currentrow neq qInspetor.recordcount><br>- </cfif></cfoutput></td>
          </tr>
          <tr class="exibir">
            <td bgcolor="eeeeee">Relatório</td>
            <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
            <td colspan="7" bgcolor="eeeeee"><cfoutput><strong>#Num_Insp#</strong></cfoutput></td>
          </tr>
          <tr class="exibir">
            <td bgcolor="eeeeee">Grupo</td>
            <td width="15" bgcolor="eeeeee"><cfoutput>#URL.Ngrup#</cfoutput></td>
            <td colspan="6" bgcolor="eeeeee"><cfoutput><strong>#rsItem.Grp_Descricao#</strong></cfoutput></td>
          </tr>
          <tr class="exibir">
            <td bgcolor="eeeeee">Item</td>
            <td bgcolor="eeeeee"><cfoutput>#URL.Nitem#</cfoutput></td>
            <td colspan="6" bgcolor="eeeeee"><cfoutput><strong>#rsItem.Itn_Descricao#</strong></cfoutput></td>
          </tr>
		 <tr class="exibir">
			<td bgcolor="eeeeee">Relevância</td>
			<td colspan="5" bgcolor="eeeeee">
				<table width="100%" border="0">
					<tr class="exibir">
					  <td width="70">Pontuação </td>
					  <td width="50"><strong class="exibir"><cfoutput>#qResposta.Pos_PontuacaoPonto#</cfoutput></strong></td>
					  <td width="169"><div align="right">Classificação do Ponto &nbsp;</div></td>
					  <td width="538"><strong class="exibir"><cfoutput>#qResposta.Pos_ClassificacaoPonto#</cfoutput></strong></td>
					</tr>
				</table>
			</td>
		</tr>	
		<tr bgcolor="eeeeee" class="exibir">
			<td>Classificação Unidade</td>
			<td colspan="7">
			<table width="100%" border="0">
				<tr>
					<td width="15%" class="exibir"><div align="center">Classificação Inicial:</div></td>
					<td width="35%" class="exibir"><strong><cfoutput>#rsItem.TNC_ClassifInicio#</cfoutput></strong></td>
					<td width="18%" class="exibir"><div align="center">Classificação Atual:</div></td>
					<td width="32%" class="exibir"><div align="left"><strong><cfoutput>#rsItem.TNC_ClassifAtual#</cfoutput></strong></div></td>
				</tr>
			</table>
			</td>
		</tr>			
<cfoutput>		
<cfset reincSN = "N">
<cfset aux_reincSN = "Nao">
<cfset db_reincInsp = "">
<cfset db_reincGrup = 0>
<cfset db_reincItem = 0>
<cfif rsItem.RIP_ReincGrupo neq 0>
	<cfset reincSN = "S">
	<cfset aux_reincSN = "Sim">
	<cfset db_reincInsp = #trim(rsItem.RIP_ReincInspecao)#>
	<cfset db_reincGrup = #rsItem.RIP_ReincGrupo#>
	<cfset db_reincItem = #rsItem.RIP_ReincItem#>
</cfif>	   
	<cfif reincSN eq 'S'>
		<tr class="red_titulo">
			<td bgcolor="eeeeee">Reincidência</td>
			<td colspan="6" bgcolor="eeeeee">Nº Avaliação:
				<input name="frmreincInsp" type="text" class="form" id="frmreincInsp" size="16" maxlength="10" value="#db_reincInsp#" onKeyPress="numericos(this.value)">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nº Grupo:
			<input name="frmreincGrup" type="text" class="form" id="frmreincGrup" size="8" maxlength="5" value="#db_reincGrup#" onKeyPress="numericos(this.value)">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nº Item:
			<input name="frmreincItem" type="text" class="form" id="frmreincItem" size="7" maxlength="4" value="#db_reincItem#" onKeyPress="numericos(this.value)">
			</strong>		  
			</td>
	</tr>
	</cfif> 
	<cfset tipoimpacto = 'NÃO QUANTIFICADO'>
	<cfif listFind(#rsItem.Itn_PTC_Seq#,'10')>
	<cfset tipoimpacto = 'QUANTIFICADO'>
	</cfif>
	<cfset falta = lscurrencyformat(rsItem.RIP_Falta,'Local')>
	<cfset sobra = lscurrencyformat(rsItem.RIP_Sobra,'Local')>
	<cfset emrisco = lscurrencyformat(rsItem.RIP_EmRisco,'Local')>	
 	<tr class="exibir">
      <td bgcolor="eeeeee"><div id="impactofin">IMPACTO FINANCEIRO (Valor)</div></td>
      <td colspan="6" bgcolor="eeeeee">
		  <table width="100%" border="0" cellspacing="0" bgcolor="eeeeee">
			<tr class="exibir"><strong>
				<td width="40%" bgcolor="eeeeee"><strong>&nbsp;#tipoimpacto#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Falta(R$):&nbsp;<input name="frmfalta" type="text" class="form" value="#falta#" size="22" maxlength="17" readonly></strong></td>
				<td width="30%" bgcolor="eeeeee"><strong>Sobra(R$):&nbsp;<input name="frmsobra" type="text" class="form" value="#sobra#" size="22" maxlength="17" readonly></strong></td>
				<td width="30%" bgcolor="eeeeee"><strong>Em Risco(R$):&nbsp;<input name="frmemrisco" type="text" class="form" value="#emrisco#" size="22" maxlength="17" readonly></strong></td>
			</tr>
		  </table>		  
	  </td>
    </tr>	  
	</cfoutput>

    <tr>
	 <td height="38" bgcolor="#eeeeee" align="center"><span class="titulos">Situação Encontrada:</span></td>
        <cfset melhoria = '#rsItem.RIP_Comentario#'>
	     <td colspan="4" bgcolor="eeeeee"><textarea name="Melhoria" cols="200" rows="20" wrap="VIRTUAL" class="form" readonly><cfoutput>#melhoria#</cfoutput></textarea></td>
	 </tr>
       <!--- <input type="hidden" name="recom" value="<cfoutput>#qResposta.RIP_Recomendacoes#</cfoutput>"> --->
    <tr>
      <td height="38"  bgcolor="eeeeee" align="center"><span class="titulos">Orientações:</span></td>
      <cfif (qResposta.Pos_Situacao_Resp is 0) or (qResposta.Pos_Situacao_Resp is 11)>
        <td colspan="4" bgcolor="eeeeee"><textarea name="recomendacao" cols="200" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#rsItem.RIP_Recomendacoes#</cfoutput></textarea></td>
	 </tr>
	  <tr>
        <td colspan="4">&nbsp;</td>
      </tr>
	      <tr>
	        <td colspan="4" class="exibir" bgcolor="#eeeeee"><div align="center"><strong>ANEXOS</strong></div></td>
	        <td class="exibir" bgcolor="#eeeeee"><input type="Submit" name="Submit" value="Salvar e Anexar arquivos" class="botao"></td>
          </tr>
		 <tr>
            <td colspan="4">&nbsp;</td>
          </tr>
    <cfloop query= "qAnexos">
       <cfif FileExists(qAnexos.Ane_Caminho)>
        <tr>
         <td colspan="3" bgcolor="#eeeeee" class="form"><cfoutput>#ListLast(qAnexos.Ane_Caminho,'\')#</cfoutput></td>
         <td width="20" bgcolor="#eeeeee"><cfset arquivo = ListLast(qAnexos.Ane_Caminho,'\')>
           <input type="button" class="botao" name="Abrir" value="Abrir" onClick="window.open('abrir_pdf_act.cfm?arquivo=<cfoutput>#arquivo#</cfoutput>','_blank')" /></td>
         <td bgcolor="eeeeee"><cfoutput>
          <input name="button" type="button" class="botao" onClick="window.open('excluir_anexo.cfm?ninsp=#URL.Ninsp#&unid=#URL.Unid#&ngrup=#URL.Ngrup#&nitem=#URL.Nitem#&cktipo=#url.cktipo#&dtfim=#url.dtfim#&dtinic=#url.dtinic#&Ane_codigo=#qAnexos.Ane_Codigo#','_self')" value="Excluir">
         </cfoutput></td>
        </tr>
        </cfif>
     </cfloop>
          <tr>
            <td colspan="4">&nbsp;</td>
          </tr>
	  <tr align="center">
         <td colspan="4" align="right"><cfoutput><input type="button" class="botao" value="Voltar" onClick="window.open('itens_unidades_controle_respostas.cfm?ninsp=#URL.Ninsp#&unid=#URL.Unid#&ngrup=#URL.Ngrup#&nitem=#URL.Nitem#&dtfim=#url.dtfim#&dtinic=#url.dtinic#&cktipo=#url.cktipo#','_self')"></cfoutput></td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<td align="left"><input type="Submit" name="Submit" value="Salvar" class="botao"></td>
	   <cfabort>
	   <cfelse>
       <td colspan="8" bgcolor="eeeeee"><textarea name="recomendacao" cols="200" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#rsItem.RIP_Recomendacoes#</cfoutput></textarea></td>
       </tr>
       </cfif>
		    <input type="hidden" name="frmResp" value="1">
           <!---  <input type="hidden" name="obs" value="<cfoutput>#qResposta.Pos_Parecer#</cfoutput>"> --->
          <tr>
            <td height="38" align="center" bgcolor="eeeeee" class="exibir"><span class="titulos">Histórico:</span> <span class="titulos">Manifestações e Plano de Ação/Análise do Controle Interno</span><span class="titulos">:</span></td>

			<td colspan="4" bgcolor="eeeeee"><cfif Not IsDefined("FORM.MM_UpdateRecord") And Trim(qResposta.Pos_Parecer) neq ''>
              <textarea name="H_obs" cols="200" rows="40" wrap="VIRTUAL" class="form" readonly><cfoutput>#qResposta.Pos_Parecer#</cfoutput></textarea></cfif></td>
          </tr>

		 <tr>
	        <td colspan="5" class="exibir" bgcolor="#eeeeee"><div align="center"><strong>ANEXOS</strong></div></td>

          </tr>
		  <tr>
            <td colspan="4">&nbsp;</td>
          </tr>
    <cfloop query= "qAnexos">
       <cfif FileExists(qAnexos.Ane_Caminho)>
        <tr>
         <td colspan="4" bgcolor="#eeeeee" class="form"><cfoutput>#ListLast(qAnexos.Ane_Caminho,'\')#</cfoutput></td>
         <td width="20" bgcolor="#eeeeee"><cfset arquivo = ListLast(qAnexos.Ane_Caminho,'\')>
           <input type="button" class="botao" name="Abrir" value="Abrir" onClick="window.open('abrir_pdf_act.cfm?arquivo=<cfoutput>#arquivo#</cfoutput>','_blank')" /></td>
        </tr>
        </cfif>
     </cfloop>
          <tr>
            <td colspan="5">&nbsp;</td>
          </tr>
		  <tr>
		   <td colspan="6"><div align="center">
                  <input name="Voltar" type="button" class="botao" value="Voltar" onClick="history.back()">
            </div></td>
			</tr>

        </table>
      </div>
<cfoutput>      
    <input type="hidden" name="MM_UpdateRecord" value="form1">
		<input type="hidden" name="salvar_anexar" value="">
		<input type="hidden" name="scodresp" id="scodresp" value="#qResposta.Pos_Situacao_Resp#">
		<input name="reincideSN" type="hidden" id="reincideSN" value="#reincSN#">	   
</cfoutput>       
	</form>

         <!--- Fim Área de conteúdo --->
</td>		 
 </tr>
</table>
</body>

<script>
	<cfoutput>
		<!---Retorna true se a data de início da inspeção for maior ou igual a 04/03/2021, data em que o editor de texto foi implantado. Isso evitará que os textos anteriores sejam desformatados--->
		<cfset CouponDate = createDate( 2021, 03, 04 ) />
		<cfif DateDiff( "d", '#rsItem.INP_DtInicInspecao#',CouponDate ) GTE 1>
			<cfset usarEditor = false />
		<cfelse>
			<cfset usarEditor = true />
		</cfif>
		var usarEditor = #usarEditor#;
	</cfoutput>
	if(usarEditor == true){
		//configurações diferenciadas do editor de texto.
		CKEDITOR.replace('Melhoria', {
		width: 1020,
		height: 200,
		toolbar:[
		{ name: 'document', items: ['Preview', 'Print', '-' ] },
		{ name: 'colors', items: [ 'TextColor', 'BGColor' ] },
		{ name: 'styles', items: [ 'Styles'] },
		{ name: 'basicstyles', items: [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ] },
		{ name: 'paragraph', items: [ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-', 'BidiLtr', 'BidiRtl' ] },
		{ name: 'insert', items: [ 'Table' ] },		
		{ name: 'insert', items: [ 'HorizontalRule' ] }
		], 
			
		// Remove the redundant buttons from toolbar groups defined above.
		removeButtons:'Cut,Copy,Paste,PasteText,PasteFromWord,Undo,Redo,Find,Replace,SelectAll,CopyFormatting,RemoveFormat'
		// removeButtons: 'Source,Save,NewPage,ExportPdf,Templates,Cut,Copy,Paste,PasteText,PasteFromWord,Undo,Redo,Find,Replace,SelectAll,Scayt,Form,Radio,TextField,Textarea,Select,ImageButton,HiddenField,Button,Bold,Italic,Underline,Strike,Subscript,Superscript,CopyFormatting,RemoveFormat,NumberedList,BulletedList,Outdent,Indent,Blockquote,CreateDiv,JustifyLeft,JustifyCenter,JustifyRight,JustifyBlock,BidiLtr,BidiRtl,Language,Link,Unlink,Anchor,Image,Flash,Table,HorizontalRule,Smiley,SpecialChar,PageBreak,Iframe,Styles,Format,Font,FontSize,TextColor,BGColor,Maximize,ShowBlocks,About,Checkbox'

		});

		CKEDITOR.replace('recomendacao', {
		width: 1020,
		height: 100,
		toolbar:[
		{ name: 'document', items: ['Preview', 'Print', '-' ] },
		{ name: 'colors', items: [ 'TextColor', 'BGColor' ] },
		{ name: 'styles', items: [ 'Styles'] },
		{ name: 'basicstyles', items: [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ] },
		{ name: 'paragraph', items: [ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-', 'BidiLtr', 'BidiRtl' ] },
		{ name: 'insert', items: [ 'Table' ] },		
		{ name: 'insert', items: [ 'HorizontalRule' ] }
		], 
			
		// Remove the redundant buttons from toolbar groups defined above.
		removeButtons:'Cut,Copy,Paste,PasteText,PasteFromWord,Undo,Redo,Find,Replace,SelectAll,CopyFormatting,RemoveFormat'
		// removeButtons: 'Source,Save,NewPage,ExportPdf,Templates,Cut,Copy,Paste,PasteText,PasteFromWord,Undo,Redo,Find,Replace,SelectAll,Scayt,Form,Radio,TextField,Textarea,Select,ImageButton,HiddenField,Button,Bold,Italic,Underline,Strike,Subscript,Superscript,CopyFormatting,RemoveFormat,NumberedList,BulletedList,Outdent,Indent,Blockquote,CreateDiv,JustifyLeft,JustifyCenter,JustifyRight,JustifyBlock,BidiLtr,BidiRtl,Language,Link,Unlink,Anchor,Image,Flash,Table,HorizontalRule,Smiley,SpecialChar,PageBreak,Iframe,Styles,Format,Font,FontSize,TextColor,BGColor,Maximize,ShowBlocks,About,Checkbox'

		});
	}
            
</script>
</html>
