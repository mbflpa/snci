<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <!--- <cfinclude template="permissao_negada.htm"> --->
 <!--- <cfabort>  --->
</cfif>
<cfquery name="rsAno" datasource="#dsn_inspecao#">
SELECT Right([NIP_NumInspecao],4) AS Ano
FROM Numera_Inspecao
GROUP BY Right([NIP_NumInspecao],4)
ORDER BY Right([NIP_NumInspecao],4) DESC
</cfquery> 
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena 
FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<!--- =========================== --->
<cfquery name="rsDados" datasource="#dsn_inspecao#">
 SELECT Year([Plan_DTInicio]) AS ano, Und_CodDiretoria, Dir_Sigla
FROM ((Planejamento INNER JOIN Inspecao ON Plan_CodUnid = INP_Unidade) INNER JOIN Unidades ON INP_Unidade = Und_Codigo) INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
GROUP BY Year([Plan_DTInicio]), Und_CodDiretoria, Dir_Sigla
</cfquery>
<!--- =========================== --->
<!--- <cfinclude template="cabecalho.cfm"> --->
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
<form action="Grafico_Gestores_Pontos1.cfm" method="get" target="_blank" name="frmObjeto">
	  <table width="41%" align="center">
        <tr>
          <td colspan="6" align="center" class="titulo1"><div align="left"><strong>GEST&Atilde;O DOS PONTOS POR ANO/SE/M&Ecirc;S </strong></div></td>
        </tr>
		<tr>
          <td colspan="6" align="center">&nbsp;</td>
        </tr>
        
         <tr>
           <td colspan="6">&nbsp;</td>
         </tr>
        <tr>
          <td colspan="6">&nbsp;</td>
        </tr>
        <tr>
	      <cfset sano = "">
          <td width="2%"><strong><div id="dDtInicio" class="exibir"></div></strong></td>
          <td width="26%"><strong><span class="exibir">Ano:</span></strong><strong></strong></td>
          <td colspan="6"><strong class="titulo1">              
		   <select name="ano" class="form" tabindex="3">
           <option selected="selected" value="">---</option>
            <cfoutput query="rsAno">
              <option value="#ano#">#ano#</option>
            </cfoutput>
          </select>
          </strong></td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td><strong><span class="exibir">Superintend&ecirc;ncia:</span></strong>            </td>
          <td colspan="5">
		  <cfif UCase(trim(qAcesso.Usu_GrupoAcesso)) eq 'GESTORMASTER' AND qAcesso.Usu_DR eq '01'>
			<cfquery name="qSE" datasource="#dsn_inspecao#">
				SELECT Dir_Codigo, Dir_Sigla FROM Diretoria where Dir_Codigo <> '01'
			</cfquery>
		  <select name="SE" class="form" tabindex="3">
				<cfoutput query="qSE">
					<option value="#qSE.Dir_Codigo#">#Ucase(trim(qSE.Dir_Sigla))#</option>
				</cfoutput>
          </select>
		  <cfelse>
 			<cfset auxtam_lista = len(TRIM(qAcesso.Usu_Coordena))>
			<cfset aux_lista = TRIM(qAcesso.Usu_Coordena)>
			<cfset aux_codse = "">			
	<!--- 	     <td colspan="3"> --->
			    <select name="SE" id="SE" class="form">
		          <option selected="selected" value="GERAL">GERAL</option>
<cfoutput>
				  <cfloop from="1" to="#val(auxtam_lista) + 1# " index="i">
				     <cfif len(aux_codse) eq 2>
					   <cfquery name="qCDR" datasource="#dsn_inspecao#">
						SELECT Dir_Sigla FROM Diretoria  WHERE Dir_Codigo = '#aux_codse#'
					   </cfquery> 
		               <option value="#aux_codse#">#Ucase(trim(qCDR.Dir_Sigla))#</option>
					   <cfset aux_codse = "">
					</cfif>
					<cfif mid(aux_lista,i,1) neq ",">
					  <cfset aux_codse = #aux_codse# & #mid(aux_lista,i,1)#>
					</cfif>
				  </cfloop>
</cfoutput>				  				  
		        </select><!--- </td> --->	  
		  </cfif>		  </td>
        </tr>
		  <tr>
          <td>&nbsp;</td>
          <td><strong><span class="exibir">M&ecirc;s:</span></strong>            </td>
          <td colspan="5">
		  <select name="MES" class="form" tabindex="3">
		    <option value="TODOS">Todos</option>
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
          </select>		  </td>
        </tr>
        <tr>
          <td colspan="7">&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td colspan="4">
            <div align="center">
              <input name="Submit1" type="submit" class="botao" id="Submit1" value="Confirmar">
            </div></td>
        </tr>
      </table>
</form>
</body>
</html>
