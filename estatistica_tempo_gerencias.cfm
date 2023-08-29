<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfset dtInicio = dtInic>
<cfset dtFinal = dtFim>
<cfset dtInicio = CreateDate(Right(dtInicio,4), Mid(dtInicio,4,2), Left(dtInicio,2))>
<cfset dtFinal = CreateDate(Right(dtFinal,4), Mid(dtFinal,4,2), Left(dtFinal,2))>

<cfquery name="rsTempo" datasource="#dsn_inspecao#">
SELECT A.Ars_Sigla, Count(A.And_NumInspecao) AS Numero, AVG(DATEDIFF(dd, Inicial, Final)) AS tempo
FROM (SELECT DISTINCT Andamento.And_NumInspecao, Andamento.And_NumItem, Min(Andamento.And_DtPosic) AS Inicial, Andamento.And_NumGrupo, Andamento.And_Orgao_Solucao, Areas.Ars_Sigla
FROM ((Andamento INNER JOIN Inspecao ON (Andamento.And_Unidade = Inspecao.INP_Unidade) AND (Andamento.And_NumInspecao = Inspecao.INP_NumInspecao)) INNER JOIN ParecerUnidade ON (Andamento.And_NumInspecao = ParecerUnidade.Pos_Inspecao) AND (Andamento.And_Unidade = ParecerUnidade.Pos_Unidade) AND (Andamento.And_NumGrupo = ParecerUnidade.Pos_NumGrupo) AND (Andamento.And_NumItem = ParecerUnidade.Pos_NumItem)) INNER JOIN Areas ON Andamento.And_Orgao_Solucao = Areas.Ars_Codigo
WHERE (((Andamento.And_Situacao_Resp)='5') AND ((ParecerUnidade.Pos_Situacao_Resp)='3') AND ((Inspecao.INP_DtFimInspecao) Between #dtInicio# And #dtFinal#))
GROUP BY Andamento.And_NumInspecao, Andamento.And_NumItem, Andamento.And_NumGrupo, Andamento.And_Orgao_Solucao, Areas.Ars_Sigla) AS A INNER JOIN (SELECT Andamento.And_NumInspecao, Andamento.And_NumItem, Andamento.And_Orgao_Solucao, Max(Andamento.And_DtPosic) AS Final, Andamento.And_NumGrupo, Areas.Ars_Sigla
FROM ((Andamento INNER JOIN Inspecao ON (Andamento.And_NumInspecao = Inspecao.INP_NumInspecao) AND (Andamento.And_Unidade = Inspecao.INP_Unidade)) INNER JOIN ParecerUnidade ON (Andamento.And_NumItem = ParecerUnidade.Pos_NumItem) AND (Andamento.And_NumGrupo = ParecerUnidade.Pos_NumGrupo) AND (Andamento.And_Unidade = ParecerUnidade.Pos_Unidade) AND (Andamento.And_NumInspecao = ParecerUnidade.Pos_Inspecao)) INNER JOIN Areas ON Andamento.And_Orgao_Solucao = Areas.Ars_Codigo
WHERE (((Andamento.And_Situacao_Resp)='6') AND ((ParecerUnidade.Pos_Situacao_Resp)='3') AND ((Inspecao.INP_DtFimInspecao) Between #dtInicio# And #dtFinal#))
GROUP BY Andamento.And_NumInspecao, Andamento.And_NumItem, Andamento.And_Orgao_Solucao, Andamento.And_NumGrupo, Areas.Ars_Sigla) AS B ON (A.And_Orgao_Solucao=B.And_Orgao_Solucao) AND (A.Ars_Sigla=B.Ars_Sigla) AND (A.And_NumGrupo=B.And_NumGrupo) AND (A.And_NumItem=B.And_NumItem) AND (A.And_NumInspecao=B.And_NumInspecao)
GROUP BY A.Ars_Sigla
</cfquery>

<cfquery name="rsTempoTotal" datasource="#dsn_inspecao#">
SELECT Count(A.And_NumInspecao) AS Numero, Avg(DateDiff(dd,Inicial,Final)) AS tempo
FROM (SELECT DISTINCT Andamento.And_NumInspecao, Andamento.And_NumItem, Min(Andamento.And_DtPosic) AS Inicial, Andamento.And_NumGrupo, Andamento.And_Orgao_Solucao, Areas.Ars_Sigla
FROM ((Andamento INNER JOIN Inspecao ON (Andamento.And_Unidade = Inspecao.INP_Unidade) AND (Andamento.And_NumInspecao = Inspecao.INP_NumInspecao)) INNER JOIN ParecerUnidade ON (Andamento.And_NumInspecao = ParecerUnidade.Pos_Inspecao) AND (Andamento.And_Unidade = ParecerUnidade.Pos_Unidade) AND (Andamento.And_NumGrupo = ParecerUnidade.Pos_NumGrupo) AND (Andamento.And_NumItem = ParecerUnidade.Pos_NumItem)) INNER JOIN Areas ON Andamento.And_Orgao_Solucao = Areas.Ars_Codigo
WHERE (((Andamento.And_Situacao_Resp)='5') AND ((ParecerUnidade.Pos_Situacao_Resp)='3') AND ((Inspecao.INP_DtFimInspecao) Between #dtInicio# And #dtFinal#))
GROUP BY Andamento.And_NumInspecao, Andamento.And_NumItem, Andamento.And_NumGrupo, Andamento.And_Orgao_Solucao, Areas.Ars_Sigla) AS A INNER JOIN (SELECT Andamento.And_NumInspecao, Andamento.And_NumItem, Andamento.And_Orgao_Solucao, Max(Andamento.And_DtPosic) AS Final, Andamento.And_NumGrupo, Areas.Ars_Sigla
FROM ((Andamento INNER JOIN Inspecao ON (Andamento.And_NumInspecao = Inspecao.INP_NumInspecao) AND (Andamento.And_Unidade = Inspecao.INP_Unidade)) INNER JOIN ParecerUnidade ON (Andamento.And_NumItem = ParecerUnidade.Pos_NumItem) AND (Andamento.And_NumGrupo = ParecerUnidade.Pos_NumGrupo) AND (Andamento.And_Unidade = ParecerUnidade.Pos_Unidade) AND (Andamento.And_NumInspecao = ParecerUnidade.Pos_Inspecao)) INNER JOIN Areas ON Andamento.And_Orgao_Solucao = Areas.Ars_Codigo
WHERE (((Andamento.And_Situacao_Resp)='6') AND ((ParecerUnidade.Pos_Situacao_Resp)='3') AND ((Inspecao.INP_DtFimInspecao) Between #dtInicio# And #dtFinal#))
GROUP BY Andamento.And_NumInspecao, Andamento.And_NumItem, Andamento.And_Orgao_Solucao, Andamento.And_NumGrupo, Areas.Ars_Sigla) AS B ON (A.And_NumInspecao = B.And_NumInspecao) AND (A.And_NumItem = B.And_NumItem) AND (A.And_NumGrupo = B.And_NumGrupo) AND (A.Ars_Sigla = B.Ars_Sigla) AND (A.And_Orgao_Solucao = B.And_Orgao_Solucao);
</cfquery>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
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
            <td height="16" colspan="5">&nbsp;</td>
          </tr>
          <tr class="titulos1">
            <td height="16" colspan="5">&nbsp;</td>
          </tr>
		  <tr class="titulos">
            <td colspan="10"><div align="center"><span class="titulo1"><strong>  <strong><strong> tempo de solu&Ccedil;&Atilde;o por &Aacute;reas </strong></strong></strong></span></div></td>
          </tr>
          <tr class="titulos1">
            <td height="16" colspan="5">&nbsp;</td>
          </tr>
          <tr class="titulos1">
            <td height="16" colspan="5"><div align="center"><span class="style1"><cfoutput>
                    <strong>Per&iacute;odo de Refer&ecirc;ncia: #DateFormat(dtInicio, "dd/mm/yyyy")#&nbsp;&nbsp;&nbsp;&nbsp; a &nbsp;&nbsp;&nbsp;&nbsp;#DateFormat(dtFinal,"dd/mm/yyyy")#</strong></cfoutput></span></div></td>
          </tr>
          <tr class="titulos">
            <td height="16" colspan="5">&nbsp;</td>
          </tr>
          <tr class="titulos">
            <td height="16" colspan="5" bgcolor="eeeeee">&nbsp;</td>
          </tr>          
          <tr class="titulos">
            <td width="12%" bgcolor="eeeeee"><div align="center"></div>              
              <div align="center"><strong>&Aacute;rea</strong></div></td>												
            <td width="12%" bgcolor="eeeeee"><div align="center">Tempo M&eacute;dio de Solu&ccedil;&atilde;o (dias) </div></td>            
            <td colspan="2" bgcolor="eeeeee"><div align="center">Quantitativo de Solu&ccedil;&otilde;es </div>              
              <div align="center"></div></td>
          </tr>
          <cfoutput query="rsTempo">
		    <tr bgcolor="f7f7f7" class="exibir">
		      <td bgcolor="f7f7f7"><div align="center">#Ars_Sigla#</div></td>
		      <td><div align="center">#tempo#</div></td>
		      <td><div align="center">#Numero#</div></td>
	        </tr>
		  </cfoutput>	
		  <cfoutput query="rsTempoTotal">
		    <tr bgcolor="eeeeee" class="exibir">
		      <td>&nbsp;</td>
		      <td>&nbsp;</td>
		      <td>&nbsp;</td>
	        </tr>
		    <tr bgcolor="f7f7f7" class="exibir">
		        <td bgcolor="f7f7f7"><div align="center"><span class="titulosClaro"><strong>Total</strong></span></div></td>
		        <td><div align="center" class="titulosClaro">#tempo#</div></td>
		        <td width="12%"><div align="center" class="titulosClaro">#Numero#</div></td>	
			</tr>		        
	      </cfoutput>	   
		   <tr class="exibir">
		     <td height="80%" colspan="5" align="center" bgcolor="eeeeee">&nbsp;</td>
           </tr>
           <tr class="exibir">
             <td height="80%" colspan="5" align="center"><div align="left"> O per&iacute;odo de refer&ecirc;ncia refere-se ao intervalo de tempo que foram realizadas as auditorias. </div></td>
           </tr>
          <tr class="exibir">
		    <td height="80%" colspan="5" align="center">&nbsp;</td>
	      </tr>
		 <tr class="exibir">
          <td height="80%" colspan="5" align="center"><input type="button" class="botao"  onClick="history.back()" value="Voltar"></td>
         </tr>
      </table>
    <!--- Fim Área de conteúdo ---></td>
  </tr>
</table>
</body>
</html>








