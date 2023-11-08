 <cftry>    
  <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="permissao_negada.htm">
  <cfabort>
</cfif>   
 <cfoutput>
<!--- #Form.arquivo#<br>
#form.numero_inspecao#<br>
<cfset nomearquivo = form.numero_inspecao> --->
</cfoutput> 
<cfset smatric = mid(form.numero_inspecao,12,8)>
<cfquery datasource="#dsn_inspecao#" name="rsFunc">
  SELECT Fun_Matric FROM Funcionarios WHERE Fun_Matric = '#smatric#'
</cfquery>
<cfif rsFunc.recordcount is 0>
  <html>
		<head>
		<title>Sistema Nacional de Controle Interno</title>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<link href="CSS.css" rel="stylesheet" type="text/css">
		<table align="center">
		<tr><td colspan="7" align="center">
	  <span class="red_titulo">Arquivo com nome fora do padrão do SGI ou Falta a identificação do Inspetor: <cfoutput>#smatric#</cfoutput> no SNCI</span><br><br>
	  <button class="botao" onClick="window.open('arquivo_dbins_transmitir.cfm', '_self')">Voltar para Transmitir</button> <button class="botao" onClick="window.close()">Fechar</button>
	  </td>
  </tr>
  </table>
  </head>
  <body>
   <cfabort>
  </body>
  </html>
  
</cfif>
<cfif isDefined("Form.arquivo")>
<!---      excluir arquivo existente no diretorio dados --->
     <cfset arquivo = GetDirectoryFromPath(gettemplatepath()) & 'dados\' & #Form.numero_inspecao#>
	 <cfif FileExists(arquivo)>
		<cffile action="delete" file="#arquivo#">
	 </cfif>
	<!--- Enviando o arquivo inspecao.xml na pasta dados no servidor --->
	<cffile action="upload" filefield="arquivo" destination="#GetDirectoryFromPath(GetTemplatePath())#Dados" nameconflict="makeunique" accept="application/x-xml,text/xml">
	
	<!--- Lendo o arquivo teste.xml na pasta dados no servidor --->
    <cffile action="read" file="#GetDirectoryFromPath(gettemplatepath())#Dados\#form.numero_inspecao#" variable="XmlDoc" charset="iso-8859-1">
	
	<!---Converte o string pra documento XML--->

    <cfset xml = XmlParse(XmlDoc)>



	<!---O array apresenta o tipo de arquivo + o nome da chave + o nome da chave primaria do xml --->
	
	<!--- Armazena dados do arquivo xml (índice do vetor = 1, primeiro registro do arquivo xml) --->
	<cfset STO = xml.rootelement.dados[1].RIP_Unidade.XmlText>
	<cfset Numero = xml.rootelement.dados[1].RIP_NumInspecao.XmlText>
	<cfset Data = xml.rootelement.dados[1].INP_DtInicInspecao.XmlText>
	
	
	<cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>
    <cfset destino = cffile.serverdirectory & '\dados\' & #Form.numero_inspecao#> 
 
	
	<!--- Existencia do Inspetor --->
	<cfset inspetorSN = 'S'>
	<cfset msginsp = "">
	<cfset numocor = 1>
	<cfloop from="1" to="#val(Len(xml.rootelement.dados[1].IPT_MatricInspetor.XmlText) / 8)#" index="j">
	    <cfset smatr = mid(xml.rootelement.dados[1].IPT_MatricInspetor.XmlText,numocor,8)>

		<cfquery datasource="#dsn_inspecao#" name="rsFunc">
		  SELECT Fun_Matric FROM Funcionarios WHERE Fun_Matric = '#smatr#'
		</cfquery>
	    <cfif rsFunc.recordcount is 0>
		 	<cfset inspetorSN = 'N'>
			<cfset msginsp = "Inspetor sem cadastro no SNCI">
		</cfif>
		<cfset numocor = numocor + 8>
	</cfloop>
	<!--- fim existencia do inspetor --->

<cfquery datasource="#dsn_inspecao#" name="qUnidade">
SELECT Und_Descricao, Und_Status
FROM Unidades
WHERE Und_Codigo = '#STO#'
</cfquery>

<cfif qUnidade.Und_Status eq 'D'>
     <cfinclude template="Unidade_desativada.htm">
  <cfabort>
</cfif>
<!--- Fim Leitura do arquivo --->
</cfif>

