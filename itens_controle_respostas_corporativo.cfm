
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfset dtInicio = dtInic>
<cfset dtFinal = dtFim>
<cfset dtInicio = CreateDate(Right(dtInicio,4), Mid(dtInicio,4,2), Left(dtInicio,2))>
<cfset dtFinal = CreateDate(Right(dtFinal,4), Mid(dtFinal,4,2), Left(dtFinal,2))>


<cfquery name="rsItem" datasource="#dsn_inspecao#">
SELECT Ars_Sigla, INP_DtInicInspecao, Pos_Unidade, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, pos_dtultatu, Itn_Descricao, Grp_Descricao, Pos_Situacao_Resp, Pos_Area, Ars_Codigo, Pos_DtPrev_Solucao, Count(Pos_Inspecao) AS Total
FROM Areas INNER JOIN ((((Inspecao INNER JOIN ParecerUnidade ON (INP_NumInspecao = Pos_Inspecao) AND
 (INP_Unidade = Pos_Unidade)) INNER JOIN Unidades ON Pos_Unidade = Und_Codigo) 
 INNER JOIN Itens_Verificacao ON (Pos_NumItem = Itn_NumItem and right(Pos_Inspecao,4)=Itn_Ano) 
AND (Pos_NumGrupo = Itn_NumGrupo) AND (INP_Modalidade = Itn_Modalidade) AND (Und_TipoUnidade = Itn_TipoUnidade)) 
INNER JOIN Grupos_Verificacao ON (Grp_Ano = Itn_Ano) AND (Itn_NumGrupo = Grp_Codigo)) ON Ars_Codigo = Pos_Area
WHERE ((INP_DtFimInspecao Between #dtInicio# And #dtFinal#) AND (Pos_Situacao_Resp='8' Or Pos_Situacao_Resp='9'))
GROUP BY Ars_Sigla, INP_DtInicInspecao, Pos_Unidade, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, pos_dtultatu, Itn_Descricao, Grp_Descricao, Pos_Situacao_Resp, Und_Descricao, Pos_Inspecao, INP_DtInicInspecao, Pos_Area, Ars_Codigo, Pos_DtPrev_Solucao
ORDER BY Pos_Area
</cfquery>

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
.style1 {color: #FF0000}
-->
</style>
</head>
<body>
<cfinclude template="cabecalho.cfm">
<table width="98%" height="50%">
 <tr>
    <td valign="top">
      <table width="98%" class="exibir">
        <tr class="exibir">
          <td height="16" colspan="2"><div align="center"><span class="titulosClaro">&nbsp;Qt. Itens:<cfoutput>&nbsp;&nbsp;#rsItem.recordCount#</span></cfoutput></div></td>	   
        </tr>
        <cfoutput query="rsItem" group="Ars_Codigo">		
          <tr class="titulos1">
            <td height="16" colspan="7"><div align="center"><span class="titulosClaro">#rsItem.Ars_Sigla#</span></div></td>												
          </tr>
          <tr class="titulosclaro">
            <td width="10%" bgcolor="eeeeee" class="exibir"><div align="center">Status</div></td>
            <td width="8%" bgcolor="eeeeee" class="exibir"><div align="center">In&iacute;cio Auditoria</div></td>
			<td width="8%" bgcolor="eeeeee" class="exibir"><div align="center">Previsão da Solução</div></td>
            <td width="15%" bgcolor="eeeeee" class="exibir"><div align="center">Nome da Unidade</div></td>
            <td width="8%" bgcolor="eeeeee" class="exibir"><div align="center">Auditoria </div></td>
            <td width="28%" bgcolor="eeeeee" class="exibir"><div align="center"> Objetivo </div></td>
            <td width="35%" bgcolor="eeeeee" class="exibir"><div align="center">Item </div></td>
           
          <cfoutput>			    
            <cfset grav = 0>
            <cfquery name="qGrav" datasource="#dsn_inspecao#">
              SELECT Ana_Col01, Ana_Col02, Ana_Col03, Ana_Col04, Ana_Col05, Ana_Col06, Ana_Col07, Ana_Col08, Ana_Col09 FROM Analise WHERE Ana_NumInspecao='#rsItem.Pos_Inspecao#' AND Ana_Unidade='#rsItem.Pos_Unidade#' AND Ana_NumGrupo=#rsItem.Pos_NumGrupo# AND Ana_NumItem=#rsItem.Pos_NumItem#
            </cfquery>
            <cfif qGrav.Ana_Col01 is 1>
              <cfset grav = int(10)>
            </cfif>
            <cfif qGrav.Ana_Col02 is 1>
              <cfset grav = val(grav) + int(5)>
            </cfif>
            <cfif qGrav.Ana_Col03 is 1>
              <cfset grav = val(grav) + int(7)>
            </cfif>
            <cfif qGrav.Ana_Col04 is 1>
              <cfset grav = val(grav) + int(10)>
            </cfif>
            <cfif qGrav.Ana_Col05 is 1>
              <cfset grav = val(grav) + int(2)>
            </cfif>
            <cfif qGrav.Ana_Col06 is 1>
              <cfset grav = val(grav) + int(5)>
            </cfif>
            <cfif qGrav.Ana_Col07 is 1>
              <cfset grav = val(grav) + int(7)>
            </cfif>
            <cfif qGrav.Ana_Col08 is 1>
              <cfset grav = val(grav) + int(4)>
            </cfif>
            <cfif qGrav.Ana_Col09 is 1>
              <cfset grav = val(grav) + int(2)>
            </cfif>
            <cfif val(grav) gte 10>
              <cfset sGrav ='<span class="red_titulo">Alto</span>'>
            </cfif>
            <cfif val(grav) is 0>
              <cfset sGrav ="----">
            </cfif>
            <cfif val(grav) gte 1 and val(grav) lte 4>
              <cfset sGrav ="Baixo">
            </cfif>
            <cfif val(grav) gte 5 and val(grav) lte 9>
              <cfset sGrav ="Médio">
            </cfif>			
            <tr bgcolor="f7f7f7" class="exibir">
              <cfif rsItem.Pos_Situacao_Resp eq 8>
                <td height="26" bgcolor="##FFCC99"><div align="center"><a href="itens_controle_respostas_corporativo1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&dtInic=#dtInic#&dtFim=#dtFim#" class="exibir"><strong>Corporativo DR</strong></a></div></td>
              <cfelseif rsItem.Pos_Situacao_Resp eq 9>
                <td height="26" bgcolor="##00FF99"><div align="center"><a href="itens_controle_respostas_corporativo1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&dtInic=#dtInic#&dtFim=#dtFim#" class="exibir"><strong>Corporativo AC</strong></a></div></td>
              </cfif>
              <td width="8%"><div align="center">#DateFormat(rsItem.INP_DtInicInspecao,'DD-MM-YYYY')#</div></td>
			  <td width="8%"><div align="center">#DateFormat(rsItem.Pos_DtPrev_Solucao,'DD-MM-YYYY')#</div></td>
              <td width="15%"><div align="left">#rsItem.Und_Descricao#</div></td>
              <td width="8%"><div align="center">#rsItem.Pos_Inspecao#</div></td>
              <td width="28%"><div align="left"><strong>#rsItem.Pos_NumGrupo#</strong> - #rsItem.Grp_Descricao#</div></td>
              <td width="34%"><div align="left"><strong>#rsItem.Pos_NumItem#</strong> - &nbsp;#rsItem.Itn_Descricao#</div></td>              
        </cfoutput> 
	  </cfoutput>		
        <tr>          
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








