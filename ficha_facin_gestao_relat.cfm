<cfoutput>
    <!--- <cfdump var="#form#"> <cfdump var="#session#"> --->
    <!---  <cfdump var="#url#">  --->
</cfoutput>
<!--- inicio atualização --->
<cfprocessingdirective pageEncoding ="utf-8">  
<cfquery datasource="#dsn_inspecao#" name="rsfacinaval">
    SELECT FAC_Qtd_Geral,FAC_Meta1_Peso_Item, FAC_Meta2_Peso_Item,FACA_Unidade, FACA_Avaliacao, FACA_Matricula, FACA_Avaliador, FACA_Grupo, FACA_Item, FACA_Meta1_AT_OrtoGram, FACA_Meta1_AT_CCCP, FACA_Meta1_AE_Tecn, FACA_Meta1_AE_Prob, FACA_Meta1_AE_Valor, FACA_Meta1_AE_Cosq, FACA_Meta1_AE_Norma, FACA_Meta1_AE_Docu, FACA_Meta1_AE_Class, FACA_Meta1_AE_Orient, FACA_Meta1_Pontos, FACA_Meta2_AR_Falta, FACA_Meta2_AR_Troca, FACA_Meta2_AR_Nomen, FACA_Meta2_AR_Ordem, FACA_Meta2_AR_Prazo, FACA_Meta2_Pontos
    FROM UN_Ficha_Facin 
    INNER JOIN UN_Ficha_Facin_Avaliador ON (FAC_Matricula = FACA_Matricula) AND (FAC_Avaliacao = FACA_Avaliacao) AND (FAC_Unidade = FACA_Unidade)
    WHERE FACA_Avaliacao='#URL.ninsp#'
</cfquery>

<cfset PesoAvaliacao = 0>
<cfset descontometa1 = 0>
<cfset descontometa2 = 0>
<cfset PesoAvaliacao = numberFormat((100/rsfacinaval.FAC_Qtd_Geral),'___.00')>
<cfset descontometa1 = numberFormat((100/rsfacinaval.FAC_Qtd_Geral)/10,'___.000')>
<cfset descontometa2 = numberFormat((100/rsfacinaval.FAC_Qtd_Geral)/5,'___.000')>
<cfset somageralmeta1 = 0>
<cfset somageralmeta2 = 0>
<cfset FACPontosRevisaoMeta1 = 0>
<cfset FACPercRevisaoMeta1 = 0>
<cfset FACPontosRevisaoMeta2 = 0>
<cfset FACPercRevisaoMeta2 = 0>

<cfoutput query="rsfacinaval">
    <cfset FACMeta1PesoItem = 0>
    <cfset FACMeta2PesoItem = 0>
    <cfset somameta1 = 0>
    <cfset somameta2 = 0>

    <cfset somameta1 = FACA_Meta1_AT_OrtoGram + FACA_Meta1_AT_CCCP + FACA_Meta1_AE_Tecn + FACA_Meta1_AE_Prob + FACA_Meta1_AE_Valor + FACA_Meta1_AE_Cosq + FACA_Meta1_AE_Norma + FACA_Meta1_AE_Docu + FACA_Meta1_AE_Class + FACA_Meta1_AE_Orient>
    <cfif somameta1 lte 0>
        <cfset FACMeta1PesoItem = PesoAvaliacao>
    <cfelse>
        <cfset FACMeta1PesoItem = numberFormat((descontometa1*10) - (somameta1*descontometa1),'___.00')>
    </cfif>
    <cfset somageralmeta1 = somageralmeta1 + somameta1>

    <cfset somameta2 = FACA_Meta2_AR_Falta + FACA_Meta2_AR_Troca + FACA_Meta2_AR_Nomen + FACA_Meta2_AR_Ordem + FACA_Meta2_AR_Prazo>
    <cfif somameta2 lte 0>
        <cfset FACMeta2PesoItem = PesoAvaliacao>
    <cfelse>
        <cfset FACMeta2PesoItem = numberFormat((descontometa2*5) - (somameta2*descontometa2),'___.00')>
    </cfif>
    <cfset somageralmeta2 = somageralmeta2 + somameta2>
    <cfquery datasource="#dsn_inspecao#">
        update UN_Ficha_Facin_Avaliador set FACA_Meta1_Pontos=#FACMeta1PesoItem#,FACA_Meta2_Pontos=#FACMeta2PesoItem#
        WHERE FACA_Avaliacao='#URL.ninsp#' and FACA_Grupo=#FACA_Grupo# and FACA_Item=#FACA_Item#
    </cfquery>
</cfoutput>

