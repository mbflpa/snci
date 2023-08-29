<!--- <cfset arquivo = GetDirectoryFromPath(gettemplatepath()) & 'Dados\' & URL.nome_arquivo>
 <cfoutput>
#URL.nome_arquivo#<br>
#arquivo#<br>
</cfoutput>  --->

 <cfdirectory directory="#GetDirectoryFromPath(GetTemplatePath())#\Dados" name = "pasta" filter="*.xml">
  <cfoutput query="pasta">
<!---   #pasta.name#<br> --->
		<cfif left(trim(pasta.name),10) eq left(trim(URL.nome_arquivo),10)>
  		  <cfset arquivo = GetDirectoryFromPath(gettemplatepath()) & 'Dados\' & pasta.name>
		   <cffile action="delete" file="#arquivo#">
		</cfif>
  </cfoutput>
<!--- <cfset gil = gil> --->
<html>
<head><title>Sistema de Acompanhamento das Respostas das Auditorias</title></head>
<body onLoad="alert('Arquivo excluído com Sucesso!');document.frmExclusao.submit()">
<form name="frmExclusao" method="post" action="arquivo_dbins_transmitir.cfm">
<input type="hidden" name="nome_arquivo" size="16" class="form" value="<cfoutput>#url.nome_arquivo#</cfoutput>">
<input type="hidden" name="numero_inspecao" size="16" class="form" value="<cfoutput>#url.num_inspecao#</cfoutput>">
</form>
</body>
</html>