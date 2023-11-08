<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="permissao_negada.htm">
  <cfabort>
</cfif>

<!--- Enviando o arquivo inspecao.xml na pasta dados no servidor --->
<cffile action="upload" filefield="arquivo" destination="#GetDirectoryFromPath(GetTemplatePath())#Dados" nameconflict="makeunique" accept="application/x-xml,text/xml">

<!--- Lendo o arquivo teste.xml na pasta dados no servidor --->
<cffile action="read" file="#GetDirectoryFromPath(gettemplatepath())#Dados\Inspecao.xml" variable="XmlDoc">

<!---Converte o string pra documento XML---> 
<cfset xml = XmlParse(XmlDoc)>



<!---O array apresenta o tipo de arquivo + o nome da chave + o nome da chave primaria do xml ---> 

<!--- Armazena dados do arquivo xml (índice do vetor = 1, primeiro registro do arquivo xml) --->
<cfset STO = xml.rootelement.dados[1].RIP_Unidade.XmlText>
<cfset Numero = xml.rootelement.dados[1].RIP_NumInspecao.XmlText> 
<cfset Data = xml.rootelement.dados[1].INP_DtInicInspecao.XmlText>


<cfquery datasource="#dsn_inspecao#" name="qUnidade">
SELECT Und_Descricao
FROM Unidades
WHERE Und_Codigo = #STO#
</cfquery>

<cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>
<cfset destino = cffile.serverdirectory & '\' & Form.numero_inspecao & '_' & TRIM(sto) & '.xml'>
<cfif FileExists(origem) And Not FileExists(destino)> 
<cffile action="rename" source="#origem#" destination="#destino#"> 
</cfif> 


<!--- Fim Leitura do arquivo --->

<cfquery datasource="#dsn_inspecao#" name="qVerifica">
SELECT INP_Unidade, INP_DtInicInspecao, Und_Descricao, INP_NumInspecao
FROM Inspecao INNER JOIN Unidades ON Inspecao.INP_Unidade = Unidades.Und_Codigo
WHERE INP_NumInspecao = '#Numero#'
</cfquery>

<cfparam name="qVerifica.RecordCount" default="0">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
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

<div align="center"></div>

<cfinclude template="cabecalho.cfm">

<cfif qVerifica.recordCount neq 0>
<table  border="1" class="Tabela" align="center" width="700">
  <tr align="center">
    <td colspan="3" class="red_titulo">INSPE&Ccedil;&Atilde;O J&Aacute; EXISTE ! </td>
  </tr>
  <tr><br><br><br>
    <td valign="top">&nbsp;</td>
    <td valign="top">&nbsp;</td>
    <td valign="top">&nbsp;</td>
  </tr>
  <tr class="titulos">
    <td valign="top" width="207"><p align="center">Nº  Inspeção</p></td>
    <td valign="top" width="271"><p align="center">Unidade</p></td>
    <td valign="top" width="207"><p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;Data de Inicio da Inspeção</p></td>
  </tr>  
  <tr class="exibir">
    <td valign="top"><p align="center"><cfoutput>#qVerifica.INP_NumInspecao#</cfoutput></p></td>
    <td valign="top"><p align="center"><cfoutput>#qVerifica.Und_Descricao#</cfoutput></p></td>
    <td valign="top"><p align="center"><cfoutput>#DateFormat(qVerifica.INP_DtInicInspecao,"dd/mm/yyyy")#</cfoutput></p></td>
  </tr>
  <tr class="exibir">
    <td colspan="3" valign="top"><p align="center">&nbsp;</p>      <p align="center"><button class="botao" onClick="window.close()">Fechar</button>            <p align="center">&nbsp;</p></td>
    </tr>
</table>
   <cffile action="delete" file="#destino#"> 
<cfelse>
<table width="700" border="1" align="center" class="Tabela">
  <tr class="titulos">
    <td valign="top" colspan="3"><p align="center">INSPE&Ccedil;&Atilde;O A SER INCORPORADA ! </p></td>
  </tr>
  <tr><br><br><br>
    <td valign="top">&nbsp;</td>
    <td valign="top">&nbsp;</td>
    <td valign="top">&nbsp;</td>
  </tr>
  <tr class="titulos">
    <td valign="top" width="191"><p align="center">N&ordm; Inspe&ccedil;&atilde;o</p></td>
    <td valign="top" width="275"><p align="center">Unidade</p></td>
    <td valign="top" width="207"><p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Data de Inicio da Inspeção </p></td>
  </tr>
  <tr class="exibir">
    <td valign="top" width="191"><p align="center"><cfoutput>#Numero#</cfoutput></p></td>
    <td valign="top" width="275"><p align="center"><cfoutput>#qUnidade.Und_Descricao#</cfoutput></p></td>
    <td valign="top" width="207"><p align="center"><cfoutput>#Data#</cfoutput></p></td>
  </tr>
<cfdirectory directory="#GetDirectoryFromPath(GetTemplatePath())#\Dados" name = "pasta" filter="*.xml">

<cfif pasta.recordcount neq 0>
 
<cfoutput query="pasta"> 
<form name="frm1" action="arquivo_dbins_visualizar_action.cfm" method="post">
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
	<input type="hidden" name="nome_arquivo" value="#pasta.name#"> 
	<input type="submit" name="adicionar" class="botao" value="Incorporar">
	&nbsp;	
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
</body>
</html>