<cfoutput>
    <cfset FACPontosRevisaoMeta1 = numberFormat(rsfacinaval.FAC_Qtd_Geral - (somageralmeta1*descontometa1),'___.00')>
    <cfset FACPercRevisaoMeta1 = numberFormat((FACPontosRevisaoMeta1/rsfacinaval.FAC_Qtd_Geral)*100,'___.00')>

    <cfset FACPontosRevisaoMeta2 = numberFormat(rsfacinaval.FAC_Qtd_Geral - (somageralmeta2*descontometa2),'___.00')>
    <cfset FACPercRevisaoMeta2 = numberFormat((FACPontosRevisaoMeta2/rsfacinaval.FAC_Qtd_Geral)*100,'___.00')>

    <cfquery datasource="#dsn_inspecao#">
        UPDATE UN_Ficha_Facin SET FAC_Pontos_Revisao_Meta1=#FACPontosRevisaoMeta1#, 
        FAC_Perc_Revisao_Meta1 = #FACPercRevisaoMeta1#, 
        FAC_Pontos_Revisao_Meta2=#FACPontosRevisaoMeta2#,
        FAC_Perc_Revisao_Meta2 = #FACPercRevisaoMeta2#
        WHERE FAC_Avaliacao= '#url.ninsp#'
    </cfquery>

</cfoutput>

<!--- Fnal atualização --->

<cfoutput>
    <cfquery name="rsFacin" datasource="#dsn_inspecao#">
        SELECT 
            RIP_Unidade, RIP_NumInspecao, RIP_NumGrupo, RIP_NumItem, FACA_Consideracao, FACA_Consideracao_Inspetor,RIP_DtUltAtu,RIP_Data_Avaliador,RIP_Recomendacao_Inspetor, RIP_Data_Avaliador, RIP_DtUltAtu_Revisor, Dir_Codigo, INP_DtInicInspecao, INP_DTConcluirRevisao,INP_RevisorDTInic, INP_Modalidade, INP_Coordenador, INP_Responsavel, Und_Descricao, Usu_Apelido, Usu_LotacaoNome, Usu_DR,Fun_Nome,FACA_Meta1_AT_OrtoGram, FACA_Meta1_AT_CCCP, FACA_Meta1_AE_Tecn, FACA_Meta1_AE_Prob, FACA_Meta1_AE_Valor, FACA_Meta1_AE_Cosq, FACA_Meta1_AE_Norma, FACA_Meta1_AE_Docu, FACA_Meta1_AE_Class, FACA_Meta1_AE_Orient, FACA_Meta1_Pontos, FACA_Meta2_AR_Falta, FACA_Meta2_AR_Troca, FACA_Meta2_AR_Nomen, FACA_Meta2_AR_Ordem, FACA_Meta2_AR_Prazo, FACA_Meta2_Pontos,Grp_Descricao,Itn_Descricao
            FROM Itens_Verificacao INNER JOIN (((((((Inspecao 
            INNER JOIN Usuarios ON INP_RevisorLogin = Usu_Login) 
            INNER JOIN Unidades ON INP_Unidade = Und_Codigo) 
            INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade)) 
            INNER JOIN UN_Ficha_Facin_Avaliador ON (RIP_NumItem = FACA_Item) AND (RIP_NumGrupo = FACA_Grupo) AND (RIP_NumInspecao = FACA_Avaliacao) AND (RIP_Unidade = FACA_Unidade)) 
            INNER JOIN Diretoria ON Usu_DR = Dir_Codigo) 
            INNER JOIN Funcionarios ON FACA_Avaliador = Fun_Matric) 
            INNER JOIN Grupos_Verificacao ON FACA_Grupo = Grp_Codigo) ON (FACA_Item = Itn_NumItem) AND (INP_Modalidade = Itn_Modalidade) AND (Und_TipoUnidade = Itn_TipoUnidade) and (convert(char(4),RIP_Ano) = Grp_Ano) AND (Itn_Ano = Grp_Ano) AND (Itn_NumGrupo = Grp_Codigo)
            WHERE RIP_NumInspecao='#URL.ninsp#' and FACA_Avaliador = '#url.matr#'
            order by RIP_NumGrupo, RIP_NumItem
    </cfquery>
<!---
 <cfquery name="rsFacin" datasource="#dsn_inspecao#">
    SELECT 
        RIP_Unidade, RIP_NumInspecao, RIP_NumGrupo, RIP_NumItem, FACA_Consideracao, FACA_Consideracao_Inspetor,RIP_DtUltAtu,RIP_Data_Avaliador,RIP_Recomendacao_Inspetor,
        RIP_Data_Avaliador, RIP_DtUltAtu_Revisor, Dir_Codigo, INP_DtInicInspecao, INP_DTConcluirRevisao,INP_RevisorDTInic, 
        INP_Modalidade, INP_Coordenador, INP_Responsavel, Und_Descricao, Usu_Apelido, Usu_LotacaoNome, Usu_DR,Fun_Nome,FACA_Meta1_AT_OrtoGram, FACA_Meta1_AT_CCCP, FACA_Meta1_AE_Tecn, FACA_Meta1_AE_Prob, FACA_Meta1_AE_Valor, FACA_Meta1_AE_Cosq, FACA_Meta1_AE_Norma, FACA_Meta1_AE_Docu, FACA_Meta1_AE_Class, FACA_Meta1_AE_Orient, FACA_Meta1_Pontos, FACA_Meta2_AR_Falta, FACA_Meta2_AR_Troca, FACA_Meta2_AR_Nomen, FACA_Meta2_AR_Ordem, FACA_Meta2_AR_Prazo, FACA_Meta2_Pontos
        FROM ((((Inspecao INNER JOIN Usuarios ON INP_RevisorLogin = Usu_Login) 
        INNER JOIN Unidades ON INP_Unidade = Und_Codigo) 
        INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade)) 
        INNER JOIN UN_Ficha_Facin_Avaliador ON (RIP_NumItem = FACA_Item) AND (RIP_NumGrupo = FACA_Grupo) AND (RIP_NumInspecao = FACA_Avaliacao) AND (RIP_Unidade = FACA_Unidade)) 
        INNER JOIN Diretoria ON Usu_DR = Dir_Codigo
        INNER JOIN Funcionarios ON FACA_Avaliador = Fun_Matric
        WHERE RIP_NumInspecao='#URL.ninsp#' and FACA_Avaliador = '#url.matr#'
        order by RIP_NumGrupo, RIP_NumItem
