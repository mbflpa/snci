<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfset dtInicio = dtInic>
<cfset dtFinal = dtFim>
<cfset dtInicio = CreateDate(Right(dtInicio,4), Mid(dtInicio,4,2), Left(dtInicio,2))>
<cfset dtFinal = CreateDate(Right(dtFinal,4), Mid(dtFinal,4,2), Left(dtFinal,2))>

<cfquery name="rsTempo" datasource="#dsn_inspecao#">
SELECT     Atividades.Atv_Descricao AS Ars_Sigla, COUNT(ParecerUnidade.Pos_NumItem) AS Numero, AVG(DATEDIFF(dd, 
                      Inspecao.INP_DtEncerramento, ParecerUnidade.Pos_DtPosic)) AS Tempo
FROM         Atividades, Itens_Verificacao, ParecerUnidade, Inspecao
WHERE     Atividades.Atv_Codigo = Itens_Verificacao.Itn_CodAtividade
AND Itens_Verificacao.Itn_NumGrupo = ParecerUnidade.Pos_NumGrupo AND 
                      Itens_Verificacao.Itn_NumItem = ParecerUnidade.Pos_NumItem
AND ParecerUnidade.Pos_Inspecao = Inspecao.INP_NumInspecao
AND ParecerUnidade.Pos_Unidade = Inspecao.INP_Unidade
AND ParecerUnidade.Pos_Situacao_Resp = 3 
AND Inspecao.INP_DtFimInspecao Between #dtInicio# And #dtFinal#
AND right([ParecerUnidade.Pos_Inspecao], 4) = Itens_Verificacao.Itn_Ano
GROUP BY Atividades.Atv_Descricao
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
            <td height="16" colspan="5">&nbsp;</td>
          </tr>
          <tr class="titulos1">
            <td height="16" colspan="5">&nbsp;</td>
          </tr>
		  <tr class="titulos">
            <td colspan="10"><div align="center"><span class="titulo1"><strong>  <strong><strong> tempo de solu&Ccedil;&Atilde;o por &Aacute;REAS </strong></strong></strong></span></div></td>
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
              <div align="center"><strong>&Aacute;reas</strong></div></td>												
            <td width="12%" bgcolor="eeeeee"><div align="center">Tempo M&eacute;dio de Solu&ccedil;&atilde;o (dias) </div></td>            
            <td colspan="2" bgcolor="eeeeee"><div align="center">Quantitativo de Solu&ccedil;&otilde;es </div>              
              <div align="center"></div></td>
          </tr>
		  <cfset total = 0>
		  <cfset media = 0>
          <cfoutput query="rsTempo">
		    <tr bgcolor="f7f7f7" class="exibir">
		      <td bgcolor="f7f7f7"><div align="center">#Ars_Sigla#</div></td>
		      <td><div align="center">#tempo#</div></td><cfset media = media + tempo>
		      <td><div align="center">#Numero#</div></td><cfset total = total + Numero>
	        </tr>
		  </cfoutput>	
		  <cfset media = Round(media/rsTempo.recordCount)>
	   
		    <tr bgcolor="eeeeee" class="exibir">
		      <td>&nbsp;</td>
		      <td>&nbsp;</td>
		      <td>&nbsp;</td>
	        </tr>
		    <tr bgcolor="f7f7f7" class="exibir">
		        <td bgcolor="f7f7f7"><div align="center"><span class="titulosClaro"><strong>Total</strong></span></div></td>
		        <td><div align="center" class="titulosClaro"><cfoutput>#media#</cfoutput></div></td>
		        <td width="12%"><div align="center" class="titulosClaro"><cfoutput>#total#</cfoutput></div></td>	
			</tr>		        
	      
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








