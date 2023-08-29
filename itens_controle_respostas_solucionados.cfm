<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfset dtInicio = dtInic>
<cfset dtFinal = dtFim>
<cfset dtInicio = CreateDate(Right(dtInicio,4), Mid(dtInicio,4,2), Left(dtInicio,2))>
<cfset dtFinal = CreateDate(Right(dtFinal,4), Mid(dtFinal,4,2), Left(dtFinal,2))>


<cfquery name="rsItem" datasource="#dsn_inspecao#">
SELECT INP_DtInicInspecao, Pos_Unidade, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, pos_dtultatu, Itn_Descricao, Grp_Descricao, Pos_Situacao_Resp
FROM (Unidades INNER JOIN 
(((ParecerUnidade 
INNER JOIN Inspecao ON (Pos_Inspecao = INP_NumInspecao) AND (Pos_Unidade = INP_Unidade)) 
INNER JOIN Itens_Verificacao ON (Pos_NumItem = Itn_NumItem) AND (Pos_NumGrupo = Itn_NumGrupo) and (INP_Modalidade = Itn_Modalidade)) 
INNER JOIN Grupos_Verificacao ON Itn_NumGrupo = Grp_Codigo AND Grp_Ano = Itn_ano) ON Und_Codigo = INP_Unidade AND Und_TipoUnidade = Itn_TipoUnidade)  
WHERE ((INP_DtFimInspecao Between #dtInicio# And #dtFinal#) AND (Pos_Situacao_Resp='3'))
GROUP BY INP_DtInicInspecao, Pos_Unidade, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, pos_dtultatu, Itn_Descricao, Grp_Descricao, Pos_Situacao_Resp, Und_Descricao, Pos_Inspecao, INP_DtInicInspecao
ORDER BY Pos_Inspecao
</cfquery>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
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
<table width="98%" height="25%">
 <tr>
    <td valign="top">
      <table width="98%" class="exibir">	     	          
          <tr class="titulosclaro">
            <td width="10%" bgcolor="eeeeee" class="exibir"><div align="center"><cfoutput>Qt. Itens: #rsItem.recordCount#</cfoutput>&nbsp;</div></td>
            <td width="8%" bgcolor="eeeeee" class="exibir"><div align="center">In&iacute;cio Auditoria</div></td>			
            <td width="15%" bgcolor="eeeeee" class="exibir"><div align="center">Nome da Unidade</div></td>
            <td width="8%" bgcolor="eeeeee" class="exibir"><div align="center">Auditoria </div></td>
            <td width="28%" bgcolor="eeeeee" class="exibir"><div align="center"> Objetivo </div></td>
            <td width="35%" bgcolor="eeeeee" class="exibir"><div align="center">Item </div></td> 
			
		 <cfoutput query="rsItem">          
         			    
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
              <cfif rsItem.Pos_Situacao_Resp eq 3>
                <td height="26" bgcolor="333333"><div align="center"><a href="itens_controle_respostas_solucionado1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&dtInic=#dtInic#&dtFim=#dtFim#" class="exibir"><strong>Solucionado</strong></a></div></td>
              </cfif>
			  <td width="8%"><div align="center">#DateFormat(rsItem.INP_DtInicInspecao,'DD-MM-YYYY')#</div></td>			  
              <td width="15%"><div align="left">#rsItem.Und_Descricao#</div></td>
              <td width="8%"><div align="center">#rsItem.Pos_Inspecao#</div></td>
              <td width="28%"><div align="left"><strong>#rsItem.Pos_NumGrupo#</strong> - #rsItem.Grp_Descricao#</div></td>
              <td width="34%"><div align="left"><strong>#rsItem.Pos_NumItem#</strong> - &nbsp;#rsItem.Itn_Descricao#</div></td>	  
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








