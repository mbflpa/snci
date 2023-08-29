<cfinclude template="cabecalho.cfm">
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena 
FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
   <cfquery name="rsPontos" datasource="#dsn_inspecao#">
SELECT Und_CodDiretoria, Pos_Situacao_Resp, STO_Descricao, Count(Pos_Situacao_Resp) AS Qtd
FROM (ParecerUnidade INNER JOIN Unidades ON Pos_Unidade = Und_Codigo) INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo
WHERE 
    <cfif #MES# neq 'TODOS'>
	  month(Pos_DtPosic) = #MES# and
	</cfif>
	right(Pos_Inspecao,4) = '#ano#'
	
GROUP BY Und_CodDiretoria, Pos_Situacao_Resp, STO_Descricao
HAVING 
    <cfif #SE# is 'GERAL'>
	  	Und_CodDiretoria In (#qAcesso.Usu_Coordena#) 
	<cfelse>
 		Und_CodDiretoria = (#SE#)
	</cfif>
	 AND Pos_Situacao_Resp Not In (51,88,99)
ORDER BY Und_CodDiretoria, Pos_Situacao_Resp
	</cfquery>

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
.style1 {color: #FFFFFF}
.style2 {
	font-size: 10px;
	text-decoration: none;
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-weight: bold;
	color: #333333;
}
-->
</style>
<link href="css.css" rel="stylesheet" type="text/css">

</head>
<body>
  <script type="text/javascript">
    document.write("<table width='" + largura() + "' height='" + altura() + "' border='0'>");
  </script>
    <tr height="5%">
<!--- 	  <td align="center"><div id="menu" align="center"><cfinclude template="cabecalho.cfm"> --->
    </tr>
	<tr height="3%">
	  <!--- <td align="center" valign="top" class="titulo">Identifica&ccedil;&atilde;o no sistema</td> --->
	</tr>
<tr height="90%"><td valign="middle" align="center">&nbsp;</td>
</tr>
   <table width="81%" border="1" align="center">
  <tr>
    <td colspan="6" class="titulo2"><div align="center"><span class="titulo"> quantitativo dos pontos por <cfoutput>#ano#</cfoutput>  na se/<cfoutput>#se#</cfoutput></span> na parecerunidade </div></td>
    </tr>
  
  <tr class="Tabela">
    <td width="19%"><p align="center">Cod_SE </p>    </td>
    <td width="26%"><div align="center">Cod. Situa&ccedil;&atilde;o </div></td>
    <td width="33%"><div align="center">Descri&ccedil;&atilde;o da Situa&ccedil;&atilde;o </div></td>
    <td width="11%"><div align="center">Quantidade</div></td>
    <td width="11%"><div align="center">Gerar Gr&aacute;fico </div></td>
  </tr>
	<cfoutput query="rsPontos">
<!--- 	, , , Count(Pos_Situacao_Resp) AS 
	 <cfset dtprevplan = dateformat(Plan_DTPrevVerif,"DD/MM/YYYY")>
	 <cfset dtiniplan = dateformat(Plan_DTInicio,"DD/MM/YYYY")>
	 <cfset dtfimplan = dateformat(Plan_DTFinal,"DD/MM/YYYY")>
	 <cfset dtinidesinp = dateformat(INP_DtInicDeslocamento,"DD/MM/YYYY")>
	 <cfset dtfimdesinp = dateformat(INP_DtFimDeslocamento,"DD/MM/YYYY")>
	 <cfset dtiniinp = dateformat(INP_DtInicInspecao,"DD/MM/YYYY")>
	 <cfset dtfiminp = dateformat(INP_DtFimInspecao,"DD/MM/YYYY")>
	 <cfset numRelat = INP_NumInspecao>
	 <cfset hrsinp = INP_HrsPreInspecao>
	 <cfset tpund = Plan_TipoUnid>	 
	 <cfset auxnumdias = DateDiff("d", Plan_DTFinal, INP_DtFimInspecao)> --->
  <tr class="exibir"> 
    <td><div align="center">#Und_CodDiretoria#</div></td>
    <td><div align="center">#Pos_Situacao_Resp#</div></td>
    <td>#STO_Descricao#</td>
    <td><div align="center">#Qtd#</div></td>
    <td><div align="center"><a href="Grafico_Gestores_Pontos2.cfm?ano=#ano#&se=#Und_CodDiretoria#&mes=#MES#&codst=#Pos_Situacao_Resp#" target="_blank"><span class="link1">Este</span></a></div></td>
  </tr>
	</cfoutput>
</table>
</body>
</html>