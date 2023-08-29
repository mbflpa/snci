<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfquery name="qLotNum" datasource="#dsn_inspecao#">
SELECT TOP 1 * FROM Pesquisa WHERE Pes_Lotacao = '#FORM.nome_orgao#'
ORDER BY Pes_DtPesquisa DESC
</cfquery>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
.linha {
	border: thin dotted #CCCCCC;
}
-->
</style>
<link href="css.css" rel="stylesheet" type="text/css">


<script language="JavaScript" type="text/JavaScript">
<!--
function MM_callJS(jsStr) { //v2.0
  return eval(jsStr)
}
//-->
</script>



<style type="text/css">
<!--
.style6 {font-weight: bold; color: #005782; text-decoration: underline; text-transform: uppercase; font-style: normal;}
-->
</style></head>

<body>
<p align="center">&nbsp;</p>
<p align="center"><span class="style6"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Pesquisa por </font></strong></span><span class="titulo1"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif"> nome do &oacute;rg&atilde;o</font></strong></span><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><br>
          <br>
          <br>
          </font></strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif" class="titulosClaro">A pesquisa serve para avaliarmos o Grau de Import&acirc;ncia e Satisfa&ccedil;&atilde;o Atribu&iacute;da a &Uacute;ltima
            Inspe&ccedil;&atilde;o<br>
      Realizada
em sua Unidade.</font></p>

<p align="center">
<cfif qLotNum.recordcount is 0>
  <span class="red_titulo"> Nome do &oacute;rg&atilde;o n&atilde;o encontrado</span> <br>
  </p>
<p align="center">&nbsp;</p>

<cfelse>
<p align="center" class="titulos"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">
     <!--- <strong>Matr&iacute;cula: </strong><cfoutput>#qLotNum.matricula#</cfoutput> --->
     <strong> &nbsp;Nome: </strong><cfoutput>#qLotNum.Pes_Nome#</cfoutput></font></p>
<p align="center" class="titulos"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Lota&ccedil;&atilde;o:</strong> <cfoutput>#qLotNum.Pes_Lotacao#</cfoutput></font></p>
<hr noshade class="linha">
<table width="100%" border="1" cellspacing="0" bordercolor="#FFFFFF" bgcolor="#FFFFCC">
  <tr>
    <td width="61%"><div align="center" class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Atributos</strong></font></div></td>
    <td width="39%"><div align="center" class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>D&ecirc; sua nota de 1 a 10</strong></font></div>
        <div align="center" class="titulos"></div></td>
  </tr>
</table>
<table width="100%" border="1" cellspacing="0" bordercolor="#FFFFFF" bgcolor="lightyellow">
  <tr>
    <td width="51%"><div align="left" class="titulos"><strong><font size="1">1.<font face="Verdana, Arial, Helvetica, sans-serif"> Comunica&ccedil;&atilde;o
      Pessoal com o Inspecionado - Compreens&atilde;o Rec&iacute;proca</font></font></strong></div></td>
    <td width="26%"><div align="center" class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><cfoutput>#qLotNum.Pes_Comoestamos1#</cfoutput></font> </div></td>
  </tr>
  <tr>
    <td height="20"><div align="left" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">2.
      Postura Durante os Trabalhos - &Eacute;tica, Educa&ccedil;&atilde;o
      e Cortesia</font></strong></div></td>
    <td><div align="center" class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><cfoutput>#qLotNum.Pes_Comoestamos2#</cfoutput></font> </div></td>
  </tr>
  <tr>
    <td height="23"><div align="left" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">3.
      Condu&ccedil;&atilde;o
      da Inspe&ccedil;&atilde;o - Simultaneidade com o M&iacute;nimo
      de Interrup&ccedil;&atilde;o
      das Atividades</font></strong></div></td>
    <td><div align="center" class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><cfoutput>#qLotNum.Pes_Comoestamos3#</cfoutput></font> </div></td>
  </tr>
  <tr>
    <td><div align="left" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">4.
      Recomenda&ccedil;&otilde;es
      - Valor e Pertin&ecirc;ncia </font></strong></div></td>
    <td><div align="center" class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><cfoutput>#qLotNum.Pes_Comoestamos4#</cfoutput></font> </div></td>
  </tr>
  <tr>
    <td><div align="left" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">5.
      Reuni&atilde;o
      de Encerramento - Simplicidade, Objetividade e Clareza </font></strong></div></td>
    <td><div align="center" class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><cfoutput>#qLotNum.Pes_Comoestamos5#</cfoutput></font> </div></td>
  </tr>
  <tr>
    <td><div align="left" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">6.
      Relat&oacute;rio
      - Clareza, Consist&ecirc;ncia e Objetividade da Reda&ccedil;&atilde;o </font></strong></div></td>
    <td><div align="center" class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><cfoutput>#qLotNum.Pes_Comoestamos6#</cfoutput></font> </div></td>
  </tr>
  <tr>
    <td><div align="left" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">7.
      Import&acirc;ncia
      da Inspe&ccedil;&atilde;o para o Aprimoramento da Unidade </font></strong></div></td>
    <td><div align="center" class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><cfoutput>#qLotNum.Pes_Comoestamos7#</cfoutput></font> </div></td>
  </tr>
</table>
<hr noshade class="linha">
<div align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><br>
      <strong> <span class="titulos"><font size="1">Entre
        os Atributos Relacionados <br>
        acima o mais Importante</font></span></strong><span class="titulos"><font color="#6699FF" size="1" face="Verdana, Arial, Helvetica, sans-serif"><cfoutput>#qLotNum.Pes_Nome#</cfoutput></font><strong> <font size="1">foi:</font></strong></span></font> <span class="titulos"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><cfoutput>#qLotNum.Pes_MaisImportante#</cfoutput></font><br>
  </span></div>
<hr noshade class="linha">
<div align="center" class="titulos"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Cr&iacute;ticas, Sugest&otilde;es</strong></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"> <font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>e Elogios</strong></font><br>
   <br>
</font>
<textarea name="sugestoes" cols="50" rows="5" readonly="readonly" wrap="VIRTUAL" id="sugestoes" face="verdana"><cfoutput>#qLotNum.Pes_Sugestoes#</cfoutput></textarea>
</div>
  <p align="left" class="titulos"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><br>
<font size="1">N&deg; da Inspe&ccedil;&atilde;o:</font></font> </strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><cfoutput>#qLotNum.Pes_NumInspecao#</cfoutput></font> </p>
</cfif>
<p align="center" class="titulos"><br>
</p>
</body>
</html>