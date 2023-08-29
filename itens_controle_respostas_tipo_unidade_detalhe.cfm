<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfset dtInicio = dtInic>
<cfset dtFinal = dtFim>

<cfquery name="rsTipo1" datasource="#dsn_inspecao#">
SELECT A.INP_NumInspecao, A.INP_DtFimInspecao, B.Und_Descricao, B.Und_TipoUnidade, B.Rep_Nome
FROM (SELECT INP_Unidade, INP_NumInspecao, INP_DtFimInspecao FROM Inspecao WHERE INP_DtFimInspecao Between #dtInicio# And #dtFinal#) AS A RIGHT JOIN (SELECT Unidades.Und_Codigo, Unidades.Und_Descricao, Unidades.Und_TipoUnidade, Reops.Rep_Nome, Reops.Rep_Codigo, Unidades.UND_Status 
FROM Unidades INNER JOIN Reops ON Unidades.Und_CodReop = Reops.Rep_Codigo
) AS B ON A.INP_Unidade = B.Und_Codigo
WHERE B.Rep_Codigo <>'0' AND B.Und_TipoUnidade=#tipo# AND B.UND_Status ='A'
ORDER BY A.INP_NumInspecao desc, B.Rep_Nome, B.Und_Descricao 
</cfquery>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<link href="css.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
.style1 {font-size: 12px}
.style2 {font-size: 12px; font-weight: bold; }
.style4 {color: #053C7E}
-->
</style>
</head>
<body>
<cfinclude template="cabecalho.cfm">
<table width="800" height="450">
 <tr>
    <td valign="top">
      <table width="90%" class="exibir" align="center">       		
          <tr class="titulos1">
            <td height="16" colspan="7">&nbsp;</td>
          </tr>
          <tr class="titulos1">
            <td height="16" colspan="7">&nbsp;</td>
          </tr>
		  <tr class="titulos">
            <td colspan="12"><div align="center"><span class="titulo1"><strong> Auditorias X unidades </strong></span></div></td>
          </tr>
          <tr class="titulos1">
            <td height="16" colspan="7">&nbsp;</td>
          </tr>
          <tr class="titulos1">
            <td height="16" colspan="7"><div align="center"><span class="style1"><cfoutput>
                    <strong>Per&iacute;odo: #DateFormat(dtInicio, "dd/mm/yyyy")#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; a &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#DateFormat(dtFinal,"dd/mm/yyyy")#</strong></cfoutput></span></div></td>
          </tr>
          <tr class="titulos">
            <td height="16" colspan="7">&nbsp;</td>
          </tr>
          <tr class="titulos">
            <td height="16" colspan="7" bgcolor="eeeeee">&nbsp;</td>
          </tr>          
          <tr class="titulos">
            <td width="30%" bgcolor="eeeeee"><div align="center"></div>              
              <div align="center">Nome da Unidade </div></td>
			  <td width="25%" bgcolor="eeeeee"><div align="center"></div>              
              <div align="center">Órgão Subordinador</div></td>												
            <td width="15%" bgcolor="eeeeee"><div align="center">Auditoria</div>              </td>            
            <td width="15%" bgcolor="eeeeee"><div align="center"><strong>Term.  da Auditoria </strong></div></td>            
          </tr>
          <cfoutput query="rsTipo1">		  		       
              <tr bgcolor="f7f7f7" class="exibir">
                <td>#Und_Descricao#</td>
                <td><div align="center">#Rep_Nome#</div></td>
                <td><div align="center">#INP_NumInspecao#</div></td>
                <td><div align="center">#DateFormat(INP_DtFimInspecao,"dd/mm/yyyy")#</div></td>
          </cfoutput>
		  <tr class="titulos">
            <td height="16" colspan="7" bgcolor="eeeeee">&nbsp;</td>
          </tr> 	       
		  <tr class="exibir">
		    <td height="26" colspan="7" align="center">&nbsp;</td>
	      </tr>
		  <tr class="exibir">
          <td height="26" colspan="7" align="center"><input type="button" class="botao"  onClick="history.back()" value="Voltar"></td>
        </tr>
      </table>
    <!--- Fim Área de conteúdo ---></td>
  </tr>
</table>
</body>
</html>








