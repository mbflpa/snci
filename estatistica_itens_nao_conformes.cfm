<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfset dtInicio = form.dtinic>
<cfset dtFinal = form.dtfinal>
<cfset dtInicio = createdate(right(dtInicio,4), mid(dtInicio,4,2), left(dtInicio,2))>
<cfset dtFinal = createdate(right(dtFinal,4), mid(dtFinal,4,2), left(dtFinal,2))> 


<cfquery name="sol_area" datasource="#dsn_inspecao#">
SELECT Count(And_NumInspecao) AS qtd_area
FROM (Andamento INNER JOIN Inspecao ON (Andamento.And_Unidade = Inspecao.INP_Unidade) AND (Andamento.And_NumInspecao = Inspecao.INP_NumInspecao)) INNER JOIN Areas ON Andamento.And_Orgao_Solucao = Areas.Ars_Codigo
WHERE And_Situacao_Resp='3' AND INP_DtFimInspecao Between #dtInicio# And #dtFinal#
</cfquery>

<cfquery name="sol_total" datasource="#dsn_inspecao#">
SELECT Count(Pos_Inspecao) AS qtd_total
FROM ParecerUnidade INNER JOIN Inspecao ON (ParecerUnidade.Pos_Inspecao = Inspecao.INP_NumInspecao) AND (ParecerUnidade.Pos_Unidade = Inspecao.INP_Unidade)
WHERE Pos_Situacao_Resp='3' AND INP_DtFimInspecao Between #dtInicio# And #dtFinal#
</cfquery>

<cfquery name="sol_reop" datasource="#dsn_inspecao#">
SELECT Count(And_NumInspecao) AS qtd_reop
FROM ((Andamento INNER JOIN Inspecao ON (Andamento.And_Unidade=Inspecao.INP_Unidade) AND (Andamento.And_NumInspecao=Inspecao.INP_NumInspecao)) INNER JOIN Reops ON Andamento.And_Orgao_Solucao=Reops.Rep_Codigo) INNER JOIN ParecerUnidade ON (Andamento.And_NumInspecao=ParecerUnidade.Pos_Inspecao) AND (Andamento.And_Unidade=ParecerUnidade.Pos_Unidade) AND (Andamento.And_NumGrupo=ParecerUnidade.Pos_NumGrupo) AND (Andamento.And_NumItem=ParecerUnidade.Pos_NumItem)
WHERE And_Situacao_Resp='3' AND INP_DtFimInspecao Between #dtInicio# And #dtFinal#
</cfquery>

<cfquery name="qinspecao" datasource="#dsn_inspecao#">
SELECT Pos_Situacao_Resp, Count(Pos_Inspecao) AS Inspecao
FROM ParecerUnidade INNER JOIN Inspecao ON Pos_Inspecao = INP_NumInspecao AND Pos_Unidade = INP_Unidade
WHERE INP_DtFimInspecao Between #dtInicio# And #dtFinal#
GROUP BY Pos_Situacao_Resp
ORDER BY Inspecao
</cfquery>

<cfquery name="qtotalinspecao" datasource="#dsn_inspecao#">
SELECT Count(INP_NumInspecao) AS TotalInspecao
FROM Inspecao
WHERE INP_DtFimInspecao Between #dtInicio# And #dtFinal#
</cfquery>

<cfquery name="qtotalitens" datasource="#dsn_inspecao#">
SELECT Count(Pos_Inspecao) AS TotalItens
FROM ParecerUnidade INNER JOIN Inspecao ON (ParecerUnidade.Pos_Unidade = Inspecao.INP_Unidade) AND (ParecerUnidade.Pos_Inspecao = Inspecao.INP_NumInspecao)
WHERE INP_DtFimInspecao Between #dtInicio# And #dtFinal#
ORDER BY Count(Pos_Inspecao)
</cfquery>

<cfquery name="qtotalitenspendentes" datasource="#dsn_inspecao#">
SELECT Count(Pos_Inspecao) AS ItensPendentes
FROM ParecerUnidade INNER JOIN Inspecao ON Pos_Unidade = INP_Unidade AND Pos_Inspecao = INP_NumInspecao
WHERE INP_DtFimInspecao between #dtInicio# And #dtFinal# AND Pos_Situacao_Resp<>'3' And Pos_Situacao_Resp<>'8' And Pos_Situacao_Resp<>'9'
ORDER BY ItensPendentes
</cfquery>

