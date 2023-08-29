<cfset dtInicio = dtInic>
<cfset dtFinal = dtFim>
<cfset dtInicio = CreateDate(Right(dtInicio,4), Mid(dtInicio,4,2), Left(dtInicio,2))>
<cfset dtFinal = CreateDate(Right(dtFinal,4), Mid(dtFinal,4,2), Left(dtFinal,2))>

<cfquery name="qDr" datasource="#dsn_inspecao#">
SELECT Con_SiglaDr
FROM Configuracao
</cfquery>


<cfquery name="qAgrupa"  datasource="#dsn_inspecao#">
SELECT     dbo.Tipo_Unidades.TUN_Descricao, COUNT(dbo.Inspecao.INP_NumInspecao) AS contarUnid, dbo.Tipo_Unidades.TUN_Codigo
FROM         dbo.Inspecao INNER JOIN
                      dbo.Unidades ON dbo.Inspecao.INP_Unidade = dbo.Unidades.Und_Codigo INNER JOIN
                      dbo.Tipo_Unidades ON dbo.Unidades.Und_TipoUnidade = dbo.Tipo_Unidades.TUN_Codigo
WHERE     (dbo.Inspecao.INP_DtFimInspecao BETWEEN #dtInicio# And #dtFinal#)
GROUP BY dbo.Tipo_Unidades.TUN_Descricao, dbo.Tipo_Unidades.TUN_Codigo
</cfquery>

<cfquery name="qitem" datasource="#dsn_inspecao#">
SELECT Atv_Codigo, COUNT(Pos_NumItem) AS Solucionados, Atv_Descricao, Pos_Situacao
FROM ParecerUnidade 
INNER JOIN Itens_Verificacao ON 
      ParecerUnidade.Pos_NumItem = Itens_Verificacao.Itn_NumItem AND 
	  ParecerUnidade.Pos_NumGrupo = Itens_Verificacao.Itn_NumGrupo AND 
	  right(ParecerUnidade.Pos_Inspecao, 4) = Itens_Verificacao.Itn_Ano 
	  INNER JOIN Atividades ON 
	  Itens_Verificacao.Itn_CodAtividade = Atividades.Atv_Codigo 
	  INNER JOIN Inspecao ON 
	  ParecerUnidade.Pos_Inspecao = Inspecao.INP_NumInspecao AND ParecerUnidade.Pos_Unidade = Inspecao.INP_Unidade 
	  INNER JOIN Tipo_Unidades 
	  INNER JOIN Unidades ON 
	  Tipo_Unidades.TUN_Codigo = Unidades.Und_TipoUnidade ON Inspecao.INP_Unidade = Unidades.Und_Codigo
WHERE (INP_DtFimInspecao BETWEEN #dtInicio# And #dtFinal#)
GROUP BY  Atv_Codigo, Atv_Descricao, Pos_Situacao
ORDER BY Atv_Codigo
</cfquery>

<cfset Eco_Total_PE = 0>
<cfset Eco_Total_SL = 0>
<cfset Com_Total_PE = 0>
<cfset Com_Total_SL = 0>
<cfset Ope_Total_PE = 0>
<cfset Ope_Total_SL = 0>
<cfset Adm_Total_PE = 0>
<cfset Adm_Total_SL = 0>
<cfset Rec_Total_PE = 0>
<cfset Rec_Total_SL = 0>
<cfset Tec_Total_PE = 0>
<cfset Tec_Total_SL = 0>
<cfset Jur_Total_PE = 0>
<cfset Jur_Total_SL = 0>
<cfset Pre_Total_PE = 0>
<cfset Pre_Total_SL = 0>
<cfloop query="qitem">
<cfif qitem.Pos_Situacao eq 'SO'>
<cfswitch expression="#qitem.Atv_Codigo#">
          <cfcase value="1">		   
            <cfset Eco_Total_SL = Eco_Total_SL + qitem.Solucionados>
	      </cfcase>
		  <cfcase value="100">		   
            <cfset Eco_Total_SL = Eco_Total_SL + qitem.Solucionados>
	      </cfcase>
          <cfcase value="2">
	        <cfset Com_Total_SL = Com_Total_SL + qitem.Solucionados>
          </cfcase>
		  <cfcase value="101">
	        <cfset Com_Total_SL = Com_Total_SL + qitem.Solucionados>
          </cfcase>
		  <cfcase value="107">
	        <cfset Com_Total_SL = Com_Total_SL + qitem.Solucionados>
          </cfcase>
 	      <cfcase value="3">
	        <cfset Ope_Total_SL = Ope_Total_SL + qitem.Solucionados> 
	      </cfcase>
		  <cfcase value="102">
	        <cfset Ope_Total_SL = Ope_Total_SL + qitem.Solucionados> 
	      </cfcase>
	      <cfcase value="4">
	        <cfset Adm_Total_SL = Adm_Total_SL + qitem.Solucionados> 
	      </cfcase>
		  <cfcase value="103">
	        <cfset Adm_Total_SL = Adm_Total_SL + qitem.Solucionados> 
	      </cfcase>
	      <cfcase value="5">
	        <cfset Rec_Total_SL = Rec_Total_SL + qitem.Solucionados> 
  	      </cfcase>
		  <cfcase value="104">
	        <cfset Rec_Total_SL = Rec_Total_SL + qitem.Solucionados> 
  	      </cfcase>
	      <cfcase value="6">
	        <cfset Tec_Total_SL = Tec_Total_SL + qitem.Solucionados> 
	      </cfcase>
		  <cfcase value="105">
	        <cfset Tec_Total_SL = Tec_Total_SL + qitem.Solucionados> 
	      </cfcase>
		  <cfcase value="106">
	        <cfset Jur_Total_SL = Jur_Total_SL + qitem.Solucionados> 
	      </cfcase>
		  <cfcase value="108">
	        <cfset Pre_Total_SL = Pre_Total_SL + qitem.Solucionados> 
	      </cfcase>
</cfswitch>
<cfelse>
<cfswitch expression="#qitem.Atv_Codigo#">
          <cfcase value="1">		   
            <cfset Eco_Total_PE = Eco_Total_PE + qitem.Solucionados>
	      </cfcase>
		  <cfcase value="100">		   
            <cfset Eco_Total_PE = Eco_Total_PE + qitem.Solucionados>
	      </cfcase>
          <cfcase value="2">
	        <cfset Com_Total_PE = Com_Total_PE + qitem.Solucionados>
          </cfcase>
		  <cfcase value="101">
	        <cfset Com_Total_PE = Com_Total_PE + qitem.Solucionados>
          </cfcase>
		  <cfcase value="107">
	        <cfset Com_Total_PE = Com_Total_PE + qitem.Solucionados>
          </cfcase>
 	      <cfcase value="3">
	        <cfset Ope_Total_PE = Ope_Total_PE + qitem.Solucionados> 
	      </cfcase>
		  <cfcase value="102">
	        <cfset Ope_Total_PE = Ope_Total_PE + qitem.Solucionados> 
	      </cfcase>
	      <cfcase value="4">
	        <cfset Adm_Total_PE = Adm_Total_PE + qitem.Solucionados> 
	      </cfcase>
		  <cfcase value="103">
	        <cfset Adm_Total_PE = Adm_Total_PE + qitem.Solucionados> 
	      </cfcase>
	      <cfcase value="5">
	        <cfset Rec_Total_PE = Rec_Total_PE + qitem.Solucionados> 
  	      </cfcase>
		  <cfcase value="104">
	        <cfset Rec_Total_PE = Rec_Total_PE + qitem.Solucionados> 
  	      </cfcase>
	      <cfcase value="6">
	        <cfset Tec_Total_PE = Tec_Total_PE + qitem.Solucionados> 
	      </cfcase>
		  <cfcase value="105">
	        <cfset Tec_Total_PE = Tec_Total_PE + qitem.Solucionados> 
	      </cfcase>
		  <cfcase value="106">
	        <cfset Jur_Total_PE = Jur_Total_PE + qitem.Solucionados> 
	      </cfcase>
		  <cfcase value="108">
	        <cfset Pre_Total_PE = Pre_Total_PE + qitem.Solucionados> 
	      </cfcase>
</cfswitch>
</cfif>
</cfloop>
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
  <br><br><br> 
  <tr class="titulos">
    <td bgcolor="eeeeee" colspan="29"><div align="center"><span class="titulo1"><strong> Pontos por atividade</strong></span></div></td>
  </tr>
  <tr class="titulos">
    <td bgcolor="eeeeee" colspan="29">&nbsp;</td>
  </tr>
  <tr class="titulos">
    <td bgcolor="eeeeee" colspan="29"><div align="center"><span class="Style1">&nbsp;PER&Iacute;ODO: &nbsp;&nbsp;&nbsp; <cfoutput>#lsdateformat(dtinicio,"dd/mm/yyyy")# a #lsdateformat(dtfinal,"dd/mm/yyyy")#</cfoutput></span></div></td>
  </tr>
  <tr>
    <td bgcolor="eeeeee" colspan="29">&nbsp;</td>
  </tr>
  <tr class="titulos">
    <td colspan="2" bgcolor="eeeeee"><div align="center"><span class="Style1">DR/<cfoutput>#qDr.Con_SiglaDr#</cfoutput></span></div></td>
    <td colspan="24" bgcolor="eeeeee"><div align="center"><span class="Style1">QUANTIDADE DE PONTOS - MACROS PROCESSOS</span></div></td>
    <td colspan="3" bgcolor="eeeeee" rowspan="4"><div align="center"><span class="Style1">TOTAL</span></div></td>
  </tr>
  

<cfset Com_NC=0>
<cfset Com_SL=0>
<cfset Com_PE=0>

<cfset Eco_NC=0>
<cfset Eco_SL=0>
<cfset Eco_PE=0>

<cfset Ope_NC=0>
<cfset Ope_SL=0>
<cfset OPe_PE=0>

<cfset Adm_NC=0>
<cfset Adm_SL=0>
<cfset Adm_PE=0>

<cfset Rec_NC=0>
<cfset Rec_SL=0>
<cfset Rec_PE=0>

<cfset Tec_NC=0>
<cfset Tec_SL=0>
<cfset Tec_PE=0> 

<cfset Jur_NC=0>
<cfset Jur_SL=0>
<cfset Jur_PE=0> 

<cfset Pre_NC=0>
<cfset Pre_SL=0>
<cfset Pre_PE=0> 

  <tr class="titulos">
    <td width="50" rowspan="3" bgcolor="eeeeee"><div align="center"><span class="Style1">TIPO</span></div></td>
    <td rowspan="3" bgcolor="eeeeee"><div align="center"><span class="Style1">QUANT. UNID.</span></div></td>
    <td colspan="3" rowspan="2" bgcolor="eeeeee"><div align="center"><span class="Style1">COMERCIAL</span></div></td>
    <td colspan="3" rowspan="2" bgcolor="eeeeee"><div align="center"><span class="Style1">OPERACIONAL</span></div></td>
    <td colspan="3" bgcolor="eeeeee"><div align="center"><span class="Style1">ECON&Ocirc;MICO</span></div></td>
    <td colspan="3" rowspan="2" bgcolor="eeeeee"><div align="center"><span class="Style1">ADMINISTRA&Ccedil;&Atilde;O</span></div></td>
    <td colspan="3" bgcolor="eeeeee"><div align="center"><span class="Style1">RECURSOS</span></div></td>
    <td colspan="3" rowspan="2" bgcolor="eeeeee"><div align="center"><span class="Style1">TECNOLOGIA</span></div></td>
	<td colspan="3" rowspan="2" bgcolor="eeeeee"><div align="center"><span class="Style1">JUR&Iacute;DICA</span></div></td>
	<td colspan="3" rowspan="2" bgcolor="eeeeee"><div align="center"><span class="Style1">PRESID&Ecirc;NCIA</span></div></td>
  </tr>
  <tr class="titulos">
    <td colspan="3" bgcolor="eeeeee"><div align="center"><span class="Style1">FINANCEIRO</span></div></td>
    <td colspan="3" bgcolor="eeeeee"><div align="center"><span class="Style1">HUMANOS</span></div></td>
  </tr>
  <tr class="titulos">
    <td width="30" bgcolor="eeeeee"><div align="center"><span class="Style1">NC</span></div></td>
    <td width="30" bgcolor="eeeeee"><div align="center"><span class="Style1">SL</span></div></td>
    <td width="30" bgcolor="eeeeee"><div align="center"><span class="Style1">PE</span></div></td>
    <td width="30" bgcolor="eeeeee"><div align="center"><span class="Style1">NC</span></div></td>
    <td width="30" bgcolor="eeeeee"><div align="center"><span class="Style1">SL</span></div></td>
    <td width="30" bgcolor="eeeeee"><div align="center"><span class="Style1">PE</span></div></td>
    <td width="30" bgcolor="eeeeee"><div align="center"><span class="Style1">NC</span></div></td>
    <td width="30" bgcolor="eeeeee"><div align="center"><span class="Style1">SL</span></div></td>
    <td width="30" bgcolor="eeeeee"><div align="center"><span class="Style1">PE</span></div></td>
    <td width="30" bgcolor="eeeeee"><div align="center"><span class="Style1">NC</span></div></td>
    <td width="30" bgcolor="eeeeee"><div align="center"><span class="Style1">SL</span></div></td>
    <td width="30" bgcolor="eeeeee"><div align="center"><span class="Style1">PE</span></div></td>
    <td width="30" bgcolor="eeeeee"><div align="center"><span class="Style1">NC</span></div></td>
    <td width="30" bgcolor="eeeeee"><div align="center"><span class="Style1">SL</span></div></td>
    <td width="30" bgcolor="eeeeee"><div align="center"><span class="Style1">PE</span></div></td>
    <td width="30" bgcolor="eeeeee"><div align="center"><span class="Style1">NC</span></div></td>
    <td width="30" bgcolor="eeeeee"><div align="center"><span class="Style1">SL</span></div></td>
    <td width="33" bgcolor="eeeeee"><div align="center"><span class="Style1">PE</span></div></td>
    <td width="38" bgcolor="eeeeee"><div align="center"><span class="Style1">NC</span></div></td>
    <td width="38" bgcolor="eeeeee"><div align="center"><span class="Style1">SL</span></div></td>
    <td width="38" bgcolor="eeeeee"><div align="center"><span class="Style1">PE</span></div></td>
	<td width="38" bgcolor="eeeeee"><div align="center"><span class="Style1">NC</span></div></td>
    <td width="38" bgcolor="eeeeee"><div align="center"><span class="Style1">SL</span></div></td>
    <td width="38" bgcolor="eeeeee"><div align="center"><span class="Style1">PE</span></div></td>
  </tr>
   <cfset sContr3 = 'N'>
   <cfset sContr4 = 'N'>
   <cfset SomaUnid =0>
   
   
<cfoutput query="qAgrupa">
<cfquery name="qSolucionados" datasource="#dsn_inspecao#">
SELECT   dbo.Unidades.Und_TipoUnidade, dbo.Atividades.Atv_Codigo, COUNT(dbo.ParecerUnidade.Pos_NumItem) AS Solucionados, 
                      dbo.ParecerUnidade.Pos_Situacao
FROM         dbo.ParecerUnidade INNER JOIN
                      dbo.Itens_Verificacao ON dbo.ParecerUnidade.Pos_NumItem = dbo.Itens_Verificacao.Itn_NumItem AND 
                      dbo.ParecerUnidade.Pos_NumGrupo = dbo.Itens_Verificacao.Itn_NumGrupo 
                      AND right([ParecerUnidade.Pos_Inspecao], 4) = dbo.Itens_Verificacao.Itn_Ano 
                      INNER JOIN
                      dbo.Atividades ON dbo.Itens_Verificacao.Itn_CodAtividade = dbo.Atividades.Atv_Codigo INNER JOIN
                      dbo.Inspecao ON dbo.ParecerUnidade.Pos_Inspecao = dbo.Inspecao.INP_NumInspecao AND 
                      dbo.ParecerUnidade.Pos_Unidade = dbo.Inspecao.INP_Unidade INNER JOIN
                      dbo.Tipo_Unidades INNER JOIN
                      dbo.Unidades ON dbo.Tipo_Unidades.TUN_Codigo = dbo.Unidades.Und_TipoUnidade ON 
                      dbo.Inspecao.INP_Unidade = dbo.Unidades.Und_Codigo
WHERE   (INP_DtFimInspecao BETWEEN #dtInicio# And #dtFinal#)
GROUP BY dbo.Unidades.Und_TipoUnidade, dbo.Atividades.Atv_Codigo, dbo.ParecerUnidade.Pos_Situacao
<cfif qAgrupa.TUN_Codigo lte 2>
    HAVING (dbo.Unidades.Und_TipoUnidade = #qAgrupa.TUN_Codigo#)
</cfif>
<cfif qAgrupa.TUN_Codigo gte 4 and qAgrupa.TUN_Codigo lte 10>
    HAVING (dbo.Unidades.Und_TipoUnidade BETWEEN 4 AND 10)
</cfif>
<cfif qAgrupa.TUN_Codigo eq 3 or qAgrupa.TUN_Codigo gt 10>
    HAVING (dbo.Unidades.Und_TipoUnidade = 3 OR dbo.Unidades.Und_TipoUnidade > 10)
</cfif>
    ORDER BY dbo.Unidades.Und_TipoUnidade, dbo.Atividades.Atv_Codigo, dbo.ParecerUnidade.Pos_Situacao
</cfquery>

  <!--- <cfset tipo_Unid = qSolucionados.Und_TipoUnidade> --->
  <cfset scab = ''> 
  <cfset contCab = ''>
  
   <!--- <cfif tipo_Unid eq Und_TipoUnidade> --->
      <!--- Cabeçalho da coluna --->
      <cfswitch expression="#qAgrupa.TUN_Codigo#">
        <cfcase value="1,26">		  
          <cfquery name="rsQtdUnid" datasource="#dsn_inspecao#">
		       SELECT DISTINCT dbo.Unidades.Und_Codigo, dbo.Tipo_Unidades.TUN_Descricao
               FROM dbo.Tipo_Unidades INNER JOIN
               dbo.Unidades ON dbo.Tipo_Unidades.TUN_Codigo = dbo.Unidades.Und_TipoUnidade INNER JOIN
               dbo.Inspecao ON dbo.Unidades.Und_Codigo = dbo.Inspecao.INP_Unidade
               WHERE (dbo.Tipo_Unidades.TUN_Codigo = 1 or dbo.Tipo_Unidades.TUN_Codigo = 26) AND (INP_DtFimInspecao BETWEEN #dtInicio# And #dtFinal#)
               GROUP BY dbo.Tipo_Unidades.TUN_Descricao, dbo.Unidades.Und_Codigo
               ORDER BY dbo.Unidades.Und_Codigo
		  </cfquery>
		   <cfset scab = 'ACF/AGF'>
		   <cfset SomaUnid = rsQtdUnid.recordcount>
        </cfcase>
        <cfcase value="2">
          <cfquery name="rsQtdUnid" datasource="#dsn_inspecao#">		  
               SELECT DISTINCT dbo.Unidades.Und_Codigo, dbo.Tipo_Unidades.TUN_Descricao
               FROM dbo.Tipo_Unidades INNER JOIN
               dbo.Unidades ON dbo.Tipo_Unidades.TUN_Codigo = dbo.Unidades.Und_TipoUnidade INNER JOIN
               dbo.Inspecao ON dbo.Unidades.Und_Codigo = dbo.Inspecao.INP_Unidade
               WHERE (dbo.Tipo_Unidades.TUN_Codigo = 2) AND (INP_DtFimInspecao BETWEEN #dtInicio# And #dtFinal#)
               GROUP BY dbo.Tipo_Unidades.TUN_Descricao, dbo.Unidades.Und_Codigo
               ORDER BY dbo.Unidades.Und_Codigo		     
		  </cfquery>		  
		    <cfset SomaUnid = rsQtdUnid.recordcount>		   
          <cfset scab = 'AC'>
        </cfcase>
        <cfcase value="4,5,6,7,8,9,10" delimiters=",">
           <cfquery name="rsQtdUnid" datasource="#dsn_inspecao#">
		       SELECT DISTINCT dbo.Unidades.Und_Codigo, dbo.Tipo_Unidades.TUN_Descricao
               FROM dbo.Tipo_Unidades INNER JOIN
               dbo.Unidades ON dbo.Tipo_Unidades.TUN_Codigo = dbo.Unidades.Und_TipoUnidade INNER JOIN
               dbo.Inspecao ON dbo.Unidades.Und_Codigo = dbo.Inspecao.INP_Unidade
               WHERE (dbo.Tipo_Unidades.TUN_Codigo BETWEEN 4 AND 10) AND (INP_DtFimInspecao BETWEEN #dtInicio# And #dtFinal#)
               GROUP BY dbo.Tipo_Unidades.TUN_Descricao, dbo.Unidades.Und_Codigo
               ORDER BY dbo.Unidades.Und_Codigo		                    
		   </cfquery>
		   <cfset SomaUnid =0>		   
             <cfset SomaUnid = SomaUnid + rsQtdUnid.recordcount>			 
          <cfset scab = 'CDD/CT/CO/CTE/CTC/CEE/CTCE'>	  
        </cfcase>			
       <cfcase value="3,11,12,13,14,15" delimiters=",">  	      
           <cfquery name="rsQtdUnid" datasource="#dsn_inspecao#">
		       SELECT DISTINCT dbo.Unidades.Und_Codigo, dbo.Tipo_Unidades.TUN_Descricao
               FROM dbo.Tipo_Unidades INNER JOIN
               dbo.Unidades ON dbo.Tipo_Unidades.TUN_Codigo = dbo.Unidades.Und_TipoUnidade INNER JOIN
               dbo.Inspecao ON dbo.Unidades.Und_Codigo = dbo.Inspecao.INP_Unidade
               WHERE (dbo.Tipo_Unidades.TUN_Codigo = 3 or dbo.Tipo_Unidades.TUN_Codigo > 10) AND (INP_DtFimInspecao BETWEEN #dtInicio# And #dtFinal#)
               GROUP BY dbo.Tipo_Unidades.TUN_Descricao, dbo.Unidades.Und_Codigo
               ORDER BY dbo.Unidades.Und_Codigo     
		   </cfquery>
		   <cfset SomaUnid =0>		           
		      <cfset SomaUnid = SomaUnid + rsQtdUnid.recordcount>		      
	      <cfset scab = 'OUTROS'>      
         </cfcase>	
     </cfswitch>     
	  <cfif qAgrupa.TUN_Codigo eq 1>
     <cfloop query="qSolucionados">  
      <!--- Solucionados --->
	  <cfif qSolucionados.Pos_Situacao eq 'SO'>
   	     <cfswitch expression="#qSolucionados.Atv_Codigo#">
          <cfcase value="1">		   
            <cfset Eco_SL = Eco_SL + qSolucionados.Solucionados>
	      </cfcase>
		  <cfcase value="100">		   
            <cfset Eco_SL = Eco_SL + qSolucionados.Solucionados>
	      </cfcase>
          <cfcase value="2">
	        <cfset Com_SL = Com_SL + qSolucionados.Solucionados>
          </cfcase>
		  <cfcase value="101">
	        <cfset Com_SL = Com_SL + qSolucionados.Solucionados>
          </cfcase>
		  <cfcase value="107">
	        <cfset Com_SL = Com_SL + qSolucionados.Solucionados>
          </cfcase>
 	      <cfcase value="3">
	        <cfset Ope_SL = Ope_SL + qSolucionados.Solucionados> 
	      </cfcase>
		  <cfcase value="102">
	        <cfset Ope_SL = Ope_SL + qSolucionados.Solucionados> 
	      </cfcase>
	      <cfcase value="4">
	        <cfset Adm_SL = Adm_SL + qSolucionados.Solucionados> 
	      </cfcase>
		  <cfcase value="103">
	        <cfset Adm_SL = Adm_SL + qSolucionados.Solucionados> 
	      </cfcase>
	      <cfcase value="5">
	        <cfset Rec_SL = Rec_SL + qSolucionados.Solucionados> 
  	      </cfcase>
		  <cfcase value="104">
	        <cfset Rec_SL = Rec_SL + qSolucionados.Solucionados> 
  	      </cfcase>
	      <cfcase value="6">
	        <cfset Tec_SL = Tec_SL + qSolucionados.Solucionados> 
	      </cfcase>
		  <cfcase value="105">
	        <cfset Tec_SL = Tec_SL + qSolucionados.Solucionados> 
	      </cfcase>
		  <cfcase value="106">
	        <cfset Jur_SL = Jur_SL + qSolucionados.Solucionados> 
	      </cfcase>
		  <cfcase value="108">
	        <cfset Pre_SL = Pre_SL + qSolucionados.Solucionados> 
	      </cfcase>
        </cfswitch> 
		<!--- <cfset qtdUnid = qtdUnid + qSolucionados.Solucionados> --->
     <cfelse>
       <cfswitch expression="#qSolucionados.Atv_Codigo#">
         <cfcase value="1">
           <cfset Eco_PE = Eco_PE + qSolucionados.Solucionados>
         </cfcase>
		 <cfcase value="100">
           <cfset Eco_PE = Eco_PE + qSolucionados.Solucionados>
         </cfcase>
         <cfcase value="2">
           <cfset Com_PE = Com_PE + qSolucionados.Solucionados>
         </cfcase>
		 <cfcase value="101">
           <cfset Com_PE = Com_PE + qSolucionados.Solucionados>
         </cfcase>
		 <cfcase value="107">
           <cfset Com_PE = Com_PE + qSolucionados.Solucionados>
         </cfcase>
	     <cfcase value="3">
	       <cfset Ope_PE = Ope_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="102">
	       <cfset Ope_PE = Ope_PE + qSolucionados.Solucionados> 
	     </cfcase>
	     <cfcase value="4">
	       <cfset Adm_PE = Adm_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="103">
	       <cfset Adm_PE = Adm_PE + qSolucionados.Solucionados> 
	     </cfcase>
	     <cfcase value="5">
	       <cfset Rec_PE = Rec_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="104">
	       <cfset Rec_PE = Rec_PE + qSolucionados.Solucionados> 
	     </cfcase>
	     <cfcase value="6">
	       <cfset Tec_PE = Tec_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="105">
	       <cfset Tec_PE = Tec_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="106">
	       <cfset Jur_PE = Jur_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="108">
	       <cfset Pre_PE = Pre_PE + qSolucionados.Solucionados> 
	     </cfcase>
        </cfswitch> 
		<!--- <cfset qtdUnid = qtdUnid + qSolucionados.Solucionados> --->
    </cfif>
	</cfloop> 
	      <cfset totalSL = Com_SL + Ope_SL + Eco_SL + Adm_SL + Rec_SL + Tec_SL + Jur_SL + Pre_SL>
          <cfset totalPE = Com_PE + Ope_PE + Eco_PE + Adm_PE + Rec_PE + Tec_PE + Jur_PE + Pre_PE>
	 <tr class="titulosClaro">
      <td bgcolor="eeeeee"><div align="center">#scab#</div></td>
      <td bgcolor="f7f7f7" class="red_titulo"><div align="center">#SomaUnid#</div></td>
      <td bgcolor="f7f7f7" class="titulosClaro"><div align="center">#VAL(Com_SL) + val(Com_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Com_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Com_PE#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#VAL(Ope_SL) + val(Ope_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Ope_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Ope_PE#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#VAL(Eco_SL) + val(Eco_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Eco_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Eco_PE#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#VAL(Adm_SL) + val(Adm_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Adm_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Adm_PE#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#VAL(Rec_SL) + val(Rec_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Rec_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Rec_PE#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#VAL(Tec_SL) + val(Tec_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Tec_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Tec_PE#</div></td>
	  <td bgcolor="f7f7f7"><div align="center">#VAL(Jur_SL) + val(Jur_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Jur_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Jur_PE#</div></td>
	  <td bgcolor="f7f7f7"><div align="center">#VAL(Pre_SL) + val(Pre_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Pre_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Pre_PE#</div></td>
      <td bgcolor="f7f7f7" class="red_titulo"><div align="center">#VAL(TotalSL) + val(TotalPE)#</div></td>
      <td bgcolor="f7f7f7" class="red_titulo"><div align="center">#TotalSL#</div></td>
      <td bgcolor="f7f7f7" class="red_titulo"><div align="center">#TotalPE#</div></td>
    </tr>
  <cfset Com_NC=0>
  <cfset Com_SL=0>
  <cfset Com_PE=0>
  <cfset Eco_NC=0>
  <cfset Eco_SL=0>
  <cfset Eco_PE=0>
  <cfset Ope_NC=0>
  <cfset Ope_SL=0>
  <cfset OPe_PE=0>
  <cfset Adm_NC=0>
  <cfset Adm_SL=0>
  <cfset Adm_PE=0>
  <cfset Rec_NC=0>
  <cfset Rec_SL=0>
  <cfset Rec_PE=0>
  <cfset Tec_NC=0>
  <cfset Tec_SL=0>
  <cfset Tec_PE=0>
  <cfset Jur_NC=0>
  <cfset Jur_SL=0>
  <cfset Jur_PE=0>
  <cfset Pre_NC=0>
  <cfset Pre_SL=0>
  <cfset Pre_PE=0>
  <cfset SomaUnid =0>
  <cfset contCab = scab>
  <cfset tipo_Unid = qSolucionados.Und_TipoUnidade> 
	 </cfif>
        <cfif qAgrupa.TUN_Codigo eq 2>
     <cfloop query="qSolucionados">  
      <!--- Solucionados --->
	  <cfif qSolucionados.Pos_Situacao eq 'SO'>
   	     <cfswitch expression="#qSolucionados.Atv_Codigo#">
          <cfcase value="1">
            <cfset Eco_SL = Eco_SL + qSolucionados.Solucionados>
	      </cfcase>
		  <cfcase value="100">
            <cfset Eco_SL = Eco_SL + qSolucionados.Solucionados>
	      </cfcase>
          <cfcase value="2">
	        <cfset Com_SL = Com_SL + qSolucionados.Solucionados>
          </cfcase>
		  <cfcase value="101">
	        <cfset Com_SL = Com_SL + qSolucionados.Solucionados>
          </cfcase>
		  <cfcase value="107">
	        <cfset Com_SL = Com_SL + qSolucionados.Solucionados>
          </cfcase>
 	      <cfcase value="3">
	        <cfset Ope_SL = Ope_SL + qSolucionados.Solucionados> 
	      </cfcase>
		  <cfcase value="102">
	        <cfset Ope_SL = Ope_SL + qSolucionados.Solucionados> 
	      </cfcase>
	      <cfcase value="4">
	        <cfset Adm_SL = Adm_SL + qSolucionados.Solucionados> 
	      </cfcase>
		  <cfcase value="103">
	        <cfset Adm_SL = Adm_SL + qSolucionados.Solucionados> 
	      </cfcase>
	      <cfcase value="5">
	        <cfset Rec_SL = Rec_SL + qSolucionados.Solucionados> 
  	      </cfcase>
		  <cfcase value="104">
	        <cfset Rec_SL = Rec_SL + qSolucionados.Solucionados> 
  	      </cfcase>
	      <cfcase value="6">
	        <cfset Tec_SL = Tec_SL + qSolucionados.Solucionados> 
	      </cfcase>
		  <cfcase value="105">
	        <cfset Tec_SL = Tec_SL + qSolucionados.Solucionados> 
	      </cfcase>
		  <cfcase value="106">
	        <cfset Jur_SL = Jur_SL + qSolucionados.Solucionados> 
	      </cfcase>
		  <cfcase value="108">
	        <cfset Pre_SL = Pre_SL + qSolucionados.Solucionados> 
	      </cfcase>
        </cfswitch> 
		<!--- <cfset qtdUnid = qtdUnid + qSolucionados.Solucionados> --->
     <cfelse>
       <cfswitch expression="#qSolucionados.Atv_Codigo#">
         <cfcase value="1">
           <cfset Eco_PE = Eco_PE + qSolucionados.Solucionados>
         </cfcase>
		 <cfcase value="100">
           <cfset Eco_PE = Eco_PE + qSolucionados.Solucionados>
         </cfcase>
         <cfcase value="2">
           <cfset Com_PE = Com_PE + qSolucionados.Solucionados>
         </cfcase>
		 <cfcase value="101">
           <cfset Com_PE = Com_PE + qSolucionados.Solucionados>
         </cfcase>
		 <cfcase value="107">
           <cfset Com_PE = Com_PE + qSolucionados.Solucionados>
         </cfcase>
	     <cfcase value="3">
	       <cfset Ope_PE = Ope_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="102">
	       <cfset Ope_PE = Ope_PE + qSolucionados.Solucionados> 
	     </cfcase>
	     <cfcase value="4">
	       <cfset Adm_PE = Adm_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="103">
	       <cfset Adm_PE = Adm_PE + qSolucionados.Solucionados> 
	     </cfcase>
	     <cfcase value="5">
	       <cfset Rec_PE = Rec_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="104">
	       <cfset Rec_PE = Rec_PE + qSolucionados.Solucionados> 
	     </cfcase>
	     <cfcase value="6">
	       <cfset Tec_PE = Tec_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="105">
	       <cfset Tec_PE = Tec_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="106">
	       <cfset Jur_PE = Jur_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="108">
	       <cfset Pre_PE = Pre_PE + qSolucionados.Solucionados> 
	     </cfcase>
        </cfswitch> 
		<!--- <cfset qtdUnid = qtdUnid + qSolucionados.Solucionados> --->
    </cfif>
	</cfloop>	 	      
	      <cfset totalSL = Com_SL + Ope_SL + Eco_SL + Adm_SL + Rec_SL + Tec_SL + Jur_SL + Pre_SL>
          <cfset totalPE = Com_PE + Ope_PE + Eco_PE + Adm_PE + Rec_PE + Tec_PE + Jur_PE + Pre_PE>
	 <tr class="titulosClaro">
      <td bgcolor="eeeeee"><div align="center">#scab#</div></td>
      <td bgcolor="f7f7f7" class="red_titulo"><div align="center">#SomaUnid#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#VAL(Com_SL) + val(Com_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Com_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Com_PE#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#VAL(Ope_SL) + val(Ope_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Ope_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Ope_PE#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#VAL(Eco_SL) + val(Eco_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Eco_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Eco_PE#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#VAL(Adm_SL) + val(Adm_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Adm_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Adm_PE#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#VAL(Rec_SL) + val(Rec_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Rec_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Rec_PE#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#VAL(Tec_SL) + val(Tec_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Tec_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Tec_PE#</div></td>
	  <td bgcolor="f7f7f7"><div align="center">#VAL(Jur_SL) + val(Jur_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Jur_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Jur_PE#</div></td>
	  <td bgcolor="f7f7f7"><div align="center">#VAL(Pre_SL) + val(Pre_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Pre_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Pre_PE#</div></td>
      <td bgcolor="f7f7f7" class="red_titulo"><div align="center">#VAL(TotalSL) + val(TotalPE)#</div></td>
      <td bgcolor="f7f7f7" class="red_titulo"><div align="center">#TotalSL#</div></td>
      <td bgcolor="f7f7f7" class="red_titulo"><div align="center">#TotalPE#</div></td>
    </tr>
	  <cfset Com_NC=0>
  <cfset Com_SL=0>
  <cfset Com_PE=0>
  <cfset Eco_NC=0>
  <cfset Eco_SL=0>
  <cfset Eco_PE=0>
  <cfset Ope_NC=0>
  <cfset Ope_SL=0>
  <cfset OPe_PE=0>
  <cfset Adm_NC=0>
  <cfset Adm_SL=0>
  <cfset Adm_PE=0>
  <cfset Rec_NC=0>
  <cfset Rec_SL=0>
  <cfset Rec_PE=0>
  <cfset Tec_NC=0>
  <cfset Tec_SL=0>
  <cfset Tec_PE=0>
  <cfset Jur_NC=0>
  <cfset Jur_SL=0>
  <cfset Jur_PE=0>
  <cfset Pre_NC=0>
  <cfset Pre_SL=0>
  <cfset Pre_PE=0>
  <cfset SomaUnid =0>
  <cfset contCab = scab>
  <cfset tipo_Unid = qSolucionados.Und_TipoUnidade> 
	</cfif>	
	 <cfif (qAgrupa.TUN_Codigo gte 4) and (qAgrupa.TUN_Codigo lte 10 and sContr4 eq 'N')>	       
     <cfloop query="qSolucionados">  
      <!--- Solucionados --->
	  <cfif qSolucionados.Pos_Situacao eq 'SO'>
   	    <cfswitch expression="#qSolucionados.Atv_Codigo#">
          <cfcase value="1">
            <cfset Eco_SL = Eco_SL + qSolucionados.Solucionados>
	      </cfcase>
		  <cfcase value="100">
            <cfset Eco_SL = Eco_SL + qSolucionados.Solucionados>
	      </cfcase>
          <cfcase value="2">
	        <cfset Com_SL = Com_SL + qSolucionados.Solucionados>
          </cfcase>
		  <cfcase value="101">
	        <cfset Com_SL = Com_SL + qSolucionados.Solucionados>
          </cfcase>
		  <cfcase value="107">
	        <cfset Com_SL = Com_SL + qSolucionados.Solucionados>
          </cfcase>
 	      <cfcase value="3">
	        <cfset Ope_SL = Ope_SL + qSolucionados.Solucionados> 
	      </cfcase>
		  <cfcase value="102">
	        <cfset Ope_SL = Ope_SL + qSolucionados.Solucionados> 
	      </cfcase>
	      <cfcase value="4">
	        <cfset Adm_SL = Adm_SL + qSolucionados.Solucionados> 
	      </cfcase>
		  <cfcase value="103">
	        <cfset Adm_SL = Adm_SL + qSolucionados.Solucionados> 
	      </cfcase>
	      <cfcase value="5">
	        <cfset Rec_SL = Rec_SL + qSolucionados.Solucionados> 
  	      </cfcase>
		  <cfcase value="104">
	        <cfset Rec_SL = Rec_SL + qSolucionados.Solucionados> 
  	      </cfcase>
	      <cfcase value="6">
	        <cfset Tec_SL = Tec_SL + qSolucionados.Solucionados> 
	      </cfcase>
		  <cfcase value="105">
	        <cfset Tec_SL = Tec_SL + qSolucionados.Solucionados> 
	      </cfcase>
		  <cfcase value="106">
	        <cfset Jur_SL = Jur_SL + qSolucionados.Solucionados> 
	      </cfcase>
		  <cfcase value="108">
	        <cfset Pre_SL = Pre_SL + qSolucionados.Solucionados> 
	      </cfcase>
        </cfswitch> 
		<!--- <cfset qtdUnid = qtdUnid + qSolucionados.Solucionados> --->
     <cfelse>
       <cfswitch expression="#qSolucionados.Atv_Codigo#">
         <cfcase value="1">
           <cfset Eco_PE = Eco_PE + qSolucionados.Solucionados>
         </cfcase>
		 <cfcase value="100">
           <cfset Eco_PE = Eco_PE + qSolucionados.Solucionados>
         </cfcase>
         <cfcase value="2">
           <cfset Com_PE = Com_PE + qSolucionados.Solucionados>
         </cfcase>
		 <cfcase value="101">
           <cfset Com_PE = Com_PE + qSolucionados.Solucionados>
         </cfcase>
		 <cfcase value="107">
           <cfset Com_PE = Com_PE + qSolucionados.Solucionados>
         </cfcase>
	     <cfcase value="3">
	       <cfset Ope_PE = Ope_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="102">
	       <cfset Ope_PE = Ope_PE + qSolucionados.Solucionados> 
	     </cfcase>
	     <cfcase value="4">
	       <cfset Adm_PE = Adm_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="103">
	       <cfset Adm_PE = Adm_PE + qSolucionados.Solucionados> 
	     </cfcase>
	     <cfcase value="5">
	       <cfset Rec_PE = Rec_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="104">
	       <cfset Rec_PE = Rec_PE + qSolucionados.Solucionados> 
	     </cfcase>
	     <cfcase value="6">
	       <cfset Tec_PE = Tec_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="105">
	       <cfset Tec_PE = Tec_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="106">
	       <cfset Jur_PE = Jur_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="108">
	       <cfset Pre_PE = Pre_PE + qSolucionados.Solucionados> 
	     </cfcase>
        </cfswitch> 
		<!--- <cfset qtdUnid = qtdUnid + qSolucionados.Solucionados> --->
    </cfif>
	</cfloop> 
	<cfset sContr4 = 'S'>
	      <cfset totalSL = Com_SL + Ope_SL + Eco_SL + Adm_SL + Rec_SL + Tec_SL + Jur_SL + Pre_SL>
          <cfset totalPE = Com_PE + Ope_PE + Eco_PE + Adm_PE + Rec_PE + Tec_PE + Jur_PE + Pre_PE>
	 <tr class="titulosClaro">
      <td bgcolor="eeeeee"><div align="center">#scab#</div></td>
      <td bgcolor="f7f7f7" class="red_titulo"><div align="center">#SomaUnid#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#VAL(Com_SL) + val(Com_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Com_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Com_PE#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#VAL(Ope_SL) + val(Ope_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Ope_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Ope_PE#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#VAL(Eco_SL) + val(Eco_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Eco_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Eco_PE#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#VAL(Adm_SL) + val(Adm_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Adm_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Adm_PE#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#VAL(Rec_SL) + val(Rec_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Rec_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Rec_PE#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#VAL(Tec_SL) + val(Tec_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Tec_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Tec_PE#</div></td>
	  <td bgcolor="f7f7f7"><div align="center">#VAL(Jur_SL) + val(Jur_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Jur_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Jur_PE#</div></td>
	  <td bgcolor="f7f7f7"><div align="center">#VAL(Pre_SL) + val(Pre_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Pre_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Pre_PE#</div></td>
      <td bgcolor="f7f7f7" class="red_titulo"><div align="center">#VAL(TotalSL) + val(TotalPE)#</div></td>
      <td bgcolor="f7f7f7" class="red_titulo"><div align="center">#TotalSL#</div></td>
      <td bgcolor="f7f7f7" class="red_titulo"><div align="center">#TotalPE#</div></td>
    </tr>
  <cfset Com_NC=0>
  <cfset Com_SL=0>
  <cfset Com_PE=0>
  <cfset Eco_NC=0>
  <cfset Eco_SL=0>
  <cfset Eco_PE=0>
  <cfset Ope_NC=0>
  <cfset Ope_SL=0>
  <cfset OPe_PE=0>
  <cfset Adm_NC=0>
  <cfset Adm_SL=0>
  <cfset Adm_PE=0>
  <cfset Rec_NC=0>
  <cfset Rec_SL=0>
  <cfset Rec_PE=0>
  <cfset Tec_NC=0>
  <cfset Tec_SL=0>
  <cfset Tec_PE=0>  
  <cfset Jur_NC=0>
  <cfset Jur_SL=0>
  <cfset Jur_PE=0>
  <cfset Pre_NC=0>
  <cfset Pre_SL=0>
  <cfset Pre_PE=0>     
  <cfset SomaUnid =0>
  <cfset contCab = scab>
  <cfset tipo_Unid = qSolucionados.Und_TipoUnidade> 
 </cfif> 
  
  <cfif (qAgrupa.TUN_Codigo eq 3) or (qAgrupa.TUN_Codigo gt 10 and sContr3 eq 'N')>    
      <cfloop query="qSolucionados">  
      <!--- Solucionados --->
	  <cfif qSolucionados.Pos_Situacao eq 'SO'>
   	     <cfswitch expression="#qSolucionados.Atv_Codigo#">
          <cfcase value="1">
            <cfset Eco_SL = Eco_SL + qSolucionados.Solucionados>
	      </cfcase>
		  <cfcase value="100">
            <cfset Eco_SL = Eco_SL + qSolucionados.Solucionados>
	      </cfcase>
          <cfcase value="2">
	        <cfset Com_SL = Com_SL + qSolucionados.Solucionados>
          </cfcase>
		  <cfcase value="101">
	        <cfset Com_SL = Com_SL + qSolucionados.Solucionados>
          </cfcase>
		  <cfcase value="107">
	        <cfset Com_SL = Com_SL + qSolucionados.Solucionados>
          </cfcase>
 	      <cfcase value="3">
	        <cfset Ope_SL = Ope_SL + qSolucionados.Solucionados> 
	      </cfcase>
		  <cfcase value="102">
	        <cfset Ope_SL = Ope_SL + qSolucionados.Solucionados> 
	      </cfcase>
	      <cfcase value="4">
	        <cfset Adm_SL = Adm_SL + qSolucionados.Solucionados> 
	      </cfcase>
		  <cfcase value="103">
	        <cfset Adm_SL = Adm_SL + qSolucionados.Solucionados> 
	      </cfcase>
	      <cfcase value="5">
	        <cfset Rec_SL = Rec_SL + qSolucionados.Solucionados> 
  	      </cfcase>
		  <cfcase value="104">
	        <cfset Rec_SL = Rec_SL + qSolucionados.Solucionados> 
  	      </cfcase>
	      <cfcase value="6">
	        <cfset Tec_SL = Tec_SL + qSolucionados.Solucionados> 
	      </cfcase>
		  <cfcase value="105">
	        <cfset Tec_SL = Tec_SL + qSolucionados.Solucionados> 
	      </cfcase>
		  <cfcase value="106">
	        <cfset Jur_SL = Jur_SL + qSolucionados.Solucionados> 
	      </cfcase>
		  <cfcase value="108">
	        <cfset Pre_SL = Pre_SL + qSolucionados.Solucionados> 
	      </cfcase>
        </cfswitch> 
		<!--- <cfset qtdUnid = qtdUnid + qSolucionados.Solucionados> --->
     <cfelse>
       <cfswitch expression="#qSolucionados.Atv_Codigo#">
         <cfcase value="1">
           <cfset Eco_PE = Eco_PE + qSolucionados.Solucionados>
         </cfcase>
		 <cfcase value="100">
           <cfset Eco_PE = Eco_PE + qSolucionados.Solucionados>
         </cfcase>
         <cfcase value="2">
           <cfset Com_PE = Com_PE + qSolucionados.Solucionados>
         </cfcase>
		 <cfcase value="101">
           <cfset Com_PE = Com_PE + qSolucionados.Solucionados>
         </cfcase>
		 <cfcase value="107">
           <cfset Com_PE = Com_PE + qSolucionados.Solucionados>
         </cfcase>
	     <cfcase value="3">
	       <cfset Ope_PE = Ope_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="102">
	       <cfset Ope_PE = Ope_PE + qSolucionados.Solucionados> 
	     </cfcase>
	     <cfcase value="4">
	       <cfset Adm_PE = Adm_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="103">
	       <cfset Adm_PE = Adm_PE + qSolucionados.Solucionados> 
	     </cfcase>
	     <cfcase value="5">
	       <cfset Rec_PE = Rec_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="104">
	       <cfset Rec_PE = Rec_PE + qSolucionados.Solucionados> 
	     </cfcase>
	     <cfcase value="6">
	       <cfset Tec_PE = Tec_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="105">
	       <cfset Tec_PE = Tec_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="106">
	       <cfset Jur_PE = Jur_PE + qSolucionados.Solucionados> 
	     </cfcase>
		 <cfcase value="108">
	       <cfset Pre_PE = Pre_PE + qSolucionados.Solucionados> 
	     </cfcase>
        </cfswitch> 
		<!--- <cfset qtdUnid = qtdUnid + qSolucionados.Solucionados> --->
    </cfif>
	</cfloop> 
	<cfset sContr3 = 'S'>
	 <cfset totalSL = Com_SL + Ope_SL + Eco_SL + Adm_SL + Rec_SL + Tec_SL + Jur_SL + Pre_SL>
     <cfset totalPE = Com_PE + Ope_PE + Eco_PE + Adm_PE + Rec_PE + Tec_PE + Jur_PE + Pre_PE>
	 <tr class="titulosClaro">
      <td bgcolor="eeeeee"><div align="center">#scab#</div></td>
      <td bgcolor="f7f7f7" class="red_titulo"><div align="center">#SomaUnid#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#VAL(Com_SL) + val(Com_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Com_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Com_PE#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#VAL(Ope_SL) + val(Ope_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Ope_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Ope_PE#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#VAL(Eco_SL) + val(Eco_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Eco_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Eco_PE#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#VAL(Adm_SL) + val(Adm_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Adm_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Adm_PE#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#VAL(Rec_SL) + val(Rec_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Rec_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Rec_PE#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#VAL(Tec_SL) + val(Tec_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Tec_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Tec_PE#</div></td>
	  <td bgcolor="f7f7f7"><div align="center">#VAL(Jur_SL) + val(Jur_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Jur_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Jur_PE#</div></td>
	  <td bgcolor="f7f7f7"><div align="center">#VAL(Pre_SL) + val(Pre_PE)#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Pre_SL#</div></td>
      <td bgcolor="f7f7f7"><div align="center">#Pre_PE#</div></td>
      <td bgcolor="f7f7f7" class="red_titulo"><div align="center">#VAL(TotalSL) + val(TotalPE)#</div></td>
      <td bgcolor="f7f7f7" class="red_titulo"><div align="center">#TotalSL#</div></td>
      <td bgcolor="f7f7f7" class="red_titulo"><div align="center">#TotalPE#</div></td>
    </tr>
  <cfset Com_NC=0>
  <cfset Com_SL=0>
  <cfset Com_PE=0>
  <cfset Eco_NC=0>
  <cfset Eco_SL=0>
  <cfset Eco_PE=0>
  <cfset Ope_NC=0>
  <cfset Ope_SL=0>
  <cfset OPe_PE=0>
  <cfset Adm_NC=0>
  <cfset Adm_SL=0>
  <cfset Adm_PE=0>
  <cfset Rec_NC=0>
  <cfset Rec_SL=0>
  <cfset Rec_PE=0>
  <cfset Tec_NC=0>
  <cfset Tec_SL=0>
  <cfset Tec_PE=0>  
  <cfset Jur_NC=0>
  <cfset Jur_SL=0>
  <cfset Jur_PE=0> 
  <cfset Pre_NC=0>
  <cfset Pre_SL=0>
  <cfset Pre_PE=0> 
  <cfset SomaUnid=0>  
  <cfset contCab = scab>
  <cfset tipo_Unid = qSolucionados.Und_TipoUnidade> 
</cfif>  	
</cfoutput>
<cfoutput>
  <tr class="red_titulo" align="center">
    <td bgcolor="eeeeee">&nbsp;</td>
    <td bgcolor="eeeeee">&nbsp;</td>
    <td bgcolor="eeeeee">#val(Com_Total_SL) + val(Com_Total_PE)#</td>
    <td bgcolor="eeeeee">#Com_Total_SL#</td>
    <td bgcolor="eeeeee">#Com_Total_PE#</td>
    <td bgcolor="eeeeee">#val(Ope_Total_SL) + val(Ope_Total_PE)#</td>
    <td bgcolor="eeeeee">#Ope_Total_SL#</td>
    <td bgcolor="eeeeee">#Ope_Total_PE#</td>
    <td bgcolor="eeeeee">#val(Eco_Total_SL) + val(Eco_Total_PE)#</td>
    <td bgcolor="eeeeee">#Eco_Total_SL#</td>
    <td bgcolor="eeeeee">#Eco_Total_PE#</td>
    <td bgcolor="eeeeee">#val(Adm_Total_SL) + val(Adm_Total_PE)#</td>
    <td bgcolor="eeeeee">#Adm_Total_SL#</td>
    <td bgcolor="eeeeee">#Adm_Total_PE#</td>
    <td bgcolor="eeeeee">#val(Rec_Total_SL) + val(Rec_Total_PE)#</td>
    <td bgcolor="eeeeee">#Rec_Total_SL#</td>
    <td bgcolor="eeeeee">#Rec_Total_PE#</td>
    <td bgcolor="eeeeee">#val(Tec_Total_SL) + val(Tec_Total_PE)#</td>
    <td bgcolor="eeeeee">#Tec_Total_SL#</td>
    <td bgcolor="eeeeee">#Tec_Total_PE#</td>
	<td bgcolor="eeeeee">#val(Jur_Total_SL) + val(Jur_Total_PE)#</td>
    <td bgcolor="eeeeee">#Jur_Total_SL#</td>
    <td bgcolor="eeeeee">#Jur_Total_PE#</td>
	<td bgcolor="eeeeee">#val(Pre_Total_SL) + val(Pre_Total_PE)#</td>
    <td bgcolor="eeeeee">#Pre_Total_SL#</td>
    <td bgcolor="eeeeee">#Pre_Total_PE#</td>
    <td bgcolor="eeeeee">&nbsp;</td>
    <td bgcolor="eeeeee">&nbsp;</td>
    <td bgcolor="eeeeee">&nbsp;</td>
  </tr> 
</cfoutput>
  <tr class="titulos">
    <td colspan="29" bgcolor="eeeeee">&nbsp;</td>
  </tr>
  <tr class="titulos">
    <td bgcolor="eeeeee">&nbsp;</td>
    <td colspan="10" bgcolor="eeeeee"><div align="center">NC-N&Atilde;O-CONFORME</div></td>
    <td colspan="10" bgcolor="eeeeee"><div align="center">SL-SOLUCIONADO</div></td>
    <td colspan="9" bgcolor="eeeeee"><div align="center">PE-EM ANDAMENTO </div></td>
  </tr>
  <tr class="titulos">
    <td bgcolor="eeeeee" colspan="29">&nbsp;</td>
  </tr>
</table>
</body>
</html>