</cfquery>
--->
<cfquery name="rsPrimAval" dbtype = "query">
    SELECT RIP_Data_Avaliador 
    FROM rsFacin
    order by RIP_Data_Avaliador
</cfquery>

<cfquery name="rsUlttraninsp" dbtype = "query">
    SELECT RIP_Data_Avaliador 
    FROM rsFacin
    order by RIP_Data_Avaliador desc
</cfquery>

<cfquery name="rsUltReanaliseRevisor" dbtype = "query">
    SELECT RIP_DtUltAtu_Revisor 
    FROM rsFacin
    order by RIP_DtUltAtu_Revisor desc
</cfquery>

<cfquery datasource="#dsn_inspecao#" name="rsFacinInd">
    SELECT FFI_Meta1_Qtd_Item, FFI_Meta1_Pontuacao_Inicial, FFI_Meta1_Pontuacao_Obtida, FFI_Meta1_Resultado, FFI_Meta2_Qtd_Item, FFI_Meta2_Pontuacao_Inicial, FFI_Meta2_Pontuacao_Obtida, FFI_Meta2_Resultado
    FROM UN_Ficha_Facin_Individual
    WHERE FFI_Avaliacao='#URL.ninsp#' AND FFI_Avaliador='#url.matr#' 
</cfquery>

<cfquery name="rsRevisor" datasource="#dsn_inspecao#">
    SELECT Dir_Sigla 
    FROM Diretoria 
    where '#rsFacin.Usu_DR#' = Dir_Codigo
</cfquery>
    
<cfquery name="qInspetor" datasource="#dsn_inspecao#">
    SELECT IPT_MatricInspetor, Fun_Nome, Usu_LotacaoNome,Dir_Sigla,INP_HrsPreInspecao, INP_DtInicDeslocamento, INP_DtFimDeslocamento, INP_HrsDeslocamento, INP_DtInicInspecao, INP_DtFimInspecao, INP_HrsInspecao, INP_DtEncerramento, INP_DTConcluirAvaliacao
    FROM Inspetor_Inspecao 
    INNER JOIN Inspecao ON (IPT_NumInspecao=INP_NumInspecao) AND (IPT_CodUnidade=INP_Unidade)
    INNER JOIN Funcionarios ON IPT_MatricInspetor = Fun_Matric AND IPT_MatricInspetor = Fun_Matric 
    INNER JOIN Usuarios ON Fun_Matric = Usu_Matricula
    INNER JOIN Diretoria ON Fun_DR = Dir_Codigo
    WHERE IPT_NumInspecao = '#URL.Ninsp#'
</cfquery>

<cfquery name="rsfac" datasource="#dsn_inspecao#">
    SELECT FAC_Unidade, FAC_Avaliacao, FAC_Matricula, FAC_Ano, FAC_Revisor, FAC_Data_SEI, FAC_Qtd_Geral, FAC_Qtd_NC, FAC_Qtd_Devolvido, FAC_Pontos_Revisao_Meta1, FAC_Perc_Revisao_Meta1, FAC_Meta1_Peso_Item, FAC_Pontos_Revisao_Meta2, FAC_Perc_Revisao_Meta2, FAC_Meta2_Peso_Item, FAC_Data_Plan_Meta3, FAC_DifDia_Meta3, FAC_Perc_Meta3, FAC_Consideracao, FAC_Data_Assinar, FAC_DtCriar, FAC_DtAlter, FAC_DtConcluirFacin
    FROM UN_Ficha_Facin
    WHERE FAC_Avaliacao='#URL.ninsp#'
</cfquery>

<cfquery datasource="#dsn_inspecao#" name="rsResultGeral">
    SELECT RIP_Resposta, RIP_Recomendacao_Inspetor, RIP_DtUltAtu, RIP_Correcao_Revisor
    FROM Resultado_Inspecao
    WHERE RIP_NumInspecao='#url.ninsp#'
</cfquery>
<cfquery name="rsReanalise" dbtype = "query">
    SELECT RIP_DtUltAtu 
    FROM rsResultGeral
    WHERE (RIP_Recomendacao_Inspetor is not null) 
