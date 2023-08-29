<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfset dtInicio = form.dtinic>
<cfset dtFinal = form.dtfinal>
<cfset dtInicio = createdate(right(dtInicio,4), mid(dtInicio,4,2), left(dtInicio,2))>
<cfset dtFinal = createdate(right(dtFinal,4), mid(dtFinal,4,2), left(dtFinal,2))> 


<cfquery name="qpesquisa" datasource="#dsn_inspecao#">
SELECT Pes_Lotacao, Pes_NumInspecao, Pes_DtPesquisa, INP_DtFimInspecao
FROM Pesquisa INNER JOIN Inspecao ON Pes_NumInspecao = INP_NumInspecao
WHERE INP_DtFimInspecao Between #dtinicio# And #dtfinal# and Pes_Tipo = '#txttipo#'
GROUP BY Pes_Lotacao, Pes_NumInspecao, Pes_DtPesquisa, INP_DtFimInspecao
ORDER BY Pes_Lotacao
</cfquery>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="css.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {font-size: 12px}
.style3 {font-weight: bold}
.style4 {font-size: 12px; font-weight: bold; }
-->
</style>
</head>
<body>
<cfinclude template="cabecalho.cfm">
<p align="center">
  <!--- Área de conteúdo   --->
</p>
<form action="estatistica_pesquisa.cfm" method="post" target="_blank">
      <table width="90%" align="center">
      <tr>
        <td colspan="4">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="4"><p align="center" class="titulo1"><strong>Relat&Oacute;rio estat&Iacute;stico das pesquisas</strong></p>
        </td>
      </tr>
	 	    <tr>
	 	      <td colspan="4" class="exibir">&nbsp;</td>
        </tr>
	 	    <tr>
	 	      <td colspan="4" class="exibir">&nbsp;</td>
        </tr>
	 	    <tr>
	 	      <td colspan="4" bgcolor="eeeeee" class="exibir">&nbsp;</td>
		    </tr>		   
            <tr>
              <td colspan="4" bgcolor="eeeeee"><span class="exibir"><strong>
                <label title="label"></label>
              </strong></span><span class="exibir style3"><cfoutput>
                </cfoutput></span><span class="exibir"><cfoutput><div align="center"><strong><span class="style1">Per&iacute;odo:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#DateFormat(dtInicio, "dd/mm/yyyy")#&nbsp;&nbsp;&nbsp;a&nbsp;&nbsp;&nbsp;#DateFormat(dtFinal,"dd/mm/yyyy")# </span></strong></div>
              </cfoutput>
              </span></td>
            </tr>
            <tr>
              <td  class="exibir" colspan="4" bgcolor="eeeeee">&nbsp;</td>
            </tr>
          

      <tr class="exibir">
        <td width="30%" bgcolor="eeeeee"><div align="left" class="style1"><strong>Nome</strong></div></td>
        <td width="20%" bgcolor="eeeeee"> <div align="center" class="style1"><strong>N&ordm; da Pesquisa </strong></div></td>
        <td width="20%" bgcolor="eeeeee"><div align="center" class="style4">Data de Envio </div></td>
		<td width="20%" bgcolor="eeeeee"><div align="center" class="style4">Data Término da Inspeção </div></td>
      </tr>	  
      <cfoutput query="qpesquisa">
	  <tr class="exibir">
	  <td width="30%" bgcolor="f7f7f7"><div align="left" class="style1">#qpesquisa.Pes_Lotacao#</div></td>
      <td width="20%" bgcolor="f7f7f7"><div align="center" class="style1">#qpesquisa.Pes_NumInspecao#</div></td>
      <td width="20%" bgcolor="f7f7f7"><div align="center" class="style1">#DateFormat(qpesquisa.Pes_DtPesquisa, "dd/mm/yyyy")#</div></td>
	  <td width="20%" bgcolor="f7f7f7"><div align="center" class="style1">#DateFormat(qpesquisa.INP_DtFimInspecao, "dd/mm/yyyy")#</div></td>
	  </tr>
	  </cfoutput>	  
      </table>
</form>
</body>
</html>
