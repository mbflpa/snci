<cfoutput>
    <!--- <cfdump var="#form#"> <cfdump var="#session#"> --->
    <!---  <cfdump var="#url#">  --->
</cfoutput>
<!--- inicio atualização --->
<cfprocessingdirective pageEncoding ="utf-8">  
<cfquery datasource="#dsn_inspecao#" name="rsfacinaval">
    SELECT FAC_Qtd_Avaliacao,FAC_Peso_Meta1, FAC_Peso_Meta2,FACA_Unidade, FACA_Avaliacao, FACA_MatriculaGestor, FACA_MatriculaInspetor, FACA_Grupo, FACA_Item, FACA_Meta1_AT_OrtoGram, FACA_Meta1_AT_CCCP, FACA_Meta1_AE_Tecn, FACA_Meta1_AE_Prob, FACA_Meta1_AE_Valor, FACA_Meta1_AE_Cosq, FACA_Meta1_AE_Norma, FACA_Meta1_AE_Docu, FACA_Meta1_AE_Class, FACA_Meta1_AE_Orient, FACA_Meta1_Pontos, FACA_Meta2_AR_Falta, FACA_Meta2_AR_Troca, FACA_Meta2_AR_Nomen, FACA_Meta2_AR_Ordem, FACA_Meta2_AR_Prazo, FACA_Meta2_Pontos
    ,FFI_MatriculaInspetor,FFI_Qtd_Item
    FROM (UN_Ficha_Facin 
    INNER JOIN UN_Ficha_Facin_Avaliador ON (FAC_MatriculaGestor = FACA_MatriculaGestor) AND (FAC_Avaliacao = FACA_Avaliacao) AND (FAC_Unidade = FACA_Unidade)) 
    INNER JOIN UN_Ficha_Facin_Individual ON (FACA_MatriculaInspetor = FFI_MatriculaInspetor) AND (FACA_MatriculaGestor = FFI_MatriculaGestor) AND (FACA_Avaliacao = FFI_Avaliacao)	
    WHERE FACA_Avaliacao='#URL.ninsp#' 
    order by FACA_MatriculaInspetor, FACA_Grupo, FACA_Item
</cfquery>
<cfquery name="rsInsp" dbtype = "query">
    SELECT distinct FACA_MatriculaInspetor 
    FROM rsfacinaval
    order by FACA_MatriculaInspetor