</cfquery>
<cfset percreanalise = numberFormat(0,'___.00')>
<cfset comreanalise = 'Não'>
<cfif rsReanalise.recordcount gt 0>
    <cfset comreanalise = 'Sim'>
    <cfset percreanalise = (rsReanalise.recordcount / rsfac.FAC_Qtd_Geral) * 100>
    <cfset percreanalise = numberFormat(percreanalise,'___.00')>
</cfif>
<cfquery name="rsUltreanalise" dbtype = "query">
    SELECT RIP_DtUltAtu 
    FROM rsReanalise
    order by RIP_DtUltAtu desc
</cfquery>  
<cfquery name="rsOrtog" dbtype = "query">
    SELECT RIP_DtUltAtu 
    FROM rsResultGeral
    WHERE RIP_Recomendacao_Inspetor is null and RIP_Correcao_Revisor = '1'
</cfquery>
<cfquery name="rsC" dbtype = "query">
    SELECT RIP_Resposta 
    FROM rsResultGeral
    WHERE RIP_Resposta = 'C'
</cfquery>
<cfset totalC = rsC.recordcount>
<cfquery name="rsN" dbtype = "query">
    SELECT RIP_Resposta 
    FROM rsResultGeral
    WHERE RIP_Resposta = 'N'
</cfquery>
<cfset totalN = rsN.recordcount>
<cfquery name="rsE" dbtype = "query">
    SELECT RIP_Resposta 
    FROM rsResultGeral
    WHERE RIP_Resposta = 'E'
</cfquery>
<cfset totalE = rsE.recordcount>
<cfquery name="rsV" dbtype = "query">
    SELECT RIP_Resposta 
    FROM rsResultGeral
    WHERE RIP_Resposta = 'V'
</cfquery>
<cfset totalV = rsV.recordcount>
</cfoutput>
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="public/bootstrap/bootstrap.min.css">
</head>

<body style="background:#fff"> 
<cfoutput>
 <cfinclude template="cabecalho.cfm">
<table width="75%"  align="left" class="table table-bordered">
  <tr>
    <td height="20" colspan="13"><div align="center"><strong class="titulo2">Avaliar Resultados Geral - (FACIN)</strong></div></td>
  </tr>
  <cfif rsFacin.INP_Modalidade is 0>
    <cfset INPModalidade = 'PRESENCIAL'>
<cfelseif rsFacin.INP_Modalidade is 1>
    <cfset INPModalidade = 'A DISTÂNCIA'>
<cfelse>
    <cfset INPModalidade = 'MISTA'>
