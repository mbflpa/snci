<cfoutput>
    <!--- <cfdump var="#form#"> <cfdump var="#session#"> --->
    <!---  <cfdump var="#url#">  --->
</cfoutput>
<cfoutput>
    <cfquery name="rsRevisor" datasource="#dsn_inspecao#">
        SELECT 
            RIP_Recomendacao_Inspetor,RIP_Critica_Inspetor,RIP_Unidade,RIP_NumInspecao,RIP_NumGrupo,RIP_NumItem,RIP_DtUltAtu,RIP_Data_Avaliador,RIP_Recomendacao_Inspetor, RIP_Data_Avaliador, RIP_DtUltAtu_Revisor, Dir_Codigo, INP_DtInicInspecao, INP_DTConcluirRevisao,INP_RevisorDTInic,INP_Modalidade,INP_Coordenador,INP_Responsavel,Und_Descricao,Usu_Apelido,Usu_LotacaoNome,Usu_DR,Grp_Descricao,Itn_Descricao,Dir_Sigla
            FROM ((((Inspecao INNER JOIN Unidades ON INP_Unidade = Und_Codigo) 
            INNER JOIN Usuarios ON INP_RevisorLogin = Usu_Login) 
            INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade)) 
            INNER JOIN (Itens_Verificacao 
            INNER JOIN Grupos_Verificacao ON (Itn_NumGrupo = Grp_Codigo) AND (Itn_Ano = Grp_Ano)) ON (convert(char(4),RIP_Ano) = Itn_Ano) AND (Und_TipoUnidade = Itn_TipoUnidade) AND (INP_Modalidade = Itn_Modalidade) AND (RIP_NumItem = Itn_NumItem) AND (RIP_NumGrupo = Itn_NumGrupo)) 
            INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
            WHERE RIP_NumInspecao='#URL.ninsp#' 
            order by RIP_NumGrupo, RIP_NumItem
    </cfquery>

    <cfquery name="rsPrimAval" dbtype = "query">
        SELECT RIP_Data_Avaliador 
        FROM rsRevisor
        order by RIP_Data_Avaliador
    </cfquery>

    <cfquery name="rsUlttraninsp" dbtype = "query">
        SELECT RIP_Data_Avaliador 
        FROM rsRevisor
        order by RIP_Data_Avaliador desc
    </cfquery>

    <cfquery name="rsUltReanaliseRevisor" dbtype = "query">
        SELECT RIP_DtUltAtu_Revisor 
        FROM rsRevisor
        order by RIP_DtUltAtu_Revisor desc
    </cfquery>


  
    <cfquery name="qInspetor" datasource="#dsn_inspecao#">
        SELECT FFI_Meta1_Pontuacao_Obtida,FFI_Meta2_Pontuacao_Obtida,FFI_Meta2_Resultado,FFI_Meta1_Resultado,FFI_Qtd_Item,IPT_MatricInspetor, Fun_Nome, Usu_LotacaoNome,Dir_Sigla,INP_HrsPreInspecao, INP_DtInicDeslocamento, INP_DtFimDeslocamento, INP_HrsDeslocamento, INP_DtInicInspecao, INP_DtFimInspecao, INP_HrsInspecao, INP_DtEncerramento, INP_DTConcluirAvaliacao
        FROM Inspetor_Inspecao 
        INNER JOIN UN_Ficha_Facin_Individual ON (IPT_NumInspecao = FFI_Avaliacao) AND (IPT_MatricInspetor = FFI_MatriculaInspetor)
        INNER JOIN Inspecao ON (IPT_NumInspecao=INP_NumInspecao) AND (IPT_CodUnidade=INP_Unidade)
        INNER JOIN Funcionarios ON IPT_MatricInspetor = Fun_Matric AND IPT_MatricInspetor = Fun_Matric 
        INNER JOIN Usuarios ON Fun_Matric = Usu_Matricula
        INNER JOIN Diretoria ON Fun_DR = Dir_Codigo
        WHERE IPT_NumInspecao = '#URL.Ninsp#'
    </cfquery>

