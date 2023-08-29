<html>
<head>
<title>Ocorr&ecirc;ncias</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
</head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<body onLoad="" text="#FFFFFF" link="#FFFFFF" vlink="#FFFFFF" alink="#FFFFFF" class="link1">

<div id="Layer1" style="position:absolute; left:11px; top:6px; width:7px; height:6px; z-index:1"></div>

<div align="center"></div>
<a name="Inicio" id="Inicio"></a>
<cfinclude template="cabecalho.cfm">
<cfdirectory directory="#servidor_ftp#" name = "pasta" filter="*.xml">

<table width="780" border="0" align="left" class="Tabela">

<cfif pasta.recordcount neq 0>
 <tr>
   <td colspan="2" class="titulo1">Respostas das ACF's a serem incorporadas
 </tr>
<cfoutput query="pasta"> 
<form name="frm1" action="arquivo_dbins_visualizar_action_parecer_acf.cfm" method="post">
 <tr>
   <td colspan="2">&nbsp;</td>
 </tr>
 <tr bgcolor="E9E9E9">
    <td><span class="exibir">#UCase(pasta.name)#</span>&nbsp;
	<cfif pasta.size lte 500>
	<span class="red_titulo">(#pasta.size#B)</span></td>
    <cfelse>	
	<span class="exibir">(#pasta.size#B)</span>
	</cfif></td>
    <td>
	<input type="hidden" name="nome_arquivo" value="#pasta.name#">
	<input type="submit" name="adicionar" class="botao" value="Incorporar">
&nbsp;
	<input name="apagar" type="button" class="botao" value="Excluir" onClick="window.open('arquivo_dbins_excluir_parecer_acf.cfm?nome=#pasta.name#','_self')" ></td>
    </tr>
</form>
</cfoutput>
<cfelse>
<tr><td colspan="2" align="center"><br>
<span class="red_titulo">NÃO HÁ ARQUIVOS PARA INCORPORAÇÃO À BASE DE DADOS.</span><br><br>

</td>
</tr>
</cfif>
  <tr>
    <td colspan="2" align="center">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2" align="center"><button class="botao" onClick="window.close()">Fechar</button></td>
  </tr>
</table>
</td>
  </tr>
</TABLE>
</body>
</html>