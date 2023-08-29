<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <!--- <cfinclude template="permissao_negada.htm"> --->
 <!--- <cfabort>  --->
</cfif>


<!--- <cfquery name="qSE" datasource="#dsn_inspecao#">
 SELECT Dir_Codigo, Dir_Sigla
 FROM Diretoria
 ORDER BY Dir_Sigla ASC
</cfquery> --->
<!--- =========================== --->
<cfquery name="rsDados" datasource="#dsn_inspecao#">
 SELECT Year([Plan_DTInicio]) AS ano, Und_CodDiretoria, Dir_Sigla
FROM ((Planejamento INNER JOIN Inspecao ON Plan_CodUnid = INP_Unidade) INNER JOIN Unidades ON INP_Unidade = Und_Codigo) INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
GROUP BY Year([Plan_DTInicio]), Und_CodDiretoria, Dir_Sigla
</cfquery>
<!--- =========================== --->
<cfinclude template="cabecalho.cfm">
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script type="text/javascript">

</script>
 <link href="css.css" rel="stylesheet" type="text/css">
</head>
<br>
<body>


<tr>
   <td colspan="6" align="center">&nbsp;</td>
</tr>

<!--- Área de conteúdo   --->
<form action="Grafico_PACIN_Realizado1.cfm" method="get" target="_blank" name="frmObjeto">
	  <table width="62%" align="center">
        <tr>
          <td colspan="7" align="center" class="titulo1"><strong>COMPARATIVO DAS INSPE&Ccedil;&Otilde;ES (PLANEJADO / EXECUTADO)</strong></td>
        </tr>
		<tr>
          <td colspan="7" align="center">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="7" align="center">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="7" align="center"><div align="left"><strong class="titulo1">Gerar Gr&Aacute;fico :
            
          </strong></div></td>
        </tr>

		 <tr>
          <td colspan="7" align="center"><div align="left">&nbsp;</div></td>
        </tr>
        <tr>
          <td width="2%" class="exibir">&nbsp;</td>
          <td colspan="6"><span class="exibir"><strong>Ano / SE / M&ecirc;s </strong></span></td>
        </tr>
        <tr>
          <td colspan="7">&nbsp;</td>
        </tr>
        <tr>
	      <cfset sano = "">
          <td><strong><div id="dDtInicio" class="exibir"></div></strong></td>
          <td width="13%"><strong><span class="exibir">Ano:</span></strong><strong></strong></td>
          <td colspan="6"><strong class="titulo1">              
		   <select name="ano" class="form" tabindex="3">
           <option selected="selected" value="">---</option>
            <cfoutput query="rsDados">
			  
			  <cfif sano neq ano>
              <option value="#ano#">#ano#</option>
			  </cfif>
			  <cfset sano = #ano#>
            </cfoutput>
          </select>
          </strong></td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td><strong><span class="exibir">Superintend&ecirc;ncia:</span></strong>            </td>
          <td colspan="5"><select name="SE" class="form" tabindex="3">
            <option selected="selected" value="">---</option>
            <cfoutput query="rsDados">
              <option value="#Und_CodDiretoria#">#Dir_Sigla#</option>
            </cfoutput>
          </select></td>
        </tr>
		  <tr>
          <td>&nbsp;</td>
          <td><strong><span class="exibir">M&ecirc;s:</span></strong>            </td>
          <td colspan="5">
		  <select name="MES" class="form" tabindex="3">
		    <option value="todos">Todos</option>
		    <option value="01">Janeiro</option>
		    <option value="02">Fevereiro</option>
			<option value="03">Março</option>
		    <option value="04">Abril</option>
			<option value="05">Maio</option>
		    <option value="06">Junho</option>
			<option value="07">Julho</option>
		    <option value="08">Agosto</option>
			<option value="09">Setembro</option>
		    <option value="10">Outubro</option>
			<option value="11">Novembro</option>
		    <option value="12">Dezembro</option>
          </select>
		  </td>
        </tr>
        <tr>
          <td colspan="7">&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td colspan="4"><input name="Submit1" type="submit" class="botao" id="Submit1" value="Confirmar"></td>
          <td colspan="3"></td>
        </tr>
      </table>
	</form>
</body>
</html>