</cfquery>
<cfset facpesometa1aval = numberFormat((100/rsfacinaval.FAC_Qtd_Avaliacao)/10,'___.000')>
<cfset facpesometa2aval = numberFormat((100/rsfacinaval.FAC_Qtd_Avaliacao)/5,'___.000')>
<cfset somageralmeta1 = 0>
<cfset somageralmeta2 = 0>
<cfoutput query="rsInsp">
    <cfset ffimatriculainspetor = rsInsp.FACA_MatriculaInspetor> 
    <cfquery name="rsDados" dbtype = "query">
        SELECT FACA_MatriculaGestor,FFI_Qtd_Item, FACA_Grupo, FACA_Item, FACA_Meta1_AT_OrtoGram, FACA_Meta1_AT_CCCP, FACA_Meta1_AE_Tecn, FACA_Meta1_AE_Prob, FACA_Meta1_AE_Valor, FACA_Meta1_AE_Cosq, FACA_Meta1_AE_Norma, 
        FACA_Meta1_AE_Docu, FACA_Meta1_AE_Class, FACA_Meta1_AE_Orient, FACA_Meta1_Pontos, FACA_Meta2_AR_Falta, FACA_Meta2_AR_Troca, FACA_Meta2_AR_Nomen, FACA_Meta2_AR_Ordem, 
        FACA_Meta2_AR_Prazo, FACA_Meta2_Pontos 
        FROM rsfacinaval
        where FACA_MatriculaInspetor = '#ffimatriculainspetor#'
        order by FACA_Grupo, FACA_Item 
    </cfquery>
    <cfset descontometa1inspetor = 0>
    <cfset descontometa2inspetor = 0>      
    <cfloop query="rsDados">
        <cfset ffimatriculagestor = rsDados.FACA_MatriculaGestor>   
        <cfset ffiqtditeminspetor = rsDados.FFI_Qtd_Item> 
        <cfset facameta1pesoind = numberFormat((100/rsDados.FFI_Qtd_Item)/10,'___.000')>
        <cfset facameta2pesoind = numberFormat((100/rsDados.FFI_Qtd_Item)/5,'___.000')>
        <cfset facameta1pontos = 0>
        <cfset facameta2pontos = 0>
        <cfset somameta1 = 0>
        <cfset somameta2 = 0>
        <cfset somameta1 = rsDados.FACA_Meta1_AT_OrtoGram + rsDados.FACA_Meta1_AT_CCCP + rsDados.FACA_Meta1_AE_Tecn + rsDados.FACA_Meta1_AE_Prob + rsDados.FACA_Meta1_AE_Valor + rsDados.FACA_Meta1_AE_Cosq + rsDados.FACA_Meta1_AE_Norma + rsDados.FACA_Meta1_AE_Docu + rsDados.FACA_Meta1_AE_Class + rsDados.FACA_Meta1_AE_Orient>
        <cfif somameta1 lte 0>
            <cfset facameta1pontos = numberFormat(facameta1pesoind*10,'___.000')>
        <cfelse>
            <cfset facameta1pontos = numberFormat((facameta1pesoind*10) - (somameta1*facameta1pesoind),'___.000')>
        </cfif>
        <cfset somageralmeta1 = somageralmeta1 + somameta1>
        <cfset descontometa1inspetor = descontometa1inspetor + somameta1>
        <cfset somameta2 = rsDados.FACA_Meta2_AR_Falta + rsDados.FACA_Meta2_AR_Troca + rsDados.FACA_Meta2_AR_Nomen + rsDados.FACA_Meta2_AR_Ordem + rsDados.FACA_Meta2_AR_Prazo>
        <cfif somameta2 lte 0>
            <cfset facameta2pontos = numberFormat(facameta2pesoind*5,'___.000')>
        <cfelse>
            <cfset facameta2pontos = numberFormat((facameta2pesoind*5) - (somameta2*facameta2pesoind),'___.000')>
        </cfif>
        <cfset somageralmeta2 = somageralmeta2 + somameta2>
        <cfset descontometa2inspetor = descontometa2inspetor + somameta2>
        <cfquery datasource="#dsn_inspecao#">
            update UN_Ficha_Facin_Avaliador set FACA_Meta1_Pontos=#facameta1pontos#,FACA_Meta2_Pontos=#facameta2pontos#
            WHERE FACA_Avaliacao='#URL.ninsp#' and FACA_Grupo=#rsDados.FACA_Grupo# and FACA_Item=#rsDados.FACA_Item# and FACA_MatriculaInspetor = '#ffimatriculainspetor#'
        </cfquery> 
    </cfloop>
 
    <cfset ffimeta1pontuacaoobtida = numberFormat((ffiqtditeminspetor - (descontometa1inspetor * facameta1pesoind)),'___.00')>
    <cfset ffimeta2pontuacaoobtida = numberFormat((ffiqtditeminspetor - (descontometa2inspetor * facameta2pesoind)),'___.00')>
    <cfset ffimeta1resultado = numberFormat((ffimeta1pontuacaoobtida / ffiqtditeminspetor)*100,'___.00')>
    <cfset ffimeta2resultado = numberFormat((ffimeta2pontuacaoobtida / ffiqtditeminspetor)*100,'___.00')>    
    <cfquery datasource="#dsn_inspecao#">
        UPDATE UN_Ficha_Facin_Individual set 
            FFI_Meta1_Peso = #facameta1pesoind#
        ,FFI_Meta1_Pontuacao_Obtida = #ffimeta1pontuacaoobtida#
        ,FFI_Meta1_Resultado = #ffimeta1resultado#
        ,FFI_Meta2_Peso = #facameta2pesoind#
        ,FFI_Meta2_Pontuacao_Obtida = #ffimeta2pontuacaoobtida#
        ,FFI_Meta2_Resultado = #ffimeta2resultado#
        where 
        FFI_Avaliacao = '#URL.ninsp#' and 
        FFI_MatriculaGestor = '#ffimatriculagestor#' and
        FFI_MatriculaInspetor = '#ffimatriculainspetor#'
    </cfquery>     