<cfquery name="qitensarea" datasource="#dsn_inspecao#">
SELECT Count(Pos_Inspecao) AS ItensArea, Ars_Sigla
FROM ParecerUnidade INNER JOIN Inspecao ON Pos_Unidade = INP_Unidade AND Pos_Inspecao = INP_NumInspecao INNER JOIN Areas ON Pos_Area = Ars_Codigo
WHERE Pos_Situacao_Resp='5' AND INP_DtFimInspecao Between #dtInicio# And #dtFinal#
GROUP BY Ars_Sigla
ORDER BY Count(Pos_Inspecao) DESC
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
-->
</style>
</head>
<body>

<cfinclude template="cabecalho.cfm">

<table width="80%" border="0" align="center">
  <tr class="titulos">
    <td colspan="17">&nbsp;</td>
  <tr class="titulos">
    <td colspan="17"><div align="center"><span class="titulo1"><strong> estat&Iacute;stica dos pontos de auditoria </strong></span></div></td>
  <tr class="titulos">
    <td colspan="17">&nbsp;</td>
  <tr class="titulos">
    <td colspan="17">&nbsp;</td>
  <tr class="titulos">
    <td colspan="17"><div align="center" class="titulo1"></div></td>
    <br>
    <br>
    <br>
  <tr class="exibir">
    <td colspan="7" bgcolor="eeeeee">&nbsp;</td>
  </tr>
  <tr class="titulos"> <cfoutput>
      <td  colspan="7" bgcolor="eeeeee"><div align="center" class="style1"><span class="style1">Per&iacute;odo</span>:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#DateFormat(dtInicio, "dd/mm/yyyy")#&nbsp;&nbsp;&nbsp;a&nbsp;&nbsp;&nbsp;<span class="style1">#DateFormat(dtFinal,"dd/mm/yyyy")#</span> </div></td>
  </cfoutput> </tr>
  <tr class="titulos">
    <td colspan="7" bgcolor="eeeeee">&nbsp;</td>
  </tr>
  <tr class="titulos">
    <td colspan="7" bgcolor="eeeeee">&nbsp;</td>
  </tr>  
      <tr class="exibir">
        <td colspan="3" bgcolor="f7f7f7"><div align="center" class="style2">Pontos Pendentes </div></td>
        <td colspan="2" bgcolor="f7f7f7"><div align="center" class="style2">Quantidade</div></td>
        <td bgcolor="f7f7f7"><div align="center" class="style2">%</div></td>		
      </tr>
	  <cfoutput query="qinspecao">      
      <tr class="exibir">
        <td width="60%" colspan="3" bgcolor="f7f7f7"><div align="left" class="style1">
            <cfswitch expression= "#qinspecao.Pos_situacao_resp#">              
			  <cfcase value="0" delimiters=",">
                Unidades(Não Respondeu)
              </cfcase>
			  <cfcase value="2">
                Unidades(Pendência)
              </cfcase>
              <cfcase value="4">
                Órgão Subordinador
              </cfcase>
              <cfcase value="5">
                Áreas
              </cfcase>
              <cfcase value="1">
                GMAD(Resposta da Unidade)
              </cfcase>
			   <cfcase value="6">
                GMAD(Resposta da Área)
              </cfcase>
			   <cfcase value="7">
                GMAD (Resposta do Órgão Subordinador)
               </cfcase>
              <cfcase value="8">
                Diretoria Regional
              </cfcase>
			  <cfcase value="9">
                Administração Central
              </cfcase>
			  <cfcase value="3">
                Solucionados
              </cfcase>
            </cfswitch>
        </div></td>
        <td width="25%" colspan="2" bgcolor="f7f7f7"><div align="center" class="style1">#qinspecao.inspecao#</div></td>		      
        <td width="18%" bgcolor="f7f7f7"><div align="center" class="style1">#NumberFormat(val((qinspecao.inspecao*100)/(qtotalitens.TotalItens)),999.00)#%</div></td> 
      </tr>  
  </cfoutput>
      <tr class="titulos">
        <td colspan="6" bgcolor="eeeeee"><div align="center" class="style1">Solucionados</div></td>
      </tr>
      <tr class="titulos">
        <td bgcolor="eeeeee"><div align="center">Unidades</div></td>
        <td colspan="2" bgcolor="eeeeee"><div align="center">&Oacute;rg&atilde;o Subordinador</div></td>
        <td colspan="3" bgcolor="eeeeee"><div align="center">&Aacute;reas</div></td>
      </tr>
      <tr class="titulos">
        <td width="30%" bgcolor="eeeeee"><div align="center"><cfoutput>#NumberFormat(sol_total.qtd_total - (sol_reop.qtd_reop + sol_area.qtd_area))#</cfoutput></div></td>        
        <td width="30%" colspan="2" bgcolor="eeeeee"><div align="center"><cfoutput>#sol_reop.qtd_reop#</cfoutput></div></td>
        <td width="15%" colspan="3" bgcolor="eeeeee"><div align="center"><cfoutput>#sol_area.qtd_area#</cfoutput></div></td>
      </tr>
      <tr class="titulos">
        <td colspan="7" bgcolor="eeeeee">&nbsp;</td>
      </tr>
  <tr class="exibir">
    <td colspan="3" bgcolor="eeeeee"><cfoutput>
        <div align="left" class="style1">Total de pontos de auditoria </div>
    </cfoutput></td>
    <td  colspan="4" bgcolor="eeeeee"><cfoutput>
      <div align="center"><span class="style1">#qtotalitens.TotalItens#</span></div>
    </cfoutput></td>    
  </tr>
  <tr class="exibir">
    <td colspan="3" bgcolor="eeeeee" class="style1">Total de pontos pendentes(n&atilde;o corporativos)</td>
    <td  colspan="4" bgcolor="eeeeee" class="style1"><cfoutput>
      <div align="center">#qtotalitenspendentes.ItensPendentes#</div>
    </cfoutput></td>    
  </tr>
  <tr class="exibir">
    <td colspan="3" bgcolor="eeeeee"><span class="style1">Total de auditorias </span></td>
    <td colspan="4" bgcolor="eeeeee"><cfoutput>
      <div align="center"><span class="style1">#qtotalinspecao.TotalInspecao#</span></div>
    </cfoutput></td>
  </tr>
  <tr class="exibir">
    <td colspan="3" bgcolor="eeeeee"><span class="style1">&Iacute;ndice de pend&ecirc;ncias</span></td>
    <td colspan="4" bgcolor="eeeeee"><cfoutput>
      <div align="center"><span class="style1"><cfif qtotalitens.TotalItens neq 0>
      #NumberFormat(val((qtotalitenspendentes.ItensPendentes*100)/(qtotalitens.TotalItens)),999.00)#% <cfelse> 0
      </cfif></span></div>
    </cfoutput></td> 
  </tr>
  <tr class="exibir">
    <td colspan="3" bgcolor="eeeeee"><span class="style1">M&eacute;dia de pontos por auditoria </span></td>
    <td colspan="4" bgcolor="eeeeee" class="style1"><cfoutput>
      <div align="center"><cfif qtotalitens.TotalItens neq 0>#NumberFormat(val((qtotalitens.TotalItens)/(qtotalinspecao.TotalInspecao)),999.00)# <cfelse> 0 </div></cfif>
    </cfoutput></td>
  </tr>  
  <tr class="exibir">    
    <td colspan="3" bgcolor="eeeeee"><span class="style1">Total de pontos n&atilde;o solucionados </span></td>
    <td colspan="4" bgcolor="eeeeee" class="style1"><cfoutput>
      <div align="center">#replace(NumberFormat((val(qtotalitens.TotalItens))-(val(sol_total.qtd_total))),',','','all')#</div></cfoutput></td>	   
  </tr>
  <tr class="exibir">
    <td colspan="7" bgcolor="eeeeee">&nbsp;</td>
  </tr>  
</table>
<cfinclude template="rodape.cfm">
<div align="center"></div>
</body>
</html>