</cfif>	

	
	<tr>
      <td width="95" class="exibir">Unidade</td>
      <td colspan="2"><strong class="exibir">#rsFacin.Und_Descricao#</strong></td>
      <td colspan="11"><strong class="exibir">Gerente unidade:&nbsp;#rsFacin.INP_Responsavel#</strong></td>
    </tr>
    <tr>
        <td width="95" class="exibir">Nº Relatório</td>
        <td><strong class="exibir">#URL.Ninsp#</strong></td>
        <td colspan="1"><strong class="exibir">Modalidade</strong></td>
        <td colspan="1"><strong class="exibir">Qtd. Ponto</strong></td>
        <td colspan="1"><strong class="exibir">Qtd. com Reanálise</strong></td>
        <td colspan="1"><strong class="exibir">Perc. com Reanálise</strong></td>
        <td colspan="1"><strong class="exibir">Qtd. com correção texto</strong></td>
        <td colspan="1"><strong class="exibir">Conforme</strong></td>
        <td colspan="1"><strong class="exibir">Não Conforme</strong></td>
        <td colspan="1"><strong class="exibir">Não Executa</strong></td>
        <td colspan="1"><strong class="exibir">Não Verificado</strong></td>
        <td colspan="1"><strong class="exibir">Perc. Meta1</strong></td>
        <td colspan="1"><strong class="exibir">Perc. Meta2</strong></td>
    </tr> 
    
    <tr>
        <td colspan="2" class="exibir"></td>
        <td colspan="1"><strong class="exibir">#INPModalidade#</strong></td>
        <td colspan="1"><strong class="exibir">#rsfac.FAC_Qtd_Geral#</strong></td>
        <td colspan="1"><strong class="exibir">#rsReanalise.recordcount#</strong></td>
        <td colspan="1"><strong class="exibir">#percreanalise#%</strong></td>
        <td colspan="1"><strong class="exibir">#rsOrtog.recordcount#</strong></td>
        <td colspan="1"><strong class="exibir">#totalC#</strong></td>
        <td colspan="1"><strong class="exibir">#totalN#</strong></td>
        <td colspan="1"><strong class="exibir">#totalE#</strong></td>
        <td colspan="1"><strong class="exibir">#totalV#</strong></td>
        <td colspan="1"><strong class="exibir">#numberFormat(rsfac.FAC_Perc_Revisao_Meta1,'___.00')#%</strong></td>
        <td colspan="1"><strong class="exibir">#numberFormat(rsfac.FAC_Perc_Revisao_Meta2,'___.00')#%</strong></td>
    </tr> 
    <tr class="exibir"><td colspan="13"><hr></td></tr>     
    <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>   
    <cfset col = 'Inspetores'>
    <cfloop query="qInspetor">
        <tr class="exibir">
            <td width="139" class="exibir">#col#</td>
            <td colspan="12">
                <cfif trim(rsFacin.INP_Coordenador) eq trim(qInspetor.IPT_MatricInspetor)>
                    <strong class="exibir">#qInspetor.Fun_Nome#</strong><strong>#qInspetor.Usu_LotacaoNome# - (SE-#trim(qInspetor.Dir_Sigla)#) - Coordenador(a)</strong>
                <cfelse>
                    <strong class="exibir">#qInspetor.Fun_Nome# - #qInspetor.Usu_LotacaoNome# - (SE-#trim(qInspetor.Dir_Sigla)#)</strong>
                </cfif>
            </td>
        </tr>
        <cfset col = ''>
    </cfloop>
    <tr class="exibir" colspan="13">
        <td class="exibir">#col#</td>
        <td>
            <strong class="exibir">Pré-Inspeção</strong>
        </td>
        <td>
            <strong class="exibir">Início Desloc.</strong>
        </td>
        <td>
            <strong class="exibir">Fim Desloc.</strong>
        </td>
        <td>
            <strong class="exibir">Horas Desloc.</strong>
        </td>
        <td>
            <strong class="exibir">Início Avaliação</strong>
        </td>
        <td>
            <strong class="exibir">Fim Avaliação</strong>
        </td>
        <td>
            <strong class="exibir">Horas Avaliação</strong>
        </td>
        <td>
            <strong class="exibir">Início Avaliação</strong>
        </td>
        <td>
            <strong class="exibir">Última Avaliação</strong>
        </td>
        <td>
            <strong class="exibir">Conclusão Avaliação</strong>
        </td>
        <td>
            <strong class="exibir">Houve Reanálise?</strong>
        </td>
        <td>
            <strong class="exibir">Última Reanálise</strong>
        </td>
    </tr>
    <tr class="exibir"  colspan="13">
        <td width="139" class="exibir">#col#</td>
        <td>
            <strong class="exibir">#qInspetor.INP_HrsPreInspecao# horas</strong>
        </td>
        <td>
            <strong class="exibir">#dateformat(qInspetor.INP_DtInicDeslocamento,"dd-mm-yyyy")#</strong>
        </td>
        <td>
            <strong class="exibir">#dateformat(qInspetor.INP_DtFimDeslocamento,"dd-mm-yyyy")#</strong>
        </td>
        <td>
            <strong class="exibir">#qInspetor.INP_HrsDeslocamento#</strong>
        </td>
        <td>
            <strong class="exibir">#dateformat(qInspetor.INP_DtInicInspecao,"dd-mm-yyyy")#</strong>
        </td>
        <td>
            <strong class="exibir">#dateformat(qInspetor.INP_DtFimInspecao,"dd-mm-yyyy")#</strong>
        </td>  
        <td>
            <strong class="exibir">#qInspetor.INP_HrsInspecao#</strong>
        </td>
        <td>
            <strong class="exibir">#DateTimeFormat(rsPrimAval.RIP_Data_Avaliador,"dd-mm-yyyy HH:NN:SS")#</strong>
        </td>
        <td>
            <strong class="exibir">#DateTimeFormat(rsUlttraninsp.RIP_Data_Avaliador,"dd-mm-yyyy HH:NN:SS")#</strong>
        </td>  
        <td>
            <strong class="exibir">#dateformat(qInspetor.INP_DTConcluirAvaliacao,"dd-mm-yyyy")#</strong>
        </td>  
        <td>
            <strong class="exibir">#comreanalise#</strong>
        </td>  
        <td>
            <strong class="exibir">#DateTimeFormat(rsUltreanalise.RIP_DtUltAtu,"dd-mm-yyyy HH:NN:SS")#</strong>
        </td> 
                      
    </tr>
    
    <tr class="exibir"><td colspan="13"><hr></td></tr> 
    <cfset dt02dduteis = CreateDate(year(rsFacin.INP_RevisorDTInic),month(rsFacin.INP_RevisorDTInic),day(rsFacin.INP_RevisorDTInic))>
	<cfset nCont = 1>
	<cfloop condition="nCont lte 2">
		<cfset dt02dduteis = DateAdd( "d", 1, dt02dduteis)>
		<cfset vDiaSem = DayOfWeek(dt02dduteis)>
		<cfif vDiaSem neq 1 and vDiaSem neq 7>
			<!--- verificar se Feriado Nacional --->
			<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
				 SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dt02dduteis#
			</cfquery>
			<cfif rsFeriado.recordcount gt 0>
			   <cfset nCont = nCont - 1>
			</cfif>
		</cfif>
		<!--- Verifica se final de semana  --->
		<cfif vDiaSem eq 1 or vDiaSem eq 7>
			<cfset nCont = nCont - 1>
		</cfif>	
		<cfset nCont = nCont + 1>
	</cfloop>
    <cfset dthhprevrevisor = DateFormat(dt02dduteis,"dd-mm-yyyy") & ' ' & DateTimeFormat(rsFacin.INP_RevisorDTInic,"HH:NN:SS")>
    <cfif comreanalise eq 'Sim'>
        <!--- <cfset dthhprevrevisor = DateFormat(dt02dduteis,"dd-mm-yyyy") & ' ' & DateTimeFormat(rsUltReanaliseRevisor.RIP_DtUltAtu_Revisor,"HH:NN:SS")> --->
    </cfif>

    <tr>
        <td width="95" class="exibir">Revisor(a)</td>
        <td colspan="5"><strong class="exibir">#rsFacin.Usu_Apelido# - #rsFacin.Usu_LotacaoNome# - (SE-#trim(rsRevisor.Dir_Sigla)#)</strong></td>
        <td colspan="1"><strong class="exibir"><strong class="exibir">Início Revisão</strong></td>
        <td colspan="1"><strong class="exibir"><strong class="exibir">Previsão Conclusão</td>
        <td colspan="1"><strong class="exibir"><strong class="exibir">Última Reanálise:&nbsp;</strong></td>
        <td colspan="1"><strong class="exibir">Conclusão Revisão</td>
        <td colspan="1"><strong class="exibir">Início FACIN</td>
        <td colspan="3"><strong class="exibir">Final FACIN</strong></td>
    </tr>  
    <tr>
        <td colspan="6" class="exibir"></td>
        <td colspan="1"><strong class="exibir"><strong class="exibir">#DateTimeFormat(rsFacin.INP_RevisorDTInic,"dd-mm-yyyy HH:NN:SS")#</strong></td>
        <td colspan="1"><strong class="exibir"><strong class="exibir">#dthhprevrevisor#</strong></td>
        <td colspan="1"><strong class="exibir">#DateTimeFormat(rsUltReanaliseRevisor.RIP_DtUltAtu_Revisor,"dd-mm-yyyy HH:NN:SS")#</strong></td>
        <td colspan="1"><strong class="exibir">#dateformat(rsFacin.INP_DTConcluirRevisao,"dd-mm-yyyy")#</strong></td>
        <td colspan="1"><strong class="exibir">#DateTimeFormat(rsfac.FAC_DtCriar,"dd-mm-yyyy HH:NN:SS")#</strong></td>
        <td colspan="3"><strong class="exibir">#DateTimeFormat(rsfac.FAC_DtAlter,"dd-mm-yyyy HH:NN:SS")#</strong></td>
    </tr>  
    <tr class="exibir"><td colspan="13"><hr></td></tr> 
    <tr>
        <td width="95" class="exibir">Nome Avaliado</td>
        <td colspan="4"><strong class="exibir">#rsFacin.Fun_Nome#</strong></td>
        <td colspan="1"><strong class="exibir">Qtd. de Item Avaliado:&nbsp;&nbsp;#rsFacinInd.FFI_Meta1_Qtd_Item#</strong></td>
        <td colspan="1"><strong class="exibir">Meta1(resultado):&nbsp;&nbsp;&nbsp#numberFormat(rsFacinInd.FFI_Meta1_Resultado,'___.00')#%</strong></td>
        <td colspan="7"><strong class="exibir">Meta2(resultado):&nbsp;&nbsp;&nbsp#numberFormat(rsFacinInd.FFI_Meta2_Resultado,'___.00')#%</strong></td>
    </tr>
    <tr class="exibir"><td colspan="13"><hr></td></tr> 
