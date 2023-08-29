<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfset dtInicio = dtInic>
<cfset dtFinal = dtFim>
<cfset dtInicio = CreateDate(Right(dtInicio,4), Mid(dtInicio,4,2), Left(dtInicio,2))>
<cfset dtFinal = CreateDate(Right(dtFinal,4), Mid(dtFinal,4,2), Left(dtFinal,2))>

<cfquery name="rsTipo" datasource="#dsn_inspecao#">
SELECT B.TUN_Descricao, QtdFalta = CASE WHEN A.QtdInsp IS NULL THEN B.QtdUnid ELSE (CASE WHEN ((QtdUnid - QtdInsp) < 0) THEN 0 ELSE (QtdUnid)-(QtdInsp) END) END, A.QtdInsp, B.QtdUnid, B.TUN_Codigo
FROM (SELECT Count(INP_NumInspecao) AS QtdInsp,TUN_Descricao, TUN_Codigo
FROM Inspecao INNER JOIN (Tipo_Unidades INNER JOIN Unidades ON Tipo_Unidades.TUN_Codigo = Unidades.Und_TipoUnidade) ON Inspecao.INP_Unidade = Unidades.Und_Codigo
WHERE INP_DtFimInspecao Between #dtInicio# And #dtFinal#
GROUP BY TUN_Descricao, TUN_Codigo)AS A RIGHT JOIN (SELECT TUN_Descricao, Count(Und_Codigo) AS QtdUnid, TUN_Codigo
FROM Tipo_Unidades INNER JOIN Unidades ON Tipo_Unidades.TUN_Codigo = Unidades.Und_TipoUnidade
GROUP BY TUN_Descricao, TUN_Codigo, UND_Status
HAVING TUN_Codigo<>0 AND UND_Status ='A') AS B ON A.TUN_Codigo = B.TUN_Codigo
</cfquery>

<cfquery name="rsFalta" datasource="#dsn_inspecao#">
SELECT  SUM(CASE WHEN A.QtdInsp IS NULL THEN B.QtdUnid ELSE (CASE WHEN ((QtdUnid - QtdInsp) < 0) THEN 0 ELSE (QtdUnid)-(QtdInsp) END) END) AS SomaQtdFalta, Sum(A.QtdInsp) AS SomaQtdInsp, Sum(B.QtdUnid) AS SomaQtdUnid
FROM (SELECT Count(INP_NumInspecao) AS QtdInsp,TUN_Descricao, TUN_Codigo
FROM Inspecao INNER JOIN (Tipo_Unidades INNER JOIN Unidades ON Tipo_Unidades.TUN_Codigo = Unidades.Und_TipoUnidade) ON Inspecao.INP_Unidade = Unidades.Und_Codigo
WHERE INP_DtFimInspecao  Between #dtInicio# And #dtFinal#
GROUP BY TUN_Descricao, TUN_Codigo) AS A RIGHT JOIN (SELECT TUN_Descricao, Count(Und_Codigo) AS QtdUnid, TUN_Codigo
FROM Tipo_Unidades INNER JOIN Unidades ON Tipo_Unidades.TUN_Codigo = Unidades.Und_TipoUnidade
GROUP BY TUN_Descricao, TUN_Codigo, UND_Status
HAVING TUN_Codigo<>0 AND UND_Status ='A') AS B ON A.TUN_Codigo = B.TUN_Codigo
</cfquery>



<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<link href="css.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
.style1 {font-size: 12px}
-->
</style>
</head>
<body>
<cfinclude template="cabecalho.cfm">
<table width="100%" height="80%">
 <tr>
    <td valign="top">
      <table width="90%" class="exibir" align="center">       		
          <tr class="titulos1">
            <td height="16" colspan="6">&nbsp;</td>
          </tr>
          <tr class="titulos1">
            <td height="16" colspan="6">&nbsp;</td>
          </tr>
		  <tr class="titulos">
            <td colspan="11"><div align="center"><span class="titulo1"><strong>  Auditorias por tipo de unidade </strong></span></div></td>
          </tr>
          <tr class="titulos1">
            <td height="16" colspan="6">&nbsp;</td>
          </tr>
          <tr class="titulos1">
            <td height="16" colspan="6"><div align="center"><span class="style1"><cfoutput>
                    <strong>Per&iacute;odo: #DateFormat(dtInicio, "dd/mm/yyyy")#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; a &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#DateFormat(dtFinal,"dd/mm/yyyy")#</strong></cfoutput></span></div></td>
          </tr>
          <tr class="titulos">
            <td height="16" colspan="6">&nbsp;</td>
          </tr>
          <tr class="titulos">
            <td height="16" colspan="6" bgcolor="eeeeee">&nbsp;</td>
          </tr>          
          <tr class="titulos">
            <td width="12%" rowspan="2" bgcolor="eeeeee"><div align="center"></div>              
              <div align="center"><strong>Tipo&nbsp;</strong></div></td>												
            <td height="24%" colspan="2" bgcolor="eeeeee"><div align="center"><strong>Auditorias</strong></div></td>            
            <td width="12%" rowspan="2" bgcolor="eeeeee"><div align="center"><strong>Total de Unidades </strong></div></td>
            <td width="12%" rowspan="2" bgcolor="eeeeee"><div align="center"></div></td>            
          </tr>
          <tr class="titulosclaro">
            <td width="12%" bgcolor="eeeeee" class="exibir"><div align="center">Realizadas</div></td>
            <td width="12%" bgcolor="eeeeee" class="exibir"><div align="center">N&atilde;o Realizadas </div></td>      	  
		  		    
          <cfoutput query="rsTipo">		   
		    <tr bgcolor="f7f7f7" class="exibir">
		        <td bgcolor="f7f7f7"><div align="center">#TUN_Descricao#</div></td>			
		        <td><div align="center">#QtdInsp#</div></td>		
			    <td><div align="center">#QtdFalta#</div></td>	        						    
		        <td><div align="center">#QtdUnid#</div></td>			
		        <td><div align="center" class="link1"><a href="itens_controle_respostas_tipo_unidade_detalhe.cfm?Tipo=#TUN_Codigo#&dtInic=#dtInicio#&dtFim=#dtFinal#" class="link1"><span class="link1">Detalhes</span></a></div></td>
	      </cfoutput>
		   <cfoutput query="rsFalta">
		    <tr bgcolor="f7f7f7" class="exibir">             			                   
              <td><div align="center"><strong>Total</strong></div></td>			
              <td><div align="center"><strong>#SomaQtdInsp#</strong></div></td>					 		 
              <td><div align="center"><strong>#SomaQtdFalta#</strong></div></td> 
              <td><div align="center"><strong>#SomaQtdUnid#</strong></div></td>
              <td><div align="center"></div></td>
           </cfoutput>       
		   <tr class="exibir">
		     <td height="80%" colspan="6" align="center" bgcolor="eeeeee">&nbsp;</td>
        </tr>
	      <tr class="exibir">
		    <td height="80%" colspan="6" align="center">&nbsp;</td>
	    </tr>
		 <tr class="exibir">
          <td height="80%" colspan="6" align="center"><input type="button" class="botao"  onClick="history.back()" value="Voltar"></td>
        </tr>
      </table>
    <!--- Fim Área de conteúdo ---></td>
  </tr>
</table>
</body>
</html>