<cfquery name="rsfac" datasource="#dsn_inspecao#">
    SELECT FAC_Unidade, FAC_Avaliacao, FAC_MatriculaGestor, FAC_Data_SEI, FAC_Qtd_Avaliacao, FAC_Qtd_Correcaotexto, FAC_Qtd_Reanalise, FAC_Pontos_Revisao_Meta1, FAC_Resultado_Meta1, FAC_Peso_Meta1, FAC_Pontos_Revisao_Meta2, FAC_Resultado_Meta2, FAC_Resultado_Meta2, FAC_Peso_Meta2, FAC_Data_Plan_Meta3, FAC_DifDia_Meta3, FAC_Resultado_Meta3, FAC_DtCriar, FAC_DtAlter, FAC_DtConcluirFacin_Gestor
    FROM UN_Ficha_Facin
    WHERE FAC_Avaliacao='#URL.ninsp#'
</cfquery>

<cfquery datasource="#dsn_inspecao#" name="rsResultGeral">
    SELECT RIP_Resposta, RIP_Recomendacao_Inspetor, RIP_DtUltAtu, RIP_Correcao_Revisor
    FROM Resultado_Inspecao
    WHERE RIP_NumInspecao='#url.ninsp#'
</cfquery>
<!------>
<cfquery name="rsReanalise" dbtype = "query">
    SELECT RIP_DtUltAtu 
    FROM rsResultGeral
    WHERE (RIP_Recomendacao_Inspetor is not null) 
</cfquery>

<cfset percreanalise = numberFormat(0,'___.00')>
<cfset comreanalise = 'Não'>
<cfif rsfac.FAC_Qtd_Reanalise gt 0>
    <cfset comreanalise = 'Sim'>
    <cfset percreanalise = (rsfac.FAC_Qtd_Reanalise / rsfac.FAC_Qtd_Avaliacao) * 100>
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
<!------>
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
    <style>
        .quebra {
            background:#d9d3d3d6;
        }
        .quebra2 {
            background:#fff9f9;
        }
        .quebra3 {
            background:#ebdeded6;
        }    
    </style>
</head>

<body style="background:#fff"> 
<cfoutput>
 <cfinclude template="cabecalho.cfm">
<table width="100%" align="center" class="table table-bordered table-hover">
  <tr>
    <td align="center"><input type="button" class="botao" onClick="window.close()" value="Fechar"></td>
    <td colspan="16"><div align="center"><strong class="titulo2">Relatório análise de Revisão</strong></div></td>
  </tr>
  <cfif rsRevisor.INP_Modalidade is 0>
    <cfset INPModalidade = 'PRESENCIAL'>
<cfelseif rsRevisor.INP_Modalidade is 1>
    <cfset INPModalidade = 'A DISTÂNCIA'>
<cfelse>
    <cfset INPModalidade = 'MISTA'>
