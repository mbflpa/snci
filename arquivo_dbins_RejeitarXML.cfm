
  <html>
		<head>
		<title>Sistema Nacional de Controle Interno</title>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<link href="CSS.css" rel="stylesheet" type="text/css">
	 </head>
  <body>
  <form action="" method="get">
  
    <table  border="1" class="Tabela" align="center" width="680">
  <tr align="center">
    <td colspan="4" class="titulosClaro2">RELATÓRIO RECUSADO! </td>
  </tr><br><br><br>
  <tr align="center">
    <td colspan="4" class="red_titulo">Motivo : <cfoutput>#form.motivo#</cfoutput></td>
  </tr>
  <tr><br><br><br>
    <td colspan="4" valign="top">&nbsp;</td>
    </tr>
  <tr class="titulos">
    <td valign="top" width="140"><p align="center">Nº Relatório</p></td>
    <td valign="top" width="117"><p align="center">Unidade</p></td>
    <td valign="top" width="101"><p align="left">&nbsp;Data de Inicio</p></td>
    <td valign="top" width="294">Nome do Arquivo </td>
  </tr>
  <tr class="exibir">
    <td valign="top"><p align="center"><cfoutput>#form.numrelat#</cfoutput></p></td>
    <td valign="top"><p align="center"><cfoutput>#form.numunid#</cfoutput></p></td>
	<cfif len(trim(form.dtiniinsp)) eq 10>
	      <cfset dtiniinsp = form.dtiniinsp>
	<cfelse>
	   <cfset dtiniinsp = "??/??/????">
	</cfif>
	<td valign="top"><p align="center"><cfoutput>#dtiniinsp#</cfoutput></p></td>
    <td valign="top"><cfoutput>#form.nomearquivo#</cfoutput></td>
  </tr>
  <tr class="exibir">
    <td colspan="4" valign="top">&nbsp;</td>
  </tr>
  <tr class="exibir">
    <td colspan="4" valign="top"><p align="center">
      <button class="botao" onClick="window.close()">Fechar</button></td>
    </tr>
</table>
<cfoutput>
 <cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

      <cfquery name="qAnexos" datasource="#dsn_inspecao#">
		SELECT     Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Codigo, Ane_Caminho
		FROM       Anexos
		WHERE  Ane_Unidade = '#form.numunid#' and Ane_NumInspecao = '#form.numrelat#'
	  </cfquery>
<!--- <cfset gil = gil> --->
<cfif IsDefined("form.nu_inspecao") and #form.nu_inspecao# neq "">
   <cfif form.excluirsn eq "S">
   		<cfquery datasource="#dsn_inspecao#">
		DELETE FROM Andamento WHERE AND_Unidade = '#form.numunid#' and AND_NumInspecao = '#form.numrelat#'
	   </cfquery>
	   <cfquery datasource="#dsn_inspecao#">
		DELETE FROM ParecerCausaProvavel WHERE PCP_Unidade = '#form.numunid#' and PCP_Inspecao = '#form.numrelat#'
	   </cfquery>
	   <cfquery datasource="#dsn_inspecao#">
		DELETE FROM ParecerUnidade WHERE Pos_Unidade = '#form.numunid#' and Pos_Inspecao = '#form.numrelat#'
	   </cfquery>
		<cfquery datasource="#dsn_inspecao#">
		DELETE FROM ProcessoParecerUnidade WHERE Pro_Unidade = '#form.numunid#' and Pro_Inspecao = '#form.numrelat#'
	   </cfquery>
	   <cfquery datasource="#dsn_inspecao#">
		DELETE FROM Resultado_Inspecao WHERE RIP_Unidade = '#form.numunid#' and RIP_NumInspecao = '#form.numrelat#'
	   </cfquery>
	   <cfquery datasource="#dsn_inspecao#">
		DELETE FROM Inspetor_Inspecao WHERE IPT_CodUnidade = '#form.numunid#' and IPT_NumInspecao = '#form.numrelat#'
	   </cfquery>
	   <cfquery datasource="#dsn_inspecao#">
		DELETE FROM Inspecao WHERE INP_Unidade = '#form.numunid#' and INP_NumInspecao = '#form.numrelat#'
	   </cfquery>
	   <cfquery datasource="#dsn_inspecao#">
		DELETE FROM Numera_Inspecao WHERE NIP_Unidade = '#form.numunid#' and NIP_NumInspecao = '#form.numrelat#'
	   </cfquery>
       <cfquery datasource="#dsn_inspecao#">
        DELETE FROM Analise WHERE Ana_Unidade = '#form.numunid#' and Ana_NumInspecao = '#form.numrelat#'
       </cfquery>
		<cfif qAnexos.recordCount Neq 0>
		   <cfif FileExists(qAnexos.Ane_Caminho)>
			  <!--- <cffile action="delete" file="#qAnexos.Ane_Caminho#"> --->
		   </cfif>
			  <cfquery datasource="#dsn_inspecao#">
				 DELETE FROM Anexos WHERE Ane_Unidade = '#form.numunid#' and Ane_NumInspecao = '#form.numrelat#'
			  </cfquery>
        </cfif>
   </cfif>
</cfif>
</cfoutput>
<cfoutput>
  <input name="motivo" id="motivo" type="hidden" value="#form.motivo#">
  <input name="nomearquivo" id="nomearquivo" type="hidden" value="#form.nomearquivo#">
  <input name="numrelat" id="numrelat" type="hidden" value="#form.numrelat#">
  <input name="numunid" id="numunid" type="hidden" value="#form.numunid#">
  <input name="dtiniinsp" id="dtiniinsp" type="hidden" value="#form.dtiniinsp#">
  <input name="excluirsn" id="excluirsn" type="hidden" value="#form.excluirsn#">
</cfoutput>
 <!--- Exclusão do arquivo enviado ao servidor --->
 <cfset arquivo = GetDirectoryFromPath(gettemplatepath()) & 'dados\' & #Form.nomearquivo#>
 <cfif FileExists(arquivo)>
	<cffile action="delete" file="#arquivo#">
 </cfif>
</form>
  </body>
  </html>

<cfset sdtatual = dateformat(now(),"YYYYMMDDHH")>
<cfset sdtarquivo = dateformat(now(),"YYYYMMDDHH")>
<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
<cfset slocal = #diretorio# & 'Dados\'>  
<!--- <cfdirectory name="qList" filter="*.*" sort="name desc" directory="#slocal#"> --->
<cfdirectory name="qList" filter="*.*" sort="name asc" directory="#slocal#">
<cfoutput query="qList">
   <cfset sdtarquivo = dateformat(dateLastModified,"YYYYMMDDHH")> 
	   <cfif left(sdtatual,8) eq left(sdtarquivo,8)>
			<cfif (right(sdtatual,2) - right(sdtarquivo,2)) gte 2>
			   <cffile action="delete" file="#slocal##name#">  
			</cfif>
	  <cfelseif left(sdtatual,8) gt left(sdtarquivo,8)>
		<cffile action="delete" file="#slocal##name#">
	  </cfif>
<!--- 	 data atual: #sdtatual# -     Data do arquivo: #sdtarquivo#   nome do arquivo: #name#<br> --->
</cfoutput>
<!--- <cfset gil = gil> --->

