<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfset data1 = CreateDate(Right(url.data_inicial,4),Mid(url.data_inicial,4,2),Left(url.data_inicial,2))>
<cfset data2 = CreateDate(Right(url.data_final,4),Mid(url.data_final,4,2),Left(url.data_final,2))>


<cfquery name="RsConsulta" datasource="#dsn_inspecao#">
SELECT count(Pes_NumInspecao) as conta
FROM Pesquisa INNER JOIN Inspecao ON Pes_NumInspecao = INP_NumInspecao
WHERE INP_DtFimInspecao between #data1# And #data2#
</cfquery>

<cfquery name="Rsmedia" datasource="#dsn_inspecao#">
SELECT AVG(Pes_Comoestamos1) AS media8, AVG(Pes_Comoestamos2) AS media9, AVG(Pes_Comoestamos3) AS media10, AVG(Pes_Comoestamos4) AS media11, AVG(Pes_Comoestamos5) AS media12, AVG(Pes_Comoestamos6) AS media13, AVG(Pes_Comoestamos7) AS media14, (AVG(Pes_Comoestamos1) + AVG(Pes_Comoestamos2) + AVG(Pes_Comoestamos3) + AVG(Pes_Comoestamos4) + AVG(Pes_Comoestamos5) + AVG(Pes_Comoestamos6) + AVG(Pes_Comoestamos7)) / 7 AS Soma
FROM Pesquisa INNER JOIN Inspecao ON Pes_NumInspecao = INP_NumInspecao
WHERE INP_DtFimInspecao between #data1# And #data2#
</cfquery>

<html>
<head>
<link href="css.css" rel="stylesheet" type="text/css">

