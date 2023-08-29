
<cfinclude template="cabecalho.cfm">
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="css.css" rel="stylesheet" type="text/css">

<style type="text/css">
<!--
.style4 {color: #11438B}
-->
</style>
</head>
<body>
  <script type="text/javascript">
    document.write("<table width='" + largura() + "' height='" + altura() + "' border='0'>");
  </script>
  <form action="Grafico_PACIN_Realizado2.cfm" method="get" target="_blank" name="form1">
    <tr height="5%">
<!--- 	  <td align="center"><div id="menu" align="center"><cfinclude template="cabecalho.cfm"> --->
    </tr>
	<tr height="3%">
	  <!--- <td align="center" valign="top" class="titulo">Identifica&ccedil;&atilde;o no sistema</td> --->
	</tr>
<tr height="90%"><td valign="middle" align="center">&nbsp;</td>
</tr>
<!---  <cfif ano neq "" and se neq ""> --->
   <table width="95%" border="1" align="left">
  <tr>
    <cfoutput>
    <td colspan="15" class="titulo2"><div align="center"><span class="titulo">EVOLUÇÃO DE REGISTROS DESTA SITUAÇÃO POR DATA NO ANO <cfoutput>#ano#</cfoutput>  se/ <cfoutput>#se#</cfoutput></span>  NA TABELA ANDAMENTO</span></div></td>
    </cfoutput>
    </tr>
 
  <tr>

<cfquery name="rsLine" datasource="#dsn_inspecao#">
SELECT Und_CodDiretoria, And_DtPosic, And_Situacao_Resp, STO_Descricao, Count(And_Situacao_Resp) AS qtdResp
FROM (Andamento INNER JOIN Unidades ON And_Unidade = Und_Codigo) INNER JOIN Situacao_Ponto ON And_Situacao_Resp = STO_Codigo
GROUP BY Und_CodDiretoria, And_DtPosic, And_Situacao_Resp, STO_Descricao
HAVING Und_CodDiretoria ='#SE#' AND And_Situacao_Resp = #codst# and year(And_DtPosic) = #ano#
ORDER BY Und_CodDiretoria, And_DtPosic, And_Situacao_Resp
</cfquery>
    <td colspan="2">
	<cfchart format="png" chartwidth="1800" show3d="no" showlegend="no" yaxistitle="Qtd" xaxistitle="Mes" chartheight="400">
		<cfchartseries type="line">
		<cfset totpontos = 0>
         <cfoutput query="rsLine">
			<cfset auxdt = dateformat(And_DtPosic,"DD-MM-YYYY")>
            <cfchartdata item="#auxdt#" value="#qtdResp#">
		    <cfset totpontos = totpontos + qtdResp>
        </cfoutput> 
        </cfchartseries>
        </cfchart> 
	</td>
  </tr>
   <tr>
     <td colspan="2" class="titulos"><hr></td>
     </tr>
   <tr>
    <td class="titulos">Total Geral de Pontos no Ano=&gt; <cfoutput>#totpontos# - #rsLine.STO_Descricao#</cfoutput></td>

   </tr>

</table>  

<!--- <cfelse>
 <p class="red_titulo">Informar os valores: Ano e Superintendência.</p>
</cfif>  --->
</form>
</body>
</html>