<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>
<cfparam name="PageNum_rsSint" default="1">
<cfquery name="rsSint" datasource="#dsn_inspecao#">
SELECT Resultado_Inspecao.RIP_Unidade, Resultado_Inspecao.RIP_NumInspecao, count(Resultado_Inspecao.RIP_Unidade) as total, Unidades.Und_Descricao 
FROM Resultado_Inspecao, Unidades 
WHERE Resultado_Inspecao.RIP_Resposta = 'N' AND Unidades.Und_Codigo = Resultado_Inspecao.RIP_Unidade 
group by Resultado_Inspecao.RIP_Unidade, Resultado_Inspecao.RIP_NumInspecao, Unidades.Und_Descricao
</cfquery>
<cfset MaxRows_rsSint=15>
<cfset StartRow_rsSint=Min((PageNum_rsSint-1)*MaxRows_rsSint+1,Max(rsSint.RecordCount,1))>
<cfset EndRow_rsSint=Min(StartRow_rsSint+MaxRows_rsSint-1,rsSint.RecordCount)>
<cfset TotalPages_rsSint=Ceiling(rsSint.RecordCount/MaxRows_rsSint)>
<cfset QueryString_rsSint=Iif(CGI.QUERY_STRING NEQ "",DE("&"&XMLFormat(CGI.QUERY_STRING)),DE(""))>
<cfset tempPos=ListContainsNoCase(QueryString_rsSint,"PageNum_rsSint=","&")>
<cfif tempPos NEQ 0>
  <cfset QueryString_rsSint=ListDeleteAt(QueryString_rsSint,tempPos,"&")>
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
<table width="616">
  <tr class="exibir">
    <td colspan="6"><p class="titulo1">Relat&oacute;rio de Inspe&ccedil;&atilde;o </p>
      <p>&nbsp;</p></td>
  </tr>
  <tr class="exibir">
    <td width="250" bgcolor="eeeeee">Unidade</td>
    <td width="75" bgcolor="eeeeee">N&ordm; Relat&oacute;rio </td>
    <td width="72" bgcolor="eeeeee"><div align="center">Consignados</div></td>
    <td width="60" bgcolor="eeeeee"><div align="center">Regular</div></td>
    <td bgcolor="eeeeee"><div align="left">&nbsp;Irregulares</div></td>
    <td>&nbsp;</td>
  </tr>
  <cfoutput query="rsSint" startrow="#StartRow_rsSint#" maxrows="#MaxRows_rsSint#">
  <cfset unid = rsSint.RIP_Unidade>
  <cfset relat = rsSint.RIP_NumInspecao>
    <tr bgcolor="f7f7f7" class="exibir">
      <td width="250">#rsSint.Und_Descricao#</td>
      <td width="75">#rsSint.RIP_NumInspecao#</td>
      <td><div align="center">#rsSint.total#</div></td>
      
	      <cfquery name="rsSint2" datasource="#dsn_inspecao#">
	      SELECT COUNT(RIP_Unidade) AS total FROM Resultado_Inspecao WHERE (RIP_Unidade = '#unid#') AND (RIP_NumInspecao = '#relat#') AND (RIP_Resposta = 'N') AND (RIP_Situacao = '1') GROUP BY RIP_Unidade, RIP_NumInspecao
	      </cfquery>
          <cfif #rsSint2.RecordCount# eq 0>
            <cfset totalreg = 0>
        <cfelse>
   	    <cfset totalreg = rsSint2.total>
          </cfif>
       <td><div align="center">#totalreg#</div></td>
      <td width="50"><div align="center">#val(rsSint.total - totalreg)#</div></td>
      <td width="60"><a href="itens_visualizar_relatorio_sintetico.cfm?Unid=#rsSint.RIP_Unidade#&Relat=#rsSint.RIP_NumInspecao#" class="links"><strong>Ver Itens</strong></a> </td>
    </tr>
  </cfoutput>
</table>
<p>

<table border="0" width="50%" align="left">
  <cfoutput>
    <tr>
      <td width="23%" align="center">
        <cfif PageNum_rsSint GT 1>
          <a href="#CurrentPage#?PageNum_rsSint=1#QueryString_rsSint#" class="links">Primeiro</a>
        </cfif>
      </td>
      <td width="31%" align="center">
        <cfif PageNum_rsSint GT 1>
          <a href="#CurrentPage#?PageNum_rsSint=#Max(DecrementValue(PageNum_rsSint),1)##QueryString_rsSint#" class="links">Anterior</a>
        </cfif>
      </td>
      <td width="23%" align="center">
        <cfif PageNum_rsSint LT TotalPages_rsSint>
          <a href="#CurrentPage#?PageNum_rsSint=#Min(IncrementValue(PageNum_rsSint),TotalPages_rsSint)##QueryString_rsSint#" class="links">Pr&oacute;ximo</a>
        </cfif>
      </td>
      <td width="23%" align="center">
        <cfif PageNum_rsSint LT TotalPages_rsSint>
          <a href="#CurrentPage#?PageNum_rsSint=#TotalPages_rsSint##QueryString_rsSint#" class="links">&Uacute;ltimo</a>
        </cfif>
      </td>
    </tr>
  </cfoutput>
</table>
</p>

<!--- Fim Área de conteúdo --->
	  </td>
  </tr>
</table>
<cfinclude template="rodape.cfm">

</body>
</html>