<cfquery datasource="#dsn_inspecao#" name="qVerifica">
SELECT INP_Unidade, INP_DtInicInspecao, Und_Descricao, INP_NumInspecao, Und_Codigo, Und_Status
FROM Inspecao INNER JOIN Unidades ON INP_Unidade = Und_Codigo
WHERE INP_NumInspecao = '#Form.numero_inspecao#'
</cfquery>


<cfparam name="qVerifica.RecordCount" default="0">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="CSS.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {font-size: 10px}
-->
</style>
</head>
<body onLoad="" text="#FFFFFF" link="#FFFFFF" vlink="#FFFFFF" alink="#FFFFFF" class="link1">

<div id="Layer1" style="position:absolute; left:11px; top:6px; width:7px; height:6px; z-index:1"></div>

<div align="center">
	<cfinclude template="cabecalho.cfm">
</div>
<!--- Critica do campo ano --->
<cfset ano_insp_aux = year(Data)>
<cfset ano_num_insp_aux = right(Numero,4)>
<cfif len(xml.rootelement.dados[1].RIP_NumInspecao.XmlText) neq 10 or ano_insp_aux gt year(now()) or ano_insp_aux lte (year(now()) - 2) or ano_num_insp_aux gt year(now()) or ano_num_insp_aux lte (year(now()) - 2)>
   <table  border="1" class="Tabela" align="center" width="700">
  <tr align="center">
    <td colspan="3" class="red_titulo">RELATÓRIO RECUSADO! </td>
  </tr><br><br><br>
  <tr align="center">
    <td colspan="3" class="red_titulo">Campo Ano: Data Inicio Inspeção e/ou do Nº da Inspeção</td>
  </tr>
  <tr><br><br><br>
    <td valign="top">&nbsp;</td>
    <td valign="top">&nbsp;</td>
    <td valign="top">&nbsp;</td>
  </tr>
  <tr class="titulos">
    <td valign="top" width="207"><p align="center">Nº Relatório</p></td>
    <td valign="top" width="271"><p align="center">Unidade</p></td>
    <td valign="top" width="207"><p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;Data de Inicio</p></td>
  </tr>
  <tr class="exibir">
    <td valign="top"><p align="center"><cfoutput>#qVerifica.INP_NumInspecao#</cfoutput></p></td>
    <td valign="top"><p align="center"><cfoutput>#qVerifica.Und_Descricao#</cfoutput></p></td>
    <td valign="top"><p align="center"><cfoutput>#DateFormat(qVerifica.INP_DtInicInspecao,"dd/mm/yyyy")#</cfoutput></p></td>
  </tr>
  <tr class="exibir">
    <td colspan="3" valign="top"><p align="center"><button class="botao" onClick="window.close()">Fechar</button></td>
    </tr>
</table>
<cfelse>
 <cfif qVerifica.recordCount neq 0>
 <!--- <cfif qUnidade.Und_Status eq 'D'> --->
 <table  border="1" class="Tabela" align="center" width="700">
  <tr align="center">
    <td colspan="3" class="red_titulo">RELATÓRIO J&Aacute; EXISTE ! </td>
  </tr>
  <tr><br><br><br>
    <td valign="top">&nbsp;</td>
    <td valign="top">&nbsp;</td>
    <td valign="top">&nbsp;</td>
  </tr>
  <tr class="titulos">
    <td valign="top" width="207"><p align="center">Nº Relatório</p></td>
    <td valign="top" width="271"><p align="center">Unidade</p></td>
    <td valign="top" width="207"><p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;Data de Inicio</p></td>
  </tr>
  <tr class="exibir">
    <td valign="top"><p align="center"><cfoutput>#qVerifica.INP_NumInspecao#</cfoutput></p></td>
    <td valign="top"><p align="center"><cfoutput>#qVerifica.Und_Descricao#</cfoutput></p></td>
    <td valign="top"><p align="center"><cfoutput>#DateFormat(qVerifica.INP_DtInicInspecao,"dd/mm/yyyy")#</cfoutput></p></td>
  </tr>
  <tr class="exibir">
    <td colspan="3" valign="top"><p align="center"><button class="botao" onClick="window.close()">Fechar</button></td>
    </tr>
</table>
   <cffile action="delete" file="#destino#">
<cfelse>

