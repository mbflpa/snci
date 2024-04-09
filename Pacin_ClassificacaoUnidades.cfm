<cfprocessingdirective pageEncoding ="utf-8"/> 
<cfsetting requesttimeout="15000"> 

<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>
 <cfif isDefined("url.Ninsp") and url.Ninsp neq ''>
<!---  <cfoutput>
#url.pagretorno#
</cfoutput>
 <cfset gil = gil> --->  
    <cfset form.frmano = right(url.Ninsp,4)>
   <!--- passagem de parametro num da avaliação e nome da página requisitante(url.pagretorno)--->
	 <cfquery name="rsClas" datasource="#dsn_inspecao#">
		SELECT distinct RIP_Unidade, RIP_NumInspecao
		FROM Inspecao 
		INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade)
		INNER JOIN Unidades ON (INP_Unidade = Und_Codigo)
		WHERE RIP_NumInspecao = '#url.Ninsp#'
	</cfquery>
<cfelse>

<!--- Criar linha de metas --->
<cfquery name="rsClas" datasource="#dsn_inspecao#">
	SELECT distinct RIP_Unidade, RIP_NumInspecao
	FROM Inspecao 
	INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade)
	INNER JOIN Unidades ON (INP_Unidade = Und_Codigo)
	WHERE Right(RIP_NumInspecao,4)= '#form.frmano#' and INP_Situacao = 'CO'
	<cfif form.se neq 'Todos'>
		and Und_CodDiretoria = '#form.se#' 
	</cfif>
	<cfif form.frmtipounid neq 'Todas'>
		and Und_TipoUnidade = '#form.frmtipounid#' 
	</cfif>
	order by RIP_NumInspecao
</cfquery>   

<!--- <cfquery name="rsClas" datasource="#dsn_inspecao#">
	SELECT distinct RIP_Unidade, RIP_NumInspecao
	FROM Inspecao 
	INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade)
	INNER JOIN Unidades ON (INP_Unidade = Und_Codigo)
	WHERE RIP_NumInspecao = '6000332022' 
</cfquery>   --->  
</cfif>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT Usu_DR, Usu_Matricula, Usu_Coordena FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
</cfquery>

<cfquery name="rsRelev" datasource="#dsn_inspecao#">
	SELECT VLR_Fator, VLR_FaixaInicial, VLR_FaixaFinal
	FROM ValorRelevancia
	WHERE VLR_Ano = '#form.frmano#'
</cfquery>

<cfoutput query="rsClas">

    <cfset totC = 0>
	<cfset totN = 0>	
	<cfset totV = 0>	
	<cfset totE = 0>	
	<cfset status3 = 0>			
	<cfset status25 = 0>			
	<cfset status12 = 0>			
	<cfset status13 = 0>	
	<cfset ripfalta = 0>					
	<cfset ripsobra = 0>	
	<cfset ripemrisco = 0>
		
	<cfquery name="rsBusca" datasource="#dsn_inspecao#">
		SELECT INP_NumInspecao, RIP_NumGrupo, RIP_NumItem, RIP_Resposta, RIP_Falta, RIP_Sobra, RIP_EmRisco, Pos_Situacao_Resp, Itn_Pontuacao, Itn_PTC_Seq
		FROM (((Inspecao 
		INNER JOIN Unidades ON INP_Unidade = Und_Codigo) 
		INNER JOIN Resultado_Inspecao ON (INP_Unidade = RIP_Unidade) AND (INP_NumInspecao = RIP_NumInspecao)) 
		INNER JOIN Itens_Verificacao ON (convert(char(4),RIP_Ano) = Itn_Ano) AND (RIP_NumGrupo = Itn_NumGrupo) AND (RIP_NumItem = Itn_NumItem) AND (Und_TipoUnidade = Itn_TipoUnidade)) 
		LEFT JOIN ParecerUnidade ON (RIP_Unidade = Pos_Unidade) AND (RIP_NumInspecao = Pos_Inspecao) AND (RIP_NumGrupo = Pos_NumGrupo) AND (RIP_NumItem = Pos_NumItem)
		WHERE Itn_Ano='#form.frmano#' AND INP_NumInspecao='#rsClas.RIP_NumInspecao#'
	</cfquery> 
						
	<cfquery dbtype="query" name="rsCNVE">
		SELECT RIP_Resposta, Count(RIP_Resposta) AS QtdCNVE
		FROM rsBusca 
		GROUP BY RIP_Resposta
	</cfquery>
	<cfloop query="rsCNVE">
		<cfif rsCNVE.RIP_Resposta is 'C'><cfset totC = rsCNVE.QtdCNVE></cfif>
		<cfif rsCNVE.RIP_Resposta is 'N'><cfset totN = rsCNVE.QtdCNVE></cfif>
		<cfif rsCNVE.RIP_Resposta is 'V'><cfset totV = rsCNVE.QtdCNVE></cfif>
		<cfif rsCNVE.RIP_Resposta is 'E'><cfset totE = rsCNVE.QtdCNVE></cfif>
	</cfloop>
	<!---  --->
	<cfquery dbtype="query" name="rsStatus">
		SELECT Pos_Situacao_Resp, Count(Pos_Situacao_Resp) AS QtdStatus
		FROM rsBusca 
		GROUP BY Pos_Situacao_Resp
	</cfquery>	
	<cfloop query="rsStatus">
		<cfif rsStatus.Pos_Situacao_Resp is 3><cfset status3 = rsStatus.QtdStatus></cfif>
		<cfif rsStatus.Pos_Situacao_Resp is 25><cfset status25 = rsStatus.QtdStatus></cfif>
		<cfif rsStatus.Pos_Situacao_Resp is 12><cfset status12 = rsStatus.QtdStatus></cfif>
		<cfif rsStatus.Pos_Situacao_Resp is 13><cfset status13 = rsStatus.QtdStatus></cfif>
	</cfloop>	
	<!---  --->
	<cfset fator = 1>
	<cfquery dbtype="query" name="rsPTSUNID">
		SELECT RIP_NumGrupo, RIP_NumItem, RIP_Resposta, RIP_Falta, RIP_Sobra, RIP_EmRisco,Itn_Pontuacao
		FROM rsBusca 
		WHERE RIP_Resposta IN('C','N')
	</cfquery>

	<cfset TNCPTSSolucao = 0>
	<cfset TNCPTSRegularizado = 0>
	<cfset TNCPTSImprocedente = 0>
	<cfset TNCPTSCancelado = 0>	
