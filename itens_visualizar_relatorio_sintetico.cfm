<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfset CurrentPage=GetFileFromPath(GetTemplatePath())><cfparam name="URL.Relat" default="0"><cfparam name="URL.Unid" default="0">
<cfparam name="PageNum_rsItem" default="1">
<cfif IsDefined("URL.Unid")>
<cfquery name="rsItem" datasource="#dsn_inspecao#">
SELECT Resultado_Inspecao.RIP_Unidade, Resultado_Inspecao.RIP_NumInspecao, Resultado_Inspecao.RIP_NumGrupo, Resultado_Inspecao.RIP_NumItem, Resultado_Inspecao.RIP_DtUltAtu, Itens_Verificacao.Itn_Descricao, Resultado_Inspecao.RIP_Situacao, Resultado_Inspecao.RIP_Observacao, Unidades.Und_Descricao
FROM Resultado_Inspecao, Itens_Verificacao, Unidades
WHERE Resultado_Inspecao.RIP_Unidade = '#URL.Unid#' and Resultado_Inspecao.RIP_NumInspecao = '#URL.Relat#' and Resultado_Inspecao.RIP_Resposta = 'N' AND Itens_Verificacao.Itn_NumGrupo = Resultado_Inspecao.RIP_NumGrupo AND Itens_Verificacao.Itn_NumItem = Resultado_Inspecao.RIP_NumItem and Unidades.Und_Codigo = Resultado_Inspecao.RIP_Unidade
ORDER BY Resultado_Inspecao.RIP_DtUltAtu, Resultado_Inspecao.RIP_Unidade, Resultado_Inspecao.RIP_NumInspecao, Resultado_Inspecao.RIP_NumGrupo, Resultado_Inspecao.RIP_NumItem</cfquery>
<cfset MaxRows_rsItem=8>
<cfset StartRow_rsItem=Min((PageNum_rsItem-1)*MaxRows_rsItem+1,Max(rsItem.RecordCount,1))>
<cfset EndRow_rsItem=Min(StartRow_rsItem+MaxRows_rsItem-1,rsItem.RecordCount)>
<cfset TotalPages_rsItem=Ceiling(rsItem.RecordCount/MaxRows_rsItem)>
<cfset QueryString_rsItem=Iif(CGI.QUERY_STRING NEQ "",DE("&"&XMLFormat(CGI.QUERY_STRING)),DE(""))>
<cfset tempPos=ListContainsNoCase(QueryString_rsItem,"PageNum_rsItem=","&")>
<cfif tempPos NEQ 0>
  <cfset QueryString_rsItem=ListDeleteAt(QueryString_rsItem,tempPos,"&")>
</cfif>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body>
<cfinclude template="cabecalho.cfm">
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
<!--- Área de conteúdo   --->
<table width="964">
  <tr>
    <td colspan="5"><span class="exibir">Controle de Respostas de Relat&oacute;rios por Item</span><br>
    <br>
    <span class="exibir">Unidade: <strong><cfoutput>#rsItem.RIP_Unidade#</cfoutput></strong> <cfoutput><strong>#rsItem.Und_Descricao#</strong></cfoutput> &nbsp;&nbsp;&nbsp;&nbsp;N&ordm; Relat&oacute;rio : <strong><cfoutput>#rsItem.RIP_NumInspecao#</cfoutput></strong></span></td>
  </tr>
  <tr bgcolor="eeeeee" class="exibir">
    <td width="75" height="14"><div align="center">Atualiz.</div></td>
    <td width="55"><div align="center">N&ordm; Grupo</div></td>
    <td><div align="left"> Item </div></td>
    <td width="55"><div align="center">Situa&ccedil;&atilde;o</div></td>
    <td width="183">Observa&ccedil;&atilde;o</td>
  </tr>
  <cfoutput query="rsItem" startRow="#StartRow_rsItem#" maxRows="#MaxRows_rsItem#">
    <tr bgcolor="f7f7f7" class="exibir">
      <td width="75" height="20"><div align="center">#LSDateFormat(rsItem.RIP_DtUltAtu,'DD-MM-YYYY')#</div></td>
      <td width="55"><div align="center"><strong>#rsItem.RIP_NumGrupo#</strong></div></td>
      <td><div align="left"><strong>#rsItem.RIP_NumItem#&nbsp;- </strong>#rsItem.Itn_Descricao#        </div>        <div align="center"></div></td>
      <cfif rsItem.RIP_Situacao eq 0>
	  <cfset sresult = "Em falta">
	  <cfelse>
	  <cfset sresult = "Feito">
	  </cfif>
      <td width="55"><strong>#sresult#</strong></td>
      <td width="183">#rsItem.RIP_Observacao# </td>
    </tr>
  </cfoutput>
</table>
<table border="0" width="50%" align="left">
  <cfoutput>
    <tr>
      <td width="23%" align="center">
        <cfif PageNum_rsItem GT 1>
          <a href="#CurrentPage#?PageNum_rsItem=1#QueryString_rsItem#" class="links">Primeiro</a>
        </cfif>
      </td>
      <td width="31%" align="center">
        <cfif PageNum_rsItem GT 1>
          <a href="#CurrentPage#?PageNum_rsItem=#Max(DecrementValue(PageNum_rsItem),1)##QueryString_rsItem#" class="links">Anterior</a>
        </cfif>
      </td>
      <td width="23%" align="center">
        <cfif PageNum_rsItem LT TotalPages_rsItem>
          <a href="#CurrentPage#?PageNum_rsItem=#Min(IncrementValue(PageNum_rsItem),TotalPages_rsItem)##QueryString_rsItem#" class="links">Pr&oacute;ximo</a>
        </cfif>
      </td>
      <td width="23%" align="center">
        <cfif PageNum_rsItem LT TotalPages_rsItem>
          <a href="#CurrentPage#?PageNum_rsItem=#TotalPages_rsItem##QueryString_rsItem#" class="links">&Uacute;ltimo</a>
        </cfif>
      </td>
    </tr>
  </cfoutput>
</table>
</p>
<cfelse>
 <cfoutput>não houve passagem</cfoutput>


<!--- Fim Área de conteúdo --->
	  </td>
  </tr>
</table>
<cfinclude template="rodape.cfm">
</body>
</html>