<table width="700" border="1" align="center" class="Tabela">
  <cfif isDefined("Form.arquivo")>
  <tr class="titulos">
    <td valign="top" colspan="3"><p align="center">INSPEÇÃO A SER INCORPORADA ! </p></td>
  </tr>
  <tr><br><br><br>
    <td valign="top">&nbsp;</td>
    <td valign="top">&nbsp;</td>
    <td valign="top">&nbsp;</td>
  </tr>
  <tr class="titulos">
    <td valign="top" width="191"><p align="center">NºRelatório</p></td>
    <td valign="top" width="275"><p align="center">Unidade</p></td>
    <td valign="top" width="207"><p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Dt.Inicio da Inspeção </p></td>
  </tr>
  <tr class="exibir">
    <td valign="top" width="191"><p align="center"><cfoutput>#Form.numero_inspecao#</cfoutput></p></td>
    <td valign="top" width="275"><p align="center"><cfoutput>#qUnidade.Und_Descricao#</cfoutput></p></td>
    <td valign="top" width="207"><p align="center"><cfoutput>#Data#</cfoutput></p></td>
  </tr>
  </cfif>

 <cfdirectory directory="#GetDirectoryFromPath(GetTemplatePath())#\Dados" name = "pasta" filter="*.xml">

 <cfif pasta.recordcount neq 0>

	 <cfoutput query="pasta">
	 <form name="frm1" action="arquivo_dbins_visualizar_action.cfm?flush=true" method="post">
	 <tr>
	   <td colspan="7">&nbsp;</td>
	 </tr>
	 <tr>
		<td colspan="2"><span class="exibir">#pasta.name#</span>&nbsp;
		<cfif pasta.size lte 500>
		<span class="red_titulo">(#pasta.size#B)</span>
		<cfelse>
		<span class="exibir">(#pasta.size#B)</span>
		</cfif></td>
		<td colspan="3">
		<input type="hidden" name="nome_arquivo" id="nome_arquivo" value="#pasta.name#">
		<input type="hidden" name="numero_inspecao" id="numero_inspecao" value="#form.numero_inspecao#">
		<cfif inspetorSN eq "N">
		<input type="submit" name="adicionar" class="botao" value="#msginsp#" disabled="Yes">
		<cfelse>
		<input type="submit" name="adicionar" class="botao" value="Incorporar">
		</cfif>
		&nbsp;
		<input name="apagar" type="button" class="botao" value="Excluir" onClick="window.open('arquivo_dbins_excluir.cfm?nome_arquivo=#pasta.name#&num_inspecao=#Form.numero_inspecao#','_self')" >
	  </tr>
	  </form>
	  </cfoutput>
  <cfelse>
	  <tr><td colspan="7" align="center">
	  <span class="red_titulo">NÃO HÁ ARQUIVOS PARA INCORPORAÇÃO À BASE DE DADOS.</span><br><br>
	  <button class="botao" onClick="window.open('arquivo_dbins_transmitir.cfm', '_self')">Transmitir outro arquivo</button> <button class="botao" onClick="window.close()">Fechar</button>
	  </td>
	  </tr>
  </cfif>
  <tr>
    <td colspan="7">&nbsp;</td>
  </tr>
  </table>
  <cfoutput>
    <input type="hidden" name="nome_arquivo" value="#pasta.name#">
  </cfoutput>
 </cfif>
 </cfif>
</body>
</html>

 <cfcatch>   
		<!--- <cfset arquivo = GetDirectoryFromPath(gettemplatepath()) & 'Dados\' & #Form.numero_inspecao#> --->
        <cfset arquivo = getDirectoryFromPath(getTemplatePath()) & 'Dados\' & FORM.nome_arquivo>
		<cfif FileExists(arquivo)>
		  <cffile action="delete" file="#arquivo#">
		</cfif>
		<!--- <cfdump var="#cfcatch#"> --->
		<html>
		<head>
		<title>Sistema Nacional de Controle Interno</title>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<link href="CSS.css" rel="stylesheet" type="text/css">
		<table align="center">
		<tr><td colspan="7" align="center">
	  <span class="red_titulo">Arquivo com problemas. Procurar o administrador do sistema.</span><br><br>
   <span class="red_titulo"><cfoutput>#cfcatch.Detail#</cfoutput></span><br><br> 
	  <button class="botao" onClick="window.open('arquivo_dbins_transmitir.cfm', '_self')">Transmitir outro arquivo</button> <button class="botao" onClick="window.close()">Fechar</button>
	  </td>
  </tr>
  </table>
  </head>
  <body>
  </body>
  </html>
   </cfcatch> 
 </cftry>  