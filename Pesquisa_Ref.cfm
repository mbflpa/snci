<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>    
<!---  --->

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso, Usu_DR, Dir_Sigla, Usu_Coordena, Dir_Descricao, Usu_Matricula
FROM Diretoria INNER JOIN Usuarios ON Dir_Codigo = Usu_DR 
WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
order by Dir_Sigla
</cfquery>
<!---  <cfif TRIM(qAcesso.Usu_GrupoAcesso) NEQ 'GESTORMASTER'>
	 <cflocation url="SNCI_MENSAGEM.cfm?form.motivo=PAGINA DE INDICADORES SLNC EM MANUTENCAO ATE 12h!">
</cfif>   --->
<cfset auxanoatu = year(now())>
<!--- <cfquery name="rsGeral" datasource="#dsn_inspecao#">
SELECT Right([NIP_NumInspecao],4) AS anoinsp, Dir_Codigo, Dir_Sigla
FROM (Pesquisa_Pos_Avaliacao INNER JOIN Numera_Inspecao ON Pes_Inspecao = NIP_NumInspecao) INNER JOIN (Unidades INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo) ON NIP_Unidade = Und_Codigo
GROUP BY Right([NIP_NumInspecao],4), Dir_Codigo, Dir_Sigla
ORDER BY Right([NIP_NumInspecao],4) DESC, Dir_Sigla
</cfquery>  --->
 <cfquery name="rsGeral" datasource="#dsn_inspecao#">
SELECT Right([NIP_NumInspecao],4) AS anoinsp, Dir_Codigo, Dir_Sigla, Pes_GestorNome
FROM (Pesquisa_Pos_Avaliacao 
INNER JOIN Numera_Inspecao ON Pes_Inspecao = NIP_NumInspecao) 
INNER JOIN (Unidades INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo) ON NIP_Unidade = Und_Codigo
where Pes_GestorNome is not null
GROUP BY Right([NIP_NumInspecao],4), Dir_Codigo, Dir_Sigla, Pes_GestorNome
ORDER BY Right([NIP_NumInspecao],4) DESC, Dir_Sigla
</cfquery> 

<cfquery dbtype="query" name="rsSE">
	SELECT distinct Dir_Codigo, Dir_Sigla 
	FROM rsGeral
	order by Dir_Codigo, Dir_Sigla
</cfquery>
<cfquery dbtype="query" name="rsAno">
	SELECT distinct anoinsp FROM rsGeral
	order by anoinsp desc
</cfquery>
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<script language="javascript">

</script>
 <link href="css.css" rel="stylesheet" type="text/css">
</head>
<br>
<body>


<tr>
   <td colspan="6" align="center">&nbsp;</td>
</tr>

<!--- Área de conteúdo   --->
	<form action="Pesquisa_resultado.cfm" method="get" target="_blank" name="form1">
	  <table width="59%" align="center">
	  <cfif UCASE(trim(qAcesso.Usu_GrupoAcesso)) eq "SUPERINTENDENTE">
		<tr>
		<td colspan="5" align="center"><cfoutput><span class="titulo2">#qAcesso.Dir_Descricao#</span></cfoutput></td>
		</tr>
		<tr>
		<td colspan="5" align="center">&nbsp;</td>
		</tr>
	  </cfif>
       
        <tr>
          <td colspan="5" align="center" class="titulo2"><strong> PESQUISA P&Oacute;S-AVALIA&Ccedil;&Atilde;O</strong> </td>
        </tr>
		<tr>
          <td colspan="5" align="center">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="5" align="center">&nbsp;</td>
        </tr>
        <tr>
          <td colspan="5" align="center"><div align="left"><strong class="titulo1">Pesquisa por:
            
          </strong></div></td>
        </tr>

		 <tr>
		   <td colspan="5" align="center">&nbsp;</td>
	    </tr>

        <tr>
          <td width="1%"></td>
          <td colspan="4"><strong>
          </strong><strong><span class="exibir">
          </span></strong></td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td width="23%"><strong><span class="exibir">Superintend&ecirc;ncia :</span></strong> </td>
          <td width="76%" colspan="3">
		  <!---  --->
<!--- 			 	<select name="se" id="se" class="form">
		          <option selected="selected" value="TODOS">TODOS</option>
				  <cfoutput query="rsSE">
		          	<option value="#rsSE.Dir_Codigo#">#Ucase(trim(rsSE.Dir_Sigla))#</option>
				  </cfoutput>
		        </select> --->
