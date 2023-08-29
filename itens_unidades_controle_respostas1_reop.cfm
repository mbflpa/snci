<cfprocessingdirective pageEncoding ="utf-8"/> 
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
<cfparam name="URL.DtInic" default="0">
<cfparam name="URL.DtFinal" default="0">
<cfparam name="url.reop" default="">
<cfif IsDefined("dtini")><cfset Url.DtInic = DtIni></cfif>

<cfquery name="qAnexos" datasource="#dsn_inspecao#">
SELECT     Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Codigo, Ane_Caminho
FROM Anexos
WHERE  Ane_NumInspecao = '#ninsp#' AND Ane_Unidade = '#unid#' AND Ane_NumGrupo = #ngrup# AND Ane_NumItem = #nitem# 
order by Ane_Codigo
</cfquery>


<cfquery name="rsItem" datasource="#dsn_inspecao#">
  SELECT Resultado_Inspecao.RIP_NumInspecao, Resultado_Inspecao.RIP_Unidade, Unidades.Und_Descricao, Resultado_Inspecao.RIP_NumGrupo, Resultado_Inspecao.RIP_NumItem, Resultado_Inspecao.RIP_Comentario, Resultado_Inspecao.RIP_Recomendacoes, Inspecao.INP_DtInicInspecao, Inspecao.INP_Responsavel
  FROM (Unidades 
  INNER JOIN ((Resultado_Inspecao 
  INNER JOIN Inspecao ON (RIP_Unidade = INP_Unidade) AND (RIP_NumInspecao = INP_NumInspecao)) 
  INNER JOIN Grupos_Verificacao 
  ON RIP_NumGrupo = Grp_Codigo) 
  ON Und_Codigo = INP_Unidade) 
  INNER JOIN Itens_Verificacao 
  ON Grp_Codigo = Itn_NumGrupo AND Itn_Ano = Grp_Ano and convert(char(4),RIP_Ano) = Itn_Ano 
  and (Itn_TipoUnidade = Und_TipoUnidade) AND (INP_Modalidade = Itn_Modalidade) and
   (RIP_NumItem = Itn_NumItem)
  WHERE Resultado_Inspecao.RIP_NumInspecao='#ninsp#' AND Resultado_Inspecao.RIP_Unidade='#unid#' AND Resultado_Inspecao.RIP_NumGrupo= #ngrup# AND Resultado_Inspecao.RIP_NumItem=#nitem#
</cfquery>


<cfquery name="qUsuario" datasource="#dsn_inspecao#">
 SELECT DISTINCT Usu_Apelido, Usu_Lotacao
 FROM Usuarios
 WHERE Usu_Login = '#CGI.REMOTE_USER#'
 GROUP BY Usu_Apelido, Usu_Lotacao 
</cfquery>

<!--- Nova consulta para verificar respostas das unidades --->
<cfquery name="qResposta" datasource="#dsn_inspecao#">
SELECT .Pos_NumGrupo,     
       ParecerUnidade.Pos_NumItem, ParecerUnidade.Pos_Unidade, 
       ParecerUnidade.Pos_Situacao_Resp, ParecerUnidade.Pos_Parecer
FROM   ParecerUnidade 
WHERE  ParecerUnidade.Pos_NumGrupo = #ngrup# AND ParecerUnidade.Pos_NumItem = #nitem# AND ParecerUnidade.Pos_Unidade = '#unid#' AND ParecerUnidade.Pos_Inspecao = '#ninsp#' 
</cfquery>

<!--- <cfdump var="#qResposta#">

<cfabort> --->

<cfquery name="qResponsavel" datasource="#dsn_inspecao#">
SELECT     INP_Responsavel
FROM         Inspecao
WHERE     (INP_NumInspecao = #URL.Ninsp#) 
</cfquery>

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
  , Pos_DtPosic=#CreateDate(Year(Now()),Month(Now()),Day(Now()))#
  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(now()),month(now()),day(now())))#
  , Pos_NomeResp='#CGI.REMOTE_USER#'
  , Pos_username = '#CGI.REMOTE_USER#'
  WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem# 
  </cfquery>
 </cfif> 
 <!--- Inserindo dados dados na tabela Andamento --->
  <cfif IsDefined("FORM.MM_UpdateRecord") AND FORM.MM_UpdateRecord EQ "form1" And IsDefined("FORM.acao") And Form.acao is "Salvar2">
 <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & Trim(Encaminhamento)  & CHR(13) & CHR(13) & 'À(O)' & '  ' & Gestor & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & 'Situação: ' & situacao & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
 <cfquery datasource="#dsn_inspecao#">
    insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_Orgao_Solucao, And_HrPosic, And_Parecer) values ('#FORM.ninsp#', '#FORM.unid#', '#FORM.ngrup#', '#FORM.nitem#', convert(char, getdate(), 102), '#CGI.REMOTE_USER#', '#FORM.frmResp#', '#qUsuario.Usu_Lotacao#', convert(char, getdate(), 108), '#and_obs#')
 </cfquery>
     
 
   <cflocation url="itens_unidades_controle_respostas_reop.cfm?#CGI.QUERY_STRING#">
