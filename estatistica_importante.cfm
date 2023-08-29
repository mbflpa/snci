<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfset datainicial = form.data_inicial>
<cfset datafinal = form.data_final>
<cfset datai = CreateDate(right(datainicial,4),mid(datainicial,4,2),left(datainicial,2))>
<cfset dataf = CreateDate(right(datafinal,4),mid(datafinal,4,2),left(datafinal,2))>

<cfquery name="cons1" datasource="#dsn_inspecao#">
SELECT count(Pes_NumInspecao) AS qtd FROM Pesquisa INNER JOIN Inspecao ON Pes_NumInspecao = INP_NumInspecao WHERE Pes_MaisImportante like '%Comu%' and INP_DtFimInspecao Between #datai# and #dataf#
</cfquery>

<cfquery name="cons2" datasource="#dsn_inspecao#">
SELECT count(Pes_NumInspecao) AS qtd FROM Pesquisa INNER JOIN Inspecao ON Pes_NumInspecao = INP_NumInspecao WHERE Pes_MaisImportante like '%Postu%' and INP_DtFimInspecao Between #datai# and #dataf#
</cfquery>

<cfquery name="cons3" datasource="#dsn_inspecao#">
SELECT count(Pes_NumInspecao) AS qtd FROM Pesquisa INNER JOIN Inspecao ON Pes_NumInspecao = INP_NumInspecao WHERE Pes_MaisImportante like '%Condu%' and INP_DtFimInspecao Between #datai# and #dataf#
</cfquery>

<cfquery name="cons4" datasource="#dsn_inspecao#">
SELECT count(Pes_NumInspecao) AS qtd FROM Pesquisa INNER JOIN Inspecao ON Pes_NumInspecao = INP_NumInspecao WHERE Pes_MaisImportante like '%Recom%' and INP_DtFimInspecao Between #datai# and #dataf#
</cfquery>

<cfquery name="cons5" datasource="#dsn_inspecao#">
SELECT count(Pes_NumInspecao) AS qtd FROM Pesquisa INNER JOIN Inspecao ON Pes_NumInspecao = INP_NumInspecao WHERE Pes_MaisImportante like '%Reun%' and INP_DtFimInspecao Between #datai# and #dataf#
</cfquery>

<cfquery name="cons6" datasource="#dsn_inspecao#">
SELECT count(Pes_NumInspecao) AS qtd FROM Pesquisa INNER JOIN Inspecao ON Pes_NumInspecao = INP_NumInspecao WHERE Pes_MaisImportante like '%Rela%' and INP_DtFimInspecao Between #datai# and #dataf#
</cfquery>

<cfquery name="cons7" datasource="#dsn_inspecao#">
SELECT count(Pes_NumInspecao) AS qtd FROM Pesquisa INNER JOIN Inspecao ON Pes_NumInspecao = INP_NumInspecao WHERE Pes_MaisImportante like '%Impo%' and INP_DtFimInspecao Between #datai# and #dataf#
</cfquery>

<cfquery name="consGeral" datasource="#dsn_inspecao#">
SELECT count(Pes_NumInspecao) AS qtd FROM Pesquisa INNER JOIN Inspecao ON Pes_NumInspecao = INP_NumInspecao WHERE INP_DtFimInspecao Between #datai# and #dataf#
</cfquery>

<cfquery name="RsConsulta" datasource="#dsn_inspecao#">
SELECT count(Pes_NumInspecao) as conta
FROM Pesquisa INNER JOIN Inspecao ON Pes_NumInspecao = INP_NumInspecao
WHERE INP_DtFimInspecao Between #datai# and #dataf#
</cfquery>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="css.css" rel="stylesheet" type="text/css">


</head>

<body>
<p align="center"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><br>
</font> </strong></p>
<p align="center" class="titulo1"><strong> <font size="2" face="Verdana, Arial, Helvetica, sans-serif">Grau
de import&Acirc;ncia dos atributos</font> </strong></p>
<p align="center"><strong>
<cfif ConsGeral.recordcount is 0>
  <span class="titulosClaro"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>N&atilde;o