</cfoutput>
<cfoutput>
    <cfset facpontosrevisaometa1 = numberFormat(rsfacinaval.FAC_Qtd_Avaliacao - (somageralmeta1*facpesometa1aval),'___.00')>
    <cfset facresultadometa1 = numberFormat((facpontosrevisaometa1/rsfacinaval.FAC_Qtd_Avaliacao)*100,'___.00')>
    <cfset facpontosrevisaometa2 = numberFormat(rsfacinaval.FAC_Qtd_Avaliacao - (somageralmeta2*facpesometa2aval),'___.00')>
    <cfset facresultadometa2 = numberFormat((facpontosrevisaometa2/rsfacinaval.FAC_Qtd_Avaliacao)*100,'___.00')>
    <cfquery datasource="#dsn_inspecao#">
        UPDATE UN_Ficha_Facin SET FAC_Peso_Meta1=#facpesometa1aval#, 
        FAC_Pontos_Revisao_Meta1=#facpontosrevisaometa1#, 
        FAC_Resultado_Meta1 = #facresultadometa1#, 
        FAC_Peso_Meta2 = #facpesometa2aval#,
        FAC_Pontos_Revisao_Meta2=#facpontosrevisaometa2#,
        FAC_Resultado_Meta2 = #facresultadometa2#
        WHERE FAC_Avaliacao= '#url.ninsp#'
    </cfquery>
</cfoutput>
<!--- Final atualização --->

<cfoutput>
    <cfquery name="rsFacin" datasource="#dsn_inspecao#">
        SELECT 
            RIP_Recomendacao_Inspetor,RIP_Critica_Inspetor,FACA_Tipo,RIP_Unidade, RIP_NumInspecao, RIP_NumGrupo, RIP_NumItem, FACA_ConsideracaoGestor, FACA_ConsideracaoInspetor,RIP_DtUltAtu,RIP_Data_Avaliador,RIP_Recomendacao_Inspetor, RIP_Data_Avaliador, RIP_DtUltAtu_Revisor, Dir_Codigo, INP_DtInicInspecao, INP_DTConcluirRevisao,INP_RevisorDTInic, INP_Modalidade, INP_Coordenador, INP_Responsavel, Und_Descricao, Usu_Apelido, Usu_LotacaoNome, Usu_DR,Fun_Nome,FACA_Meta1_AT_OrtoGram, FACA_Meta1_AT_CCCP, FACA_Meta1_AE_Tecn, FACA_Meta1_AE_Prob, FACA_Meta1_AE_Valor, FACA_Meta1_AE_Cosq, FACA_Meta1_AE_Norma, FACA_Meta1_AE_Docu, FACA_Meta1_AE_Class, FACA_Meta1_AE_Orient, FACA_Meta1_Pontos, FACA_Meta2_AR_Falta, FACA_Meta2_AR_Troca, FACA_Meta2_AR_Nomen, FACA_Meta2_AR_Ordem, FACA_Meta2_AR_Prazo, FACA_Meta2_Pontos,Grp_Descricao,Itn_Descricao
            FROM Itens_Verificacao INNER JOIN (((((((Inspecao 
            INNER JOIN Usuarios ON INP_RevisorLogin = Usu_Login) 
            INNER JOIN Unidades ON INP_Unidade = Und_Codigo) 
            INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade)) 
            INNER JOIN UN_Ficha_Facin_Avaliador ON (RIP_NumItem = FACA_Item) AND (RIP_NumGrupo = FACA_Grupo) AND (RIP_NumInspecao = FACA_Avaliacao) AND (RIP_Unidade = FACA_Unidade)) 
            INNER JOIN Diretoria ON Usu_DR = Dir_Codigo) 
            INNER JOIN Funcionarios ON FACA_MatriculaInspetor = Fun_Matric) 
            INNER JOIN Grupos_Verificacao ON FACA_Grupo = Grp_Codigo) ON (FACA_Item = Itn_NumItem) AND (INP_Modalidade = Itn_Modalidade) AND (Und_TipoUnidade = Itn_TipoUnidade) and (convert(char(4),RIP_Ano) = Grp_Ano) AND (Itn_Ano = Grp_Ano) AND (Itn_NumGrupo = Grp_Codigo)
            WHERE RIP_NumInspecao='#URL.ninsp#' and FACA_MatriculaInspetor = '#url.matrinsp#'
            order by RIP_NumGrupo, RIP_NumItem
    </cfquery>

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
    SELECT FFI_Qtd_Item,FFI_Meta1_Pontuacao_Obtida,FFI_Meta1_Resultado,FFI_Meta2_Pontuacao_Obtida,FFI_Meta2_Resultado,FFI_DtConcluirFacin_Inspetor
    FROM UN_Ficha_Facin_Individual
    WHERE FFI_Avaliacao='#URL.ninsp#' AND FFI_MatriculaInspetor='#url.matrinsp#' 
</cfquery>

