<html>
<head>
<title>Rotinas de Parecer</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
</head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<body text="#FFFFFF" link="#FFFFFF" vlink="#FFFFFF" alink="#FFFFFF" class="link1">

<a name="Inicio" id="Inicio"></a>
<cfinclude template="cabecalho.cfm">
<cfif isDefined("FORM.nome_arquivo")>
<cffile action="read" file="#GetDirectoryFromPath(gettemplatepath())#Dados\#FORM.nome_arquivo#" variable="XmlDoc">
<!---Lendo nosso arquivo .xml--->
<cfset xml = XmlParse(XmlDoc)>
<!---Converte o string pra XML---> 

<!---O array apresenta o tipo de arquivo + o nome da chave + o nome da chave primaria do xml ---> 
<cfset arq_ins = 0>
<cfset arq_rej = 0>
<cfset verifica = false>

<!--- Insere dados na tabela ParecerUnidade --->
<cfloop from="1" to="#ArrayLen(xml.rootelement.dados)#" index="i"> 
<cftry>
<cfquery datasource="#dsn_inspecao#" name="qVerificaParecer">
SELECT Pos_Unidadem 
FROM ParecerUnidade
WHERE Pos_Unidade = '#xml.rootelement.dados[i].Pos_Unidade.XmlText#' AND Pos_Inspecao = '#xml.rootelement.dados[i].Pos_Inspecao.XmlText#' AND Pos_NumGrupo = #xml.rootelement.dados[i].Pos_NumGrupo.XmlText# AND Pos_NumItem = #xml.rootelement.dados[i].Pos_NumItem.XmlText#;  
</cfquery>
 
<cfif qVerificaParecer.recordCount is 1>	
    <cfset strparecer = xml.rootelement.dados[i].Pos_Parecer.XmlText>
    <cfset strparecer = Replace(strparecer,'"','','All')>
	<cfset strparecer = Replace(strparecer,"'","","All")>
	<cfset strparecer = Replace(strparecer,'&','','All')>
	<cfset strparecer = Replace(strparecer,'*','','All')>
	<!--- <cfset strparecer = Replace(strparecer,'%','','All')> ---> 
	<!--- ================================= --->

<cfquery datasource="#dsn_inspecao#">
UPDATE ParecerUnidade
SET 	Pos_DtPosic = #xml.rootelement.dados[i].Pos_DtPosic.XmlText# ,
		Pos_NomeResp = '#xml.rootelement.dados[i].Pos_NomeResp.XmlText#' ,
		Pos_Parecer = '#strparecer#',
		Pos_Situacao_Resp = '#xml.rootelement.dados[i].Pos_Situacao_Resp.XmlText#',
		Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
WHERE 	Pos_Unidade = '#xml.rootelement.dados[i].Pos_Unidade.XmlText#' AND 
		Pos_Inspecao = '#xml.rootelement.dados[i].Pos_Inspecao.XmlText#' AND 
		Pos_NumGrupo = #xml.rootelement.dados[i].Pos_NumGrupo.XmlText# AND 
		Pos_NumItem = #xml.rootelement.dados[i].Pos_NumItem.XmlText#;
</cfquery>

<cfset arq_ins = arq_ins + 1>

<cfelse>

<cfset arq_rej = arq_rej + 1>

</cfif>

<cfset verifica = true>

<cfcatch type="database">
<script>alert('Ocorreu um erro durante esta operação! Favor verificar novamente os dados, ou contacte o administrador do sistema!')</script>
<a href="" onClick="history.back()">Voltar para a página anterior</a>
</cfcatch>
</cftry>

</cfloop>
<!--- Fim Insere ParecerUnidade --->

<!--- Exclui arquivo xml adicionado com sucesso --->
<cfset arquivo = getDirectoryFromPath(getTemplatePath()) & 'Dados\' & FORM.nome_arquivo>
<cfif verifica is true And FileExists(arquivo)>
  <cffile action="delete" file="#arquivo#">
</cfif>
<table width="780">
	<tr>
		<td width="19%" class="titulos">Registros Incluídos:</td>
		<td width="81%"><cfoutput><span class="titulosClaro">#arq_ins#</span></cfoutput></td>
	</tr>
	<tr>
		<td class="titulos">Registros Rejeitados:</td>
		<td><cfoutput><span class="titulosClaro">#arq_rej#</span></cfoutput></td>
	</tr>
	<tr>
	  <td class="titulos">&nbsp;</td>
	  <td>&nbsp;</td>
	  </tr>
	<tr>
	  <td colspan="2" class="titulos"><center>
	  	<input type="button" class="botao" onClick="window.open('arquivo_dbins_transmitir.cfm','_self')" value="Voltar">
		&nbsp;&nbsp;&nbsp;
	    <input type="button" class="botao" onClick="window.close()" value="Sair">
	    </center></td>
	  </tr>
</table>
<cfelse>
<table width="780">
	<tr>
	  <td class="titulos">&nbsp;</td>
	  <td>&nbsp;</td>
	</tr>
	<tr>
	  <!--- Esta mensagem aparece caso o arquivo de inapeção não seja transmitido. --->
	  <td colspan="3" class="titulos">Não foi possível concluir esta operação. Arquivo de auditoria não localizado.</td>
	</tr>
	<tr>
	  <td colspan="2" class="titulos"><center>
	  	<input type="button" class="botao" onClick="window.open('arquivo_dbins_transmitir.cfm','_self')" value="Voltar">
		&nbsp;&nbsp;&nbsp;
	    <input type="button" class="botao" onClick="window.close()" value="Sair">
	    </center></td>
	  </tr>
</table>
</cfif>
</body>
</html>