foi encontrado nenhum resultado para o intervalo de data entre</strong></font> <strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif">
        <cfoutput>#datainicial#</cfoutput>
        </font></strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>e</strong></font> <strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif">
        <cfoutput>#datafinal#</cfoutput>
        </font></strong>
  </strong></span><span class="titulos">
  </p>

  <cfelse>
          </span>
  <p align="center" class="titulosClaro"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Foram encontradas<cfoutput> <font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>#RsConsulta.conta#</strong></font> </cfoutput> pesquisas de satisfa&ccedil;&atilde;o no intervalo  entre <cfoutput>#datainicial#</cfoutput> e <cfoutput>#datafinal#</cfoutput>
  </strong> </font> </p>

<table width="82%" border="1" align="center" bordercolor="#FFFFFF">
  <tr>
    <td colspan="3" bgcolor="#FFFFE0"><div align="center" class="titulos"><strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Grau
            de import&acirc;ncia</font></strong></div>    </td>
  </tr>
  <tr>
    <td width="79%" bgcolor="lightyellow"><div align="center" class="titulos"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Atributos</strong></font></div>    </td>
    <td width="20%" bgcolor="lightyellow"><div align="center" class="titulos"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>Votos</strong></font></div>    </td>
    
  </tr>
  <tr>
    <td bgcolor="lightyellow" class="titulos"><strong><font size="1">1.<font face="Verdana, Arial, Helvetica, sans-serif"> Comunica&ccedil;&atilde;o
            Pessoal com o Inspecionado - Compreens&atilde;o Rec&iacute;proca</font></font></strong></td>
    <td bgcolor="lightyellow"><div align="center"><cfoutput><span class="titulos">#cons1.qtd#</span></cfoutput></div></td>
    
  </tr>
  <tr>
    <td bgcolor="lightyellow" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">2.
            Postura Durante os Trabalhos - &Eacute;tica, Educa&ccedil;&atilde;o
          e Cortesia</font></strong></td>
    <td bgcolor="lightyellow"><div align="center"><cfoutput><span class="titulos">#cons2.qtd#</span></cfoutput></div></td>
    
  </tr>
  <tr>
    <td bgcolor="lightyellow" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">3.
            Condu&ccedil;&atilde;o da Inspe&ccedil;&atilde;o - Simultaneidade com
          o M&iacute;nimo de Interrup&ccedil;&atilde;o das Atividades</font></strong></td>
    <td bgcolor="lightyellow"><div align="center"><cfoutput><span class="titulos">#cons3.qtd#</span></cfoutput></div></td>
   
  </tr>
  <tr>
    <td bgcolor="lightyellow" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">4.
          Recomenda&ccedil;&otilde;es - Valor e Pertin&ecirc;ncia </font></strong></td>
    <td bgcolor="lightyellow"><div align="center"><cfoutput><span class="titulos">#cons4.qtd#</span></cfoutput></div></td>
    
  </tr>
  <tr>
    <td bgcolor="lightyellow" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">5.
          Reuni&atilde;o de Encerramento - Simplicidade, Objetividade e Clareza </font></strong></td>
    <td bgcolor="lightyellow"><div align="center"><cfoutput><span class="titulos">#cons5.qtd#</span></cfoutput></div></td>
    
  </tr>
  <tr bgcolor="lightyellow">
    <td bgcolor="lightyellow" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">6.
          Relat&oacute;rio - Clareza, Consist&ecirc;ncia e Objetividade da Reda&ccedil;&atilde;o </font></strong></td>
    <td bgcolor="lightyellow"><div align="center"><cfoutput><span class="titulos">#cons6.qtd#</span></cfoutput></div></td>
    
  </tr>
  <tr bgcolor="lightyellow">
    <td bgcolor="lightyellow" class="titulos"><strong><font size="1" face="Verdana, Arial, Helvetica, sans-serif">7.
            Import&acirc;ncia da Inspe&ccedil;&atilde;o para o Aprimoramento da
          Unidade </font></strong></td>
    <td bgcolor="lightyellow"><div align="center"><cfoutput><span class="titulos">#cons7.qtd#</span></cfoutput></div></td>    
  </tr>
</table>
</cfif>

<p align="center">&nbsp;</p>

<div align="center"></div>
</body>
</html>