</table>

<table width="75%"  align="left" class="table table-bordered">
<tr>
    <td width="139" class="exibir">FACIN</td>
    <td>
        <strong class="exibir">Grupo</strong>&nbsp;&nbsp;
    </td>
    <td colspan="9">
        <strong class="exibir">Item</strong>&nbsp;&nbsp;
    </td>
</tr>

<cfloop query="rsFacin">
    <tr>
        <td width="95" class="exibir"></td>
        <td>
            <strong class="exibir">#rsFacin.RIP_NumGrupo# - #rsFacin.Grp_Descricao#</strong>
        </td>
        <td colspan="9">
            <strong class="exibir">#rsFacin.RIP_NumItem# - #rsFacin.Itn_Descricao#</strong>
        </td>
    </tr> 
    <cfset ptogrpitm = numberFormat((100/rsfac.FAC_Qtd_Geral),'___.00')>
    <cfset ptodescmeta1 = numberFormat((ptogrpitm/10),'___.00')>
    <cfset ptodescontadometa1 = 0>
    <cfset ortogram = 'Não'>
    <cfset cccp = 'Não'>
    <cfset tecn = 'Não'>
    <cfset prob = 'Não'>
    <cfset valor = 'Não'>
    <cfset cosq = 'Não'>
    <cfset norma = 'Não'>
    <cfset docu = 'Não'>
    <cfset class = 'Não'>
    <cfset orient = 'Não'>
    <cfif rsFacin.FACA_Meta1_AT_OrtoGram eq 1><cfset ortogram = 'Sim'><cfset ptodescontadometa1 = ptodescontadometa1 + ptodescmeta1></cfif>
    <cfif rsFacin.FACA_Meta1_AT_CCCP eq 1><cfset cccp = 'Sim'><cfset ptodescontadometa1 = ptodescontadometa1 + ptodescmeta1></cfif>
    <cfif rsFacin.FACA_Meta1_AE_Tecn eq 1><cfset tecn = 'Sim'><cfset ptodescontadometa1 = ptodescontadometa1 + ptodescmeta1></cfif>
    <cfif rsFacin.FACA_Meta1_AE_Prob eq 1><cfset prob = 'Sim'><cfset ptodescontadometa1 = ptodescontadometa1 + ptodescmeta1></cfif>
    <cfif rsFacin.FACA_Meta1_AE_Valor eq 1><cfset valor = 'Sim'><cfset ptodescontadometa1 = ptodescontadometa1 + ptodescmeta1></cfif>
    <cfif rsFacin.FACA_Meta1_AE_Cosq eq 1><cfset cosq = 'Sim'><cfset ptodescontadometa1 = ptodescontadometa1 + ptodescmeta1></cfif>
    <cfif rsFacin.FACA_Meta1_AE_Norma eq 1><cfset norma = 'Sim'><cfset ptodescontadometa1 = ptodescontadometa1 + ptodescmeta1></cfif>
    <cfif rsFacin.FACA_Meta1_AE_Docu eq 1><cfset docu = 'Sim'><cfset ptodescontadometa1 = ptodescontadometa1 + ptodescmeta1></cfif>
    <cfif rsFacin.FACA_Meta1_AE_Class eq 1><cfset class = 'Sim'><cfset ptodescontadometa1 = ptodescontadometa1 + ptodescmeta1></cfif>
    <cfif rsFacin.FACA_Meta1_AE_Orient eq 1><cfset orient = 'Sim'><cfset ptodescontadometa1 = ptodescontadometa1 + ptodescmeta1></cfif>    
    <cfset ptodescontadometa1 = numberFormat((ptodescontadometa1),'___.00')>
    <cfset ptofinalmeta1 = numberFormat((FACA_Meta1_Pontos),'___.00')>
    <tr>
        <td colspan="12" align="center"><strong class="exibir">Meta1 - Redigir Apontamentos</strong>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong class="exibir">Pontuação Inicial: &nbsp;&nbsp;#ptogrpitm# </strong>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong class="exibir">Valor Desconto: &nbsp;&nbsp;#ptodescmeta1# </strong>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong class="exibir">Valor Descontado: &nbsp;&nbsp;#ptodescontadometa1# </strong>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong class="exibir">Pontuação Final: &nbsp;&nbsp;#ptofinalmeta1# </strong>
        </td>
    </tr> 
    <tr>
        <td class="exibir">&nbsp;</td>
        <td colspan="2" align="center"><strong class="exibir">Aspectos Textuais</strong></td>
        <td colspan="8" align="center"><strong class="exibir">Aspectos Estruturais</strong></td>
    </tr>
    <tr colspan="12">
        <td class="exibir">&nbsp;</td>
        <td align="center"><strong class="exibir">Ortografia e Gramática</strong></td>
        <td align="center"><strong class="exibir">Clareza/Concisão e/ou Coerência/Precisão</strong></td>
        <td align="center"><strong class="exibir">Técnica</strong></td>
        <td align="center"><strong class="exibir">Problema</strong></td>
        <td align="center"><strong class="exibir">Valor</strong></td>
        <td align="center"><strong class="exibir">Consequências</strong></td>
        <td align="center"><strong class="exibir">Normativo</strong></td>
        <td align="center"><strong class="exibir">Documentos</strong></td>
        <td align="center"><strong class="exibir">Classificação</strong></td>
        <td align="center"><strong class="exibir">Orientação</strong></td>
    </tr> 

    <tr colspan="12">
        <td class="exibir">&nbsp;</td>
        <td align="center"><strong class="exibir">#ortogram#</strong></td>
        <td align="center"><strong class="exibir">#cccp#</strong></td>
        <td align="center"><strong class="exibir">#tecn#</strong></td>
        <td align="center"><strong class="exibir">#prob#</strong></td>
        <td align="center"><strong class="exibir">#valor#</strong></td>
        <td align="center"><strong class="exibir">#cosq#</strong></td>
        <td align="center"><strong class="exibir">#norma#</strong></td>
        <td align="center"><strong class="exibir">#docu#</strong></td>
        <td align="center"><strong class="exibir">#class#</strong></td>
        <td align="center"><strong class="exibir">#orient#</strong></td>
    </tr>    
    <tr class="exibir"><td>&nbsp;</td></tr>
    <cfset ptodescmeta2 = numberFormat((ptogrpitm/5),'___.00')>
    <cfset ptodescontadometa2 = 0>
    <cfset falta = 'Não'>
    <cfset troca = 'Não'>
    <cfset nomen = 'Não'>
    <cfset ordem = 'Não'>
    <cfset prazo = 'Não'>
    <cfif rsFacin.FACA_Meta2_AR_Falta eq 1><cfset falta = 'Sim'><cfset ptodescontadometa2 = ptodescontadometa2 + ptodescmeta2></cfif>
    <cfif rsFacin.FACA_Meta2_AR_Troca eq 1><cfset troca = 'Sim'><cfset ptodescontadometa2 = ptodescontadometa2 + ptodescmeta2></cfif>
    <cfif rsFacin.FACA_Meta2_AR_Nomen eq 1><cfset nomen = 'Sim'><cfset ptodescontadometa2 = ptodescontadometa2 + ptodescmeta2></cfif>
    <cfif rsFacin.FACA_Meta2_AR_Ordem eq 1><cfset ordem = 'Sim'><cfset ptodescontadometa2 = ptodescontadometa2 + ptodescmeta2></cfif>
    <cfif rsFacin.FACA_Meta2_AR_Prazo eq 1><cfset prazo = 'Sim'><cfset ptodescontadometa2 = ptodescontadometa2 + ptodescmeta2></cfif>   
    <cfset ptodescontadometa2 = numberFormat((ptodescontadometa2),'___.00')> 
    <cfset ptofinalmeta2 = numberFormat((FACA_Meta2_Pontos),'___.00')>
    <tr>
        <td colspan="12" align="center">
            <strong class="exibir">Meta2 - Organizar documento no SEI</strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong class="exibir">Pontuação Inicial: &nbsp;&nbsp;#ptogrpitm# </strong>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong class="exibir">Valor Desconto: &nbsp;&nbsp;#ptodescmeta2# </strong>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong class="exibir">Valor Descontado: &nbsp;&nbsp;#ptodescontadometa2# </strong>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong class="exibir">Pontuação Final: &nbsp;&nbsp;#ptofinalmeta2# </strong>
        </td>
    </tr> 
    <tr>
        <td class="exibir">&nbsp;</td>
        <td colspan="10" align="center"><strong class="exibir">Arquivo</strong></td>
    </tr>
    <tr colspan="12">
        <td class="exibir">&nbsp;</td>
        <td align="center"><strong class="exibir">Falta</strong></td>
        <td align="center"><strong class="exibir">Troca</strong></td>
        <td align="center"><strong class="exibir">Nomenclatura</strong></td>
        <td align="center"><strong class="exibir">Ordem</strong></td>
        <td align="center"><strong class="exibir">Prazo</strong></td>
    </tr> 

    <tr colspan="12">
        <td class="exibir">&nbsp;</td>
        <td align="center"><strong class="exibir">#falta#</strong></td>
        <td align="center"><strong class="exibir">#troca#</strong></td>
        <td align="center"><strong class="exibir">#nomen#</strong></td>
        <td align="center"><strong class="exibir">#ordem#</strong></td>
        <td align="center"><strong class="exibir">#prazo#</strong></td>
    </tr>      
    <tr class="exibir"><td>&nbsp;</td></tr>
    <tr>
        <td width="139" class="exibir"></td>
        <td colspan="5">
            <strong class="exibir">Consideração Revisor</strong>
        </td>
        <td colspan="5">
            <strong class="exibir">Consideração Inspetor</strong>
        </td>
    </tr>
    <tr>
        <td width="95" class="exibir"></td>
        <td colspan="5">
            <textarea name="" cols="90" rows="3" wrap="VIRTUAL" class="form" readonly>#rsFacin.FACA_Consideracao#</textarea>
        </td>
        <td colspan="5">
            <textarea name="" cols="90" rows="3" wrap="VIRTUAL" class="form" readonly>#rsFacin.FACA_Consideracao_Inspetor#</textarea>
        </td>
    </tr> 
    <tr>
        <td colspan="12" align="center"><hr></td>
    </tr>     
</cfloop> 
   
    <tr>
        <td colspan="12" align="center"><strong class="exibir">Meta3 - Liberar 100% das Avaliações de Controle para revisão dentro do prazo estabelecido pela SGCIN/PE. (Liberar para revisão no prazo)</strong></td>
    </tr> 
    <tr colspan="12">
        <td class="exibir">&nbsp;</td>
        <td align="center"><strong class="exibir">Data Transmissão Planejada</strong></td>
        <td align="center"><strong class="exibir">Diferencia(dia)</strong></td>
        <td align="center"><strong class="exibir">Resultado</strong></td>
    </tr> 

    <tr colspan="12">
        <td class="exibir">&nbsp;</td>
        <td align="center"><strong class="exibir">#rsfac.fac_data_plan_meta3#</strong></td>
        <td align="center"><strong class="exibir">#int(rsfac.fac_difdia_meta3)#</strong></td>
        <td align="center"><strong class="exibir">#numberFormat(rsfac.fac_perc_meta3,'___.00')#%</strong></td>
    </tr> 
</table>
</cfoutput>
</body>
<script>
	            
</script>
</html>