<cfquery name="rsRevisor" datasource="#dsn_inspecao#">
    SELECT Dir_Sigla 
    FROM Diretoria 
    where '#rsFacin.Usu_DR#' = Dir_Codigo
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
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link href="CSS.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" href="public/bootstrap/bootstrap.min.css">
    <style>
        .quebra {
            background:#beb7b7;
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
    <td colspan="16"><div align="center"><strong class="titulo2">Avaliar Resultados Geral - (FACIN)</strong></div></td>
  </tr>
  <cfif rsFacin.INP_Modalidade is 0>
    <cfset INPModalidade = 'PRESENCIAL'>
<cfelseif rsFacin.INP_Modalidade is 1>
    <cfset INPModalidade = 'A DISTÂNCIA'>
<cfelse>
    <cfset INPModalidade = 'MISTA'>
</cfif>	

	
	<tr class="quebra">
      <td colspan="1" class="exibir"><strong>Unidade</strong></td>
      <td colspan="4"><strong class="exibir">#rsFacin.Und_Descricao#</strong></td>
      <td colspan="12"><strong class="exibir">Gerente unidade:&nbsp;#rsFacin.INP_Responsavel#</strong></td>
    </tr>
    
    <tr class="quebra">
        <td colspan="1" align="center"><strong class="exibir">Avaliação</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Modalidade</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Qtd. Geral</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Com Reanálise</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Perc.(Reanálise)</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Correção texto</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Conforme</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Não Conforme</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Não Executa</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Não Verificado</strong></td>
        <td colspan="2" align="center"><strong class="exibir">Pto Obtidos / Resultado Meta1</strong></td>
        <td colspan="2" align="center"><strong class="exibir">Pto Obtidos / Resultado Meta2</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Data Planejada</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Dif.(dias)</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Resultado Meta3</strong></td>
    </tr> 
    
    <tr>
        <td colspan="1" align="center"><strong class="exibir">#URL.Ninsp#</strong></td>
        <td colspan="1" align="center"><strong class="exibir">#INPModalidade#</strong></td>
        <td colspan="1" align="center"><strong class="exibir">#rsfac.FAC_Qtd_Avaliacao#</strong></td>
        <td colspan="1" align="center"><strong class="exibir">#rsfac.FAC_Qtd_Reanalise#</strong></td>
        <td colspan="1" align="center"><strong class="exibir">#percreanalise#%</strong></td>
        <td colspan="1" align="center"><strong class="exibir">#RSFac.FAC_Qtd_Correcaotexto#</strong></td>
        <td colspan="1" align="center"><strong class="exibir">#totalC#</strong></td>
        <td colspan="1" align="center"><strong class="exibir">#totalN#</strong></td>
        <td colspan="1" align="center"><strong class="exibir">#totalE#</strong></td>
        <td colspan="1" align="center"><strong class="exibir">#totalV#</strong></td>
        <td colspan="1" align="center"><strong class="exibir">#numberFormat(rsfac.FAC_Pontos_Revisao_Meta1,'___.00')#</strong></td>
        <td colspan="1" align="center"><strong class="exibir">#numberFormat(rsfac.FAC_Resultado_Meta1,'___.00')#%</strong></td>
        <td colspan="1" align="center"><strong class="exibir">#numberFormat(rsfac.FAC_Pontos_Revisao_Meta2,'___.00')#</strong></td>
        <td colspan="1" align="center"><strong class="exibir">#numberFormat(rsfac.FAC_Resultado_Meta2,'___.00')#%</strong></td>
        <td colspan="1" align="center"><strong class="exibir">#dateformat(rsfac.fac_data_plan_meta3,"DD/MM/YYYY")#</strong></td>
        <td colspan="1" align="center"><strong class="exibir">#int(rsfac.fac_difdia_meta3)#</strong></td>
        <td colspan="1" align="center"><strong class="exibir">#numberFormat(rsfac.FAC_Resultado_Meta3,'___.00')#%</strong></td>
    </tr>  
    <tr class="quebra">
        <td colspan="8"><strong class="exibir">Inspetores(as)</strong></td>
        <td colspan="2" align="center"><strong class="exibir">Qtd. de Item Avaliado</strong></td>
        <td colspan="2" align="center"><strong class="exibir">Meta1(Ptos. Obtidos)</strong></td>
        <td colspan="2" align="center"><strong class="exibir">Meta1(Individual)</strong></td>
        <td colspan="2" align="center"><strong class="exibir">Meta2(Ptos. Obtidos)</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Meta2(Individual)</strong></td>
    </tr>
    <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>   
    <cfset col = 'Inspetores'>
    <cfloop query="qInspetor">
        <tr class="exibir">
            <td colspan="8">
                <cfif trim(rsFacin.INP_Coordenador) eq trim(qInspetor.IPT_MatricInspetor)>
                    <strong class="exibir">#qInspetor.Fun_Nome#</strong><strong>#qInspetor.Usu_LotacaoNome# - (SE-#trim(qInspetor.Dir_Sigla)#) - Coordenador(a)</strong>
                <cfelse>
                    <strong class="exibir">#qInspetor.Fun_Nome# - #qInspetor.Usu_LotacaoNome# - (SE-#trim(qInspetor.Dir_Sigla)#)</strong>
                </cfif>
            </td>
            <td colspan="2" align="center"><strong class="exibir">#qInspetor.FFI_Qtd_Item#</strong></td>
            <td colspan="2" align="center"><strong class="exibir">#numberFormat(qInspetor.FFI_Meta1_Pontuacao_Obtida,'___.00')#</strong></td>
            <td colspan="2" align="center"><strong class="exibir">#numberFormat(qInspetor.FFI_Meta1_Resultado,'___.00')#%</strong></td>
            <td colspan="2" align="center"><strong class="exibir">#numberFormat(qInspetor.FFI_Meta2_Pontuacao_Obtida,'___.00')#</strong></td>
            <td colspan="1" align="center"><strong class="exibir">#numberFormat(qInspetor.FFI_Meta2_Resultado,'___.00')#%</strong></td>
        </tr>
        <cfset col = ''>
    </cfloop>
    <tr class="exibir quebra3">
        <td colspan="2" align="center">
            <strong class="exibir">Pré-Inspeção</strong>
        </td>
        <td colspan="2" align="center">
            <strong class="exibir">Início Desloc.</strong>
        </td>
        <td colspan="1" align="center">
            <strong class="exibir">Fim Desloc.</strong>
        </td>
        <td colspan="1" align="center">
            <strong class="exibir">Horas Desloc.</strong>
        </td>
        <td colspan="1" align="center">
            <strong class="exibir">Início Inspeção</strong>
        </td>
        <td colspan="1" align="center">
            <strong class="exibir">Fim Inspeção</strong>
        </td>
        <td colspan="1" align="center">
            <strong class="exibir">Horas Inspeção</strong>
        </td>
        <td colspan="2" align="center">
            <strong class="exibir">Início Avaliação</strong>
        </td>
        <td colspan="2" align="center">
            <strong class="exibir">Última Avaliação</strong>
        </td>
        <td colspan="1" align="center">
            <strong class="exibir">Conclusão Avaliação</strong>
        </td>
        <td colspan="1" align="center">
            <strong class="exibir">Reanálise?</strong>
        </td>
        <td colspan="2"  align="center">
            <strong class="exibir">Última Reanálise</strong>
        </td>
    </tr>
    <tr class="exibir">
        <td colspan="2" align="center">
            <strong>#qInspetor.INP_HrsPreInspecao# horas</strong>
        </td>
        <td colspan="2" align="center">
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
        <td colspan="2" align="center">
            <strong>#DateTimeFormat(rsPrimAval.RIP_Data_Avaliador,"dd-mm-yyyy HH:NN:SS")#</strong>
        </td>
        <td colspan="2" align="center">
            <strong>#DateTimeFormat(rsUlttraninsp.RIP_Data_Avaliador,"dd-mm-yyyy HH:NN:SS")#</strong>
        </td>  
        <td colspan="1" align="center">
            <strong>#dateformat(qInspetor.INP_DTConcluirAvaliacao,"dd-mm-yyyy")#</strong>
        </td>  
        <td colspan="1" align="center">
            <strong>#comreanalise#</strong>
        </td>  
        <td colspan="2" align="center">
            <strong>#DateTimeFormat(rsUltreanalise.RIP_DtUltAtu,"dd-mm-yyyy HH:NN:SS")#</strong>
        </td>                    
    </tr>
    
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
    <tr class="quebra">
        <td colspan="7" class="exibir" align="left"><strong>Revisor(a)</strong></td>
        <td colspan="2" class="exibir" align="center"><strong><strong class="exibir">Início Revisão</strong></td>
        <td colspan="2" class="exibir" align="center"><strong><strong class="exibir">Previsão Conclusão</td>
        <td colspan="1" class="exibir" align="center"><strong><strong class="exibir">Última Reanálise:&nbsp;</strong></td>
        <td colspan="1" class="exibir" align="center"><strong>Conclusão Revisão</td>
        <td colspan="1" class="exibir" align="center"><strong>Início FACIN</td>
        <td colspan="3" class="exibir" align="center"><strong>Final FACIN</strong></td>
    </tr>  
    <tr>
        <td colspan="7" class="exibir" align="left"><strong>#rsFacin.Usu_Apelido# - #rsFacin.Usu_LotacaoNome# - (SE-#trim(rsRevisor.Dir_Sigla)#)</strong></td>
        <td colspan="2" class="exibir" align="center"><strong><strong class="exibir">#DateTimeFormat(rsFacin.INP_RevisorDTInic,"dd-mm-yyyy HH:NN:SS")#</strong></td>
        <td colspan="2" class="exibir" align="center"><strong><strong class="exibir">#dthhprevrevisor#</strong></td>
        <td colspan="1" class="exibir" align="center"><strong>#DateTimeFormat(rsUltReanaliseRevisor.RIP_DtUltAtu_Revisor,"dd-mm-yyyy HH:NN:SS")#</strong></td>
        <td colspan="1" class="exibir" align="center"><strong>#dateformat(rsFacin.INP_DTConcluirRevisao,"dd-mm-yyyy")#</strong></td>
        <td colspan="1" class="exibir" align="center"><strong>#DateTimeFormat(rsfac.FAC_DtCriar,"dd-mm-yyyy HH:NN:SS")#</strong></td>
        <td colspan="3" class="exibir" align="center"><strong>#DateTimeFormat(rsfac.FAC_DtAlter,"dd-mm-yyyy HH:NN:SS")#</strong></td>
    </tr>  
    <tr class="quebra">
        <td colspan="6" class="exibir"><strong>Inspetor(a)</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Qtd. Avaliado</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Meta1(Pontos Obtidos)</strong></td>
        <td colspan="2" align="center"><strong class="exibir">Meta1(Individual)</strong></td>
        <td colspan="1" align="center"><strong class="exibir">Meta2(Pontos Obtidos)</strong></td>
        <td colspan="2" align="center"><strong class="exibir">Meta2(Individual)</strong></td>
        <td colspan="4" align="center"><strong class="exibir">Conclusão das considerações (FACIN)</strong></td>   
    </tr>
    <tr>
        <td colspan="6"><strong class="exibir">#rsFacin.Fun_Nome#</strong></td>
        <td colspan="1" align="center"><strong class="exibir">#rsFacinInd.FFI_Qtd_Item#</strong></td>
        <td colspan="1" align="center"><strong class="exibir">#numberFormat(rsFacinInd.FFI_Meta1_Pontuacao_Obtida,'___.00')#</strong></td>
        <td colspan="2" align="center"><strong class="exibir">#numberFormat(rsFacinInd.FFI_Meta1_Resultado,'___.00')#%</strong></td>
        <td colspan="1" align="center"><strong class="exibir">#numberFormat(rsFacinInd.FFI_Meta2_Pontuacao_Obtida,'___.00')#</strong></td>
        <td colspan="2" align="center"><strong class="exibir">#numberFormat(rsFacinInd.FFI_Meta2_Resultado,'___.00')#%</strong></td>
        <td colspan="4" align="center"><strong class="exibir">#DateTimeFormat(rsFacinInd.FFI_DtConcluirFacin_Inspetor,"dd-mm-yyyy HH:NN:SS")#</strong></td>   
    </tr>
<!---    
</table>

<table width="75%"  align="left" class="table table-bordered table-hover">
--->

<cfloop query="rsFacin">
    <tr class="quebra">
        <td colspan="6">
            <strong class="exibir">Grupo</strong>&nbsp;&nbsp;
        </td>
        <td colspan="8">
            <strong class="exibir">Item</strong>&nbsp;&nbsp;
        </td>
        <td colspan="4" align="center">
            <strong class="exibir">Tipo FACIN</strong>&nbsp;&nbsp;
        </td>
    </tr>

    <tr>
        <td colspan="6">
            <strong class="exibir">#rsFacin.RIP_NumGrupo# - #rsFacin.Grp_Descricao#</strong>
        </td>
        <td colspan="8">
            <strong class="exibir">#rsFacin.RIP_NumItem# - #rsFacin.Itn_Descricao#</strong>
        </td>
        <td colspan="4" align="center">
            <strong class="exibir">#rsFacin.FACA_Tipo#</strong>
        </td>
    </tr> 
    <cfset ptogrpitm = numberFormat((100/rsfac.FAC_Qtd_Avaliacao),'___.00')>
    <cfset ptodescmeta1 = numberFormat((ptogrpitm/10),'___.00')>
    <cfset ptogrpitmind = numberFormat((100/rsFacinInd.FFI_Qtd_Item),'___.00')>
    <cfset ptodescmeta1ind = numberFormat((ptogrpitmind/10),'___.00')>
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
    <cfif rsFacin.FACA_Meta1_AT_OrtoGram eq 1><cfset ortogram = 'Sim'><cfset ptodescontadometa1 = ptodescontadometa1 + ptodescmeta1ind></cfif>
    <cfif rsFacin.FACA_Meta1_AT_CCCP eq 1><cfset cccp = 'Sim'><cfset ptodescontadometa1 = ptodescontadometa1 + ptodescmeta1ind></cfif>
    <cfif rsFacin.FACA_Meta1_AE_Tecn eq 1><cfset tecn = 'Sim'><cfset ptodescontadometa1 = ptodescontadometa1 + ptodescmeta1ind></cfif>
    <cfif rsFacin.FACA_Meta1_AE_Prob eq 1><cfset prob = 'Sim'><cfset ptodescontadometa1 = ptodescontadometa1 + ptodescmeta1ind></cfif>
    <cfif rsFacin.FACA_Meta1_AE_Valor eq 1><cfset valor = 'Sim'><cfset ptodescontadometa1 = ptodescontadometa1 + ptodescmeta1ind></cfif>
    <cfif rsFacin.FACA_Meta1_AE_Cosq eq 1><cfset cosq = 'Sim'><cfset ptodescontadometa1 = ptodescontadometa1 + ptodescmeta1ind></cfif>
    <cfif rsFacin.FACA_Meta1_AE_Norma eq 1><cfset norma = 'Sim'><cfset ptodescontadometa1 = ptodescontadometa1 + ptodescmeta1ind></cfif>
    <cfif rsFacin.FACA_Meta1_AE_Docu eq 1><cfset docu = 'Sim'><cfset ptodescontadometa1 = ptodescontadometa1 + ptodescmeta1ind></cfif>
    <cfif rsFacin.FACA_Meta1_AE_Class eq 1><cfset class = 'Sim'><cfset ptodescontadometa1 = ptodescontadometa1 + ptodescmeta1ind></cfif>
    <cfif rsFacin.FACA_Meta1_AE_Orient eq 1><cfset orient = 'Sim'><cfset ptodescontadometa1 = ptodescontadometa1 + ptodescmeta1ind></cfif>    
    <cfset ptodescontadometa1 = numberFormat((ptodescontadometa1),'___.00')>
    <cfset ptofinalmeta1 = numberFormat((FACA_Meta1_Pontos),'___.00')>
    <tr class="quebra3">
        <td colspan="17" align="center"><strong class="exibir">Meta1 - Redigir Apontamentos</strong>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong class="exibir">Pontuação Inicial: &nbsp;&nbsp;#ptogrpitmind# </strong>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong class="exibir">Valor Desconto: &nbsp;&nbsp;#ptodescmeta1ind# </strong>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong class="exibir">Valor Descontado: &nbsp;&nbsp;(-#ptodescontadometa1#) </strong>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong class="exibir">Pontuação Final: &nbsp;&nbsp;#ptofinalmeta1# </strong>
        </td>
    </tr> 
    <tr>
        <td colspan="5" align="center"><strong class="exibir">Aspectos Textuais</strong></td>
        <td colspan="13" align="center"><strong class="exibir">Aspectos Estruturais</strong></td>
    </tr>
    <tr class="quebra3">
        <td align="center" colspan="3"><strong class="exibir">Ortografia e Gramática</strong></td>
        <td align="center" colspan="2"><strong class="exibir">Clareza/Concisão e/ou Coerência/Precisão</strong></td>
        <td align="center" colspan="1"><strong class="exibir">Técnica</strong></td>
        <td align="center" colspan="1"><strong class="exibir">Problema</strong></td>
        <td align="center" colspan="1"><strong class="exibir">Valor</strong></td>
        <td align="center" colspan="2"><strong class="exibir">Consequências</strong></td>
        <td align="center" colspan="2"><strong class="exibir">Normativo</strong></td>
        <td align="center" colspan="2"><strong class="exibir">Documentos</strong></td>
        <td align="center" colspan="2"><strong class="exibir">Classificação</strong></td>
        <td align="center" colspan="2"><strong class="exibir">Orientação</strong></td>
    </tr> 

    <tr>
        <td align="center" colspan="3"><strong class="exibir">#ortogram#</strong></td>
        <td align="center" colspan="2"><strong class="exibir">#cccp#</strong></td>
        <td align="center" colspan="1"><strong class="exibir">#tecn#</strong></td>
        <td align="center" colspan="1"><strong class="exibir">#prob#</strong></td>
        <td align="center" colspan="1"><strong class="exibir">#valor#</strong></td>
        <td align="center" colspan="2"><strong class="exibir">#cosq#</strong></td>
        <td align="center" colspan="2"><strong class="exibir">#norma#</strong></td>
        <td align="center" colspan="2"><strong class="exibir">#docu#</strong></td>
        <td align="center" colspan="2"><strong class="exibir">#class#</strong></td>
        <td align="center" colspan="2"><strong class="exibir">#orient#</strong></td>
    </tr>    

    <cfset ptodescmeta2 = numberFormat((ptogrpitmind/5),'___.00')>
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
    <tr class="quebra2"><td colspan="17"></td></tr> 
    <tr class="quebra3">
        <td colspan="17" align="center">
            <strong class="exibir">Meta2 - Organizar documento no SEI</strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong class="exibir">Pontuação Inicial: &nbsp;&nbsp;#ptogrpitmind# </strong>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong class="exibir">Valor Desconto: &nbsp;&nbsp;#ptodescmeta2# </strong>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong class="exibir">Valor Descontado: &nbsp;&nbsp;(-#ptodescontadometa2#) </strong>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong class="exibir">Pontuação Final: &nbsp;&nbsp;#ptofinalmeta2# </strong>
        </td>
    </tr> 
    <tr>
        <td colspan="17" align="center"><strong class="exibir">Arquivo</strong></td>
    </tr>
    <tr class="quebra3">
        <td align="center" colspan="3"><strong class="exibir">Falta</strong></td>
        <td align="center" colspan="3"><strong class="exibir">Troca</strong></td>
        <td align="center" colspan="6"><strong class="exibir">Nomenclatura</strong></td>
        <td align="center" colspan="3"><strong class="exibir">Ordem</strong></td>
        <td align="center" colspan="3"><strong class="exibir">Prazo</strong></td>
    </tr> 

    <tr>
        <td align="center" colspan="3"><strong class="exibir">#falta#</strong></td>
        <td align="center" colspan="3"><strong class="exibir">#troca#</strong></td>
        <td align="center" colspan="6"><strong class="exibir">#nomen#</strong></td>
        <td align="center" colspan="3"><strong class="exibir">#ordem#</strong></td>
        <td align="center" colspan="3"><strong class="exibir">#prazo#</strong></td>
    </tr>   
    <tr class="quebra2"><td colspan="17"></td></tr> 
    <cfif rsFacin.Faca_Tipo eq 'Com Reanálise'>
        <tr class="quebra3">
            <td colspan="9">
                <strong class="exibir">Recomendado pelo(a) Revisor(a)</strong>
            </td>
            <td colspan="9">
                <strong class="exibir">Crítica Inspetor(a)</strong>
            </td>
        </tr>
        <tr>
            <td colspan="9">
                <textarea name="" cols="145" rows="8" wrap="VIRTUAL" class="form" readonly>#rsFacin.RIP_Recomendacao_Inspetor#</textarea>
            </td>
            <td colspan="9">
                <textarea name="" cols="145" rows="8" wrap="VIRTUAL" class="form" readonly>#rsFacin.RIP_Critica_Inspetor#</textarea>
            </td>
        </tr> 
    </cfif>

    <tr class="quebra3">
        <td colspan="9">
            <strong class="exibir">Consideração Revisor(a)</strong>
        </td>
        <td colspan="9">
            <strong class="exibir">Consideração Inspetor(a)</strong>
        </td>
    </tr>
    <tr>
        <td colspan="9">
            <textarea name="" cols="145" rows="5" wrap="VIRTUAL" class="form" readonly>#rsFacin.FACA_ConsideracaoGestor#</textarea>
        </td>
        <td colspan="9">
            <textarea name="" cols="145" rows="5" wrap="VIRTUAL" class="form" readonly>#rsFacin.FACA_ConsideracaoInspetor#</textarea>
        </td>
    </tr> 
</cfloop> 
    <tr>
        <td colspan="17" align="center"><input type="button" class="botao" onClick="window.close()" value="Fechar"></td>
    </tr>   
<!---
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
        <td align="center"><strong class="exibir">#numberFormat(rsfac.FAC_Resultado_Meta3,'___.00')#%</strong></td>
    </tr> 
--->    
</table>
</cfoutput>
</body>
<script>
	            
</script>
</html>