<!--- ============================================================================= --->	
      <cfset somapiini = 0>
	  <cfset somaptsmax = 0>		  
      <cfset somapiatu = 0>
	  <cfset somafalta = 0>	
	  <cfset somasobra = 0>		
	  <cfset somaemrisco = 0>  
      <cfloop query="rsBusca">
			<cfset grp = rsBusca.RIP_NumGrupo>	
			<cfset item = rsBusca.RIP_NumItem>	
			<cfset resp = rsBusca.RIP_Resposta>										
			<cfset composic = Itn_PTC_Seq>	
			<cfset impactosn = 'N'>
			<cfif left(composic,2) eq '10'>
			  <cfset impactosn = 'S'>
			</cfif>
			<cfset pontua = rsBusca.Itn_Pontuacao>
			<cfset fator = 0>
            <cfif impactosn eq 'S'>
              <cfset somafaltasobrarisco = rsBusca.RIP_Falta + rsBusca.RIP_Sobra + rsBusca.RIP_EmRisco>
              <cfset somafaltasobrarisco = numberformat(#somafaltasobrarisco#,9999999999.99)>
              <cfif somafaltasobrarisco gte 0>
                <cfloop query="rsRelev">
                  <cfset fxini = numberformat(rsRelev.VLR_FaixaInicial,9999999999.99)>
                  <cfset fxfim = numberformat(rsRelev.VLR_FaixaFinal,9999999999.99)>
                  <cfif fxini eq 0.00 and somafaltasobrarisco lte fxfim and fator eq 0>
                    <cfset fator = rsRelev.VLR_Fator>
                  </cfif>
                  <cfif (fxini neq 0.00 and fxfim neq 0.00) and (somafaltasobrarisco gt fxini and somafaltasobrarisco lte fxfim) and fator eq 0>
                    <cfset fator = rsRelev.VLR_Fator>
                  </cfif>					
                  <cfif fxfim eq 0.00 and somafaltasobrarisco gte fxini and fator eq 0>
                    <cfset fator = rsRelev.VLR_Fator> 
                  </cfif>
                </cfloop>
              </cfif>	
            </cfif>	
						
			<cfset fatorconst = 4.5>
			<cfset PTSMAXUNIDINICIAL = 0>

            <!--- inicio: Pontuação Maxima Unidade --->  
			<cfif rsBusca.RIP_Resposta eq 'N' or rsBusca.RIP_Resposta eq 'C'>
				<cfif impactosn eq 'S'>
					<cfset PTSMAXUNIDINICIAL = (pontua * fatorconst)>
				<cfelse>
					<cfset PTSMAXUNIDINICIAL = pontua>	
				</cfif>
			</cfif>
			<!--- final:  Pontuação Maxima Unidade --->  	
			<!---  --->		
            <!--- inicio: Pontuação Item Inicial e Atual --->  
			<cfset PTSITEMUNIDINICIAL = 0>	
			<cfset PTSITEMUNIDATUAL = 0>
		    <!---  --->
			<cfif rsBusca.RIP_Resposta eq 'N'>
				<cfset PTSITEMUNIDINICIAL =  (pontua * fator)>
				<cfif rsBusca.Pos_Situacao_Resp neq 3 and rsBusca.Pos_Situacao_Resp neq 12 and rsBusca.Pos_Situacao_Resp neq 13 and rsBusca.Pos_Situacao_Resp neq 25>
					<cfset PTSITEMUNIDATUAL = (pontua * fator)>
				<cfelse>
					<cfset PTSITEMUNIDATUAL = 0>
					<!---  --->
					<cfif rsBusca.Pos_Situacao_Resp eq 3>
						<cfset TNCPTSSolucao = TNCPTSSolucao + (pontua * fator)>   
					</cfif>
					<cfif rsBusca.Pos_Situacao_Resp eq 25>
						<cfset TNCPTSRegularizado = TNCPTSRegularizado + (pontua * fator)>   
					</cfif>	
					<cfif rsBusca.Pos_Situacao_Resp eq 12>
						<cfset TNCPTSImprocedente = TNCPTSImprocedente + (pontua * fator)>   
					</cfif>		
					<cfif rsBusca.Pos_Situacao_Resp eq 13>
						<cfset TNCPTSCancelado = TNCPTSCancelado + (pontua * fator)>   
					</cfif>								
					<!---  --->					
				</cfif>	
			</cfif>
			<!--- final: Pontuação Item Inicial e Atual --->
			<cfset piini = PTSITEMUNIDINICIAL>	 
			<cfset pmini = PTSMAXUNIDINICIAL>	
			
			<cfset piatu = PTSITEMUNIDATUAL>	 
			
			<cfset somapiini = somapiini + piini>
			<cfset somaptsmax = somaptsmax + pmini>		  
			<cfset somapiatu = somapiatu + piatu>
			<cfset somafalta = somafalta + rsBusca.RIP_Falta>	
			<cfset somasobra = somasobra + rsBusca.RIP_Sobra>	
			<cfset somaemrisco = somaemrisco + rsBusca.RIP_EmRisco>		
	</cfloop>
	<cfset totCN = totC + totN>
	
	<cfif somaptsmax eq 0> 
		<cfset somaptsmax=1>
	</cfif>
	<cfif form.frmano lt 2024>
		<cfset TNCInicio = numberFormat((somapiini/somaptsmax)*100,999)>
		<cfif TNCInicio lte 5>
		<cfset TNCClassInicio = 'Plenamente eficaz'>
		<cfelseif TNCInicio lte 10>
		<cfset TNCClassInicio = 'Eficaz'>
		<cfelseif TNCInicio lte 20>
		<cfset TNCClassInicio = 'Eficacia mediana'>	  
		<cfelseif TNCInicio lte 50>
		<cfset TNCClassInicio = 'Pouco eficaz'>	  
		<cfelse>
		<cfset TNCClassInicio = 'Ineficaz'>	  	
		</cfif>
		<!---  --->	
		<cfset TNCAtual = numberFormat((somapiatu/somaptsmax)*100,999)>
		<cfif TNCAtual lte 5>
		<cfset TNCClassAtual = 'Plenamente eficaz'>
		<cfelseif TNCAtual lte 10>
		<cfset TNCClassAtual = 'Eficaz'>
		<cfelseif TNCAtual lte 20>
		<cfset TNCClassAtual = 'Eficacia mediana'>	  
		<cfelseif TNCAtual lte 50>
		<cfset TNCClassAtual = 'Pouco eficaz'>	  
		<cfelse>
		<cfset TNCClassAtual = 'Ineficaz'>	  	
		</cfif>	
	</cfif>	
	<cfif form.frmano gte 2024>
		<cfset TNCInicio = numberFormat((somapiini/somaptsmax)*100,999)>
		<cfif TNCInicio lte 5>
		<cfset TNCClassInicio = 'Plenamente eficaz'>
		<cfelseif TNCInicio lte 10>
		<cfset TNCClassInicio = 'Eficaz'>
		<cfelseif TNCInicio lte 30>
		<cfset TNCClassInicio = 'Eficacia mediana'>	  
		<cfelseif TNCInicio lte 50>
		<cfset TNCClassInicio = 'Pouco eficaz'>	  
		<cfelse>
		<cfset TNCClassInicio = 'Ineficaz'>	  	
		</cfif>
		<!---  --->	
		<cfset TNCAtual = numberFormat((somapiatu/somaptsmax)*100,999)>
		<cfif TNCAtual lte 5>
		<cfset TNCClassAtual = 'Plenamente eficaz'>
		<cfelseif TNCAtual lte 10>
		<cfset TNCClassAtual = 'Eficaz'>
		<cfelseif TNCAtual lte 20>
		<cfset TNCClassAtual = 'Eficacia mediana'>	  
		<cfelseif TNCAtual lte 50>
		<cfset TNCClassAtual = 'Pouco eficaz'>	  
		<cfelse>
		<cfset TNCClassAtual = 'Ineficaz'>	  	
		</cfif>	
	</cfif>	
<!--- ============================================================================= --->
<!--- FINAL OBTER PONTUACAO ATUAL DA UNIDADE E PONTUAÇÃO ATUAL MÁXIMA DA UNIDADE --->
	<cfquery name="rsNegar" datasource="#dsn_inspecao#">
		SELECT Pos_Situacao_Resp
		FROM ParecerUnidade
		WHERE Pos_Inspecao='#rsClas.RIP_NumInspecao#' AND Pos_Situacao_Resp In (0,11)
	</cfquery>
<cfif rsNegar.recordcount lte 0> 	
    <cfquery datasource="#dsn_inspecao#" name="rsExiste">
	 select TNC_Avaliacao from TNC_Classificacao
	 where TNC_Ano = '#form.frmano#' and TNC_Unidade='#rsClas.RIP_Unidade#' and TNC_Avaliacao='#rsClas.RIP_NumInspecao#'
	</cfquery>
	<cfif rsExiste.recordcount lte 0>
		<cfquery datasource="#dsn_inspecao#">
		insert into	TNC_Classificacao (TNC_Ano,TNC_Unidade,TNC_Avaliacao,TNC_dtultatu,TNC_username,TNC_QTDC,TNC_QTDN,TNC_QTDV,TNC_QTDE,TNC_QTDCN,TNC_QTDSolucao,TNC_QTDRegularizado,TNC_QTDImprocedente,TNC_QTDCancelado,TNC_VLRFALTA,TNC_VLRSOBRA,TNC_VLREMRISCO,TNC_PTSMaxUnidade,TNC_PTSUnidInicio,TNC_TNCInicio,TNC_Classifinicio,TNC_PTSUnidAtual,TNC_TNCAtual,TNC_ClassifAtual,TNC_PTSSolucao,TNC_PTSRegularizado,TNC_PTSImprocedente,TNC_PTSCancelado) values ('#Right(rsClas.RIP_NumInspecao,4)#','#rsClas.RIP_Unidade#','#rsClas.RIP_NumInspecao#',CONVERT(char, GETDATE(), 120),'#CGI.REMOTE_USER#',#totC#,#totN#,#totV#,#totE#,#totCN#,#status3#,#status25#,#status12#,#status13#,#somafalta#,#somasobra#,#somaemrisco#,#somaptsmax#,#somapiini#,#TNCInicio#,'#TNCClassInicio#',#somapiatu#,#TNCAtual#,'#TNCClassAtual#',#TNCPTSSolucao#,#TNCPTSRegularizado#,#TNCPTSImprocedente#,#TNCPTSCancelado#)
		</cfquery>
	<cfelse>	
	   <cfquery datasource="#dsn_inspecao#">
			update TNC_Classificacao set TNC_dtultatu=CONVERT(char, GETDATE())
			,TNC_username='#CGI.REMOTE_USER#'
			,TNC_QTDSolucao=#status3#
			,TNC_QTDRegularizado=#status25#
			,TNC_QTDImprocedente=#status12#
			,TNC_QTDCancelado=#status13#
			,TNC_VLRFALTA=#somafalta#
			,TNC_VLRSOBRA=#somasobra#
			,TNC_VLREMRISCO=#somaemrisco#
			,TNC_PTSMaxUnidade=#somaptsmax#
			,TNC_PTSUnidInicio=#somapiini#
			,TNC_TNCInicio=#TNCInicio#
			,TNC_Classifinicio='#TNCClassInicio#'
			,TNC_PTSUnidAtual=#somapiatu#
			,TNC_TNCAtual=#TNCAtual#
			,TNC_ClassifAtual='#TNCClassAtual#'
			,TNC_PTSSolucao=#TNCPTSSolucao#
			,TNC_PTSRegularizado=#TNCPTSRegularizado#
			,TNC_PTSImprocedente=#TNCPTSImprocedente#
			,TNC_PTSCancelado=#TNCPTSCancelado# 
			where TNC_Ano = '#form.frmano#' and TNC_Unidade='#rsClas.RIP_Unidade#' and TNC_Avaliacao='#rsClas.RIP_NumInspecao#'
	   </cfquery>	
	</cfif>
</cfif>	
<cfif isDefined("url.Ninsp") and url.Ninsp neq ''>
	<cfif not isDefined("url.Ngrup")>
		<cflocation url="#url.pagretorno#?&Unid=#url.Unid#&numInspecao=#url.Ninsp#">
	<cfelse>
		<cflocation url="#url.pagretorno#?&Unid=#Unid#&Ninsp=#Ninsp#&Ngrup=#Ngrup#&Nitem=#Nitem#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#reop#&vlrdec=#vlrdec#&situacao=#situacao#&posarea=&modal=">	
	</cfif>
</cfif>

<!--- =================================== --->	
<cfif form.se neq 'Todos'>
	<cfquery name="qAcesso" datasource="#dsn_inspecao#">
		SELECT Dir_Codigo, Dir_Sigla 
		FROM Diretoria  
		WHERE Dir_Codigo = '#trim(form.se)#'
	</cfquery>
</cfif>	
	<cfquery name="rsBusca" datasource="#dsn_inspecao#">
		SELECT TNC_Ano, TNC_Unidade, TNC_Avaliacao, TNC_QTDC, TNC_QTDN, TNC_QTDV, TNC_QTDE, TNC_QTDCN, TNC_QTDSolucao, TNC_PTSSolucao, TNC_QTDRegularizado, TNC_PTSRegularizado, TNC_QTDImprocedente, TNC_PTSImprocedente, TNC_QTDCancelado, TNC_PTSCancelado, TNC_VLRFALTA, TNC_VLRSOBRA, TNC_VLREMRISCO, TNC_PTSUnidInicio, TNC_PTSMaxUnidade, TNC_TNCInicio, TNC_ClassifInicio, TNC_PTSUnidAtual, TNC_TNCAtual, TNC_ClassifAtual, TNC_dtultatu, TNC_username, Und_CodDiretoria, Und_Descricao, Und_TipoUnidade,TUN_Descricao
		FROM TNC_Classificacao 
		INNER JOIN Unidades ON TNC_Unidade = Und_Codigo
		INNER JOIN Tipo_Unidades ON Und_TipoUnidade = TUN_Codigo
		WHERE 
		<cfif form.se neq 'Todos' or form.frmtipounid neq 'Todas' or trim(form.frmano) neq 'Todos'>
			 <cfif form.se neq 'Todos'>
				 Und_CodDiretoria = '#form.se#' and
			 </cfif>
			<cfif form.frmtipounid neq 'Todas'>
				Und_TipoUnidade= #form.frmtipounid# and
			 </cfif>			
			<cfif trim(form.frmano) neq 'Todos'>
				TNC_Ano = '#form.frmano#' and
			</cfif>
		</cfif>
		TNC_Ano is not null
		<cfif form.se eq 'Todos' and form.grupoacesso eq 'GESTORES'>
			and Und_CodDiretoria in(#form.usucoordena#)
		</cfif>
		ORDER BY Und_CodDiretoria, TUN_Descricao, Und_Descricao, TNC_Avaliacao
		</cfquery>
	</cfoutput>	 
	<cfquery name="rsXLS" datasource="#dsn_inspecao#">
		SELECT TNC_Ano, TNC_Unidade, Und_Descricao, TUN_Descricao, TNC_Avaliacao, TNC_QTDC, TNC_QTDN, TNC_QTDV, TNC_QTDE, TNC_QTDCN, TNC_QTDSolucao, TNC_PTSSolucao, TNC_QTDRegularizado, TNC_PTSRegularizado, TNC_QTDImprocedente, TNC_PTSImprocedente, TNC_QTDCancelado, TNC_PTSCancelado, convert(money, TNC_VLRFALTA,1) as TNCVLRFALTA,  convert(money, TNC_VLRSOBRA,1) as TNCVLRSOBRA, convert(money, TNC_VLREMRISCO,1) as TNCVLREMRISCO, TNC_PTSUnidInicio, TNC_PTSMaxUnidade, TNC_TNCInicio, TNC_ClassifInicio, TNC_PTSUnidAtual, TNC_TNCAtual, TNC_ClassifAtual, convert(char,TNC_dtultatu,103) as TNCdtultatu
		FROM TNC_Classificacao 
		INNER JOIN Unidades ON TNC_Unidade = Und_Codigo
		INNER JOIN Tipo_Unidades ON Und_TipoUnidade = TUN_Codigo
		WHERE 
		<cfif form.se neq 'Todos' or form.frmtipounid neq 'Todas' or trim(form.frmano) neq 'Todos'>
			 <cfif form.se neq 'Todos'>
				 Und_CodDiretoria = '#form.se#' and
			 </cfif>
			<cfif form.frmtipounid neq 'Todas'>
				Und_TipoUnidade= #form.frmtipounid# and
			 </cfif>			
			<cfif trim(form.frmano) neq 'Todos'>
				TNC_Ano = '#form.frmano#' and
			</cfif>
		</cfif>
		TNC_Ano is not null
		<cfif form.se eq 'Todos' and form.grupoacesso eq 'GESTORES'>
			and Und_CodDiretoria in(#form.usucoordena#)
		</cfif>
		ORDER BY Und_CodDiretoria, TUN_Descricao, Und_Descricao, TNC_Avaliacao
	</cfquery>
	
<cfoutput>
<cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #trim(qUsuario.Usu_Matricula)# & '.xls'>
</cfoutput>

	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>Sistema Nacional de Controle Interno</title>
	<link href="../../estilo.css" rel="stylesheet" type="text/css">
	<link href="css.css" rel="stylesheet" type="text/css">

<script language="JavaScript" type="text/JavaScript">
<cfinclude template="mm_menu.js">
function troca(a){
	document.formx.frmx_aval.value=a;
	document.formx.submit(); 
}
</script>
	</head>

<body onLoad="onsubmit="mensagem()">


<cfinclude template="cabecalho.cfm">
	    <span class="exibir"><strong>
	    </strong></span>
        <table width="72%" border="0" align="center">
          <tr valign="baseline">
            <td colspan="6" class="exibir">&nbsp;</td>
          </tr>
          <tr valign="baseline">
            <td colspan="6" class="exibir"><div align="center"><span class="titulo2"><strong class="titulo1">CLASSIFICAÇÃO DAS UNIDADES</strong><span class="titulo1"></span></span></div></td>
          </tr>
          <tr valign="baseline">
            <td colspan="6">&nbsp;</td>
          </tr>
 <cfoutput>	  
	  
            <tr valign="baseline">
              <td width="14%"><div align="right"><span class="titulos">Superintendência:</span></div></td>
              <td width="17%"><div align="left">
                <select name="dr" id="dr" class="form" disabled>
				
				 <cfif form.se eq 'Todos'>
				 	<option value="Todos" selected="selected">Todos</option>
				 <cfelse>
                  <option selected="selected" value="#qAcesso.Dir_Codigo#">#qAcesso.Dir_Sigla#</option>
				 </cfif> 
                </select>
              </div></td>
              <td width="21%"><div align="right"><span class="titulos">Tipo de Unidade  :</span></div></td>
              <td width="25%"><div align="left">
			     <select name="frmtipounid" id="frmtipounid" class="form" disabled>
				 <cfif form.frmtipounid eq 'Todas'>
				 	<option value="Todas" selected="selected">Todas</option>
				 <cfelse>
					<option selected="selected" value="#rsBusca.Und_TipoUnidade#">#rsBusca.TUN_Descricao#</option>
				 </cfif>
                </select>
              </div></td>
              <td width="6%"><div align="right"><span class="titulos">Exercício:</span></div></td>
              <td width="17%"><div align="left">
                <select name="frmano" id="frmano" class="form"" disabled>
                  <option value="#frmano#">#frmano#</option>
                </select>
              </div></td>
            </tr>
          </cfoutput>
        </table>
<form action="Pacin_o.cfm" method="post" target="_parent" name="form1">  
	  <table width="2200" border="0" align="center">
        <tr bgcolor="f7f7f7">
          <td colspan="35" align="center" bgcolor="f7f7f7">
		  <cfif form.grupoacesso is 'GESTORMASTER'>
		  <div align="left"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/excel.jpg" width="50" height="35" border="0"></a></div>
		  </cfif>		  </td>
        </tr>
		
		<tr bgcolor="f7f7f7">
			<td colspan="35" align="center" bgcolor="#B4B4B4" class="titulo1">LISTAS DAS UNIDADES  classificadas nO EXERCÍCIO DE: <cfoutput>#form.frmano#</cfoutput></td>
		</tr>
        <tr class="titulosClaro">
          <td colspan="41" bgcolor="eeeeee" class="exibir"><cfoutput>Qtd. #rsBusca.recordcount#</cfoutput></td>
        </tr>
          <tr bgcolor="#CCCCCC" class="titulos">
            <td width="3%" align="center">+Dados</td>
            <td width="3%" align="center">Código</td>
            <td width="11%"><div align="left">Descrição</div></td>
            <td width="5%"><div align="left">Tipo</div></td>
            <td width="3%">Avaliação</td>
            <td width="2%"><div align="center">Qtd.C</div></td>
            <td width="2%"><div align="center">Qtd.N</div></td>
            <td width="2%"><div align="center">Qtd.V</div></td>
            <td width="2%"><div align="center">Qtd.E</div></td>
            <td width="3%"><div align="center">Qtd.<br>
            (N+C)</div></td>
            <td width="3%"><div align="center">Qtd. <br>
              (3-SO)</div></td>
            <td width="3%"><div align="center">Pts.<br>
              (3-SO)</div></td>
            <td width="3%"><div align="center">Qtd.<br>
              (25-RC)</div></td>
            <td width="3%"><div align="center">Pts.<br>
              (25-RC)</div></td>
            <td width="3%"><div align="center">Qtd.<br>
              (12-PI)</div></td>
            <td width="3%"><div align="center">Pts.<br>
              (12-PI)</div></td>
            <td width="3%"><div align="center">Qtd.<br>
              (13-OC)</div></td>
            <td width="3%"><div align="center">Pts.<br>
              (13-OC)</div></td>
            <td width="5%"><div align="center">Falta(R$)</div></td>
            <td width="4%"><div align="center">Sobra(R$)</div></td>
			<td width="5%"><div align="center">EmRisco(R$)</div></td>
            <td width="4%"><div align="center">Pts.Max Unidade<br></div></td>
            <td width="4%"><div align="center">Pts.Item<br>(Inicial)</div></td>
            <td width="3%"><div align="center">TNC<br>
            (Inicial)</div></td>
            <td width="7%">Classif(Inicial)</td>
            <td width="3%"><div align="center">Pts.Item<br>
            (Atual)</div></td>
            <td width="3%"><div align="center">TNC<br>
            (Atual)</div></td>
            <td width="10%">Classif(Atual)</td>
          </tr>
      <cfoutput query="rsBusca">
			<cfset scor = 'f7f7f7'>		
  			<cfset ano = rsBusca.TNC_Ano>
			<cfset UndCod = TNC_Unidade>
			<cfset UndDesc = Und_Descricao>
			<cfset TUNDesc = TUN_Descricao>
			<cfset Numaval = TNC_Avaliacao>
			<cfset qtdc = TNC_QTDC>		
			<cfset qtdn = TNC_QTDN>
			<cfset qtdv = TNC_QTDV>
			<cfset qtde = TNC_QTDE>
			<cfset qtdcn = TNC_QTDCN>	
			<cfset qtd3so = TNC_QTDSolucao>	
			<cfset pts3so = TNC_PTSSolucao>	
			<cfset qtd25rc = TNC_QTDRegularizado>	
			<cfset pts25rc = TNC_PTSRegularizado>	
			<cfset qtd12pi = TNC_QTDImprocedente>	
			<cfset pts12pi = TNC_PTSImprocedente>	
			<cfset qtd13oc = TNC_QTDCancelado>	
			<cfset pts13oc = TNC_PTSCancelado>	
			<cfset falta = lscurrencyformat(TNC_VLRFALTA)>	
			<cfset sobra = lscurrencyformat(TNC_VLRSOBRA)>
			<cfset emrisco = lscurrencyformat(TNC_VLREMRISCO)>			

			<cfset piini = TNC_PTSUnidInicio>	
			<cfset pmini = TNC_PTSMaxUnidade>	
			<cfset tncini = numberFormat(TNC_TNCInicio,999)>
			<cfset classini = TNC_ClassifInicio>	
			<cfset piatu = TNC_PTSUnidAtual>	
			<cfset tncatu = numberFormat(TNC_TNCAtual,999)>
			<cfset classatu = TNC_ClassifAtual>			
						
          <tr bgcolor="#scor#" class="exibir">
            <td><div align="center">
              <button name="submitAlt" type="button" class="botao" onClick="troca('#Numaval#');">+Detalhes</button>
            </div></td>
            <td>#UndCod#</td>
            <td width="11%">#UndDesc#</td>
            <td width="5%">#TUNDesc#</td>
            <td width="3%"><div align="center">#Numaval#</div></td>
            <td width="2%"><div align="center">#qtdc#</div></td>
            <td width="2%"><div align="center">#qtdn#</div></td>
            <td width="2%"><div align="center">#qtdv#</div></td>
            <td width="2%"><div align="center">#qtde#</div></td>
            <td width="3%"><div align="center">#qtdcn#</div></td>
            <td width="3%"><div align="center">#qtd3so#</div></td>
            <td width="3%"><div align="center">#pts3so#</div></td>
            <td width="3%"><div align="center">#qtd25rc#</div></td>
            <td width="3%"><div align="center">#pts25rc#</div></td>
            <td width="3%"><div align="center">#qtd12pi#</div></td>
            <td width="3%"><div align="center">#pts12pi#</div></td>
            <td width="3%"><div align="center">#qtd13oc#</div></td>
            <td width="3%"><div align="center">#pts13oc#</div></td>
            <td width="5%"><div align="center">#falta#</div></td>
            <td width="4%"><div align="center">#sobra#</div></td>
			<td width="4%"><div align="center">#emrisco#</div></td>
			<cfset auxcol = replace(pmini,'.',',')>
            <td width="4%"><div align="center">#auxcol#</div></td>
			<cfset auxcol = replace(piini,'.',',')>
            <td width="4%"><div align="center">#auxcol#</div></td>
            <td width="3%"><div align="center">#tncini#</div></td>
            <td width="7%"><div align="left">#classini#</div></td>
			<cfset auxcol = replace(piatu,'.',',')>
            <td><div align="center">#auxcol#</div></td>
            <td width="3%"><div align="center">#tncatu#</div></td>
            <td width="12%"><div align="left">#classatu#</div></td>
          </tr>

		  <cfif scor eq 'f7f7f7'>
		    <cfset scor = 'CCCCCC'>
		  <cfelse>
		    <cfset scor = 'f7f7f7'>
		  </cfif>
      </cfoutput>
        <tr bgcolor="f7f7f7">
          <td colspan="35" align="center" class="titulos"><hr></td>
        </tr>
        <tr>
          <td colspan="28">
              <div align="center">
			  <input name="Submit1" type="button" class="form" id="Submit1" value="Fechar" onClick="window.close()">
          </div>
             <div align="right"></div></td>
        </tr>
        <tr>
          <td colspan="35" align="center" class="titulos"><hr></td>
        </tr>
<!--- inicio exclusão --->
<!--- Excluir arquivos anteriores ao dia atual --->
<cfset sdata = dateformat(now(),"YYYYMMDDHH")>
<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
<cfset slocal = #diretorio# & 'Fechamento\'>
<cfdirectory name="qList" filter="*.*" sort="name desc" directory="#slocal#">
  	<cfoutput query="qList">
		   <cfif len(name) eq 23>
				<cfif (left(name,8) lt left(sdata,8)) or (int(mid(sdata,9,2) - mid(name,9,2)) gte 2)>
				    <cffile action="delete" file="#slocal##name#"> 
				</cfif>
		  </cfif>
	</cfoutput>
<!--- fim exclusão --->

<cftry>

<cfif Month(Now()) eq 1>
  <cfset vANO = Year(Now()) - 1>
<cfelse>
  <cfset vANO = Year(Now())>
</cfif>

<cfset objPOI = CreateObject(
    "component",
    "Excel"
    ).Init()
    />

<cfset data = now() - 1>
	 <cfset objPOI.WriteSingleExcel(
    FilePath = ExpandPath( "./Fechamento/" & sarquivo ),
    Query = rsXLS,
	ColumnList = 
"TNC_Ano,TNC_Unidade,Und_Descricao,TUN_Descricao,TNC_Avaliacao,TNC_QTDC,TNC_QTDN,TNC_QTDV,TNC_QTDE,TNC_QTDCN,TNC_QTDSolucao,TNC_PTSSolucao,TNC_QTDRegularizado,TNC_PTSRegularizado,TNC_QTDImprocedente,TNC_PTSImprocedente,TNC_QTDCancelado,TNC_PTSCancelado,TNCVLRFALTA,TNCVLRSOBRA,TNCVLREMRISCO,TNC_PTSMaxUnidade,TNC_PTSUnidInicio,TNC_TNCInicio,TNC_ClassifInicio,TNC_PTSUnidAtual,TNC_TNCAtual,TNC_ClassifAtual,TNCdtultatu",
	ColumnNames = "Ano,Código,Descrição,Tipo,Avaliação,Qtd.C,Qtd.N,Qtd.V,Qtd.E,Qtd.(C+N),Qtd.(3-SO),Pts.(3-SO),Qtd.(25-RC),Pts.(25-RC),Qtd.(12-PI),Pts.(12-PI),Qtd.(13-OC),Pts.(13-OC),Falta(R$),Sobra(R$),Em Risco(R$),Pts.MaxUnidade,Pts.Item(Inicial),TNC(Inicial),Classif(Inicial),Pts.Item(Atual),TNC(Atual),Classif(Atual),DT.Atualiz",
	SheetName = "CLASSIFICAÇÕES DAS UNIDADES"
    ) />

<cfcatch type="any">
	<cfdump var="#cfcatch#">
</cfcatch>
</cftry>
<!--- =========================================== --->
<!--- Fim gerar planilha ---> 	
	  <!--- FIM DA ÁREA DE CONTEÚDO --->
 </table>
</form>	
<form name="formx" method="POST" target="_blank" action="Pacin_ClassificacaoUnidades1.cfm">
  <input name="frmx_aval" type="hidden" id="frmx_aval" value="">
</form>
  <!--- Término da área de conteúdo --->
</body>
</html>

