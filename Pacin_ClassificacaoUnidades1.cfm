<cfprocessingdirective pageEncoding ="utf-8"/> 
<cfsetting requesttimeout="15000"> 

<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

<!--- <cfoutput></cfoutput> --->
<cfoutput>
<cfset auxano=right(form.frmx_aval,4)>

<cfquery name="rsBusca" datasource="#dsn_inspecao#">
	SELECT RIP_Ano, TUN_Codigo, TUN_Descricao, RIP_Unidade, Und_Descricao, RIP_NumInspecao, RIP_NumGrupo, RIP_NumItem, RIP_Resposta, RIP_Falta, RIP_Sobra, Itn_PTC_Seq, Itn_Pontuacao, Pos_Situacao_Resp, STO_Descricao, INP_Modalidade, INP_DtInicInspecao, INP_DtFimInspecao, INP_HrsInspecao, INP_Responsavel
	FROM (((Unidades 
	INNER JOIN (Inspecao 
	INNER JOIN (Resultado_Inspecao 
	LEFT JOIN ParecerUnidade ON (RIP_Unidade = Pos_Unidade) AND (RIP_NumInspecao = Pos_Inspecao) AND (RIP_NumGrupo = Pos_NumGrupo) AND (RIP_NumItem = Pos_NumItem)) ON (INP_Unidade = RIP_Unidade) AND (INP_NumInspecao = RIP_NumInspecao)) ON Und_Codigo = RIP_Unidade) 
	INNER JOIN Itens_Verificacao ON (INP_Modalidade = Itn_Modalidade) AND (Und_TipoUnidade = Itn_TipoUnidade) AND (RIP_NumGrupo = Itn_NumGrupo) AND (RIP_NumItem = Itn_NumItem)) 
	INNER JOIN Tipo_Unidades ON Und_TipoUnidade = TUN_Codigo) LEFT JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo
	WHERE (((Itn_Ano)='#auxano#') AND ((RIP_Ano)=#auxano#) AND ((RIP_NumInspecao)='#form.frmx_aval#'))
	ORDER BY RIP_NumGrupo, RIP_NumItem
</cfquery>
<cfquery name="rsRelev" datasource="#dsn_inspecao#">
	SELECT VLR_Fator, VLR_FaixaInicial, VLR_FaixaFinal
	FROM ValorRelevancia
	WHERE VLR_Ano = '#auxano#'
</cfquery>	
</cfoutput>

	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>Sistema Nacional de Controle Interno</title>
	<link href="../../estilo.css" rel="stylesheet" type="text/css">
	<link href="css.css" rel="stylesheet" type="text/css">

<script language="JavaScript" type="text/JavaScript">
<cfinclude template="mm_menu.js">
</script>
	</head>

<body onLoad="onsubmit="mensagem()">


<cfinclude template="cabecalho.cfm">
	    <span class="exibir"><strong>
	    </strong></span>
        <table width="72%" border="0" align="center">
          <tr valign="baseline">
            <td class="exibir">&nbsp;</td>
          </tr>
          <tr valign="baseline">
            <td class="exibir"><div align="center"><span class="titulo2"><strong class="titulo1">COMPOSIÇÃO DA CLASSIFICAÇÃO De UNIDADE</strong></span></div></td>
          </tr>
        </table>
<cfset codtp = rsBusca.TUN_Codigo>
<cfset desctp = rsBusca.TUN_Descricao>	
<cfset UndCod = rsBusca.RIP_Unidade>		
<cfset UndDesc = rsBusca.Und_Descricao>
<cfset Numaval = rsBusca.RIP_NumInspecao>
<cfif rsBusca.INP_Modalidade is 0>
  <cfset modal = 'PRESENCIAL'>
<cfelseif rsBusca.INP_Modalidade is 1>
  <cfset modal = 'A DISTÂNICA'>
<cfelse>
  <cfset modal = 'MISTA'>			
</cfif>	
<cfset INPDtInic = dateformat(rsBusca.INP_DtInicInspecao,"dd/mm/yyyy")>
<cfset INPDtFim = dateformat(rsBusca.INP_DtFimInspecao,"dd/mm/yyyy")>
<cfset INPResp = rsBusca.INP_Responsavel>	
<cfset HRAval = rsBusca.INP_HrsInspecao>
<form action="Pacin_o.cfm" method="post" target="_parent" name="form1">  
	  <table width="1950" border="0" align="center">
	       <tr bgcolor="#CCCCCC" class="exibir">
            <td colspan="19" align="center">
	<cfoutput>	
			<table width="100%" border="0">
              <tr class="exibir">
                <th scope="row">Ano</th>
                <th colspan="2" scope="row"><div align="left">Tipo Unidade</div></th>
                <th colspan="2" scope="row"><div align="left">Unidade</div></th>
                <th width="8%" scope="row"><div align="left">Nº da Avaliação</div></th>
                <th width="7%" scope="row">Modal</th>
                <th width="6%" scope="row">DT. Início</th>
                <th width="6%" scope="row">DT.Final</th>
                <th width="7%" scope="row">Horas Avaliação </th>
                <th width="34%" scope="row"><div align="left">Gestor da Unidade</div></th>
              </tr>

              <tr class="exibir">
                <th width="3%" scope="row"><strong>#auxano#</strong></th>
                <th width="3%" scope="row">#codtp#</th>
                <th width="8%" scope="row"><div align="left">#desctp#</div></th>
                <th width="3%" scope="row">#UndCod#</th>
                <th width="15%" scope="row"><div align="left">#UndDesc#</div></th>
                <th scope="row"><div align="left">#Numaval#</div></th>
                <th scope="row">#modal#</th>
                <th scope="row">#INPDtInic#</th>
                <th scope="row">#INPDtFim#</th>
                <th scope="row">#HRAval#</th>
                <th scope="row"><div align="left">#INPResp#</div></th>
              </tr>
            </table>
</cfoutput>			</td>
          </tr>
		   
	      <tr bgcolor="#CCCCCC" class="titulos">
            <td width="2%" align="center"><div align="center">Grupo</div></td>
            <td width="2%"><div align="center">Item</div></td>
            <td width="3%"><div align="center">Resposta</div></td>
            <td width="6%"><div align="center">Falta(R$)</div></td>
            <td width="7%"><div align="center">Sobra(R$)</div></td>
            <td width="5%"><div align="center">Composição <br />
            Pontuação</div></td>
            <td width="4%"><div align="center">Impacto <br />
              Financeiro?</div></td>
            <td width="3%"><div align="center">Pontuação<br />
            Item</div></td>
            <td width="2%"><div align="center">Fator<br />
            <br />
            </div></td>
			<td width="3%"><div align="center">Situação<br />
            (Item)</div></td>
            <td width="11%"><div align="left">Descrição
            Situação Item</div></td>
            <td width="5%"><div align="center">Pts. Máxima<br />
              Unidade</div></td>
            <td width="4%"><div align="center">Pts. Item<br />
(Inicial)</div></td>
            <td width="3%"><div align="center">TNC<br />
            (Inicial)</div></td>
            <td width="13%">Classif(Inicial)</td>
            <td width="6%"><div align="center">Pts.Item<br />
            (Atual)</div></td>
            <td width="3%"><div align="center">TNC<br />
            (Atual)</div></td>
            <td width="18%">Classif(Atual)</td>
          </tr>
      <cfset somapiini = 0>
	  <cfset somapmini = 0>		  
      <cfset somapiatu = 0>
	  <cfset somaptsmaxunidatual = 0>	
	  <cfset somafalta = 0>	
	  <cfset somasobra = 0>		  
      <cfoutput query="rsBusca">
			<cfset scor = 'f7f7f7'>		
			<cfset grp = RIP_NumGrupo>	
			<cfset item = RIP_NumItem>	
			<cfset resp = RIP_Resposta>										
			<cfset falta = lscurrencyformat(RIP_Falta)>	
			<cfset sobra = lscurrencyformat(RIP_Sobra)>
			<cfset composic = Itn_PTC_Seq>	
			<cfset impactosn = 'N'>
			<cfif left(composic,2) eq '10'>
			  <cfset impactosn = 'S'>
			</cfif>
			<cfset pontua = Itn_Pontuacao>
			<cfset fator = 1>
			<cfif impactosn eq 'S'>
				 <cfset somafaltasobra = rsBusca.RIP_Falta>
				 <cfif (rsBusca.RIP_NumItem eq 1 and (rsBusca.RIP_NumGrupo eq 53 or rsBusca.RIP_NumGrupo eq 72 or rsBusca.RIP_NumGrupo eq 214 or rsBusca.RIP_NumGrupo eq 284))>
					<cfset somafaltasobra = somafaltasobra + rsBusca.RIP_Sobra>
				 </cfif>
				 <cfif somafaltasobra gt 0>
					<cfloop query="rsRelev">
						 <cfif rsRelev.VLR_FaixaInicial is 0 and rsRelev.VLR_FaixaFinal lte somafaltasobra>
							<cfset fator = rsRelev.VLR_Fator>
						 <cfelseif rsRelev.VLR_FaixaInicial neq 0 and VLR_FaixaFinal neq 0 and somafaltasobra gt rsRelev.VLR_FaixaInicial and somafaltasobra lte rsRelev.VLR_FaixaFinal>
							<cfset fator = rsRelev.VLR_Fator>
						 <cfelseif VLR_FaixaFinal eq 0 and somafaltasobra gt rsRelev.VLR_FaixaInicial>
							<cfset fator = rsRelev.VLR_Fator> 
						 </cfif>
<!--- 				rsRelev.VLR_FaixaInicial: #rsRelev.VLR_FaixaInicial#  rsRelev.VLR_FaixaFinal: #rsRelev.VLR_FaixaFinal#	rsRelev.VLR_Fator#rsRelev.VLR_Fator#  falta:#somafaltasobra#  fator:#fator#<br> --->
					</cfloop>
				</cfif>	
			</cfif>						
			
			<cfset stat = Pos_Situacao_Resp>
			<cfset statdesc = STO_Descricao>
			<cfset fatorconst = 4.5>
			<cfset PTSMAXUNIDINICIAL = 0>
			<cfset PTSMAXUNIDATUAL = 0>
            <!--- inicio: Pontuação maxima Inicial e Atual --->  
			<cfif rsBusca.RIP_Resposta eq 'N' or rsBusca.RIP_Resposta eq 'C'>
				<cfif impactosn eq 'S'>
					<cfset PTSMAXUNIDINICIAL = (pontua * fatorconst)>
				<cfelse>
					<cfset PTSMAXUNIDINICIAL = pontua>					
				</cfif>
			</cfif>				
			<!--- final:  Pontuação maxima Inicial e Atual --->  	
			<!---  --->		
            <!--- inicio: Pontuação Item Inicial e Atual --->  
			<cfset PTSITEMUNIDINICIAL = 0>	
			<cfset PTSITEMUNIDATUAL = 0>
			<cfif rsBusca.RIP_Resposta eq 'N'>
				<cfset PTSITEMUNIDINICIAL =  (pontua * fator)>
				<cfif rsBusca.Pos_Situacao_Resp neq 3 and rsBusca.Pos_Situacao_Resp neq 12 and rsBusca.Pos_Situacao_Resp neq 13 and rsBusca.Pos_Situacao_Resp neq 25>
					<cfset PTSITEMUNIDATUAL = (pontua * fator)>
				<cfelse>
					<cfset PTSITEMUNIDATUAL = 0>
				</cfif>	 							
			</cfif>
			<!--- final: Pontuação Item Inicial e Atual --->
		 	<cfset piini = PTSITEMUNIDINICIAL>	 
		    <cfset somapiini = somapiini + piini>			
			
			<cfset pmini = PTSMAXUNIDINICIAL>	
			<cfset somapmini = somapmini + pmini>
			<cfset piatu = PTSITEMUNIDATUAL>	 
          <tr bgcolor="#scor#" class="exibir">
            <td>#grp#</td>
            <td width="2%"><div align="center">#item#</div></td>
            <td width="3%"><div align="center">#resp#</div></td>
            <td width="6%"><div align="center">#falta#</div></td>
            <td width="7%"><div align="center">#sobra#</div></td>
            <td width="5%"><div align="center">#composic#</div></td>
            <td width="4%"><div align="center">#impactosn#</div></td>
            <td width="3%"><div align="center">#pontua#</div></td>
            <td><div align="center">#fator#</div></td>
            <td width="3%"><div align="center">#stat#</div></td>
            <td width="11%"><div align="left">#statdesc#</div></td>
			<cfset auxcol = replace(pmini,'.',',')>
            <td><div align="center">#auxcol#</div></td>
			<cfset auxcol = replace(piini,'.',',')>
            <td width="4%"><div align="center">#auxcol#</div></td>
            <td width="3%"><div align="center"></div></td>
            <td width="13%">&nbsp;</td>
			<cfset auxcol = replace(piatu,'.',',')>
            <td><div align="center">#auxcol#</div></td>
            <td width="3%"><div align="center"></div></td>
            <td width="18%"><div align="left"></div></td>
          </tr>

		  <cfif scor eq 'f7f7f7'>
		    <cfset scor = 'CCCCCC'>
		  <cfelse>
		    <cfset scor = 'f7f7f7'>
		  </cfif>
		<!---  --->		

		  		  
		  <cfset somapiatu = somapiatu + piatu>
		  <cfset somafalta = somafalta + rsBusca.RIP_Falta>	
	  	  <cfset somasobra = somasobra + rsBusca.RIP_Sobra>			
		<!---  --->  
      </cfoutput>
	<!---  --->	
    <cfset TNCI = numberFormat((somapiini/somapmini)*100,999)>
	<cfif TNCI lte 5>
	  <cfset TNCClassInicio = 'Plenamente eficaz'>
	<cfelseif TNCI lte 10>
	  <cfset TNCClassInicio = 'Eficaz'>
	<cfelseif TNCI lte 20>
	  <cfset TNCClassInicio = 'Eficacia mediana'>	  
	<cfelseif TNCI lte 50>
	  <cfset TNCClassInicio = 'Pouco eficaz'>	  
	<cfelse>
	  <cfset TNCClassInicio = 'Ineficaz'>	  	
	</cfif>
	<!---  --->	
	<cfset TNCA = numberFormat((somapiatu/somapmini)*100,999)>
	<cfif TNCA lte 5>
	  <cfset TNCClassAtual = 'Plenamente eficaz'>
	<cfelseif TNCA lte 10>
	  <cfset TNCClassAtual = 'Eficaz'>
	<cfelseif TNCA lte 20>
	  <cfset TNCClassAtual = 'Eficacia mediana'>	  
	<cfelseif TNCA lte 50>
	  <cfset TNCClassAtual = 'Pouco eficaz'>	  
	<cfelse>
	  <cfset TNCClassAtual = 'Ineficaz'>	  	
	</cfif>	
<cfoutput>	
<cfset somafalta = lscurrencyformat(somafalta)>	
<cfset somasobra = lscurrencyformat(somasobra)>
<cfset totreg = rsBusca.recordcount>	
<cfset sptmu = somapmini>
<cfset sptitui = somapiini>
<cfset sptitua = somapiatu>
<tr bgcolor="CCCCCC" class="titulos">
		     <td align="center">&nbsp;</td>
		     <td>&nbsp;</td>
		     <td><div align="center">#totreg#</div></td>
		     <td><div align="right">#somafalta#</div></td>
		     <td><div align="right">#somasobra#</div></td>
		     <td>&nbsp;</td>
		     <td>&nbsp;</td>
		     <td>&nbsp;</td>
		     <td>&nbsp;</td>
		     <td width="3%">&nbsp;</td>
		     <td width="11%">&nbsp;</td>
			 <cfset auxcol = replace(sptmu,'.',',')>
		     <td><div align="center">#auxcol#</div></td>
			 <cfset auxcol = replace(sptitui,'.',',')>			 
		     <td><div align="center">#auxcol#</div></td>
		     <td><div align="center">#TNCI#</div></td>
		     <td>#TNCClassInicio#</td>
			 <cfset auxcol = replace(sptitua,'.',',')>				 
		     <td><div align="center">#auxcol#</div></td>
		     <td><div align="center">#TNCA#</div></td>
		     <td colspan="2"><div align="left">#TNCClassAtual#</div>
	         <div align="center"></div>		       <div align="left"></div></td>
      </tr>	
</cfoutput>				  
        <tr bgcolor="f7f7f7">
          <td colspan="27" align="center" class="titulos"><hr></td>
        </tr>
        <tr>
          <td colspan="20">
              <div align="center">
                <input name="Submit1" type="button" class="form" id="Submit1" value="Fechar" onClick="window.close()">
          </div>
             <div align="right"></div></td>
        </tr>
        <tr>
          <td colspan="27" align="center" class="titulos"><hr></td>
        </tr>
	  <!--- FIM DA ÁREA DE CONTEÚDO --->
 </table>
</form>	

  <!--- Término da área de conteúdo --->
</body>
</html>