<cfif UCase(trim(qAcesso.Usu_GrupoAcesso)) eq 'GESTORMASTER' AND qAcesso.Usu_DR eq '01'>
			<cfquery name="qSE" datasource="#dsn_inspecao#">
				SELECT Dir_Codigo, Dir_Sigla FROM Diretoria where dir_codigo <> '01'
			</cfquery>
			 	<select name="se" id="se" class="form">
		          <option selected="selected" value="TODOS">TODOS</option>
				  <cfoutput query="qSE">
		          	<option value="#qSE.Dir_Codigo#">#Ucase(trim(qSE.Dir_Sigla))#</option>
				  </cfoutput>
		        </select>
		<cfelseif (UCase(trim(qAcesso.Usu_GrupoAcesso)) eq 'GESTORES' OR UCase(trim(qAcesso.Usu_GrupoAcesso)) eq 'ANALISTAS') AND len(TRIM(qAcesso.Usu_Coordena)) gt 0> 
		
            <cfset auxtam_lista = len(TRIM(qAcesso.Usu_Coordena))>
			<cfset aux_lista = TRIM(qAcesso.Usu_Coordena)>
			<cfset aux_codse = "">			
			    <select name="se" id="se" class="form">
		          <option selected="selected" value="TODOS">TODOS</option>
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
		        </select>

        <cfelseif qAcesso.Usu_DR eq '04'>
			    <select name="se" id="se" class="form">
		          <option selected="selected" value="TODOS">TODOS</option>
		          <option value="04">AL</option>
				  <option value="70">SE</option>
		        </select>
			 <cfset seprinc= '04'>
	         <cfset sesubor= '70'>
		 <cfelseif qAcesso.Usu_DR eq '10'>
			 <select name="se"  id="se" class="form">
		          <option selected="selected" value="TODOS">TODOS</option>
		          <option value="10">BSB</option>
				  <option value="16">GO</option>
	         </select>
			 <cfset seprinc= '10'>
	         <cfset sesubor= '16'>
		<cfelseif qAcesso.Usu_DR eq '06'>
			 <select name="se" id="se" class="form">
		          <option selected="selected" value="TODOS">TODOS</option>
		          <option value="06">AM</option>
				  <option value="65">RR</option>
	         </select>
			 <cfset seprinc= '06'>
	         <cfset sesubor= '65'>
		<cfelseif qAcesso.Usu_DR eq '26'>
			 <select name="se" id="se" class="form">
		          <option selected="selected" value="TODOS">TODOS</option>
		          <option value="26">RO</option>
				  <option value="03">ACR</option>
	         </select>
			 <cfset seprinc= '26'>
	         <cfset sesubor= '03'>				 
		 <cfelseif qAcesso.Usu_DR eq '28'>
			 <select name="se" id="se" class="form">
		         <option selected="selected" value="TODOS">TODOS</option>
		          <option value="28">PA</option>
				  <option value="05">AP</option>
		     </select>
			 <cfset seprinc= '28'>
	         <cfset sesubor= '05'>
		 <cfelse>
			   <cfoutput>
			    <select name="se" id="se" class="form">
		          <option selected="selected" value="#qAcesso.Usu_DR#">#qAcesso.Dir_Sigla#</option>
		        </select>
	           </cfoutput>
		 </cfif>				
	  
		  <!---  --->
		  </td>
	    </tr>

  
          <tr>
            <td>&nbsp;</td>
            <td class="exibir"><strong>Ano : </strong></td>
            <td colspan="2">
			<select name="frmano" class="exibir" id="frmano">
			<cfoutput query="rsAno">
			  <option value="#rsAno.anoinsp#">#rsAno.anoinsp#</option>
			  </cfoutput>
            </select>
			
			</td>
          </tr>
          <td>&nbsp;</td>
            <td colspan="3">
              <div align="center">
                <input name="Submit1" type="submit" class="botao" id="Submit1" value="Confirmar" onClick="document.frmObjeto.ckTipo.value='ano';">
            </div></td></tr>
        <tr>
          <td>&nbsp;</td>
          <td colspan="3">&nbsp;</td>
        </tr>
      </table>  
	</form>
</body>
</html>