<style type="text/css">
<!--
.style2 {color: #ECE9D8}
-->
</style>
</head>

<cfif RsConsulta.RecordCount is 0>

Não foi encontrado nenhum formulário!


<cfelse>

<body>
<div align="center">
  <p><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><br>
  </font> </strong></p>
  
  
  <p class="titulo1"> <font size="2" face="Verdana, Arial, Helvetica, sans-serif">M&eacute;dia
        das notas dos atributos </font> </p>
  <p><strong> </strong></p>
  <p class="titulosClaro"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Foram
        encontradas <cfoutput> <font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>#RsConsulta.conta#</strong></font> </cfoutput> pesquisas de satisfa&ccedil;&atilde;o
        no intervalo  entre <cfoutput> #url.data_inicial# </cfoutput>
        
          e <cfoutput> #url.data_final# </cfoutput>
       
  </strong></font>         </p>
  <table width="94%" border="1" bordercolor="#FFFFFF">
    <tr>
      <td colspan="3" bgcolor="#FFFFCC"><div align="center" class="titulos"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">M&eacute;dia
        dos atributos relacionados a expectativa e avalia&ccedil;&atilde;o</font></div></td>
    </tr>
    <tr>
      <td width="78%" bgcolor="lightyellow"><div align="left" class="titulos"><strong><font size="1"><font face="Verdana, Arial, Helvetica, sans-serif">1.
        Comunica&ccedil;&atilde;o
        Pessoal com o Inspecionado - Compreens&atilde;o Rec&iacute;proca</font></font></strong> </div>
        <div align="center"></div></td>
      <td width="21%" bgcolor="lightyellow" class="titulos"><div align="center" class="titulos">
          <div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>M&eacute;dia</strong></font></div>
      </div></td>
      
    </tr>
  <td bgcolor="lightyellow"><div align="center"><cfoutput></cfoutput></div></td>
      <td bgcolor="lightyellow" class="titulos"><div align="center"><cfoutput>#LSNumberFormat(Rsmedia.media8,"__._")#</cfoutput></div></td>
  </tr>
  <tr>
    <td bgcolor="lightyellow" class="titulos style2"><div align="left" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">2.
      Postura Durante os Trabalhos - &Eacute;tica, Educa&ccedil;&atilde;o
      e Cortesia</font></strong></div>
        <div align="center" class="titulos"></div></td>
    <td bgcolor="lightyellow" class="titulos"><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>M&eacute;dia</strong></font></div></td>
  </tr>
  <td bgcolor="lightyellow"><div align="center"><cfoutput></cfoutput></div></td>
      <td bgcolor="lightyellow" class="titulos"><div align="center"><cfoutput>#LSNumberFormat(Rsmedia.media9,"__._")#</cfoutput></div></td>
  </tr>
  <tr class="titulosClaro">
    <td bgcolor="lightyellow"><div align="left" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">3.
      Condu&ccedil;&atilde;o da Inspe&ccedil;&atilde;o - Simultaneidade
      com o M&iacute;nimo de Interrup&ccedil;&atilde;o das Atividades</font></strong></div>
        <div align="center" class="titulos"></div></td>
    <td bgcolor="lightyellow" class="titulos"><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>M&eacute;dia</strong></font></div></td>
  </tr>
  <td bgcolor="lightyellow"><div align="center"><cfoutput></cfoutput></div></td>
      <td bgcolor="lightyellow" class="titulos"><div align="center"><cfoutput>#LSNumberFormat(Rsmedia.media10,"__._")#</cfoutput></div></td>
  </tr>
  <tr>
    <td bgcolor="lightyellow"><div align="left" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">4.
      Recomenda&ccedil;&otilde;es - Valor e Pertin&ecirc;ncia </font></strong></div>
        <div align="center" class="titulos"></div></td>
    <td bgcolor="lightyellow" class="titulos"><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>M&eacute;dia</strong></font></div></td>
  </tr>
  <td bgcolor="lightyellow"><div align="center"><cfoutput></cfoutput></div></td>
      <td bgcolor="lightyellow" class="titulos"><div align="center"><cfoutput>#LSNumberFormat(Rsmedia.media11,"__._")#</cfoutput></div></td>
  </tr>
  <tr>
    <td bgcolor="lightyellow"><div align="left" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">5.
      Reuni&atilde;o de Encerramento - Simplicidade, Objetividade e
      Clareza </font></strong></div>
        <div align="center" class="titulos"></div></td>
    <td bgcolor="lightyellow" class="titulos"><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>M&eacute;dia</strong></font></div></td>
  </tr>
  <td bgcolor="lightyellow"><div align="center"><cfoutput></cfoutput></div></td>
      <td bgcolor="lightyellow" class="titulos"><div align="center"><cfoutput>#LSNumberFormat(Rsmedia.media12,"__._")#</cfoutput></div></td>
  </tr>
  <tr>
    <td bgcolor="lightyellow"><div align="left" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">6.
      Relat&oacute;rio - Clareza, Consist&ecirc;ncia e Objetividade da
      Reda&ccedil;&atilde;o</font> </strong></div>
        <div align="center" class="titulos"></div></td>
    <td bgcolor="lightyellow" class="titulos"><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>M&eacute;dia</strong></font></div></td>
  </tr>
  <td bgcolor="lightyellow"><div align="center"><cfoutput></cfoutput></div></td>
      <td bgcolor="lightyellow" class="titulos"><div align="center"><cfoutput>#LSNumberFormat(Rsmedia.media13,"__._")#</cfoutput></div></td>
  </tr>
  <tr bgcolor="lightyellow">
    <td bgcolor="lightyellow"><div align="left" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">7.
      Import&acirc;ncia da Inspe&ccedil;&atilde;o para o Aprimoramento
      da Unidade</font> </strong></div>
        <div align="center" class="titulos"></div></td>
    <td bgcolor="lightyellow" class="titulos"><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>M&eacute;dia</strong></font></div></td>
  </tr>
  <tr>
    <td bgcolor="lightyellow"><div align="center"><cfoutput></cfoutput></div></td>
    <td bgcolor="lightyellow" class="titulos"><div align="center"><cfoutput>#LSNumberFormat(Rsmedia.media14,"__._")#</cfoutput></div></td>
  </tr>
  <tr>
    <td bgcolor="lightyellow">&nbsp;</td>
    <td bgcolor="lightyellow" class="titulos">&nbsp;</td>
  </tr>
  <tr>
    <td bgcolor="lightyellow"><div align="center"><cfoutput></cfoutput><span class="titulos"><strong></strong></span></div></td>
    <td bgcolor="lightyellow" class="titulos"><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"></font></div></td>
  </tr>
  <td bgcolor="lightyellow"><div align="center"><cfoutput></cfoutput><span class="titulosClaro"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Média Geral</font></strong></span></div></td>
      <td bgcolor="lightyellow" class="titulosClaro"><div align="center"><font size="2"><cfoutput>#LSNumberFormat(Rsmedia.Soma,"__._")#</cfoutput></font></div></td>
  </tr>
  </table>
</div>
</body>
</cfif>
</html>