</cfif>	

	
	<tr class="quebra">
      <td colspan="1" class="exibir"><strong>Unidade</strong></td>
      <td colspan="3"><strong class="exibir">#rsRevisor.Und_Descricao#</strong></td>
      <td colspan="8"><strong class="exibir">Gerente unidade:&nbsp;#rsRevisor.INP_Responsavel#</strong></td>
    </tr>
    
    <tr class="quebra">
        <td colspan="1" align="center"><strong class="exibir">Nº Avaliação</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Modalidade</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Qtd. Geral</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Com Reanálise</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Perc.(Reanálise)</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Correção texto</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Conforme</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Não Conforme</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Não Executa</strong></td>
        <td colspan="3" align="center"><strong class="exibir">Não Verificado</strong></td>
    </tr> 
    
    <tr>
        <td align="center"><strong class="exibir">#URL.Ninsp#</strong></td>
        <td align="center"><strong class="exibir">#INPModalidade#</strong></td>
        <td align="center"><strong class="exibir">#rsfac.FAC_Qtd_Avaliacao#</strong></td>
        <td align="center"><strong class="exibir">#rsfac.FAC_Qtd_Reanalise#</strong></td>
        <td align="center"><strong class="exibir">#percreanalise#%</strong></td>
        <td align="center"><strong class="exibir">#RSFac.FAC_Qtd_Correcaotexto#</strong></td>
        <td align="center"><strong class="exibir">#totalC#</strong></td>
        <td align="center"><strong class="exibir">#totalN#</strong></td>
        <td align="center"><strong class="exibir">#totalE#</strong></td>
        <td colspan="3" align="center"><strong class="exibir">#totalV#</strong></td>
    </tr>  
    <tr class="quebra">
        <td colspan="9"><strong class="exibir">Inspetores(as)</strong></td>
        <td colspan="3" align="center"><strong class="exibir">Qtd. de Item Avaliado</strong></td>
    </tr>
    <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>   
    <cfset col = 'Inspetores'>
    <cfloop query="qInspetor">
        <tr class="exibir">
            <td colspan="9">
                <cfif trim(rsRevisor.INP_Coordenador) eq trim(qInspetor.IPT_MatricInspetor)>
                    <strong class="exibir">#qInspetor.Fun_Nome#</strong><strong>#qInspetor.Usu_LotacaoNome# - (SE-#trim(qInspetor.Dir_Sigla)#) - Coordenador(a)</strong>
                <cfelse>
                    <strong class="exibir">#qInspetor.Fun_Nome# - #qInspetor.Usu_LotacaoNome# - (SE-#trim(qInspetor.Dir_Sigla)#)</strong>
                </cfif>
            </td>
            <td colspan="3" align="center"><strong class="exibir">#qInspetor.FFI_Qtd_Item#</strong></td>
        </tr>
        <cfset col = ''>
    </cfloop>
    <tr class="exibir quebra3">
        <td colspan="1" align="center">
            <strong class="exibir">Pré-Inspeção</strong>
        </td>
        <td colspan="1" align="center">
            <strong class="exibir">Início Desloc.</strong>
        </td>
        <td colspan="1" align="center">
            <strong class="exibir">Fim Desloc.</strong>
        </td>
        <td colspan="1" align="center">
            <strong class="exibir">Horas Desloc.</strong>
        </td>
        <td colspan="1" align="center">
            <strong class="exibir">Início Avaliação</strong>
        </td>
        <td colspan="1" align="center">
            <strong class="exibir">Fim Avaliação</strong>
        </td>
        <td colspan="1" align="center">
            <strong class="exibir">Horas Avaliação</strong>
        </td>
        <td colspan="1" align="center">
            <strong class="exibir">Início Avaliação</strong>
        </td>
        <td colspan="1" align="center">
            <strong class="exibir">Última Avaliação</strong>
        </td>
        <td colspan="1" align="center">
            <strong class="exibir">Conclusão Avaliação</strong>
        </td>
        <td colspan="1" align="center">
            <strong class="exibir">Houve Reanálise?</strong>
        </td>
        <td colspan="1"  align="center">
            <strong class="exibir">Última Reanálise</strong>
        </td>
    </tr>
    <tr class="exibir">
        <td colspan="1" align="center">
            <strong>#qInspetor.INP_HrsPreInspecao# horas</strong>
        </td>
        <td colspan="1" align="center">
            <strong>#dateformat(qInspetor.INP_DtInicDeslocamento,"dd-mm-yyyy")#</strong>
        </td>
        <td colspan="1" align="center">
            <strong>#dateformat(qInspetor.INP_DtFimDeslocamento,"dd-mm-yyyy")#</strong>
        </td>
        <td colspan="1" align="center">
            <strong>#qInspetor.INP_HrsDeslocamento#</strong>
        </td>
        <td colspan="1" align="center">
            <strong>#dateformat(qInspetor.INP_DtInicInspecao,"dd-mm-yyyy")#</strong>
        </td>
        <td colspan="1" align="center">
            <strong>#dateformat(qInspetor.INP_DtFimInspecao,"dd-mm-yyyy")#</strong>
        </td>  
        <td colspan="1" align="center">
            <strong>#qInspetor.INP_HrsInspecao#</strong>
        </td>
        <td colspan="1" align="center">
            <strong>#DateTimeFormat(rsPrimAval.RIP_Data_Avaliador,"dd-mm-yyyy HH:NN:SS")#</strong>
        </td>
        <td colspan="1" align="center">
            <strong>#DateTimeFormat(rsUlttraninsp.RIP_Data_Avaliador,"dd-mm-yyyy HH:NN:SS")#</strong>
        </td>  
        <td colspan="1" align="center">
            <strong>#dateformat(qInspetor.INP_DTConcluirAvaliacao,"dd-mm-yyyy")#</strong>
        </td>  
        <td colspan="1" align="center">
            <strong>#comreanalise#</strong>
        </td>  
        <td colspan="1" align="center">
            <strong>#DateTimeFormat(rsUltreanalise.RIP_DtUltAtu,"dd-mm-yyyy HH:NN:SS")#</strong>
        </td>                    
    </tr>
    
    <cfset dt02dduteis = CreateDate(year(rsRevisor.INP_RevisorDTInic),month(rsRevisor.INP_RevisorDTInic),day(rsRevisor.INP_RevisorDTInic))>
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
    <cfset dthhprevrevisor = DateFormat(dt02dduteis,"dd-mm-yyyy") & ' ' & DateTimeFormat(rsRevisor.INP_RevisorDTInic,"HH:NN:SS")>
    <cfif comreanalise eq 'Sim'>
        <!--- <cfset dthhprevrevisor = DateFormat(dt02dduteis,"dd-mm-yyyy") & ' ' & DateTimeFormat(rsUltReanaliseRevisor.RIP_DtUltAtu_Revisor,"HH:NN:SS")> --->
    </cfif>
    <tr class="quebra">
        <td colspan="8" class="exibir" align="left"><strong>Revisor(a)</strong></td>
        <td colspan="1" class="exibir" align="center"><strong><strong class="exibir">Início Revisão</strong></td>
        <td colspan="1" class="exibir" align="center"><strong><strong class="exibir">Previsão Conclusão</td>
        <td colspan="1" class="exibir" align="center"><strong><strong class="exibir">Última Reanálise:&nbsp;</strong></td>
        <td colspan="1" class="exibir" align="center"><strong>Conclusão Revisão</td>
    </tr>  
    <tr>
        <td colspan="8" class="exibir" align="left"><strong>#rsRevisor.Usu_Apelido# - #rsRevisor.Usu_LotacaoNome# - (SE-#trim(rsRevisor.Dir_Sigla)#)</strong></td>
        <td colspan="1" class="exibir" align="center"><strong><strong class="exibir">#DateTimeFormat(rsRevisor.INP_RevisorDTInic,"dd-mm-yyyy HH:NN:SS")#</strong></td>
        <td colspan="1" class="exibir" align="center"><strong><strong class="exibir">#dthhprevrevisor#</strong></td>
        <td colspan="1" class="exibir" align="center"><strong>#DateTimeFormat(rsUltReanaliseRevisor.RIP_DtUltAtu_Revisor,"dd-mm-yyyy HH:NN:SS")#</strong></td>
        <td colspan="1" class="exibir" align="center"><strong>#dateformat(rsRevisor.INP_DTConcluirRevisao,"dd-mm-yyyy")#</strong></td>
    </tr>  
    <tr>
        <td colspan="12" align="center"><input type="button" class="botao" onClick="window.close()" value="Fechar"></td>
    </tr>   

</table>
</cfoutput>
</body>
<script>
	            
</script>
</html>


