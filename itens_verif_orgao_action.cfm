<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>  
<cfoutput>


<cfparam name="PageNum_rsGeral" default="1">
<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

<cfset total=0>
<cfset auxdtini = CreateDate(right(form.dtinic,4),mid(form.dtinic,4,2),left(form.dtinic,2))>
<cfset auxdtfim = CreateDate(right(form.dtfinal,4),mid(form.dtfinal,4,2),left(form.dtfinal,2))>

<!--- #form.dtinic# #form.dtfinal#<br>
#auxdtini# and #auxdtfim#<br>
#form.se#
#form.Unidade#<br> --->
<cfif form.SE eq "Todas">
		<cfset cabse = "Todas">
		<cfset cabunid = "Todas">
		<cfquery name="rsGeral" datasource="#dsn_inspecao#">
			SELECT Und_CodDiretoria, RIP_Unidade, Und_Descricao, INP_DtEncerramento, RIP_NumInspecao, RIP_Resposta, Count(RIP_Resposta) AS Total
			FROM (Unidades INNER JOIN Inspecao ON Und_Codigo = INP_Unidade) INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade)
			GROUP BY Und_CodDiretoria, RIP_Unidade, Und_Descricao, RIP_NumInspecao, INP_DtEncerramento, RIP_Resposta
			HAVING (RIP_Resposta <> 'A' and INP_DtEncerramento Between #auxdtini# and #auxdtfim#)
			ORDER BY Und_CodDiretoria, RIP_Unidade, RIP_NumInspecao
		</cfquery>
		<!--- planilha --->
		<cfquery name="rsXLSa" datasource="#dsn_inspecao#">
			SELECT Und_CodDiretoria, RIP_Unidade, Und_Descricao, INP_DtEncerramento, RIP_NumInspecao, RIP_Resposta, Count(RIP_Resposta) AS Total
			FROM (Unidades INNER JOIN Inspecao ON Und_Codigo = INP_Unidade) INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade)
			GROUP BY Und_CodDiretoria, RIP_Unidade, Und_Descricao, RIP_NumInspecao, INP_DtEncerramento, RIP_Resposta
			HAVING (RIP_Resposta <> 'A' and INP_DtEncerramento Between #auxdtini# and #auxdtfim#)
			ORDER BY Und_CodDiretoria, RIP_Unidade, RIP_NumInspecao
		</cfquery>
		<!--- fim planilha --->
<cfelseif form.unidade eq "Todas">
		<cfset cabse = form.se>
		<cfset cabunid = "Todas">		
		<cfquery name="rsGeral" datasource="#dsn_inspecao#">
			SELECT Und_CodDiretoria, RIP_Unidade, Und_Descricao, INP_DtEncerramento, RIP_NumInspecao, RIP_Resposta, Count(RIP_Resposta) AS Total
			FROM (Unidades INNER JOIN Inspecao ON Und_Codigo = INP_Unidade) INNER JOIN Resultado_Inspecao ON (INP_Unidade = RIP_Unidade) AND (INP_NumInspecao = RIP_NumInspecao)
			GROUP BY Und_CodDiretoria, RIP_Unidade, Und_Descricao, INP_DtEncerramento, RIP_NumInspecao, RIP_Resposta
			HAVING (Und_CodDiretoria = '#cabse#') AND (INP_DtEncerramento Between #auxdtini# and #auxdtfim#) AND (RIP_Resposta <> 'A')
			ORDER BY Und_CodDiretoria, RIP_Unidade, RIP_NumInspecao
		</cfquery>
		<!--- planilha --->
		<cfquery name="rsXLSa" datasource="#dsn_inspecao#">
			SELECT Und_CodDiretoria, RIP_Unidade, Und_Descricao, INP_DtEncerramento, RIP_NumInspecao, RIP_Resposta, Count(RIP_Resposta) AS Total
			FROM (Unidades INNER JOIN Inspecao ON Und_Codigo = INP_Unidade) INNER JOIN Resultado_Inspecao ON (INP_Unidade = RIP_Unidade) AND (INP_NumInspecao = RIP_NumInspecao)
			GROUP BY Und_CodDiretoria, RIP_Unidade, Und_Descricao, INP_DtEncerramento, RIP_NumInspecao, RIP_Resposta
			HAVING (Und_CodDiretoria = '#cabse#') AND (INP_DtEncerramento Between #auxdtini# and #auxdtfim#) AND (RIP_Resposta <> 'A')
			ORDER BY Und_CodDiretoria, RIP_Unidade, RIP_NumInspecao
		</cfquery>
		<!--- fim planilha --->
<cfelse>
		<cfset cabse = form.se>
		<cfset cabunid = form.Unidade>
		<cfquery name="rsGeral" datasource="#dsn_inspecao#">
			SELECT Und_CodDiretoria, RIP_Unidade, Und_Descricao, INP_DtEncerramento, RIP_NumInspecao, RIP_Resposta, Count(RIP_Resposta) AS Total
			FROM (Unidades INNER JOIN Inspecao ON Und_Codigo = INP_Unidade) INNER JOIN Resultado_Inspecao ON (INP_Unidade = RIP_Unidade) AND (INP_NumInspecao = RIP_NumInspecao)
			GROUP BY Und_CodDiretoria, RIP_Unidade, Und_Descricao, INP_DtEncerramento, RIP_NumInspecao, RIP_Resposta
			HAVING (Und_CodDiretoria = '#cabse#') and (RIP_Unidade = '#cabunid#') AND (INP_DtEncerramento Between #auxdtini# and #auxdtfim#) AND (RIP_Resposta <> 'A')
			ORDER BY Und_CodDiretoria, RIP_Unidade, RIP_NumInspecao
		</cfquery>
		<!--- planilha --->
		<cfquery name="rsXLSa" datasource="#dsn_inspecao#">
			SELECT Und_CodDiretoria, RIP_Unidade, Und_Descricao, INP_DtEncerramento, RIP_NumInspecao, RIP_Resposta, Count(RIP_Resposta) AS Total
			FROM (Unidades INNER JOIN Inspecao ON Und_Codigo = INP_Unidade) INNER JOIN Resultado_Inspecao ON (INP_Unidade = RIP_Unidade) AND (INP_NumInspecao = RIP_NumInspecao)
			GROUP BY Und_CodDiretoria, RIP_Unidade, Und_Descricao, INP_DtEncerramento, RIP_NumInspecao, RIP_Resposta
			HAVING (Und_CodDiretoria = '#form.se#') and (RIP_Unidade = '#form.Unidade#') AND (INP_DtEncerramento Between #auxdtini# and #auxdtfim#) AND (RIP_Resposta <> 'A')
			ORDER BY Und_CodDiretoria, RIP_Unidade, RIP_NumInspecao
		</cfquery>
		<!--- fim planilha --->

</cfif>
</cfoutput>

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="css.css" rel="stylesheet" type="text/css">

<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body>
<cfinclude template="cabecalho.cfm">

<table width="1287" height="450" align="center">
<tr>
<td valign="top" width="1%" class="link1">&nbsp;</td>
<td width="99%" valign="top">
<!--- Área de conteúdo   --->
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT DISTINCT Usu_Matricula FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
</cfquery>

<!---  <cfquery name="rsXLSb" datasource="#dsn_inspecao#">
SELECT TUI_TipoUnid, TUI_Modalidade, Count(TUI_Modalidade) AS Total
FROM (Grupos_Verificacao INNER JOIN Itens_Verificacao ON Grp_Codigo = Itn_NumGrupo) INNER JOIN TipoUnidade_ItemVerificacao ON (Itn_NumItem = TUI_ItemVerif) AND (Itn_NumGrupo = TUI_GrupoItem) GROUP BY Grp_Situacao, Itn_Situacao, TUI_TipoUnid, TUI_Modalidade HAVING (((Grp_Situacao)='A') AND ((Itn_Situacao)='A')) ORDER BY TUI_TipoUnid, TUI_Modalidade
</cfquery> ---> 
<!--- <cfoutput>#rsGeral.recordcount#</cfoutput> --->

<cfif rsGeral.recordcount gt 0>

		<!--- Excluir arquivos anteriores ao dia atual --->
		<cfset sdata = dateformat(now(),"YYYYMMDDHH")>
		<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
		<cfset slocal = #diretorio# & 'Fechamento\'>


		<!--- #diretorio#<br>
		#slocal#<br> --->
		<cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #trim(qUsuario.Usu_Matricula)# & '.xml'>
		 <cffile action="write" addnewline="no" file="#slocal##sarquivo#" output=''>
		 <cffile action="Append" file="#slocal##sarquivo#" output='<?xml version="1.0" encoding="ISO-8859-1" ?>'>


		 <cfdirectory name="qList" filter="*.xml" sort="name desc" directory="#slocal#">
			<cfloop query="qList">
			   <cfif len(name) gte 22>
				<cfif (mid(name,12,8) eq trim(qUsuario.Usu_Matricula)) or (left(sdata,4) gt left(name,4)) or (left(sdata,8) eq left(name,8) and (right(sdata,2) gt mid(name,9,2)))>
				  <cffile action="delete" file="#slocal##name#">
				</cfif>
			  </cfif>
			</cfloop>
		<!--- Fim exclusão de arquivos --->
        <cfif cabse neq 'Todas'>
			<cfquery name="rsSE" datasource="#dsn_inspecao#">
				SELECT Dir_Sigla FROM Diretoria WHERE Dir_Codigo = '#cabse#'
			</cfquery>
		    <cfset cabse = cabse & ' - ' & rsSE.Dir_Sigla >
		</cfif>
        <cfif cabunid neq 'Todas'>
			<cfquery name="rsUni" datasource="#dsn_inspecao#">
				SELECT Und_Descricao FROM Unidades WHERE Und_Codigo = '#cabunid#'
			</cfquery>
		    <cfset cabunid = cabunid & ' - ' & rsUni.Und_Descricao >
		</cfif>		

		  <table width="76%" cellspacing="1" align="center">
		   <tr class="titulos">
			 <td colspan="13">&nbsp;</td>
		   </tr>
			<tr class="titulos">
			  <td colspan="13"><p align="center" class="titulo1"><strong>Pontos de CONTROLE INTERNO</strong></p></td>
			</tr>
		<!---  <cfif form.unidade neq "Todas"> --->
		
			<tr class="exibir">
		
			  <td colspan="13"><div align="right"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>" target="_blank"><img src="icones/xml.jpg" width="103" height="38" border="0"></a></div></td>
			  </tr>
			<tr class="exibir">
			  <td colspan="13" bgcolor="eeeeee">&nbsp;Per&iacute;odo: <strong><cfoutput>#form.dtinic#</cfoutput></strong> até <strong><cfoutput>#form.dtfinal#</cfoutput></strong> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Superintend&ecirc;ncia: <strong><cfoutput>#cabse#</cfoutput></strong> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Unidade(s): <strong><cfoutput>#cabunid#</cfoutput></strong></td>
			  </tr>
			  <cffile action="Append" file="#slocal##sarquivo#" output="<rootelement>">
			  <cffile action="Append" file="#slocal##sarquivo#" output="<Periodo>#form.dtinic# ate #form.dtfinal#</Periodo><Superintendencia>#cabse#</Superintendencia><Unidade>#cabunid#</Unidade>">
		
			<tr class="exibir">
			  <td width="75" bgcolor="eeeeee"><div align="center"></div>
				<div align="left">Dt de In&iacute;cio </div>
				<div align="center"></div>        <div align="center"></div></td>
			  <td width="65" bgcolor="eeeeee">Unidade</td>
			  <td width="292" bgcolor="eeeeee">Nome</td>
			  <td width="98" bgcolor="eeeeee">N&ordm; Inspe&ccedil;&atilde;o</td>
			  <td colspan="2" bgcolor="eeeeee"> <div align="center"><strong>C</strong></div></td>
			  <td colspan="2" bgcolor="eeeeee"> <div align="center"><strong>N</strong></div></td>
			  <td colspan="2" bgcolor="eeeeee"><div align="center"><strong>V</strong></div></td>
			  <td colspan="2" bgcolor="eeeeee"><div align="center"><strong>E</strong></div></td>
			  <td width="60" bgcolor="eeeeee"><div align="center"><strong>Total</strong></div></td>
			</tr>
		
			 <cfset TotC = 0>
			 <cfset TotN = 0>
			 <cfset TotE = 0>
			 <cfset TotV = 0>
			 <cfset TotGerResp = 0>
			 <cfset auxDesc = rsGeral.Und_Descricao>
			 <cfset auxcodunid = rsGeral.RIP_Unidade>
			 <cfset auxinsp = rsGeral.RIP_NumInspecao>
			 <cfset auxdtinic = DateFormat(rsGeral.INP_DtEncerramento,'DD-MM-YYYY')>
		 <!---  <cfdump var="#rsGeral#"> --->

		  <cfoutput query="rsGeral">
			
			<cfif auxinsp eq rsGeral.RIP_NumInspecao>
			  <cfif #uCase(trim(rsGeral.RIP_Resposta))# eq "C"><cfset TotC = rsGeral.Total></cfif>
			  <cfif #uCase(trim(rsGeral.RIP_Resposta))# eq "N"><cfset TotN = rsGeral.Total></cfif>
			  <cfif #uCase(trim(rsGeral.RIP_Resposta))# eq "V"><cfset TotV = rsGeral.Total></cfif>
			  <cfif #uCase(trim(rsGeral.RIP_Resposta))# eq "E"><cfset TotE = rsGeral.Total></cfif>
			<cfelse>
				<cfset TotGerResp = val(TotC + TotN + TotV + TotE)>
				<cffile action="Append" file="#slocal##sarquivo#" output="<Dados>">
				<tr bgcolor="f7f7f7" class="exibir">
			
				<cfset codunid = rsGeral.RIP_Unidade>
				<cfset numinsp = rsGeral.RIP_NumInspecao>
				<td width="75">#auxdtinic#</td>
				<td width="65">#auxcodunid#</td>
				<td width="292">#auxDesc#</td>
				<td width="98">#auxinsp#</td>

				<cfset NF = 0>
				<cfif TotC neq 0 and TotN neq 0>
				   <cfset NF = val((TotC*100)/(TotC + TotN))>
				</cfif>
		
				<cfif NF GTE 80>
				   <cfset corFundo = "eeeeee">
				<cfelse>
				   <cfset corFundo = "FFFFA4">
				</cfif>
				
				<cffile action="Append" file="#slocal##sarquivo#" output="<DtInicio>#auxdtinic#</DtInicio><Unidade>#auxcodunid#</Unidade><Nome>#auxDesc#</Nome><Inspecao>#auxinsp#</Inspecao>">
				<cffile action="Append" file="#slocal##sarquivo#" output="<Resposta>">
				<td width="39"><div align="center"><strong>#TotC#</strong></div></td>
				<td width="45"><div align="right">#NumberFormat(val(TotC / TotGerResp * 100),999.00)#%</div></td>
				<td width="40"><div align="center"><strong>#TotN#</strong></div></td>
				<td width="45"><div align="right">#NumberFormat(val(TotN / TotGerResp * 100),999.00)#%</div></td>
				<td width="40"><div align="center"><strong>#TotV#</strong></div></td>
				<td width="45"><div align="right">#NumberFormat(val(TotV / TotGerResp * 100),999.00)#%</div></td>
				<td width="39"><div align="center"><strong>#TotE#</strong></div></td>
				<td width="45"><div align="right">#NumberFormat(val(TotE / TotGerResp * 100),999.00)#%</div></td>
			   <td width="60"><div align="center">#val(TotGerResp)#</div></td>
				<cffile action="Append" file="#slocal##sarquivo#" output="<TipoC><TotC>#TotC#</TotC><PerC>#NumberFormat(val(TotC / TotGerResp * 100),999.00)#%</PerC></TipoC>">
				<cffile action="Append" file="#slocal##sarquivo#" output="<TipoN><TotN>#TotN#</TotN><PerN>#NumberFormat(val(TotN / TotGerResp * 100),999.00)#%</PerN></TipoN>">
				<cffile action="Append" file="#slocal##sarquivo#" output="<TipoV><TotV>#TotV#</TotV><PerV>#NumberFormat(val(TotV / TotGerResp * 100),999.00)#%</PerV></TipoV>">
				<cffile action="Append" file="#slocal##sarquivo#" output="<TipoE><TotE>#TotE#</TotE><PerE>#NumberFormat(val(TotE / TotGerResp * 100),999.00)#%</PerE></TipoE>">
				<cffile action="Append" file="#slocal##sarquivo#" output="<Total>#TotGerResp#</Total>">
			  </tr>
			  <cffile action="Append" file="#slocal##sarquivo#" output="</Resposta></Dados>">
			<!---  --->
			 <cfset TotC = 0>
			 <cfset TotN = 0>
			 <cfset TotE = 0>
			 <cfset TotV = 0>
			 <cfset TotGerResp = 0>
			  <cfif #uCase(rsGeral.RIP_Resposta)# eq "C"><cfset TotC = rsGeral.Total></cfif>
			  <cfif #uCase(rsGeral.RIP_Resposta)# eq "N"><cfset TotN = rsGeral.Total></cfif>
			  <cfif #uCase(rsGeral.RIP_Resposta)# eq "V"><cfset TotV = rsGeral.Total></cfif>
			  <cfif #uCase(rsGeral.RIP_Resposta)# eq "E"><cfset TotE = rsGeral.Total></cfif>
			 <cfset auxinsp = rsGeral.RIP_NumInspecao>
			 <cfset auxcodunid = rsGeral.RIP_Unidade>
			 <cfset auxDesc = rsGeral.Und_Descricao>
			 <cfset auxdtinic = DateFormat(rsGeral.INP_DtEncerramento,'DD-MM-YYYY')>
	<!---  --->
	</cfif>
     </cfoutput>
	 <!---  --->
	 <cfoutput>
	 <cfset TotGerResp = val(TotC + TotN + TotV + TotE)>
				<cffile action="Append" file="#slocal##sarquivo#" output="<Dados>">
				<tr bgcolor="f7f7f7" class="exibir">
			
				<cfset codunid = rsGeral.RIP_Unidade>
				<cfset numinsp = rsGeral.RIP_NumInspecao>
				<td width="75">#auxdtinic#</td>
				<td width="65">#auxcodunid#</td>
				<td width="292">#auxDesc#</td>
				<td width="98">#auxinsp#</td>

				<cfset NF = 0>
				<cfif TotC neq 0 and TotN neq 0>
				   <cfset NF = val((TotC*100)/(TotC + TotN))>
				</cfif>
		
				<cfif NF GTE 80>
				   <cfset corFundo = "eeeeee">
				<cfelse>
				   <cfset corFundo = "FFFFA4">
				</cfif>
				
				<cffile action="Append" file="#slocal##sarquivo#" output="<DtInicio>#auxdtinic#</DtInicio><Unidade>#auxcodunid#</Unidade><Nome>#auxDesc#</Nome><Inspecao>#auxinsp#</Inspecao>">
				<cffile action="Append" file="#slocal##sarquivo#" output="<Resposta>">
				<td width="39"><div align="center"><strong>#TotC#</strong></div></td>
				<td width="45"><div align="right">#NumberFormat(val(TotC / TotGerResp * 100),999.00)#%</div></td>
				<td width="40"><div align="center"><strong>#TotN#</strong></div></td>
				<td width="45"><div align="right">#NumberFormat(val(TotN / TotGerResp * 100),999.00)#%</div></td>
				<td width="40"><div align="center"><strong>#TotV#</strong></div></td>
				<td width="45"><div align="right">#NumberFormat(val(TotV / TotGerResp * 100),999.00)#%</div></td>
				<td width="39"><div align="center"><strong>#TotE#</strong></div></td>
				<td width="45"><div align="right">#NumberFormat(val(TotE / TotGerResp * 100),999.00)#%</div></td>
			   <td width="60"><div align="center">#val(TotGerResp)#</div></td>
				<cffile action="Append" file="#slocal##sarquivo#" output="<TipoC><TotC>#TotC#</TotC><PerC>#NumberFormat(val(TotC / TotGerResp * 100),999.00)#%</PerC></TipoC>">
				<cffile action="Append" file="#slocal##sarquivo#" output="<TipoN><TotN>#TotN#</TotN><PerN>#NumberFormat(val(TotN / TotGerResp * 100),999.00)#%</PerN></TipoN>">
				<cffile action="Append" file="#slocal##sarquivo#" output="<TipoV><TotV>#TotV#</TotV><PerV>#NumberFormat(val(TotV / TotGerResp * 100),999.00)#%</PerV></TipoV>">
				<cffile action="Append" file="#slocal##sarquivo#" output="<TipoE><TotE>#TotE#</TotE><PerE>#NumberFormat(val(TotE / TotGerResp * 100),999.00)#%</PerE></TipoE>">
				<cffile action="Append" file="#slocal##sarquivo#" output="<Total>#TotGerResp#</Total>">
			  </tr>
			  <cffile action="Append" file="#slocal##sarquivo#" output="</Resposta></Dados>">
			<!---  --->
			 <cfset TotC = 0>
			 <cfset TotN = 0>
			 <cfset TotE = 0>
			 <cfset TotV = 0>
			 <cfset TotGerResp = 0>
			  <cfif #uCase(rsGeral.RIP_Resposta)# eq "C"><cfset TotC = rsGeral.Total></cfif>
			  <cfif #uCase(rsGeral.RIP_Resposta)# eq "N"><cfset TotN = rsGeral.Total></cfif>
			  <cfif #uCase(rsGeral.RIP_Resposta)# eq "V"><cfset TotV = rsGeral.Total></cfif>
			  <cfif #uCase(rsGeral.RIP_Resposta)# eq "E"><cfset TotE = rsGeral.Total></cfif>
			 <cfset auxinsp = rsGeral.RIP_NumInspecao>
			 <cfset auxcodunid = rsGeral.RIP_Unidade>
			 <cfset auxDesc = rsGeral.Und_Descricao>
			 <cfset auxdtinic = DateFormat(rsGeral.INP_DtEncerramento,'DD-MM-YYYY')>
			 </cfoutput>
	 <!---  --->
   
	  </table>
	 
	  <cffile action="Append" file="#slocal##sarquivo#" output="</rootelement>">
	  <table width="76%" align="center">
		<tr>
		  <td width="956" height="26" bgcolor="f7f7f7"><div align="left"><span class="exibir"><strong>&nbsp;C</strong> - Conforme <strong> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;N</strong> - N&atilde;o Conforme <strong> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;V</strong> - N&atilde;o Verificado<strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;E</strong> - N&atilde;o Executou Tarefa</span></div></td>
		</tr>
	  </table>
	  <p><strong> </strong>
	  
</cfif>
<div align="center" class="exibir">
  <div align="center">
  <cfif rsGeral.RecordCount EQ 0>
      <strong class="exibir">Não existe informação para o período/&oacute;rg&atilde;o informado</strong>
  </cfif> </div>
</div>

<!--- Fim Área de conteúdo --->
    </td>
  </tr>
</table>
<cfinclude template="rodape.cfm">
</body>
</html>