</cfif>
<cfquery name="rsMod" datasource="#dsn_inspecao#">
SELECT Unidades.Und_Descricao, Unidades.Und_CodReop
FROM Unidades
WHERE Unidades.Und_Codigo = '#URL.Unid#' 
</cfquery>

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
function popupPage() {
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
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="css.css" rel="stylesheet" type="text/css">

</head>
<body>
<cfset form.acao = ''>
<cfinclude template="cabecalho.cfm">
<table width="77%" height="60%">
<tr>
	  <td width="74%" valign="top">
<!--- Área de conteúdo   --->
	<form name="form1" method="post" onSubmit="return valida_form(this.name)" action="<cfoutput>#CurrentPage#?#CGI.QUERY_STRING#</cfoutput>">
      <div align="right">
        <table width="74%" align="center">
          <tr><br>
              <td colspan="7"><p align="center" class="titulo1"><strong>ponto de auditoria </strong>
                      <input name="unid" type="hidden" id="unid" value="<cfoutput>#URL.Unid#</cfoutput>">
                      <input name="ninsp" type="hidden" id="ninsp" value="<cfoutput>#URL.Ninsp#</cfoutput>">
                      <input name="ngrup" type="hidden" id="ngrup" value="<cfoutput>#URL.Ngrup#</cfoutput>">
                      <input name="nitem" type="hidden" id="nitem" value="<cfoutput>#URL.Nitem#</cfoutput>">
                      <input name="dtinicio" type="hidden" id="dtinicio" value="<cfoutput>#URL.DtInic#</cfoutput>">
                      <input name="dtfinal" type="hidden" id="dtfinal" value="<cfoutput>#URL.DtFinal#</cfoutput>">
                      <input name="reop" type="hidden" id="reop" value="<cfoutput>#URL.reop#</cfoutput>">
              </p></td>
          </tr>
          <tr bgcolor="#FFFFFF" class="exibir">
            <td colspan="7">&nbsp;</td>
          </tr>
          <tr class="exibir">
            <td width="97" bgcolor="eeeeee">Unidade </td>
            <td colspan="2" bgcolor="f7f7f7"><cfoutput><strong>#rsMOd.Und_Descricao#</strong></cfoutput></td>
            <td width="128" bgcolor="f7f7f7">Respons&aacute;vel</td>
            <td width="200" colspan="3" bgcolor="f7f7f7"><cfoutput><strong>#qResponsavel.INP_Responsavel#</strong></cfoutput></td>
            </tr>
          <tr class="exibir">
            <cfif qInspetor.RecordCount lt 2>
              <td bgcolor="eeeeee">Analista</td>
              <cfelse>
              <td width="162" bgcolor="eeeeee">Analistas</td>
            </cfif>
            <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
            <td colspan="6" bgcolor="f7f7f7">-&nbsp;<cfoutput query="qInspetor"><strong>#qInspetor.Fun_Nome#</strong>&nbsp;<cfif qInspetor.currentrow neq qInspetor.recordcount><br>- </cfif></cfoutput></td>
          </tr>
          <tr class="exibir">
            <td bgcolor="eeeeee">Auditoria</td>
            <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
            <td colspan="2" bgcolor="f7f7f7"><cfoutput><strong>#Num_Insp#</strong></cfoutput></td>
            <td colspan="4" bgcolor="f7f7f7"><cfoutput></cfoutput><cfoutput></cfoutput></td>
            </tr>
          <tr class="exibir">
            <td bgcolor="eeeeee">Objetivo</td>
            <td width="162" bgcolor="f7f7f7"><cfoutput>#URL.Ngrup#</cfoutput></td>
            <td colspan="5" bgcolor="f7f7f7"><cfoutput><strong>#URL.DGrup#</strong></cfoutput></td>
            </tr>
          <tr class="exibir">
            <td bgcolor="eeeeee">Item</td>
            <td bgcolor="f7f7f7"><cfoutput>#URL.Nitem#</cfoutput></td>
            <td colspan="5" bgcolor="f7f7f7"><cfoutput><strong>#URL.Desc#</strong></cfoutput></td>
            </tr>
          <tr class="exibir">
            <td colspan="7" bgcolor="f7f7f7">&nbsp;</td>
            </tr>
          <tr class="exibir">
            <td colspan="7" bgcolor="f7f7f7"></td>
           </tr>
        <!---  <tr class="exibir">
            <td bgcolor="eeeeee">&nbsp;</td>
            <td colspan="5" bgcolor="f7f7f7"><cfoutput>
                <input name="comentarios" type="button" class="botao" onClick="window.open('itens_unidades_controle_respostas_comentarios.cfm?numero=#URL.ninsp#&unidade=<cfoutput>#URL.unid#</cfoutput>&numgrupo=<cfoutput>#URL.ngrup#</cfoutput>&numitem=<cfoutput>#URL.nitem#</cfoutput>','','scrollbars=yes, resizable=yes, width=600, height=460, left=120, top=100')" value="Situação Encontrada">
            </cfoutput></td>
          </tr> --->
          <input type="hidden" name="frmResp" value="7">
          <input type="hidden" name="obs" value="<cfoutput>#qResposta.Pos_Parecer#</cfoutput>">
          <tr>
            <td valign="middle" bgcolor="eeeeee" class="exibir"><span class="titulos">Situação Encontrada:</span></td>
            <td colspan="6" bgcolor="f7f7f7"><span class="exibir">
              <textarea name="Melhoria" cols="120" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#rsItem.RIP_Comentario#</cfoutput></textarea>
            </span></td>
            <input type="hidden" name="frmResp" value="3">
            <!--- <input type="hidden" name="obs" value="<cfoutput>#qResposta.Pos_Parecer#</cfoutput>"> --->
          <tr>
            <td valign="middle" bgcolor="eeeeee" class="exibir"><span class="titulos">Hist&oacute;rico:</span> <span class="titulos">Manifesta&ccedil;&atilde;o/An&aacute;lise da Auditoria</span><span class="titulos">:</span></td>
            <td colspan="6" bgcolor="f7f7f7"><cfif Not IsDefined("FORM.MM_UpdateRecord") And Trim(qResposta.Pos_Parecer) neq ''>
              <textarea name="H_obs" cols="120" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#qResposta.Pos_Parecer#</cfoutput></textarea></cfif>
               <!--- <textarea name="observacao" cols="120" rows="5" nome="Observação" vazio="false" wrap="VIRTUAL" class="form" id="observacao"></textarea></td>--->
          </tr>
          <tr>
            <td bgcolor="eeeeee"><span class="exibir"><span class="titulos">Recomenda&ccedil;&otilde;es:</span></span></td>
            <td colspan="6"><span class="exibir">
              <textarea name="H_recom" cols="120" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#rsItem.RIP_Recomendacoes#</cfoutput></textarea>
            </span></td>
          </tr>		  
          <tr>
            <td colspan="7" bgcolor="eeeeee"><span class="exibir"><strong>ANEXOS</strong>
            </span> <!---<cfoutput><span class="exibir">
              <input type="button" value="Anexar arquivos" class="botao" onClick="window.open('itens_usuarios_transmitir_anexo.cfm?ninsp=#URL.Ninsp#&unid=#URL.Unid#&ngrup=#URL.Ngrup#&nitem=#URL.Nitem#&area=#url.area#','_self')">
            </span></cfoutput>---></td>
            </tr>
		<cfloop query="qAnexos">
	  	   <cfif FileExists(qAnexos.Ane_Caminho)>
	        <tr>
      		 <td colspan="2" bgcolor="eeeeee">				
				<a target="_blank" href="<cfoutput>#qAnexos.Ane_Caminho#</cfoutput>"></a><a target="_blank" href="<cfoutput>#qAnexos.Ane_Caminho#</cfoutput>"><span class="link1"><cfoutput>#ListLast(qAnexos.Ane_Caminho,'\')#</cfoutput></span></a></td>
			<cfoutput>
			  <td colspan="6" bgcolor="eeeeee">
			  <!--- <input type="button" class="botao" value="Excluir" onClick="window.open('excluir_usuario_anexo.cfm?ninsp=#URL.Ninsp#&unid=#URL.Unid#&ngrup=#URL.Ngrup#&nitem=#URL.Nitem#&Ane_codigo=#qAnexos.Ane_Codigo#&area=#url.area#','_self')"> --->
			  </td>
			</cfoutput>			     
		    </tr>
		  </cfif>
	   </cfloop>
          <tr>
            <td colspan="5">&nbsp;</td>
            </tr>
          <tr>
            <td colspan="5">&nbsp;</td>
            </tr>
          <tr>		  
            <td colspan="3"><div align="right">
                <input name="Cancelar" type="button" class="botao" value="Voltar" onClick="history.back()">
            </div></td>
            <td colspan="2"><div align="right"> </div>
             <cfif IsDefined("dtini")>			    
                  <div align="right">
                    <input name="Submit" type="submit" class="botao" value="Confirmar">
                  </div>
			  </cfif>
              </td>
          </tr>
        </table>
        <input type="hidden" name="MM_UpdateRecord" value="form1">
		<input type="hidden" name="scodresp" id="scodresp" value="<cfoutput>#qResposta.Pos_Situacao_Resp#</cfoutput>">
      </div>
	</form>

<!--- Fim Área de conteúdo --->
	  </td>
  </tr>
</table>
</body>
</html>
